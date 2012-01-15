%define api.pure
%locations
%defines
%error-verbose

%parse-param { struct _jc *j }
%lex-param { void *scanner }

%union {
	long long int  j_number;
	double         j_double;
	char          *j_string;
	char          *j_json;
	char          *j_ident;
	void          *j_tree;
}


%start stmt

%token LEX_ERROR

%token EACH FILTER TRANSFORM EXPAND GROUP INTO BY AS JOIN WHERE IN
%token SORT TOP DESC ASC EXPLAIN PLAN PLANF

%token _ARROW _DOLLAR _ASSIGN _EQUALS _NEQUAL _TRUE _FALSE
%token _GREATER _GEQUAL _LESS _LEQUAL _NOT _AND _OR _SCOLON _DOT

%token <j_ident>  _IDENT
%token <j_json>   _ARRAY _OBJECT

%token <j_number> _NUMBER
%token <j_double> _DOUBLE
%token <j_string> _STRING

%type <j_tree> stmt jaql jaqlpipe opt_actions actions action predicates
	predicate variable and_or opt_not comparison value literal
	opt_each json_fragment opt_command sort_arg
%type <j_ident> ident
%type <j_number> opt_asc_desc

/* get it right:
http://www.cs.man.ac.uk/~pjj/cs211/ho/node8.html
http://www.phpcompiler.org/articles/reentrantparser.html
http://www.usualcoding.eu/post/2007/09/03/Building-a-reentrant-parser-in-C-with-Flex/Bison
*/

%{
#include <string.h>

#include "jaql.h"

#define YYLEX_PARAM j->scanner

int yylex(YYSTYPE* lvalp, YYLTYPE* llocp, void *scanner);

void
yyerror(YYLTYPE* locp, struct _jc* j, char const *msg)
{
	if (j->err[0] == '\0')
		snprintf(j->err, sizeof(j->err), "%s at or around %d",
			msg, locp->first_line);
}

%}

%%

stmt: jaql _SCOLON
	{
		j->p = $$ = $1;
		YYACCEPT;
	}
	| EXPLAIN jaql _SCOLON
	{
		j->p = $$ = $2;
		j->explain = 1;
		YYACCEPT;
	}
	| PLAN jaql _SCOLON
	{
		j->p = $$ = $2;
		j->explain = 2;
		YYACCEPT;
	}
	| PLANF jaql _SCOLON
	{
		j->p = $$ = $2;
		j->explain = 3;
		YYACCEPT;
	}
	| LEX_ERROR
	{
		j->p = $$ = NULL;
		YYABORT;
	}
	| _SCOLON
	{
		j->p = $$ = NULL;
		YYACCEPT;
	}
	|
	{
		j->p = $$ = NULL;
		YYACCEPT;
	};

jaql: jaqlpipe                  {$$ = append_jaql_pipe($1, make_json_output(NULL));}
	| _IDENT _ASSIGN jaqlpipe   {$$ = append_jaql_pipe($3, make_json_output($1));}
	;

jaqlpipe: _IDENT opt_actions    {$$ = append_jaql_pipe(make_varname($1), $2);}
		| '[' {j->expect_json = '[';}
		  _ARRAY opt_actions    {$$ = append_jaql_pipe(make_json($3), $4);}
		;

opt_actions: /* empty */        {$$ = NULL;}
		   | actions            {$$ = $1;}
		   ;

actions: _ARROW action          {$$ = $2;}
	   | actions _ARROW action  {$$ = append_jaql_pipe($1, $3);}
	   ;

action: FILTER opt_each predicates        {$$ = make_jaql_filter($2, $3);}
	  | TRANSFORM opt_each json_fragment  {$$ = make_jaql_transform($2, $3);}
	  | EXPAND opt_each opt_command       {$$ = make_jaql_expand($2, $3);}
	  | SORT opt_each BY '[' sort_arg ']' {$$ = make_jaql_sort($2, $5);}
	  ;

opt_command: /* empty */            {$$ = NULL;}
		   | variable               {$$ = $1;}
		   | '(' ident actions ')'  {$$ = append_jaql_pipe(make_varname($2), $3);}
		   ;

opt_each: /* empty */  {$$ = make_varname(GDKstrdup("$"));}
		| EACH _IDENT  {$$ = make_varname($2);}
		;

sort_arg: variable opt_asc_desc
		                   {$$ = make_sort_arg($1, $2 == ASC);}
		| sort_arg ',' variable opt_asc_desc
		                   {$$ = append_sort_arg($1, make_sort_arg($3, $4));}
		;

opt_asc_desc: /* empty */  {$$ = ASC;}
			| ASC          {$$ = ASC;}
			| DESC         {$$ = DESC;}
			;

ident: _IDENT   {$$ = $1;}
	 | _DOLLAR  {$$ = GDKstrdup("$");}
	 ;

predicates: predicate        {$$ = $1;}
		  | opt_not '(' predicates and_or predicate ')' 
                             {$$ = make_cpred(NULL, $1, make_cpred($3, $4, $5));}
		  | predicates and_or predicate
                             {$$ = make_cpred($1, $2, $3);}
		  ;

predicate: opt_not variable
		       {$$ = make_cpred(NULL, $1, make_pred($2, make_comp(j_equals), make_bool(1)));}
		 | opt_not variable comparison value
		       {$$ = make_cpred(NULL, $1, make_pred($2, $3, $4));}
		 ;

variable: ident                 {$$ = make_varname($1);}
		| variable _DOT _IDENT  {$$ = append_varname($1, $3);}
		;

and_or: _AND  {$$ = make_comp(j_and);}
	  | _OR   {$$ = make_comp(j_or);}
	  ;

opt_not: /* empty */ {$$ = NULL;}
	   | _NOT        {$$ = make_comp(j_not);}
	   ;

comparison: _EQUALS   {$$ = make_comp(j_equals);}
		  | _NEQUAL   {$$ = make_comp(j_nequal);}
		  | _GREATER  {$$ = make_comp(j_greater);}
		  | _GEQUAL   {$$ = make_comp(j_gequal);}
		  | _LESS     {$$ = make_comp(j_less);}
		  | _LEQUAL   {$$ = make_comp(j_lequal);}
		  ;

value: variable  {$$ = $1;}
	 | literal   {$$ = $1;}
	 ;

literal: _NUMBER  {$$ = make_number($1);}
	   | _DOUBLE  {$$ = make_double($1);}
	   | _STRING  {$$ = make_string($1);}
	   | _TRUE    {$$ = make_bool(1);}
	   | _FALSE   {$$ = make_bool(0);}
	   ;

json_fragment: '[' {j->expect_json = '[';} _ARRAY   {$$ = make_json($3);}
			 | '{' {j->expect_json = '{';} _OBJECT  {$$ = make_json($3);}
			 ;
