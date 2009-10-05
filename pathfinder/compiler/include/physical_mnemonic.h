/**
 * @file
 *
 * Mnemonic abbreviations for physical algebra constructors.
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

#define serialize(a,b,c)     PFpa_serialize ((a), (b), (c))

/** literal table construction */
#define lit_tbl(a,b,c)       PFpa_lit_tbl ((a), (b), (c))

/** empty table construction */
#define empty_tbl(atts)      PFpa_empty_tbl (atts)

/** ColumnAttach */
#define attach(a,b,c)        PFpa_attach ((a), (b), (c))

/** cartesian product */
#define cross(a,b)           PFpa_cross ((a),(b))

/** dependent cross product */
#define dep_cross(a,b)       PFpa_dep_cross ((a),(b))
/** dependent border indicator */
#define dep_border(a)        PFpa_dep_border ((a))

/** join that preserves the order of the first argument */
#define leftjoin(a,b,c,d)    PFpa_leftjoin ((a), (b), (c), (d))

/** standard join operator */
#define eqjoin(a,b,c,d)      PFpa_eqjoin ((a), (b), (c), (d))

/** semijoin operator */
#define semijoin(a,b,c,d)    PFpa_semijoin ((a), (b), (c), (d))

/** thetajoin operator */
#define thetajoin(a,b,c,d)   PFpa_thetajoin ((a), (b), (c), (d))

/** thetajoin operator */
#define unq2_tjoin(a,b,c,d,e,f,g) PFpa_unq2_thetajoin((a), (b), (c), \
                                                 (d), (e), (f), (g))

/** thetajoin operator */
#define unq1_tjoin(a,b,c,d,e,f,g) PFpa_unq1_thetajoin((a), (b), (c), \
                                                 (d), (e), (f), (g))

/** projection operator */
#define project(a,b,c)       PFpa_project ((a), (b), (c))

#define slice(a,b,c)         PFpa_slice ((a), (b), (c))
#define select_(a,b)         PFpa_select ((a), (b))
#define val_select(a,b,c)    PFpa_value_select ((a), (b), (c))

#define append_union(a,b)    PFpa_append_union ((a), (b))
#define merge_union(a,b,c)   PFpa_merge_union ((a), (b), (c))

#define intersect(a,b)       PFpa_intersect ((a), (b))
#define difference(a,b)      PFpa_difference ((a), (b))
#define sort_distinct(a,b)   PFpa_sort_distinct ((a), (b))
#define std_sort(a,b)        PFpa_std_sort ((a), (b))
#define refine_sort(a,b,c)   PFpa_refine_sort ((a), (b), (c))

#define fun_1to1(a,b,c,d)    PFpa_fun_1to1 ((a), (b), (c), (d))

#define bool_not(a,b,c)      PFpa_bool_not ((a), (b), (c))

#define to(a,b,c,d)          PFpa_to ((a), (b), (c), (d))

#define ecount(a,b,c,d,e)    PFpa_count_ext ((a), (b), (c), (d), (e))
#define aggr(a,b,c,d)        PFpa_aggr ((a), (b), (c), (d))

/** a sort specification list is just another attribute list */
#define sortby(...)          PFord_order_intro (__VA_ARGS__)

/** Numbering operators */
#define mark(a,b)            PFpa_mark ((a), (b))
#define rank(a,b,c)          PFpa_rank ((a), (b), (c))
#define mark_grp(a,b,c)      PFpa_mark_grp ((a), (b), (c))

#define type(a,b,c,d)        PFpa_type ((a), (b), (c), (d))
#define type_assert(a,b,c)   PFpa_type_assert ((a), (b), (c))
#define cast(a,b,c,d)        PFpa_cast ((a), (b), (c), (d))

/** StaircaseJoin */
#define llscjoin(a,b,c,d,e,f) PFpa_llscjoin ((a), (b), (c), (d), (e), (f))
#define llscjoin_dup(a,b,c,d,e) PFpa_llscjoin_dup ((a), (b), (c), (d), (e))

#define doc_tbl(a,b,c,d)     PFpa_doc_tbl ((a), (b), (c), (d))
#define doc_access(a,b,c,d)  PFpa_doc_access ((a), (b), (c), (d))

/* twig root operator */
#define twig(a,b,c)          PFpa_twig ((a),(b),(c))

/* twig constructor sequence */
#define fcns(a,b)            PFpa_fcns ((a),(b))

/* document node-constructing operator */
#define docnode(a,b,c)       PFpa_docnode ((a),(b),(c))

/* element-constructing operator */
#define element(a,b,c,d)     PFpa_element ((a),(b),(c),(d))

/* attribute-constructing operator */
#define attribute(a,b,c,d)   PFpa_attribute ((a),(b),(c),(d))

/* text node-constructing operator */
#define textnode(a,b,c)      PFpa_textnode ((a),(b),(c))

/* comment-constructing operator */
#define comment(a,b,c)       PFpa_comment ((a),(b),(c))

/* processing instruction-constructing operator */
#define processi(a,b,c,d)    PFpa_processi ((a),(b),(c),(d))

/* constructor content operator (elem|doc) */
#define content(a,b,c)       PFpa_content ((a),(b),(c))

/* slim constructor content operator (elem|doc) */
#define slim_content(a,b,c)  PFpa_slim_content ((a),(b),(c))

#define merge_adjacent(a,b,c,d) PFpa_merge_adjacent ((a),(b),(c),(d))

#define error(a,b,c)         PFpa_error ((a), (b), (c))
#define nil()                PFpa_nil ()
#define cache(a,b,c,d)       PFpa_cache ((a),(b),(c),(d))
#define cache_border(a)      PFpa_cache_border (a)
#define trace(a,b)           PFpa_trace ((a),(b))
#define trace_items(a,b,c,d) PFpa_trace_items ((a),(b),(c),(d))
#define trace_msg(a,b,c,d)   PFpa_trace_msg ((a), (b), (c), (d))
#define trace_map(a,b,c,d)   PFpa_trace_map ((a), (b), (c), (d))

/* recursion operators */
#define rec_fix(a,b)         PFpa_rec_fix ((a),(b))
#define side_effects(a,b)    PFpa_side_effects ((a),(b))
#define rec_param(a,b)       PFpa_rec_param ((a),(b))
#define rec_arg(a,b,c)       PFpa_rec_arg ((a),(b),(c))
#define rec_base(a,b)        PFpa_rec_base ((a),(b))
#define rec_border(a)        PFpa_rec_border (a)

/* function application */
#define fun_call(a,b,c,d,e,f,g,h) \
        PFpa_fun_call ((a),(b),(c),(d),(e),(f),(g),(h))
#define fun_param(a,b,c)  PFpa_fun_param ((a),(b),(c))  

#define string_join(a,b,c,d) PFpa_string_join ((a),(b),(c),(d))

/* id/idref operator */
#define findnodes(a,b,c,d,e,f) PFpa_findnodes ((a),(b),(c),(d),(e),(f))

/* pf:text/attribute operator */
#define vx_lookup(a,b,c,d,e,f) PFpa_vx_lookup ((a),(b),(c),(d),(e),(f))


/* vim:set shiftwidth=4 expandtab: */
