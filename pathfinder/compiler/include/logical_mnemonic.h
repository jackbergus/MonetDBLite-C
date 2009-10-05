/**
 * @file
 *
 * Mnemonic abbreviations for logical algebra constructors.
 *
 * Copyright Notice:
 * -----------------
 *
 * The contents of this file are subject to the Pathfinder Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/PathfinderLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the Pathfinder system.
 *
 * The Original Code has initially been developed by the Database &
 * Information Systems Group at the University of Konstanz, Germany and
 * the Database Group at the Technische Universitaet Muenchen, Germany.
 * It is now maintained by the Database Systems Group at the Eberhard
 * Karls Universitaet Tuebingen, Germany.  Portions created by the
 * University of Konstanz, the Technische Universitaet Muenchen, and the
 * Universitaet Tuebingen are Copyright (C) 2000-2005 University of
 * Konstanz, (C) 2005-2008 Technische Universitaet Muenchen, and (C)
 * 2008-2009 Eberhard Karls Universitaet Tuebingen, respectively.  All
 * Rights Reserved.
 *
 * $Id$
 */

/* Also import generic algebra stuff */
#include "algebra_mnemonic.h"

/** dummy operator */
#define dummy(a) PFla_dummy (a)

/** serialization */
#define serialize_seq(a,b,c,d) PFla_serialize_seq ((a),(b),(c),(d))
#define serialize_rel(a,b,c,d,e) PFla_serialize_rel ((a),(b),(c),(d),(e))

/** literal table construction */
#define lit_tbl(...)      PFla_lit_tbl (__VA_ARGS__)

/** empty table construction */
#define empty_tbl(atts)   PFla_empty_tbl (atts)

/** ColumnAttach operator */
#define attach(a,b,c)   PFla_attach ((a),(b),(c))

/** cartesian product */
#define cross(a,b)        PFla_cross ((a),(b))

/** equi-join */
#define eqjoin(a,b,c,d)   PFla_eqjoin ((a),(b),(c),(d))

/** semi-join */
#define semijoin(a,b,c,d) PFla_semijoin ((a),(b),(c),(d))

/** theta-join */
#define thetajoin(a,b,c,d) PFla_thetajoin ((a),(b),(c),(d))

/** projection operator */
#define project(...)      PFla_project (__VA_ARGS__)

/* selection operator */
#define select_(a,b)      PFla_select ((a),(b))

/* positional selection operator */
#define pos_select(a,b,c,d) PFla_pos_select ((a),(b),(c),(d))

/** disjoint union (where both argument must have the same schema) */
#define disjunion(a,b)    PFla_disjunion ((a),(b))

/** intersection (where both argument must have the same schema) */
#define intersect(a,b)    PFla_intersect ((a),(b))

/** difference (where both argument must have the same schema) */
#define difference(a,b)   PFla_difference ((a),(b))

/* duplicate elimination operator */
#define distinct(a)       PFla_distinct ((a))

/* generic function operator */
#define fun_1to1(a,b,c,d) PFla_fun_1to1 ((a),(b),(c),(d))

/* numeric equal operator */
#define eq(a,b,c,d)       PFla_eq ((a),(b),(c),(d))

/* numeric greater-than operator */
#define gt(a,b,c,d)       PFla_gt ((a),(b),(c),(d))

/* boolean AND operator */
#define and(a,b,c,d)      PFla_and ((a),(b),(c),(d))

/* boolean OR operator */
#define or(a,b,c,d)       PFla_or ((a),(b),(c),(d))

/* boolean NOT operator */
#define not(a,b,c)        PFla_not ((a),(b),(c))

/* op:to operator */
#define to(a,b,c,d)       PFla_to ((a),(b),(c),(d))

/* operator applying a (partitioned) aggregation function */
#define aggr(a,b,c,d)     PFla_aggr ((a),(b),(c),(d))

/** rownumber operator */
#define rownum(a,b,c,d)   PFla_rownum ((a),(b),(c),(d))

/** rowrank operator */
#define rowrank(a,b,c)    PFla_rowrank ((a),(b),(c))

/** rank operator */
#define rank(a,b,c)       PFla_rank ((a),(b),(c))

/** numbering operator */
#define rowid(a,b)        PFla_rowid ((a),(b))

/** type test operator */
#define type(a,b,c,d)     PFla_type ((a),(b),(c),(d))

/** type restriction operators */
#define type_assert_pos(a,b,c)   PFla_type_assert ((a),(b),(c),(true))
#define type_assert_neg(a,b,c)   PFla_type_assert ((a),(b),(c),(false))

/* type cast operator */
#define cast(a,b,c,d)     PFla_cast ((a),(b),(c),(d))

/* path step */
#define step(a,b,c,d,e,f,g) PFla_step ((a),(b),(c),(d),(e),(f),(g))
#define step_join(a,b,c,d,e,f) PFla_step_join ((a),(b),(c),(d),(e),(f))
#define guide_step(a,b,c,d,e,f,g,h,i) \
        PFla_guide_step ((a),(b),(c),(d),(e),(f),(g),(h),(i))
#define guide_step_join(a,b,c,d,e,f,g,h) \
        PFla_guide_step_join ((a),(b),(c),(d),(e),(f),(g),(h))

/* doc index join */
#define doc_index_join(a,b,c,d,e,f) \
        PFla_doc_index_join ((a),(b),(c),(d),(e),(f))

/* document table */
#define doc_tbl(a,b,c,d)    PFla_doc_tbl((a),(b),(c),(d))

/* document content access */
#define doc_access(a,b,c,d,e) PFla_doc_access ((a), (b), (c), (d), (e))

/* twig root operator */
#define twig(a,b,c)       PFla_twig ((a),(b),(c))

/* twig constructor sequence */
#define fcns(a,b)         PFla_fcns ((a),(b))

/* document node-constructing operator */
#define docnode(a,b,c)    PFla_docnode ((a),(b),(c))

/* element-constructing operator */
#define element(a,b,c,d) PFla_element ((a),(b),(c),(d))

/* attribute-constructing operator */
#define attribute(a,b,c,d) PFla_attribute ((a),(b),(c),(d))

/* text node-constructing operator */
#define textnode(a,b,c)   PFla_textnode ((a),(b),(c))

/* comment-constructing operator */
#define comment(a,b,c)    PFla_comment ((a),(b),(c))

/* processing instruction-constructing operator */
#define processi(a,b,c,d) PFla_processi ((a),(b),(c),(d))

/* constructor content operator (elem|doc) */
#define content(a,b,c,d,e) PFla_content ((a),(b),(c),(d),(e))

/* constructor for pf:merge-adjacent-text-nodes() functionality */
#define merge_adjacent(a,b,c,d,e,f,g,h) \
        PFla_pf_merge_adjacent_text_nodes ((a),(b),(c),(d),(e),(f),(g),(h))

/* constructor for fs:item-sequence-to-node-sequence() functionality */
#define pos_merge_str(a)  PFla_pos_merge_str ((a))

/** constructor for algebraic representation of newly ceated xml nodes */
#define roots(a)          PFla_roots ((a))

/** constructor for a new fragment, containing newly ceated xml nodes */
#define fragment(a)       PFla_fragment ((a))

/** constructor for a fragment extract operator */
#define frag_extract(a,b) PFla_frag_extract ((a),(b))

/** constructor for an empty fragment */
#define empty_frag()      PFla_empty_frag ()

/* error operator */
#define error(a,b,c)      PFla_error ((a), (b), (c))

#define nil()             PFla_nil ()

/* duplicates a node with its given children */
#define duplicate(n, l, r)  PFla_op_duplicate ((n), (l), (r))

/* Constructor for cache operator */
#define cache(a,b,c,d,e) PFla_cache ((a),(b),(c),(d),(e))

/* Constructor for debug operator */
#define trace(a,b)        PFla_trace ((a),(b))

/* Constructor for debug items operator */
#define trace_items(a,b,c,d,e) PFla_trace_items ((a),(b),(c),(d),(e))

/* Constructor for debug message operator */
#define trace_msg(a,b,c,d) PFla_trace_msg ((a),(b),(c),(d))

/* Constructor for debug relation map operator */
#define trace_map(a,b,c,d) PFla_trace_map ((a),(b),(c),(d))

#ifdef HAVE_PFTIJAH
/* Constructor for pftijah operations */
#define pft_options(a,b)   PFla_pft_options ((a),(b))
#define pft_query(a,b,c)   PFla_pft_query ((a),(b),(c))
#endif

/* recursion operators */
#define rec_fix(a,b) PFla_rec_fix ((a),(b))
#define rec_param(a,b) PFla_rec_param ((a),(b))
#define rec_arg(a,b,c) PFla_rec_arg ((a),(b),(c))
#define rec_base(a) PFla_rec_base (a)

/* function application */
#define fun_call(a,b,c,d,e,f,g,h) \
        PFla_fun_call ((a),(b),(c),(d),(e),(f),(g),(h))
#define fun_param(a,b,c)  PFla_fun_param ((a),(b),(c))  
#define fun_frag_param(a,b,c) PFla_fun_frag_param ((a),(b),(c))  

/* constructors for built-in functions */
#define fn_string_join(a,b,c,d,e,f,g,h,i) \
        PFla_fn_string_join ((a),(b),(c),(d),(e),(f),(g),(h),(i))

/** a sort specification list is just another attribute list */
#define sortby(...)     PFord_order_intro (__VA_ARGS__)

/* vim:set shiftwidth=4 expandtab: */
