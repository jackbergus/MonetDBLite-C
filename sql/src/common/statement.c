
#include <string.h>
#include "mem.h"
#include "statement.h"
#include "optimize.h"

const char * st_type2string(st_type type) {
	switch (type) {
	case st_none:	return "st_none";
	case st_schema:	return "st_schema";
	case st_table:	return "st_table";
	case st_column:	return "st_column";
	case st_key:	return "st_key";
	case st_basetable:	return "st_basetable";
	case st_temp:	return "st_temp";
	case st_bat:	return "st_bat";
	case st_ubat:	return "st_ubat";
	case st_ibat:	return "st_ibat";
	case st_obat:	return "st_obat";
	case st_dbat:	return "st_dbat";
	case st_kbat:	return "st_kbat";
	case st_drop_schema:	return "st_drop_schema";
	case st_create_schema:	return "st_create_schema";
	case st_drop_table:	return "st_drop_table";
	case st_create_table:	return "st_create_table";
	case st_create_column:	return "st_create_column";
	case st_null:	return "st_null";
	case st_default:	return "st_default";
	case st_create_key:	return "st_create_key";
	case st_create_role:	return "st_create_role";
	case st_drop_role:	return "st_drop_role";
	case st_grant:	return "st_grant";
	case st_revoke:	return "st_revoke";
	case st_grant_role:	return "st_grant_role";
	case st_revoke_role:	return "st_revoke_role";
	case st_commit:	return "st_commit";
	case st_rollback:	return "st_rollback";
	case st_release:	return "st_release";
	case st_reverse:	return "st_reverse";
	case st_mirror:	return "st_mirror";
	case st_atom:	return "st_atom";
	case st_reljoin:	return "st_reljoin";
	case st_join:	return "st_join";
	case st_semijoin:	return "st_semijoin";
	case st_outerjoin:	return "st_outerjoin";
	case st_diff:	return "st_diff";
	case st_intersect:	return "st_intersect";
	case st_union:	return "st_union";
	case st_filter:	return "st_filter";
	case st_select:	return "st_select";
	case st_select2:	return "st_select2";
	case st_bulkinsert:	return "st_bulkinsert";
	case st_like:	return "st_like";
	case st_append:	return "st_append";
	case st_insert:	return "st_insert";
	case st_replace:	return "st_replace";
	case st_exception:	return "st_exception";
	case st_count:	return "st_count";
	case st_const:	return "st_const";
	case st_mark:	return "st_mark";
	case st_group_ext:	return "st_group_ext";
	case st_group:	return "st_group";
	case st_derive:	return "st_derive";
	case st_unique:	return "st_unique";
	case st_ordered:	return "st_ordered";
	case st_order:	return "st_order";
	case st_reorder:	return "st_reorder";
	case st_op:	return "st_op";
	case st_unop:	return "st_unop";
	case st_binop:	return "st_binop";
	case st_Nop:	return "st_Nop";
	case st_aggr:	return "st_aggr";
	case st_limit:	return "st_limit";
	case st_column_alias:	return "st_column_alias";
	case st_alias:	return "st_alias";
	case st_set:	return "st_set";
	case st_sets:	return "st_sets";
	case st_ptable:	return "st_ptable";
	case st_partial_pivot:	return "st_partial_pivot";
	case st_pivot:	return "st_pivot";
	case st_list:	return "st_list";
	case st_output:	return "st_output";
	}
	return "unknown"; /* just needed for broken compilers ! */
}

/* #TODO make proper traversal operations */
static stmt *stmt_atom_string( char * s )
{
	sql_subtype *t = sql_bind_subtype("CHAR", strlen(s), 0);
	return stmt_atom( atom_string(t, _strdup(s)) );
}

static stmt *stmt_create()
{
	stmt *s = NEW(stmt);
	s->type = st_none;
	s->op1.sval = NULL;
	s->op2.sval = NULL;
	s->op3.sval = NULL;
	s->op4.sval = NULL;
	s->flag = 0;
	s->nrcols = 0;
	s->key = 0;
	s->nr = 0;
	s->h = NULL;
	s->t = NULL;
	s->refcnt = 1;
	s->optimized = 0;
	return s;
}

static stmt *stmt_ext( stmt *grp )
{
	stmt *ns = stmt_create();

	ns->type = st_group_ext;
	ns->op1.stval = grp;
	ns->nrcols = grp->nrcols;
	ns->key = 1;
	ns->h = stmt_dup(grp->h);
	ns->t = stmt_dup(grp->t);
	return ns;
}

static stmt *stmt_group(stmt * s)
{
	stmt *ns = stmt_create();
	ns->type = st_group;
	ns->op1.stval = s;
	ns->nrcols = s->nrcols;
	ns->key = 0;
	ns->h = stmt_dup(s->h);
	ns->t = stmt_dup(s->t);
	return ns;
}

static stmt *stmt_derive(stmt * s, stmt * t)
{
	stmt *ns = stmt_create();
	ns->type = st_derive;
	ns->op1.stval = s;
	ns->op2.stval = t;
	ns->nrcols = s->nrcols;
	ns->key = 0;
	ns->h = stmt_dup(s->h);
	ns->t = stmt_dup(s->t);
	return ns;
}

void grp_destroy( group * g)
{
	assert(g->refcnt > 0);
	if (--g->refcnt == 0) {
		stmt_destroy(g->grp);
		stmt_destroy(g->ext);
		_DELETE(g);
	}
}

group *grp_dup( group * g) 
{
	if (g) g->refcnt++;
	return g;
}

group *grp_create( stmt *s, group *og )
{
	group *g = NEW(group);
	if (og){
		g->grp = stmt_derive(stmt_dup(og->grp), s);
		grp_destroy(og);
	} else {
		g->grp = stmt_group(s);
	}
	g->ext = stmt_ext(stmt_dup(g->grp));
	g->refcnt = 1;
	return g;
}

static stmt *stmt_semijoin_tail( stmt *op1, stmt *op2 )
{
	return stmt_reverse(stmt_semijoin(stmt_reverse(op1), op2));
}

group *grp_semijoin( group *og, stmt *s )
{
	group *g = NEW(group);
	g->grp = stmt_semijoin_tail(stmt_dup(og->grp),s);
	g->ext = stmt_semijoin(stmt_dup(og->ext),stmt_dup(s));
	g->refcnt = 1;
	grp_destroy(og);
	return g;
}

void stmt_destroy(stmt * s)
{
	assert(s->refcnt > 0);
	if (--s->refcnt == 0) {
		switch (s->type) {
			/* stmt_destroy  op1 */
		case st_ibat:
		case st_column: case st_create_column:
		case st_table: case st_create_table: 
		case st_key:

		case st_null:
		case st_reverse:
		case st_mirror:
		case st_count:
		case st_group:
		case st_group_ext:
		case st_order:
		case st_limit:
		case st_output:
			stmt_destroy(s->op1.stval);
			break;
		case st_drop_table:
			stmt_destroy(s->op1.stval);
			_DELETE(s->op2.sval);
			if (s->op3.sval) _DELETE(s->op3.sval);
			break;
		case st_create_key:
			if (s->op2.stval)
				stmt_destroy(s->op2.stval);
			break;
		case st_reljoin:
			list_destroy(s->op1.lval);
			list_destroy(s->op2.lval);
			break;
		case st_default:
		case st_like:
		case st_semijoin:
		case st_diff: case st_intersect: case st_union:
		case st_join: case st_outerjoin:
		case st_const:
		case st_derive:
		case st_ordered: case st_reorder:
		case st_filter: case st_select: case st_select2:
		case st_unique:
		case st_mark:
		case st_alias: case st_column_alias:
		case st_aggr:
		case st_append: case st_insert: case st_replace:
		case st_exception:
		case st_partial_pivot: case st_pivot:
		case st_temp:

			if (s->op1.stval) stmt_destroy(s->op1.stval);
			if (s->op2.stval) stmt_destroy(s->op2.stval);
			if (s->op3.stval) stmt_destroy(s->op3.stval);
			break;
		case st_op: case st_unop: case st_binop: case st_Nop:
			if (s->op1.stval) stmt_destroy(s->op1.stval);
			if (s->op2.stval) stmt_destroy(s->op2.stval);
			if (s->op3.stval) stmt_destroy(s->op3.stval);
			_DELETE (s->op4.sval);
			break;
		case st_set:
		case st_sets:
		case st_list:
			list_destroy(s->op1.lval);
			break;
		case st_ptable:
			list_destroy(s->op1.lval);
			stmt_destroy(s->op2.stval);
			break;
		case st_atom:
			atom_destroy(s->op1.aval);
			break;

		case st_bat: case st_ubat:
		case st_obat: case st_dbat: case st_kbat:

		case st_schema: case st_create_schema: case st_drop_schema:
		case st_basetable: 
		case st_grant: case st_revoke: 

		case st_none:
			break;
		case st_release:
			if (s->op1.sval) _DELETE(s->op1.sval);
			break;
		case st_commit:
		case st_rollback:
			if (s->op2.sval) _DELETE(s->op2.sval);
			break;
		case st_create_role:
		case st_drop_role:
		case st_grant_role:
		case st_revoke_role:
			_DELETE(s->op1.sval);
			if (s->op2.sval) _DELETE(s->op2.sval);
			break;
		case st_var:
			_DELETE(s->op1.sval);
			if (s->op2.stval) stmt_destroy(s->op2.stval);
			break;
		case st_bulkinsert:
			if (s->op1.stval) stmt_destroy(s->op1.stval);
			if (s->op2.stval) stmt_destroy(s->op2.stval);
			if (s->op3.stval) stmt_destroy(s->op3.stval);
			if (s->op4.stval) stmt_destroy(s->op4.stval);
			break;
		}
		if (s->h) 
			stmt_destroy(s->h);
		if (s->t) 
			stmt_destroy(s->t);
		_DELETE(s);
	}
}

stmt *stmt_none(){
	return stmt_create();
}

stmt *stmt_var(char *varname, stmt *val){
	stmt *s = stmt_create();
	s->type = st_var;
	s->op1.sval = varname;
	s->op2.stval = val;
	return s;
}

stmt *stmt_release(char *name)
{
	stmt *s = stmt_create();
	s->type = st_release;
	if (name)
		s->op1.sval = _strdup(name);
	return s;
}

stmt *stmt_commit(int chain, char *name)
{
	stmt *s = stmt_create();
	s->type = st_commit;
	s->op1.ival = chain;
	if (name)
		s->op2.sval = _strdup(name);
	return s;
}

stmt *stmt_rollback(int chain, char *name)
{
	stmt *s = stmt_create();
	s->type = st_rollback;
	s->op1.ival = chain;
	if (name)
		s->op2.sval = _strdup(name);
	return s;
}

stmt *stmt_bind_schema(schema * sc)
{
	stmt *s = stmt_create();
	s->type = st_schema;
	s->op1.schema = sc;
	return s;
}

stmt *stmt_bind_table(stmt *schema, table * t)
{
	stmt *s = stmt_create();
	s->type = st_table;
	s->op1.stval = schema;
	s->op2.tval = t;
	return s;
}

/* split in two parts */
stmt *stmt_bind_column(stmt *table, column * c)
{
	stmt *s = c->s;
	if (s){
	} else {
		s = stmt_create();
		s->type = st_column;
		s->op1.stval = table;
		s->op2.cval = c;
	}
	return s;
}

stmt *stmt_bind_key(stmt *table, key * k)
{
	stmt *s = stmt_create();
	s->type = st_key;
	s->op1.stval = table;
	s->op2.kval = k;
	return s;
}

stmt *stmt_create_schema(schema * schema)
{
	stmt *s = stmt_create();
	s->type = st_create_schema;
	s->op1.schema = schema;
	return s;
}

stmt *stmt_drop_schema(schema * schema, int dropaction)
{
	stmt *s = stmt_create();
	s->type = st_drop_schema;
	s->op1.schema = schema;
	s->flag = dropaction;
	return s;
}

stmt *stmt_create_table(stmt *schema, table * t)
{
	stmt *s = stmt_create();
	s->type = st_create_table;
	s->op1.stval = schema;
	s->op2.tval = t;
	return s;
}

stmt *stmt_drop_table(stmt * schema, char *name, int drop_action)
{
	stmt *s = stmt_create();
	s->type = st_drop_table;
	s->op1.stval = schema;
	s->op2.sval = _strdup(name);
	s->flag = drop_action;
	return s;
}

stmt *stmt_create_column(stmt *table, column * c)
{
	stmt *s = stmt_create();
	s->type = st_create_column;
	s->op1.stval = table;
	s->op2.cval = c;
	return s;
}

stmt *stmt_null(stmt * col, int flag)
{
	stmt *s = stmt_create();
	s->type = st_null;
	s->op1.stval = col;
	s->flag = flag;
	return s;
}

stmt *stmt_default(stmt * col, stmt * def)
{
	stmt *s = stmt_create();
	s->type = st_default;
	s->op1.stval = col;
	s->op2.stval = def;
	return s;
}

stmt *stmt_create_key( key *k, stmt *rk )
{
	stmt *s = stmt_create();
	s->type = st_create_key;
	s->op1.kval = k; 
	if (rk){
		s->op2.stval = rk; 
	}
	return s;
}

stmt *stmt_create_role(char *name, int admin)
{
	stmt *s = stmt_create();
	s->type = st_create_role;
	s->op1.sval = _strdup(name);
	s->flag = admin; 
	return s;
}

stmt *stmt_drop_role(char *name ) 
{
	stmt *s = stmt_create();
	s->type = st_drop_role;
	s->op1.sval = _strdup(name);
	return s;
}

stmt *stmt_grant_role(char *authid, char *role)
{
	stmt *s = stmt_create();
	s->type = st_grant_role;
	s->op1.sval = _strdup(authid);
	s->op2.sval = _strdup(role);
	return s;
}
stmt *stmt_revoke_role(char *authid, char *role)
{
	stmt *s = stmt_create();
	s->type = st_revoke_role;
	s->op1.sval = _strdup(authid);
	s->op2.sval = _strdup(role);
	return s;
}

stmt *stmt_basetable( table *t )
{
	stmt *s = stmt_create();
	s->type = st_basetable;
	s->op1.tval = t;
	return s;
}

stmt *stmt_cbat(column * op1, stmt * basetable, int access, int type)
{
	stmt *s = stmt_create();
	s->type = type;
	s->op1.cval = op1;
	s->nrcols = 1;
	s->flag = access;
	s->h = basetable; /* oid's used from this basetable */
	return s;
}

stmt *stmt_ibat(stmt * op1, stmt * basetable )
{
	stmt *s = stmt_create();
	s->type = st_ibat;
	s->op1.stval = op1;
	s->nrcols = 1;
	s->h = basetable; /* oid's used from this basetable */
	return s;
}

stmt *stmt_tbat(table * t, int access, int type)
{
	stmt *s = stmt_create();
	s->type = type;
	s->nrcols = 0;
	s->flag = access;
	s->op1.tval = t;
	return s;
}

stmt *stmt_kbat(key * k, int access)
{
	stmt *s = stmt_create();
	s->type = st_kbat;
	s->op1.kval = k;
	s->nrcols = 1;
	s->flag = access;
	return s;
}

stmt *stmt_count(stmt * s)
{
	stmt *ns = stmt_create();
	ns->type = st_count;
	ns->op1.stval = s;
	ns->nrcols = 0;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_const(stmt * s, stmt * val)
{
	stmt *ns = stmt_create();
	ns->type = st_const;
	ns->op1.stval = s;
	ns->op2.stval = val;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->h = stmt_dup(s->h);
	return ns;
}

stmt *stmt_mark(stmt * s, int id)
{
	stmt *ns = stmt_create();
	ns->type = st_mark;
	ns->op1.stval = s;
	ns->flag = id;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_remark(stmt * s, stmt * t, int id)
{
	stmt *ns = stmt_create();
	ns->type = st_mark;
	ns->op1.stval = s;
	ns->op2.stval = t;
	ns->flag = id;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_reverse(stmt * s)
{
	stmt *ns = stmt_create();
	ns->type = st_reverse;
	ns->op1.stval = s;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->h = stmt_dup(s->t);
	ns->t = stmt_dup(s->h);
	return ns;
}

stmt *stmt_mirror(stmt * s)
{
	stmt *ns = stmt_create();
	ns->type = st_mirror;
	ns->op1.stval = s;
	ns->nrcols = 2;
	ns->key = s->key;
	ns->h = stmt_dup(s->h);
	ns->t = stmt_dup(s->h);
	return ns;
}


stmt *stmt_unique(stmt * s, group * g)
{
	stmt *ns = stmt_create();
	ns->type = st_unique;
	ns->op1.stval = s;
	if (g) {
		ns->op2.stval = stmt_dup(g->grp);
		grp_destroy(g);
	}
	ns->nrcols = s->nrcols;
	ns->key = 1; /* ?? maybe change key to unique ? */
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_limit(stmt * s, int limit)
{
	stmt *ns = stmt_create();
	ns->type = st_limit;
	ns->op1.stval = s;
	ns->flag = limit;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_order(stmt * s, int direction)
{
	stmt *ns = stmt_create();
	ns->type = st_order;
	ns->op1.stval = s;
	ns->flag = direction;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_reorder(stmt * s, stmt * t, int direction)
{
	stmt *ns = stmt_create();
	ns->type = st_reorder;
	ns->op1.stval = s;
	ns->op2.stval = t;
	ns->flag = direction;
	ns->nrcols = s->nrcols;
	ns->key = s->key;
	ns->t = stmt_dup(s->t);
	return ns;
}

stmt *stmt_temp(sql_subtype * t)
{
	stmt *s = stmt_create();
	s->type = st_temp;
	s->op4.typeval = t;
	s->nrcols = 1;
	return s;
}

stmt *stmt_atom(atom * op1)
{
	stmt *s = stmt_create();
	s->type = st_atom;
	s->op1.aval = op1;
	s->key = 1; /* values are also unique */
	return s;
}

stmt *stmt_filter(stmt * sel )
{
	stmt *s = stmt_create();
	s->type = st_filter;
	s->op1.stval = sel;
	s->nrcols = 1;
	s->h = stmt_dup(s->op1.stval->h);
	return s;
}

stmt *stmt_select(stmt * op1, stmt * op2, comp_type cmptype)
{
	stmt *s = stmt_create();
	s->type = st_select;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->flag = cmptype;
	s->nrcols = 1;
	s->h = stmt_dup(s->op1.stval->h);
	return s;
}

stmt *stmt_select2(stmt * op1, stmt * op2,
			     stmt * op3, int cmp)
{
	stmt *s = stmt_create();
	s->type = st_select2;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->op3.stval = op3;
	s->flag = cmp;
	s->nrcols = 1;
	s->h = stmt_dup(s->op1.stval->h);
	return s;
}

stmt *stmt_like(stmt * op1, stmt * a)
{
	stmt *s = stmt_create();
	s->type = st_like;
	s->op1.stval = op1;
	s->op2.stval = a;
	s->nrcols = 1;
	s->h = stmt_dup(s->op1.stval->h);
	s->t = stmt_dup(s->op1.stval->t);
	return s;
}

stmt *stmt_reljoin2(list * l1, list * l2)
{
	stmt *s = stmt_create();
	s->type = st_reljoin;
	s->op1.lval = l1;
	s->op2.lval = l2;
	s->nrcols = 2;
	s->h = stmt_dup(((stmt*)(s->op1.lval->h->data))->h);
	s->t = stmt_dup(((stmt*)(s->op2.lval->h->data))->h);
	return s;
}

stmt *stmt_reljoin1(list * joins)
{
	list *l1 = list_create((fdestroy)&stmt_destroy);
	list *l2 = list_create((fdestroy)&stmt_destroy);
	node *n = NULL;
	for (n = joins->h; n; n = n->next){
		stmt *l = stmt_dup(((stmt*)(n->data))->op1.stval);
		stmt *r = stmt_dup(((stmt*)(n->data))->op2.stval);
		while(l->type == st_reverse){
			stmt *t = l;
			l = stmt_dup(l->op1.stval);
			stmt_destroy(t);
		}
		while(r->type == st_reverse){
			stmt *t = r;
			r = stmt_dup(r->op1.stval);
			stmt_destroy(t);
		}
		if (l->t != r->t){
			r = stmt_reverse(r);
		}
		l1 = list_append(l1, l);
		l2 = list_append(l2, r);
	}
	return stmt_reljoin2(l1, l2);
}

stmt *stmt_join(stmt * op1, stmt * op2, comp_type cmptype)
{
	stmt *s = stmt_create();
	s->type = st_join;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->flag = cmptype;
	s->nrcols = 2;
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op2->t);
	return s;
}

stmt *stmt_outerjoin(stmt * op1, stmt * op2, comp_type cmptype)
{
	stmt *s = stmt_create();
	s->type = st_outerjoin;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->flag = cmptype;
	s->nrcols = 2;
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op2->t);
	return s;
}

stmt *stmt_semijoin(stmt * op1, stmt * op2)
{
	stmt *s = stmt_create();
	s->type = st_semijoin;
	s->op1.stval = op1;
	s->op2.stval = op2;
	//assert( op1->h == op2->h );
	s->nrcols = op1->nrcols;
	s->key = op1->key;
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op1->t);
	return s;
}

stmt *stmt_diff(stmt * op1, stmt * op2)
{
	stmt *s = stmt_create();
	s->type = st_diff;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->nrcols = op1->nrcols;
	s->key = op1->key;
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op1->t);
	return s;
}

stmt *stmt_intersect(stmt * op1, stmt * op2)
{
	stmt *res = NULL;
	int reverse = 0;
	while(op1->type == st_reverse){
		stmt *r = op1;
		op1 = stmt_dup(op1->op1.stval);
		stmt_destroy(r);
	}
	while(op2->type == st_reverse){
		stmt *r = op2;
		op2 = stmt_dup(op2->op1.stval);
		stmt_destroy(r);
	}
	if (op1->h != op2->h){
		reverse = 1;
	}
	assert ((op1->type == st_join || op1->type == st_reljoin) && (op2->type == st_join || op2->type == st_reljoin));
	if (op1->type == st_join && op1->flag == cmp_all){
		stmt_destroy(op1);
		return op2;
	} else if (op2->type == st_join && op2->flag == cmp_all){
		stmt_destroy(op2);
		return op1;
	}

	/* this case should have been transformed into a proper multi-att join ("st_reljoin") by push_selects_down() */
	assert (!(op1->flag == cmp_equal && op2->flag == cmp_equal));
	
	if (op1->type == st_reljoin || op2->type == st_reljoin) {
printf("= TODO stmt_intersect (1)\n");
		/* 
		 * could/should we do a similar rewrite here as we do below?
		 */
		res = stmt_create();
		res->type = st_intersect;
		res->op1.stval = op1;
		if (reverse){
			res->op2.stval = stmt_reverse(op2);
		} else {
			res->op2.stval = op2;
		}
		res->nrcols = op1->nrcols;
		res->key = op1->key;
		res->h = stmt_dup(op1->h);
		res->t = stmt_dup(op1->t);
	} else {
printf("= TODO stmt_intersect (2)\n");
		/*
	         * need to add the mark trick as [].select(true) on tables 
		 * without unique head identifiers + semijoin is wrong
		 */
		if (!reverse){
			stmt *ml = stmt_mark(stmt_reverse(stmt_dup(op1)), 50);
			stmt *mr = stmt_mark(stmt_dup(op1), 50);
			stmt *l = stmt_join(stmt_dup(ml), 
				stmt_dup(op2->op1.stval), cmp_equal ); 
			stmt *r = stmt_join(stmt_dup(mr), 
				stmt_reverse(stmt_dup(op2->op2.stval)), cmp_equal);
			stmt *v = stmt_select( l, r, op2->flag);
			res = stmt_join(stmt_reverse(stmt_semijoin(ml,v)), mr, cmp_equal);
		} else { /* reverse */
			stmt *ml = stmt_mark(stmt_reverse(stmt_dup(op1)), 50);
			stmt *mr = stmt_mark(stmt_dup(op1), 50);
			stmt *l = stmt_join(stmt_dup(mr), 
				stmt_dup(op2->op1.stval), cmp_equal ); 
			stmt *r = stmt_join(stmt_dup(ml), 
				stmt_reverse(stmt_dup(op2->op2.stval)), cmp_equal);
			stmt *v = stmt_select( l, r, op2->flag);
			res = stmt_join(stmt_reverse(stmt_semijoin(ml,v)), mr, cmp_equal);
		}

/*
		if (!reverse){
	 		res = stmt_semijoin( stmt_dup(op1), stmt_select( stmt_join(op1, stmt_reverse(stmt_dup(op2->op2.stval)), cmp_equal ), stmt_dup(op2->op1.stval), op2->flag));
		} else {
	 		res = stmt_semijoin( stmt_dup(op1), stmt_select( stmt_join(op1, stmt_dup(op2->op1.stval), cmp_equal ), stmt_reverse(stmt_dup(op2->op2.stval)), op2->flag));
		}
		stmt_destroy(op2);
*/
		stmt_destroy(op1);
		stmt_destroy(op2);
	}
	return res;
}

stmt *stmt_union(stmt * op1, stmt * op2)
{
	stmt *s = stmt_create();
	s->type = st_union;
	s->op1.stval = op1;
	s->op2.stval = op2;
	s->nrcols = op1->nrcols;
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op1->t);
	return s;
}

stmt *stmt_find(stmt * b, stmt * v)
{
	stmt *s = stmt_create();
	s->type = st_find;
	s->op1.stval = b;
	s->op2.stval = v;
	s->nrcols = 1;
	s->key = 1;
	s->h = stmt_dup(b->h);
	s->t = stmt_dup(b->t);
	return s;
}

stmt *stmt_bulkinsert(stmt *t, char *sep, char *rsep, stmt *file, int nr )
{
	stmt *s = stmt_create();
	s->type = st_bulkinsert;
	s->op1.stval = t;
	s->op2.stval = stmt_atom_string(sep);
	s->op3.stval = stmt_atom_string(rsep);
	s->op4.stval = file;
	s->flag = nr; 
	return s;
}

stmt *stmt_senddata(){
	stmt *s = stmt_create();
	s->type = st_senddata;
	return s;
}

stmt *stmt_list(list * l)
{
	stmt *s = stmt_create();
	s->type = st_list;
	s->op1.lval = l;
	return s;
}

/* consuming stmt's */
stmt *stmt_ordered(stmt * order, stmt * res)
{
	stmt *ns = stmt_create();
	ns->type = st_ordered;
	ns->op1.stval = order;
	ns->op2.stval = res;
	ns->nrcols = res->nrcols;
	ns->key = res->key;
	ns->t = stmt_dup(res->t);
	return ns;
}

stmt *stmt_set(stmt * s1)
{
	stmt *s = stmt_create();
	s->type = st_set;
	s->op1.lval = list_append(list_create((fdestroy)&stmt_destroy),s1);
	return s;
}

stmt *stmt_output(stmt * l)
{
	stmt *s = stmt_create();
	s->type = st_output;
	s->op1.stval = l;
	return s;
}

stmt *stmt_sets(list * l1)
{
	stmt *s = stmt_create();
	s->type = st_sets;
	s->op1.lval = l1;
	return s;
}

/* ptable 
		list of stmts 	(stmt)
		list of pivots
		list of filters ?	
 */

stmt *stmt_ptable()
{
	stmt *s = stmt_create();
	s->type = st_ptable;		
	s->op1.lval = list_create( (fdestroy)&stmt_destroy );
	s->op2.lval = list_create( (fdestroy)&stmt_destroy );
	s->op3.stval = NULL;
	return s;
}

stmt *stmt_ptable_add_ppivot( stmt *ptable, stmt *piv )
{
	list_append(ptable->op1.lval, stmt_dup(piv));
}

stmt *stmt_ptable_add_pivot( stmt *ptable, stmt *piv )
{
	list_append(ptable->op2.lval, stmt_dup(piv));
}

stmt *stmt_partial_pivot(stmt * base, stmt *ptable)
{
	stmt *s = stmt_create();
	s->type = st_partial_pivot;

	s->op1.stval = base;
	s->op2.stval = ptable;
	stmt_ptable_add_ppivot(ptable, s);
	s->nrcols = 2;
	s->h = stmt_dup(ptable); /* the ptable is the new base table */
	s->t = stmt_dup(base); 	 /* pivots have oid's in the tail */
	return s;
}

stmt *stmt_pivot(stmt * base, stmt *ptable)
{
	stmt *s = stmt_create();
	s->type = st_pivot;

	s->op1.stval = base;
	s->op2.stval = ptable;
	stmt_ptable_add_pivot(ptable, s);
	s->nrcols = 2;
	s->h = stmt_dup(ptable); /* the ptable is the new base table */
	s->t = stmt_dup(base); 	 /* pivots have oid's in the tail */
	/* keep seperate partial and full pivots */
	stmt_destroy(stmt_partial_pivot(stmt_dup(base),stmt_dup(ptable))); 
	return s;
}

stmt *stmt_append(stmt * c, stmt * a )
{
	stmt *s = stmt_create();
	s->type = st_append;
	s->op1.stval = c;
	s->op2.stval = a;
	s->h = stmt_dup(c->h);
	s->t = stmt_dup(c->t);
	return s;
}

stmt *stmt_insert(stmt * c, stmt * a )
{
	stmt *s = stmt_create();
	s->type = st_insert;
	s->op1.stval = c;
	s->op2.stval = a;
	s->h = stmt_dup(c->h);
	s->t = stmt_dup(c->t);
	return s;
}

stmt *stmt_replace(stmt * c, stmt * b)
{
	stmt *s = stmt_create();
	s->type = st_replace;
	s->op1.stval = c;
	s->op2.stval = b;
	s->nrcols = 1;
	return s;
}

stmt *stmt_exception(stmt * cond, char *errstr )
{
	stmt *s = stmt_create();
	s->type = st_exception;
	s->op1.stval = cond;
	s->op2.stval = stmt_atom_string(errstr);
	s->nrcols = 0;
	return s;
}

stmt *stmt_op(sql_subfunc * op)
{
	stmt *s = stmt_create();
	s->type = st_op;
	assert(op);
	
	s->op4.funcval = op;
	s->nrcols = 0; /* function without arguments returns single value */
	s->key = 1;
	return s;
}

stmt *stmt_unop(stmt * op1, sql_subfunc * op)
{
	stmt *s = stmt_create();
	s->type = st_unop;
	s->op1.stval = op1;
	assert(op);
	s->op4.funcval = op;
	s->h = stmt_dup(op1->h);
	s->nrcols = op1->nrcols;
	s->key = op1->key;
	return s;
}

stmt *stmt_binop(stmt * op1, stmt * op2, sql_subfunc * op)
{
	stmt *s = stmt_create();
	s->type = st_binop;
	s->op1.stval = op1;
	s->op2.stval = op2;
	assert(op);
	s->op4.funcval = op;
	if (op1->nrcols > op2->nrcols){
		s->h = stmt_dup(op1->h);
		s->nrcols = op1->nrcols;
		s->key = op1->key;
	} else {
		s->h = stmt_dup(op2->h);
		s->nrcols = op2->nrcols;
		s->key = op2->key;
	}
	return s;
}

stmt *stmt_Nop(stmt * ops, sql_subfunc * op)
{
	node *n;
	stmt *o, *s = stmt_create();

	s->type = st_Nop;
	s->op1.stval = ops; 
	assert(op);
	s->op4.funcval = op;
	for(n = ops->op1.lval->h, o = n->data; n; n = n->next){
		stmt *c = n->data;
		if (o->nrcols < c->nrcols)
			o = c;
	}

	s->h = stmt_dup(o->h);
	s->nrcols = o->nrcols;
	s->key = o->key;

	return s;
}

stmt *stmt_aggr(stmt * op1, group * grp, sql_subaggr * op )
{
	stmt *s = stmt_create();
	s->type = st_aggr;
	s->op1.stval = op1;
	if (grp) {
		s->op2.stval = stmt_dup(grp->grp);
		s->op3.stval = stmt_dup(grp->ext);
		s->nrcols = 1;
		s->h = stmt_dup(grp->grp->h);
		s->key = 1;
		grp_destroy(grp);
	} else {
		s->nrcols = 0;	
		s->key = 1;
		s->h = stmt_dup(op1->h);
	}
	s->op4.aggrval = op;
	return s;
}

stmt *stmt_alias(stmt * op1, char *alias)
{
	stmt *s = stmt_create();
	s->type = st_alias;
	s->op1.stval = op1;
	s->op2.stval = stmt_atom_string(alias);
	s->h = stmt_dup(op1->h);
	s->t = stmt_dup(op1->t);
	s->nrcols = op1->nrcols;
	s->key = op1->key;
	return s;
}

stmt *stmt_column(stmt * op1, stmt *t, char *tname, char *cname)
{
	stmt *s = stmt_create();
	s->type = st_column_alias;
	s->op1.stval = op1;
	s->op2.stval = (tname)? stmt_atom_string(tname):NULL;
	s->op3.stval = (cname)? stmt_atom_string(cname):NULL;
	s->h = t;
	s->nrcols = 1; 
	s->key = op1->key;
	return s;
}

stmt *stmt_dup( stmt * s)
{
	if (s) s->refcnt++;
	return s;
}


sql_subtype *tail_type(stmt * st) 
{
	switch (st->type) {
	case st_const:
	case st_join:
	case st_outerjoin:
		return tail_type(st->op2.stval);
	case st_reljoin:
		return tail_type(st->op2.lval->h->data);

	case st_diff:
	case st_filter:
	case st_select:
	case st_select2:
	case st_unique:
	case st_union:
	case st_append:
	case st_replace:
	case st_mark:
	case st_alias:
	case st_column_alias:
	case st_ibat:
	case st_partial_pivot: case st_pivot:
		return tail_type(st->op1.stval);

	case st_list:
		return tail_type(st->op1.lval->h->data);

	case st_bat:
		return st->op1.cval->tpe;
	case st_mirror:
	case st_reverse:
		return head_type(st->op1.stval);

	case st_aggr:
		return &st->op4.aggrval->res;
	case st_op:
	case st_unop:
	case st_binop:
	case st_Nop:
		return &st->op4.funcval->res;
	case st_atom:
		return atom_type(st->op1.aval);
	case st_temp:
		return st->op4.typeval;

	default:
		fprintf(stderr, "missing tail type %d: %s\n", st->type, st_type2string(st->type) );
		return NULL;
	}
}

sql_subtype *head_type(stmt * st)
{
	switch (st->type) {
	case st_aggr:
	case st_unop:
	case st_binop:
	case st_Nop:
	case st_unique:
	case st_union:
	case st_alias:
	case st_column_alias:
	case st_diff:
	case st_join:
	case st_outerjoin:
	case st_semijoin:
	case st_mirror:
	case st_filter:
	case st_select:
	case st_select2:
	case st_ibat:
	case st_append:
	case st_insert:
	case st_replace:
	case st_partial_pivot: case st_pivot:
		return head_type(st->op1.stval);
	case st_reljoin:
		return head_type(st->op1.lval->h->data);

	case st_list:
		return head_type(st->op1.lval->h->data);

	case st_temp:
	case st_mark:
	case st_bat:
		return NULL;	/* oid */

	case st_reverse:
		return tail_type(st->op1.stval);
	case st_atom:
		return atom_type(st->op1.aval);

	default:
		fprintf(stderr, "missing head type %d: %s\n", st->type, st_type2string(st->type) );
		return NULL;
	}
}

stmt *tail_column(stmt * st)
{
	switch (st->type) {
	case st_join:
	case st_outerjoin:
	case st_derive:
	case st_intersect:
		return tail_column(st->op2.stval);
	case st_reljoin:
		return tail_column(st->op2.lval->h->data);

	case st_mark:
	case st_const:
	case st_unop:
	case st_binop:
	case st_Nop:
	case st_diff:
	case st_like:
	case st_filter:
	case st_select:
	case st_select2:
	case st_semijoin:
	case st_atom:
	case st_alias:
	case st_group:
	case st_group_ext:
	case st_union:
	case st_append:
	case st_unique:
	case st_partial_pivot: case st_pivot:
		return tail_column(st->op1.stval);

	case st_column_alias:
	case st_ibat:
	case st_bat:
		return st;

	case st_mirror:
	case st_reverse:
		return head_column(st->op1.stval);
	case st_list:
		return tail_column(st->op1.lval->h->data);

	default:
		fprintf(stderr, "missing tail column %d: %s\n", st->type, st_type2string(st->type) );
		assert(0);
		return NULL;
	}
}

stmt *head_column(stmt * st)
{
	switch (st->type) {
	case st_atom:
	case st_const:
	case st_mark:
	case st_alias:
	case st_union:
	case st_unique:
	case st_aggr:
	case st_unop:
	case st_binop:
	case st_Nop:
	case st_diff:
	case st_join:
	case st_outerjoin:
	case st_intersect:
	case st_semijoin:
	case st_like:
	case st_filter:
	case st_select:
	case st_select2:
	case st_append:
	case st_insert:
	case st_replace:
	case st_partial_pivot: case st_pivot:
	case st_mirror:
		return head_column(st->op1.stval);
	case st_reljoin:
		return head_column(st->op1.lval->h->data);

	case st_column_alias:
	case st_ibat:
	case st_bat:
		return st;

	case st_group:
	case st_group_ext:
	case st_reverse:
		return tail_column(st->op1.stval);

	case st_derive:
		return tail_column(st->op2.stval);
	case st_list:
		return head_column(st->op1.lval->h->data);

	default:
		fprintf(stderr, "missing head column %d: %s\n", st->type, st_type2string(st->type) );
		assert(0);
		return NULL;
	}
}

static char *func_name(char *n1, char *n2)
{
	int l1 = strlen(n1);
	int l2 = strlen(n2);
	char *ns = NEW_ARRAY(char, l1 + l2 + 2), *s = ns;
	strncpy(ns, n1, l1);
	ns += l1;
	*ns++ = '_';
	strncpy(ns, n2, l2);
	ns += l2;
	*ns = '\0';
	return s;
}

char *column_name(stmt * st)
{
	switch (st->type) {
	case st_group:
	case st_group_ext:
	case st_reverse:
	case st_mirror:
		return column_name(head_column(st->op1.stval));
	case st_const:
	case st_join:
	case st_outerjoin:
	case st_derive:
		return column_name(st->op2.stval);
	case st_ibat:
	case st_union:
	case st_append:
	case st_mark:
	case st_filter:
	case st_select:
	case st_select2:
	case st_diff:
	case st_unique:
	case st_partial_pivot: case st_pivot:
		return column_name(st->op1.stval);

	case st_op:
		return _strdup(st->op4.funcval->func->name);
	case st_unop:
	case st_binop:
	case st_Nop:
		return func_name(st->op4.funcval->func->name,
				 column_name(st->op1.stval));
	case st_aggr:
		return func_name(st->op4.aggrval->aggr->name,
				 column_name(st->op1.stval));
	case st_alias:
		return column_name(st->op2.stval);
	case st_column_alias:
		return column_name(st->op3.stval);
	case st_bat:
		return _strdup(st->op1.cval->name);
	case st_atom:
		if (st->op1.aval->type == string_value)
			return atom2string(st->op1.aval);
		return strdup("single_value");

	case st_reljoin:
	default:
		fprintf(stderr, "missing column name %d: %s\n", st->type, st_type2string(st->type) );
		return NULL;
	}
}

char *table_name(stmt * st)
{
	switch (st->type) {
	case st_group:
	case st_group_ext:
	case st_reverse:
	case st_mirror:
		return table_name(head_column(st->op1.stval));
	case st_join:
	case st_outerjoin:
	case st_derive:
		return table_name(st->op2.stval);
	case st_union:
	case st_append:
	case st_mark:
	case st_filter:
	case st_select:
	case st_select2:
	case st_diff:
	case st_aggr:
	case st_unique:
	case st_partial_pivot: case st_pivot:
		return table_name(st->op1.stval);

	case st_bat:
		return st->op1.cval->table->name;
	case st_alias:
		return "unknown";
	case st_column_alias:
		return table_name(st->op2.stval);

	case st_atom:
		if (st->op1.aval->type == string_value)
			return atom2string(st->op1.aval);
		assert(0);

	case st_reljoin:
	default:
		fprintf(stderr, "missing table name %d: %s\n", st->type, st_type2string(st->type) );
		return NULL;
	}
}

column *basecolumn(stmt * st)
{
	switch (st->type) {
	case st_reverse:
	case st_mirror:
		return basecolumn(head_column(st->op1.stval));

	case st_partial_pivot: case st_pivot:
		return basecolumn(st->op1.stval);
	case st_bat:
		return st->op1.cval;

	default:
		return basecolumn(tail_column(st));
	}
}

