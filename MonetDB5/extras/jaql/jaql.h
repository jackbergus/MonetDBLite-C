/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
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
 * Copyright August 2008-2012 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef JAQL_H
#define JAQL_H 1

#include "mal_client.h"

#ifdef WIN32
#ifndef LIBJAQL
#define jaql_export extern __declspec(dllimport)
#else
#define jaql_export extern __declspec(dllexport)
#endif
#else
#define jaql_export extern
#endif

typedef struct _jvar {
	char *vname;
	int kind;
	int string;
	int integer;
	int doble;
	int array;
	int object;
	int name;
	struct _jvar *next;
} jvar;

typedef struct _jc {
	struct _tree *p;
	int esc_depth;
	char expect_json;
	char *buf;
	char err[1024];
	void *scanner;
	char explain;
	jvar *vars;
} jc;

enum treetype {
	j_output_var,
	j_output,
	j_json,
	j_pipe,
	j_filter,
	j_transform,
	j_expand,
	j_sort,
	j_top,
	j_cmpnd,
	j_comp,
	j_pred,
	j_sort_arg,
	j_var,
	j_num,
	j_dbl,
	j_str,
	j_bool,
	j_error
};

enum comptype {
	j_equals,
	j_nequal,
	j_greater,
	j_gequal,
	j_less,
	j_lequal,
	j_not,
	j_or,
	j_and
};

typedef struct _tree {
	enum treetype type;
	long long int nval;
	double dval;
	char *sval;
	enum comptype cval;
	struct _tree *tval1;
	struct _tree *tval2;
	struct _tree *tval3;
	struct _tree *next;
} tree;

tree *make_json_output(char *ident);
tree *make_json(char *json);
tree *append_jaql_pipe(tree *oaction, tree *naction);
tree *make_jaql_filter(tree *var, tree *pred);
tree *make_jaql_transform(tree *var, tree *tmpl);
tree *make_jaql_expand(tree *var, tree *expr);
tree *make_jaql_sort(tree *var, tree *expr);
tree *make_jaql_top(long long int num);
tree *make_cpred(tree *ppred, tree *comp, tree *pred);
tree *make_pred(tree *var, tree *comp, tree *value);
tree *make_sort_arg(tree *var, char asc);
tree *append_sort_arg(tree *osarg, tree *nsarg);
tree *make_varname(char *ident);
tree *append_varname(tree *var, char *ident);
tree *make_comp(enum comptype t);
tree *make_number(long long int n);
tree *make_double(double d);
tree *make_string(char *s);
tree *make_bool(char b);
void printtree (tree *t, int level, char op);


jaql_export str JAQLexecute(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
jaql_export str JAQLgetVar(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
jaql_export str JAQLsetVar(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);

#endif

