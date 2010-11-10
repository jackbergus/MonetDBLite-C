/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2010 MonetDB B.V.
 * All Rights Reserved.
 */

#include "sql_config.h"
#include "sql_psm.h"
#include "sql_schema.h"
#include "sql_semantic.h"
#include "sql_privileges.h"
#include "sql_env.h"

#include "rel_subquery.h"
#include "rel_select.h"
#include "rel_updates.h"
#include "rel_optimizer.h"
#include "rel_schema.h"
#include "rel_bin.h"

static stmt*
psm_call(mvc * sql, symbol *se)
{

	stmt *res = NULL;
	exp_kind ek = {type_value, card_none, FALSE};
	res = value_exp(sql, se, sql_sel, ek);
	return res;
}

/* SET variable = value */

static stmt *
psm_set(mvc *sql, dnode *n)
{
	exp_kind ek = {type_value, card_value, FALSE};
	char *name = n->data.sval;
	symbol *val = n->next->data.sym;
	stmt *var, *r = NULL;
	int level = 0;
	sql_subtype *tpe = NULL;

	/* name can be 
		'parameter of the function' (ie in the param list)
		or a local or global variable, declared earlier
	*/

	/* check if variable is known from the stack */
	if ((var=stack_find_var(sql, name)) == NULL) {
		sql_arg *a = sql_bind_param(sql, name);

		if (!a) /* not parameter, ie local var ? */
			return sql_error(sql, 01, "Variable %s unknown", name);
		tpe = &a->type;
	} else { 
		tpe = tail_type(var);
	}

	r = value_exp(sql, val, sql_sel, ek);
	if (!r)
		return NULL;

	level = stack_find_frame(sql, name);
	r = check_types(sql, tpe, r, type_cast); 
	if (!r)
		return NULL;
	return stmt_assign(name, r, level);
}

/* TODO add logic to check if variables get initialized */
static stmt *
psm_declare(mvc *sql, dnode *n)
{
	list *l;

	l = create_stmt_list();
	while(n) { /* list of 'identfiers with type' */
		dnode *ids = n->data.sym->data.lval->h->data.lval->h;
		sql_subtype *ctype = &n->data.sym->data.lval->h->next->data.typeval;
		while(ids) {
			char *name = ids->data.sval;
			stmt *r = NULL;

			/* check if we overwrite a scope local variable declare x; declare x; */
			if (frame_find_var(sql, name)) {
				list_destroy(l);
				return sql_error(sql, 01, 
					"Variable '%s' allready declared", name);
			}
			r = stmt_var(_strdup(name), ctype, 1, sql->frame );
			stack_push_var(sql, name, r, ctype);
			list_append(l, r);
			ids = ids->next;
		}
		n = n->next;
	}
	return stmt_list(l);
}

static stmt *
psm_declare_table(mvc *sql, dnode *n)
{
	sql_rel *rel;
	dlist *qname = n->next->data.lval;
	char *name = qname_table(qname);
	char *sname = qname_schema(qname);
	sql_subtype ctype = *sql_bind_localtype("bat");

	if (sname)  /* not allowed here */
		return sql_error(sql, 02, "DECLARE TABLE: qualified name allowed");
	if (frame_find_var(sql, name)) 
		return sql_error(sql, 01, "Variable '%s' allready declared", 
			name);
	
	assert(n->next->next->next->type == type_int);
	
	rel = rel_create_table(sql, cur_schema(sql), SQL_DECLARED_TABLE, NULL, name, n->next->next->data.sym, n->next->next->next->data.i_val);

	if (!rel || rel->op != op_ddl || rel->flag != DDL_CREATE_TABLE)
		return NULL;

	ctype.comp_type = (sql_table*)((atom*)((sql_exp*)rel->exps->t->data)->l)->data.val.pval;
	stack_push_rel_var(sql, name, rel_dup(rel), &ctype);
	return rel_bin(sql, rel);
}

/* [ label: ]
   while (cond) do 
	statement_list
   end [ label ]
   currently we only parse the labels, they cannot be used as there is no

   support for LEAVE and ITERATE (sql multi-level break and continue)
 */
static stmt * 
psm_while_do( mvc *sql, sql_subtype *res, dnode *w, int is_func )
{
	if (!w)
		return NULL;
	if (w->type == type_symbol) { 
		stmt *cond, *whilestmts;
		dnode *n = w;
		exp_kind ek = {type_value, card_value, FALSE};

		cond = logical_value_exp(sql, n->data.sym, sql_sel, ek); 
		n = n->next;
		whilestmts = sequential_block(sql, res, n->data.lval, n->next->data.sval, is_func);

		if (sql->session->status || !cond || !whilestmts) {
			cond_stmt_destroy(cond);
			cond_stmt_destroy(whilestmts);
			return NULL;
		}
		return stmt_while( cond, whilestmts );
	}
	return NULL;
}


/* if (cond) then statement_list
   [ elseif (cond) then statement_list ]*
   [ else statement_list ]
   end if
 */
static stmt * 
psm_if_then_else( mvc *sql, sql_subtype *res, dnode *elseif, int is_func)
{
	if (!elseif)
		return NULL;
	if (elseif->next && elseif->type == type_symbol) { /* if or elseif */
		stmt *cond, *ifstmts, *elsestmts;
		dnode *n = elseif;
		exp_kind ek = {type_value, card_value, FALSE };

		cond = logical_value_exp(sql, n->data.sym, sql_sel, ek); 
		n = n->next;
		ifstmts = sequential_block(sql, res, n->data.lval, NULL, is_func);
		n = n->next;
		elsestmts = psm_if_then_else( sql, res, n, is_func);

		if (sql->session->status || !cond || !ifstmts) {
			cond_stmt_destroy(cond);
			cond_stmt_destroy(ifstmts);
			cond_stmt_destroy(elsestmts);
			return NULL;
		}
		return stmt_if( cond, ifstmts, elsestmts);
	} else { /* else */
		symbol *e = elseif->data.sym;

		if (e==NULL || (e->token != SQL_ELSE))
			return NULL;
		return sequential_block( sql, res, e->data.lval, NULL, is_func);
	}
}

/* 	1
	CASE
	WHEN search_condition THEN statements
	[ WHEN search_condition THEN statements ]
	[ ELSE statements ]
	END CASE

	2
	CASE case_value
	WHEN when_value THEN statements
	[ WHEN when_value THEN statements ]
	[ ELSE statements ]
	END CASE
 */
static stmt * 
psm_case( mvc *sql, sql_subtype *res, dnode *case_when, int is_func )
{
	exp_kind ek = {type_value, card_value, FALSE};

	if (!case_when)
		return NULL;

	/* case 1 */
	if (case_when->type == type_symbol) {
		dnode *n = case_when;
		symbol *case_value = n->data.sym;
		dlist *when_statements = n->next->data.lval;
		dlist *else_statements = n->next->next->data.lval;
		stmt *else_stmt = NULL, *v = value_exp(sql, case_value, sql_sel, ek);
		stmt *cur_if = NULL, *top = NULL;

		if (!v)
			return NULL;
		if (else_statements) {
			else_stmt = sequential_block( sql, res, else_statements, NULL, is_func);
			if (!else_stmt) {
				stmt_destroy(v);
				return NULL;
			}
		}
		n = when_statements->h;
		while(n) {
			dnode *m = n->data.sym->data.lval->h;
			stmt *cond=0, *when_value = value_exp(sql, m->data.sym, sql_sel, ek);
			stmt *if_stmts = NULL;
			stmt *case_stmt = NULL;

			if (!when_value || 
			   (cond = sql_binop_(sql, NULL /* default schema */, "=", stmt_dup(v), when_value)) == NULL || 
			   (if_stmts = sequential_block( sql, res, m->next->data.lval, NULL, is_func)) == NULL ) {
				stmt_destroy(v);
				cond_stmt_destroy(else_stmt);
				cond_stmt_destroy(cond);
				return NULL;
			}
			case_stmt = stmt_if(cond, if_stmts, NULL);
			if (cur_if)
				cur_if->op3.stval = case_stmt;
			cur_if = case_stmt;
			if (!top)
				top = case_stmt;
			n = n->next;
		}
		if (cur_if)
			cur_if->op3.stval = else_stmt;
		return top;
	} else { 
		/* case 2 */
		dnode *n = case_when;
		dlist *whenlist = n->data.lval;
		dlist *else_statements = n->next->data.lval;
		stmt *else_stmt = NULL, *cur_if = NULL, *top = NULL;

		if (else_statements) {
			else_stmt = sequential_block( sql, res, else_statements, NULL, is_func);
			if (!else_stmt) 
				return NULL;
		}
		n = whenlist->h;
		while(n) {
			dnode *m = n->data.sym->data.lval->h;
			stmt *cond = logical_value_exp(sql, m->data.sym, sql_sel, ek);
			stmt *if_stmts = NULL;
			stmt *case_stmt = NULL;

			if (!cond || 
			   (if_stmts = sequential_block( sql, res, m->next->data.lval, NULL, is_func)) == NULL ) {
				cond_stmt_destroy(else_stmt);
				cond_stmt_destroy(cond);
				return NULL;
			}
			case_stmt = stmt_if(cond, if_stmts, NULL);
			if (cur_if)
				cur_if->op3.stval = case_stmt;
			cur_if = case_stmt;
			if (!top)
				top = case_stmt;
			n = n->next;
		}
		if (cur_if)
			cur_if->op3.stval = else_stmt;
		return top;
	}
}

/* return val;
 */
static stmt * 
psm_return( mvc *sql, sql_subtype *restype, symbol *return_sym )
{
	exp_kind ek = {type_value, card_value, FALSE};
	stmt *res;

	if (restype->comp_type)
		ek.card = card_relation;
	res = value_exp(sql, return_sym, sql_sel, ek);
	if (!res || (res = check_types(sql, restype, res, type_equal)) == NULL)
		return NULL;
	return stmt_return(res, stack_nr_of_declared_tables(sql));
}

static int
has_return(stmt *s )
{
	if (s->type == st_return) {
		return 1;
	} else if (s->type == st_if) {
		int res = has_return(s->op2.stval); /* ifstmts */
		if (res && s->op3.stval)
			res = has_return(s->op3.stval); /* elsestmts */
		return res;
	} else if (s->type == st_list) { /* sequential block */
		return has_return(s->op1.lval->t->data);
	}
	return 0;
}

stmt *
sequential_block (mvc *sql, sql_subtype *restype, dlist *blk, char *opt_label, int is_func) 
{
	list *l=0;
	dnode *n;
	int i;

 	if (THRhighwater())
		return sql_error(sql, 10, "SELECT: too many nested operators");

	if (blk->h)
 		l = create_stmt_list();
	stack_push_frame(sql, opt_label);
	for (n = blk->h; n; n = n->next ) {
		stmt *res = NULL;
		symbol *s = n->data.sym;

		switch (s->token) {
		case SQL_SET:
			res = psm_set(sql, s->data.lval->h);
			break;
		case SQL_DECLARE:
			res = psm_declare(sql, s->data.lval->h);
			break;
		case SQL_CREATE_TABLE: 
			res = psm_declare_table(sql, s->data.lval->h);
			break;
		case SQL_WHILE:
			res = psm_while_do(sql, restype, s->data.lval->h, is_func);
			break;
		case SQL_IF:
			res = psm_if_then_else(sql, restype, s->data.lval->h, is_func);
			break;
		case SQL_CASE:
			res = psm_case(sql, restype, s->data.lval->h, is_func);
			break;
		case SQL_CALL:
			res = psm_call(sql, s->data.sym);
			break;
		case SQL_RETURN:
			/*If it is not a function it cannot have a return statement*/
			if (!is_func)
				res = sql_error(sql, 01, 
					"Return statement in the procedure body");
			else {
				/* should be last statement of a sequential_block */
				if (n->next) { 
					res = sql_error(sql, 01, 
						"Statement after return");
				} else {
					res = psm_return(sql, restype, s->data.sym);
				}
			}
			break;
		case SQL_SELECT: { /* row selections (into variables) */
			exp_kind ek = {type_value, card_row, TRUE};
			res = select_into(sql, s, ek);
		}	break;
		case SQL_COPYFROM:
		case SQL_BINCOPYFROM:
		case SQL_INSERT:
		case SQL_UPDATE:
		case SQL_DELETE: {
			sql_rel *r = rel_updates(sql, s);
			if (!r)
				return NULL;
			r = rel_optimizer(sql, r);
			res = rel_bin(sql, r);
		}	break;
		default:
			res = sql_error(sql, 01, 
			 "Statement '%s' is not a valid flow control statement",
			 token2string(s->token));
		}
		if (!res) {
			list_destroy(l);
			l = NULL;
			break;
		}
		list_append(l, res);
	}
	/* drop the declared tables of this frame */
	if (l && l->t && !has_return(l->t->data)) {
		i = sql->topvars;
		while(sql->vars[--i].s) {
			sql_var *v = &sql->vars[i];

			if (v->type.comp_type && !v->view) 
				list_append(l, stmt_assign(v->name, NULL, sql->frame));
		}
	}
	stack_pop_frame(sql);
	if (l)
		return stmt_list(l);
	return NULL;
}

static sql_subtype *
result_type(mvc *sql, char *fname, symbol *res, int instantiate ) 
{
	if (res->token == SQL_TYPE) {
		return &res->data.lval->h->data.typeval;
	} else if (res->token == SQL_TABLE) {
		/* here we create a new table-type */
		sql_subtype *t = NEW(sql_subtype);
		sql_table *tbl;
		char *tnme = NEW_ARRAY(char, strlen(fname) + 2);

		tnme[0] = '#';
		strcpy(tnme+1, fname);
		if (instantiate) {
			tbl = mvc_bind_table(sql, sql->session->schema, tnme);
			if (!tbl)
				return NULL;
		} else {
			dnode *n = res->data.lval->h;

			tbl = mvc_create_generated(sql, sql->session->schema, tnme, NULL, 1 /* system ?*/);
			for(;n; n = n->next->next) {
				sql_subtype *ct = &n->next->data.typeval;
		    		mvc_create_column(sql, tbl, n->data.sval, ct);
			}
		}
		_DELETE(tnme);

		sql_find_subtype(t, "table", 0, 0);
		t->comp_type = tbl;
		t->digits = tbl->base.id; /* pass the table through digits */
		return t;
	}
	return NULL;
}

list *
create_type_list(dlist *params, int param)
{
	sql_subtype *par_subtype;
	list * type_list = list_create((fdestroy) NULL);
	dnode * n = NULL;
	
	if (params) {
		for (n = params->h; n; n = n->next) {
			dnode *an = n;
	
			if (param) {
				an = n->data.lval->h;
				par_subtype = &an->next->data.typeval;
				list_append(type_list, par_subtype);
			} else { 
				par_subtype = &an->data.typeval;
				list_prepend(type_list, par_subtype);
			}
		}
	}
	return type_list;
}

static stmt *
create_func(mvc *sql, dlist *qname, dlist *params, symbol *res, dlist *ext_name, dlist *body, int is_func, int is_aggr)
{
	char *fname = qname_table(qname);
	char *sname = qname_schema(qname);
	sql_schema *s = NULL;
	sql_func *f;
	dnode *n;
	list *l = list_create((fdestroy) &arg_destroy), *type_list = NULL;
	list *id_func_l = NULL, *id_col_l = NULL, *view_id_l = NULL;
	sql_subtype *restype = NULL;
	int instantiate = (sql->emode == m_instantiate);
	int deps = (sql->emode == m_deps);
	int create = (!instantiate && !deps);
	char *F = is_aggr?"AGGREGATE":(is_func?"FUNCTION":"PROCEDURE");

	if (STORE_READONLY(active_store_type) && create) 
		return sql_error(sql, 06, "schema statements cannot be executed on a readonly database.");
			
	if (sname && !(s = mvc_bind_schema(sql, sname)))
		return sql_error(sql, 02, "CREATE %s: no such schema '%s'", F, sname);
	if (s == NULL)
		s = cur_schema(sql);

	if (res)
		restype = result_type(sql, fname, res, instantiate);

	type_list = create_type_list(params, 1);
	
	if (create && sql_bind_func_(s, fname, type_list)) {
		if (params) {
			char *arg_list = NULL;
			node *n;
			
			for (n = type_list->h; n; n = n->next) {
				char *tpe =  subtype2string((sql_subtype *) n->data);
				
				if (arg_list) {
					arg_list = sql_message("%s, %s", arg_list, tpe);
					_DELETE(tpe);	
				} else {
					arg_list = tpe;
				}
			}
			list_destroy(type_list);
				
			(void)sql_error(sql, 02, "CREATE %s: name '%s' (%s) already in use", F, fname, arg_list);
			_DELETE(arg_list);
			return NULL;
		} else {
			return sql_error(sql, 02, "CREATE %s: name '%s' already in use", F, fname);
		}
	} else {
		if (type_list)
			list_destroy(type_list);
	
		if (create && !schema_privs(sql->role_id, s)) {
			return sql_error(sql, 02, "CREATE %s: insufficient privileges "
					"for user '%s' in schema '%s'", F,
					stack_get_string(sql, "current_user"), s->base.name);
		} else {
		 	if (params) 
				for (n = params->h; n; n = n->next) {
					dnode *an = n->data.lval->h;
		
					list_append(l, sql_create_arg(_strdup(an->data.sval), &an->next->data.typeval));
					sql_add_param(sql, an->data.sval, &an->next->data.typeval);
				}
		 	if (body) {		/* sql func */
				char emode = sql->emode;
				char *q = QUERY(sql->scanner);
				stmt *b = NULL;
	
				if (create) /* for subtable we only need direct dependencies */
					sql->emode = m_deps;
				b = sequential_block(sql, restype, body, NULL, is_func);
				sql->emode = emode;
				if (!b) {
					sql_destroy_params(sql);
					list_destroy(l);
					return NULL;
				}
			
				/* check if we have a return statement */
				if (is_func && restype && !has_return(b)) {
					sql_destroy_params(sql);
					list_destroy(l);
					return sql_error(sql, 01,
							"CREATE %s: missing return statement", F);
				}
				if (!is_func && !restype && has_return(b)) {
					sql_destroy_params(sql);
					list_destroy(l);
					return sql_error(sql, 01, "CREATE %s: procedures "
							"cannot have return statements", F);
				}
	
				/* in execute mode we instantiate the function */
				sql_destroy_params(sql);

				if (instantiate) {
					list_destroy(l);
					return b;
				} else if (create) {
					f = mvc_create_func(sql, sql->session->schema, fname,
							l, restype, TRUE, is_aggr, "user", q, is_func);
					if (b) {
						id_col_l = stmt_list_dependencies(b, COLUMN_DEPENDENCY);
						id_func_l = stmt_list_dependencies(b, FUNC_DEPENDENCY);
						view_id_l = stmt_list_dependencies(b, VIEW_DEPENDENCY);
						
						mvc_create_dependencies(sql, id_col_l, f->base.id,
								f->is_func ? FUNC_DEPENDENCY : PROC_DEPENDENCY);
						mvc_create_dependencies(sql, id_func_l, f->base.id,
								f->is_func ? FUNC_DEPENDENCY : PROC_DEPENDENCY);
						mvc_create_dependencies(sql, view_id_l, f->base.id,
								f->is_func ? FUNC_DEPENDENCY : PROC_DEPENDENCY);
	
						list_destroy(id_col_l);
						list_destroy(id_func_l);
						list_destroy(view_id_l);
						stmt_destroy(b);
					}
					list_destroy(l);
				}
			} else {
				char *fmod = qname_module(ext_name);
				char *fnme = qname_fname(ext_name);
				mvc_create_func(sql, sql->session->schema, fname, l, restype,
						FALSE, is_aggr, fmod, fnme, is_func);
				sql_destroy_params(sql);
				list_destroy(l);
			}
		}
	}
	return stmt_none();
}

stmt* 
drop_func(mvc *sql, dlist *qname, dlist *typelist, int drop_action, int is_func)
{
	char *name = qname_table(qname);
	char *sname = qname_schema(qname);
	sql_schema *s = NULL;
	list * list_func = NULL, *type_list = NULL; 
	sql_subfunc *sub_func = NULL;
	sql_func *func = NULL;

	char *F = is_func?"FUNCTION":"PROCEDURE";
	char *f = is_func?"function":"procedure";


	if (sname && !(s = mvc_bind_schema(sql, sname)))
		return sql_error(sql, 02, "DROP %s: no such schema '%s'", F, sname);

	if (s == NULL) 
		s =  cur_schema(sql);
	
	if (typelist) {	
		type_list = create_type_list(typelist, 0);
		sub_func = sql_bind_func_(s,name, type_list);
		if (!sub_func && !sname) {
			s = tmp_schema(sql);
			sub_func = sql_bind_func_(s, name, type_list);
		}
		if ( sub_func && sub_func->func->is_func == is_func)
			func = sub_func->func;
	} else {
		list_func = schema_bind_func(sql,s,name, is_func);
		if (list_func && list_func->cnt > 1)
			return sql_error(sql, 02, "DROP %s: there are more than one %s called '%s', please use the full signature", F, f,name);
		if (list_func && list_func->cnt == 1)
			func = (sql_func*) list_func->h->data;
	}
	
	if (!func) { 
		if (typelist) {
			char *arg_list = NULL;
			node *n;
			
			if (type_list->cnt > 0) {
				for (n = type_list->h; n; n = n->next) {
					char *tpe =  subtype2string((sql_subtype *) n->data);
				
					if (arg_list) {
						arg_list = sql_message("%s, %s", arg_list, tpe);
						_DELETE(tpe);	
					} else {
						arg_list = tpe;
					}
				}
				list_destroy(type_list);
				
				return sql_error(sql, 02, "DROP %s: no such %s '%s' (%s)", F, f, name, arg_list);
			}
			list_destroy(type_list);
			return sql_error(sql, 02, "DROP %s: no such %s '%s' ()", F, f, name);

		} else {
			return sql_error(sql, 02, "DROP %s: no such %s '%s'", F, f, name);
		}
	} else if ((is_func && !func->res.type) || 
		   (!is_func && func->res.type)) {
		return sql_error(sql, 02, "DROP %s: cannot drop %s '%s'", F, is_func?"procedure":"function", name);
	}
	
	list_destroy(type_list);

	if (!schema_privs(sql->role_id, s)) {
		return sql_error(sql, 02, "DROP %s: access denied for %s to schema ;'%s'", F, stack_get_string(sql, "current_user"), s->base.name);
	}
	
	if (!drop_action && mvc_check_dependency(sql, func->base.id, func->is_func ? FUNC_DEPENDENCY : PROC_DEPENDENCY, NULL))
		return sql_error(sql, 02, "DROP %s: there are database objects dependent on %s %s;", F, f, func->base.name);
	
	if (is_func && func->res.comp_type) 
		mvc_drop_table(sql, func->res.comp_type->s, func->res.comp_type, 0);
	mvc_drop_func(sql, s, func, drop_action);

	return stmt_none();
}

stmt* 
drop_all_func(mvc *sql, dlist *qname, int drop_action, int is_func)
{
	char *name = qname_table(qname);
	char *sname = qname_schema(qname);
	sql_schema *s = NULL;
	list * list_func = NULL; 
	sql_func *func = NULL;
	node *n = NULL;

	char *F = is_func?"FUNCTION":"PROCEDURE";
	char *f = is_func?"function":"procedure";

	if (sname && !(s = mvc_bind_schema(sql, sname)))
		return sql_error(sql, 02, "DROP %s: no such schema '%s'", F, sname);

	if (s == NULL) 
		s =  cur_schema(sql);
	
	list_func = schema_bind_func(sql,s,name, is_func);
	
	if (!list_func) { 
			return sql_error(sql, 02, "DROP ALL %s: no such %s '%s'", F, f, name);
	} 
	
	if (!schema_privs(sql->role_id, s)) {
		return sql_error(sql, 02, "DROP %s: access denied for %s to schema ;'%s'", F, stack_get_string(sql, "current_user"), s->base.name);
	}
	
	
	for( n = list_func->h ; n; n = n->next) {
		func = (sql_func *) n->data;

		if (!drop_action && mvc_check_dependency(sql, func->base.id, func->is_func ? FUNC_DEPENDENCY : PROC_DEPENDENCY, list_func))
			return sql_error(sql, 02, "DROP %s: there are database objects dependent on %s %s;", F, f, func->base.name);
	}
		
	mvc_drop_all_func(sql, s, list_func, drop_action);

	list_destroy(list_func);

	return stmt_none();
}

stmt *
psm(mvc *sql, symbol *s)
{
	stmt *ret = NULL;

	switch (s->token) {

	case SQL_CREATE_PROC:
	case SQL_CREATE_FUNC:
	case SQL_CREATE_AGGR:
	{
		dlist *l = s->data.lval;
		int is_func = (s->token == SQL_CREATE_FUNC);
		int is_aggr = (s->token == SQL_CREATE_AGGR);

		ret = create_func(sql, l->h->data.lval, l->h->next->data.lval, l->h->next->next->data.sym, l->h->next->next->next->data.lval, l->h->next->next->next->next->data.lval, is_func, is_aggr);
		sql->type = Q_SCHEMA;
	} 	break;
	case SQL_DROP_FUNC:
	case SQL_DROP_PROC:
	{
		dlist *l = s->data.lval;
		int is_func = (s->token == SQL_DROP_FUNC);

		if (STORE_READONLY(active_store_type)) 
			return sql_error(sql, 06, "schema statements cannot be executed on a readonly database.");
			
		assert(l->h->next->type == type_int);
		assert(l->h->next->next->next->type == type_int);
		if (l->h->next->data.i_val) /*?l_val?*/
			ret = drop_all_func(sql, l->h->data.lval, l->h->next->next->next->data.i_val, is_func);
		else
			ret = drop_func(sql, l->h->data.lval, l->h->next->next->data.lval, l->h->next->next->next->data.i_val, is_func);

		sql->type = Q_SCHEMA;
	}	break;
	case SQL_SET:
		ret = psm_set(sql, s->data.lval->h);
		sql->type = Q_UPDATE;
		break;
	case SQL_DECLARE:
		ret = psm_declare(sql, s->data.lval->h);
		sql->type = Q_UPDATE;
		break;
	case SQL_CALL:
		ret = psm_call(sql, s->data.sym);
		sql->type = Q_UPDATE;
		break;
	default:
		return sql_error(sql, 01, "schema statement unknown symbol(" PTRFMT ")->token = %s", PTRFMTCAST s, token2string(s->token));
	}
	return ret;
}
