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
 * Copyright August 2008- MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef SQL_RELATION_H
#define SQL_RELATION_H

#include <sql_catalog.h>

#define BASETABLE 0
#define RELATION 1

typedef enum expression_type {
	e_atom,
	e_column,
	e_cmp,
	e_func,
	e_aggr,
	e_convert
} expression_type;

#define CARD_ATOM 1
#define CARD_AGGR 2
#define CARD_MULTI 3

typedef struct expression {
	sql_ref ref;

	expression_type  type;	/* atom, cmp, func/aggr */
	char *name;
	char *rname;
	void *l;
	void *r;
	void *f; 	/* func's and aggr's and column type */
			/* e_cmp may have have 2 arguments */
	int  flag;	/* EXP_DISTINCT, NO_NIL, ASCENDING, cmp types */
	char card;	/* card 
				(0 truth value!)
				(1 atoms) 
				(2 aggr)
				(3 multi value)
			*/
	void *p;	/* properties for the optimizer */
} sql_exp;

#define EXP_DISTINCT	1
#define NO_NIL		2
/* ASCENDING > 8 else we have problems with cmp types */
#define ASCENDING	16
#define ANTISEL	32
#define HAS_NO_NIL	64
#define EXP_INTERN	128
 
#define MAXOPS 20

typedef enum operator_type {
	op_basetable = 0,
	op_table,
	op_project,
	op_select,	/* includes order by */
	op_join,
	op_left,
	op_right,
	op_full,
	op_semi,	
	op_anti,
	op_union,
	op_inter,
	op_except,
	op_groupby,	/* currently includes the projection (aggr) */
	op_topn,
	op_insert, 	/* insert(l=table, r insert expressions) */ 
	op_update, 	/* update(l=table, r update expressions) */
	op_delete 	/* delete(l=table, r delete expression) */
} operator_type;

#define is_column(et) \
	(et != e_cmp)
#define is_base(op) \
	(op == op_basetable || op == op_table)
#define is_outerjoin(op) \
	(op == op_left || op == op_right || op == op_full)
#define is_join(op) \
	(op == op_join || is_outerjoin(op))
#define is_semi(op) \
	(op == op_semi || op == op_anti)
#define is_select(op) \
	(op == op_select /*|| op == op_semi || op == op_anti*/)
#define is_set(op) \
	(op == op_union || op == op_inter || op == op_except)
#define is_union(op) \
	(op == op_union)
#define is_inter(rel) \
	(op == op_inter)
#define is_except(rel) \
	(op == op_except)
#define is_project(op) \
	(op == op_project || op == op_groupby || is_set(op))
#define is_groupby(op) \
	(op == op_groupby)
#define is_sort(rel) \
	((rel->op == op_project && rel->r) || rel->op == op_topn)
#define is_topn(op) \
	(op == op_topn)
#define is_modify(op) \
	(op == op_insert || op == op_update || op == op_delete)

/* NO NIL semantics of aggr operations */
#define has_no_nil(e) \
	((e->flag&NO_NIL))
#define set_no_nil(e) \
	e->flag |= NO_NIL

/* does the expression (possibly) have nils */
#define has_nil(e) \
	((e->flag&HAS_NO_NIL) == 0)
#define set_has_no_nil(e) \
	e->flag |= HAS_NO_NIL

#define is_ascending(e) \
	((e->flag&ASCENDING))
#define set_direction(e, dir) \
	e->flag |= (dir?ASCENDING:0)

#define is_anti(e) \
	((e->flag&ANTISEL))
#define set_anti(e) \
	e->flag |= ANTISEL

/* used for expressions and relations */
#define need_distinct(e) \
	((e->flag&EXP_DISTINCT))
#define set_distinct(e) \
	e->flag |= EXP_DISTINCT

/* used for expressions and relations */
#define is_intern(e) \
	((e->flag&EXP_INTERN))
#define set_intern(e) \
	e->flag |= EXP_INTERN

#define is_processed(rel) \
	(rel->processed)
#define set_processed(rel) \
	rel->processed = 1
#define is_subquery(rel) \
	(rel->subquery)
#define set_subquery(rel) \
	rel->subquery = 1

#define rel_is_ref(rel) 	(((sql_rel*)rel)->ref.refcnt > 2)

typedef struct relation {
	sql_ref ref;

	operator_type op;	
	void *l;
	void *r;
	list *exps; 
	int nrcols;	/* nr of cols */	
	char flag;	/* EXP_DISTINCT */ 
	char card;	/* 0, 1 (row), 2 aggr, 3 */
	char processed; /* fully processed or still in the process of building */
	char subquery;	/* is this part a subquery, this is needed for proper name binding */
	void *p;	/* properties for the optimizer */
} sql_rel;

#endif /* SQL_RELATION_H */
