/**
 * @file
 *
 * Serialize MIL tree.
 *
 * Serialization is done with the help of a simplified MIL grammar:
 *
 * @verbatim

   statements    : statements statements                    <m_seq>
                 | 'if (' Expr ') {' stmts '} else {' stmts '}' <m_if>
                 | 'while (' Expr ') {' stmts '}'           <m_while>
                 | 'break'                                  <m_break>
                 | <nothing>                                <m_nop>
                 | <nothing> ( expression )                 <m_use>
                 | '#' c                                    <m_comment>
                 | statement ';'                            <otherwise>

   statement     : Variable ':=' expression                 <m_assgn>
                 | 'module (' literal ')'                   <m_module>
                 | Variable ':= CATCH ({' statements '})'   <m_catch>
                 | expr '.insert (' expr ',' expr ')'       <m_insert>
                 | expression '.append (' expression ')'    <m_bappend>
                 | expression '.access (' restriction ')'   <m_access>
                 | 'serialize (...)'                        <m_serialize>
                 | 'trace (...)'                            <m_trace>
                 | 'var' Variable                           <m_declare>
                 | 'ERROR (' expression ')'                 <m_error>
                 | 'print (' args ')'                       <m_print>
                 | 'printf (' args ')'                      <m_printf>
                 | 'col_name (' expr ',' expr ')'           <m_col_name>
                 | 'destroy_ws (' expression ')'            <m_destroy_ws>

   expression    : Variable                                 <m_var>
                 | literal                                  <m_lit_*, m_nil>
                 | 'new (' Type ',' Type ')'                <m_new>
                 | expression '.seqbase ()'                 <m_sseqbase>
                 | expression '.seqbase (' expression ')'   <m_seqbase>
                 | expression '.select (' expression ')'    <m_select>
                 | expression '.exist (' expression ')'     <m_exist>
                 | expression '.project (' expression ')'   <m_project>
                 | expression '.mark (' expression ')'      <m_mark>
                 | expression '.hmark (' expression ')'     <m_hmark>
                 | expression '.tmark (' expression ')'     <m_tmark>
                 | expression '.mark_grp (' expression ')'  <m_mark_grp>
                 | expression '.cross (' expression ')'     <m_cross>
                 | expression '.join (' expression ')'      <m_join>
                 | expression '.leftjoin (' expression ')'  <m_leftjoin>
                 | expression '.outerjoin (' expression ')' <m_outerjoin>
                 | expression '.leftfetchjoin (' expr ')'   <m_leftfetchjoin>
                 | 'thetajoin ('exp','exp','exp','exp')'    <m_thetajoin>
                 | 'htordered_unique_thetajoin ('
                      exp ',' exp ',' exp ', nil, nil)'     <m_unq2_tjoin>
                 | 'll_htordered_unique_thetajoin ('
                      exp ',' exp ',' exp ','
                      exp ',' exp ', nil, nil)'             <m_unq1_tjoin>
                 | 'combine_node_info(' exp ',' exp ','
                      exp ',' exp ',' exp ',' exp ')'       <m_zip_nodes>
                 | 'get_attr_own (' exp ',' exp ',' exp ')' <m_attr_own>
                 | expression '.kunion (' expression ')'    <m_kunion>
                 | expression '.kdiff (' expression ')'     <m_kdiff>
                 | expression '.kintersect (' expression ')'<m_kintersect>
                 | expression '.sintersect (' expression ')'<m_sintersect>
                 | expression '.CTrefine (' expression ')'  <m_ctrefine>
                 | expression '.CTrefine_rev (' exp ')'     <m_ctrefine_rev>
                 | expression '.CTderive (' expression ')'  <m_ctderive>
                 | expression '.texist (' expression ')'    <m_texist>
                 | expression '.insert (' expression ')'    <m_binsert>
                 | expression '.append (' expression ')'    <m_bappend>
                 | expression '.fetch (' expression ')'     <m_fetch>
                 | expression '.set_kind (' expression ')'  <m_set_kind>
                 | expression '.kunique ()'                 <m_kunique>
                 | expression '.tunique ()'                 <m_tunique>
                 | expression '.reverse ()'                 <m_reverse>
                 | expression '.mirror ()'                  <m_mirror>
                 | expression '.copy ()'                    <m_copy>
                 | expression '.sort ()'                    <m_sort>
                 | expression '.sort_rev ()'                <m_sort_rev>
                 | expression '.count ()'                   <m_count>
                 | expression '.avg ()'                     <m_avg>
                 | expression '.max ()'                     <m_max>
                 | expression '.min ()'                     <m_min>
                 | expression '.sum ()'                     <m_sum>
                 | expression '.prod ()'                    <m_prod>
                 | expression 'bat ()'                      <m_bat>
                 | expression '.CTgroup ()'                 <m_ctgroup>
                 | expression '.CTmap ()'                   <m_ctmap>
                 | expression '.CTextend ()'                <m_ctextend>
                 | expression '.get_fragment ()'            <m_get_fragment>
                 | expression '.materialize (' exp ')'      <m_materialize>
                 | expression '.assert_order ()'            <m_assert_order>
                 | expression '.chk_order ()'               <m_chk_order>
                 | expression '.access (' restriction ')'   <m_access>
                 | expression '.key (' bool ')'             <m_key>
                 | expr '.insert (' expr ',' expr ')'       <m_insert>
                 | expr '.slice (' expr ',' expr ')'        <m_slice>
                 | expr '.select (' expr ',' expr ')'       <m_select2>
                 | Type '(' expression ')'                  <m_cast>
                 | '[' Type '](' expression ')'             <m_mcast>
                 | '+(' expression ',' expression ')'       <m_add>
                 | '[+](' expression ',' expression ')'     <m_madd>
#ifdef HAVE_GEOXML
                 | '[create_wkb](' expression )'                   <m_mgeo_create_wkb>
                 | '[wkb_point](' expression ',' expression ')'       <m_mgeo_wkb>
                 | '[Distance](' expression ',' expression ')'    <m_mgeo_distance>
                 | '[Intersection](' expression ',' expression ')'<m_mgeo_intersection>
                 | '[Relate](' expression ',' expression ')'<m_mgeo_relate>
                 | 'wkb_geometry('exp','exp','exp','exp')'            <m_wkb_geometry>
#endif
                 | '-(' expression ',' expression ')'       <m_sub>
                 | '[-](' expression ',' expression ')'     <m_msub>
                 | '[*](' expression ',' expression ')'     <m_mmult>
                 | '/(' expression ',' expression ')'       <m_div>
                 | '[/](' expression ',' expression ')'     <m_mdiv>
                 | '[%](' expression ',' expression ')'     <m_mmod>
                 | '[max](' expression ',' expression ')'   <m_mmax>
                 | '[abs](' expression ')'                  <m_mabs>
                 | '[ceil](' expression ')'                 <m_mceiling>
                 | '[floor](' expression ')'                <m_mfloor>
                 | '[log](' expression ')'                  <m_mlog>
                 | '[sqrt](' expression ')'                 <m_msqrt>
                 | '[round_up](' expression ')'             <m_mround_up>
                 | '>(' expression ',' expression ')'       <m_gt>
                 | '<=(' expression ',' expression ')'      <m_le>
                 | '=(' expression ',' expression ')'       <m_eq>
                 | '[=](' expression ',' expression ')'     <m_meq>
                 | '[>](' expression ',' expression ')'     <m_mgt>
                 | '[>=](' expression ',' expression ')'    <m_mge>
                 | '[<](' expression ',' expression ')'     <m_mlt>
                 | '[<=](' expression ',' expression ')'    <m_mle>
                 | '[!=](' expression ',' expression ')'    <m_mne>
                 | 'enumerate(' expr ',' expr ')'           <m_enum>
                 | 'not(' expression ')'                    <m_not>
                 | '[not](' expression ')'                  <m_mnot>
                 | '[-](' expression ')'                    <m_mneg>
                 | 'isnil(' expression ')'                  <m_isnil>
                 | '[isnil](' expression ')'                <m_misnil>
                 | 'and(' expression ',' expression ')'     <m_and>
                 | '[and](' expression ',' expression ')'   <m_mand>
                 | '[or](' expression ',' expression ')'    <m_mor>
                 | '[ifthenelse](' exp ',' exp ',' exp ')'  <m_ifthenelse>
                 | '[search](' expression ',' expression ')'<m_msearch>
                 | '[string](' expression ',' expression ')'<m_mstring>
                 | '[string](' exp ',' exp ',' exp ')'      <m_mstring2>
                 | '[startsWith](' exp ',' exp ')'          <m_mstarts_with>
                 | 'startsWith(' exp ',' exp ')'            <m_starts_with>
                 | '[endsWith](' exp ',' exp ')'            <m_mends_with>
                 | '[length](' expresion ')'                <m_mlength>
                 | '[toUpper](' expresion ')'               <m_mtoUpper>
                 | '[toLower](' expresion ')'               <m_mtoLower>
                 | '[translate](' exp ',' exp ',' exp ')'   <m_mtranslate>
                 | '[normSpace](' expresion ')'             <m_mnorm_space>
                 | '[pcre_match]('exp','exp')'              <m_mpcre_match>
                 | '[pcre_match]('exp','exp','exp')'        <m_mpcre_match_flag>
                 | '[pcre_replace]('exp','exp','exp','exp')'<m_mpcre_replace>
                 | '{count}(' expression ')'                <m_gcount>
                 | '{count}(' expression ',' expression ')' <m_egcount>
                 | '{avg}(' expression ')'                  <m_gavg>
                 | '{max}(' expression ')'                  <m_gmax>
                 | '{min}(' expression ')'                  <m_gmin>
                 | '{sum}(' expression ')'                  <m_gsum>
                 | '{prod}(' expression ')'                 <m_gprod>
                 | '{sum}(' expression ',' expression ')'   <m_egsum>
                 | 'usec ()'                                <m_usec>
                 | 'new_ws ('exp')'                         <m_new_ws>
                 | 'mposjoin (' exp ',' exp ',' exp ')'     <m_mposjoin>
                 | 'mvaljoin (' exp ',' exp ',' exp ')'     <m_mvaljoin>
                 | 'doc_tbl (' expr ',' expr ')'            <m_doc_tbl>
                 | 'attr_constr (' exp ',' exp ',' exp ')'  <m_attr_constr>
                 | 'elem_constr (' e ',' e ',' e ',' e ','
                                   e ',' e ',' e ',' e ')'  <m_elem_constr>
                 | 'elem_constr_empty (' expr ',' expr ')'  <m_elem_constr_e>
                 | 'text_constr (' expr ',' expr ')'        <m_text_constr>
                 | 'add_qname (' ex ',' ex ',' ex ',' ex ')'<m_add_qname>
                 | 'add_qnames(' ex ',' ex ',' ex ',' ex ')'<m_add_qnames>
                 | 'add_content (' exp ',' exp ',' exp ')'  <m_add_content>
                 | 'check_qnames (' expression ')'          <m_chk_qnames>
                 | 'sc_desc (' ex ',' ex ',' ex ',' ex ')'  <m_sc_desc>
                 | 'merged_adjacent_text_nodes
                             (' ex ',' ex ',' ex ',' ex ')' <m_merge_adjacent>
                 | 'string_join (' expr ',' expr ')'        <m_string_join>
                 | 'merged_union (' args ')'                <m_merged_union>
                 | 'multi_merged_union (' expr ')'          <m_multi_mu>
                 | 'ds_link (' args ')'                     <m_mc_intersect>

                 | 'step (' e ',' e ',' e ',' e ',' e ',' e ', e
                        ',' e ',' e ',' e ',' e ',' e ')'   <m_step>
                 | 'ws_collection_root('exp','exp')'      <m_ws_collection_root>
                 | 'ws_documents('exp','exp')'             <m_ws_documents>
                 | 'ws_documents('exp',' exp','exp')'      <m_ws_documents_str>
                 | 'ws_docname('exp','exp','exp','exp')'   <m_ws_docname>
                 | 'ws_collections('exp','exp')'           <m_ws_collections>
                 | 'ws_docavailable('exp','exp')'          <m_ws_docavailable>
                 | 'ws_findnodes('e','e','e','e','e','e','e')' <m_ws_findnodes>
                 | 'vx_lookup('e','e','e','e','e','e','e','e','e','e')'
                                                           <m_vx_lookup>
                 | '[date]' (expr);                        <m_mdate>
                 | '[daytime]' (expr);                     <m_mdaytme>
                 | '[year]' (expr);                        <m_myear>
                 | '[month]' (expr);                       <m_mmonth>
                 | '[day]' (expr);                         <m_mday>
                 | '[hour]' (expr);                        <m_mhour>
                 | '[minutes]' (expr);                     <m_mminutes>

   args          : args ',' args                            <m_arg>
                 | expression                               <otherwise>

   literal       : IntegerLiteral                           <m_lit_int>
                 | LongIntegerLiteral                       <m_lit_lng>
                 | StringLiteral                            <m_lit_str>
                 | OidLiteral                               <m_lit_oid>
                 | 'nil'                                    <m_nil>
@endverbatim
 *
 * Grammar rules are reflected by @c print_* functions in this file.
 * Depending on the current MIL tree node kind (see enum values
 * in brackets above), the corresponding sub-rule is chosen (i.e.
 * the corresponding sub-routine is called).
 *
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

/* always include pathfinder.h first! */
#include "pathfinder.h"

#include <stdio.h>
#include <assert.h>

#include "milprint.h"

#include "oops.h"
#include "pfstrings.h"

static char *ID[] = {

      [m_new]          = "new"
    , [m_sseqbase]     = "seqbase"
    , [m_seqbase]      = "seqbase"
    , [m_key]          = "key"
    , [m_order]        = "order"
    , [m_slice]        = "slice"
    , [m_select]       = "select"
    , [m_uselect]      = "ord_uselect"
    , [m_select2]      = "select"
    , [m_exist]        = "exist"
    , [m_insert]       = "insert"
    , [m_binsert]      = "insert"
    , [m_bappend]      = "append"
    , [m_fetch]        = "fetch"
    , [m_project]      = "project"
    , [m_mark]         = "mark"
    , [m_hmark]        = "hmark"
    , [m_tmark]        = "tmark"
    , [m_mark_grp]     = "mark_grp"
    , [m_access]       = "access"
    , [m_cross]        = "cross"
    , [m_join]         = "join"
    , [m_leftjoin]     = "leftjoin"
    , [m_outerjoin]    = "outerjoin"
    , [m_leftfetchjoin]= "leftfetchjoin"
    , [m_thetajoin]    = "thetajoin"
    , [m_unq2_tjoin]   = "htordered_unique_thetajoin"
    , [m_unq1_tjoin]   = "ll_htordered_unique_thetajoin"
    , [m_zip_nodes]    = "combine_node_info"
    , [m_attr_own]     = "get_attr_own"
    , [m_reverse]      = "reverse"
    , [m_mirror]       = "mirror"
    , [m_copy]         = "copy"
    , [m_kunique]      = "kunique"
    , [m_tunique]      = "tunique"
    , [m_kunion]       = "kunion"
    , [m_kdiff]        = "kdiff"
    , [m_kintersect]   = "kintersect"
    , [m_sintersect]   = "sintersect"
    , [m_mc_intersect] = "ds_link"
    , [m_merged_union] = "merged_union"
    , [m_multi_mu]     = "multi_merged_union"
    , [m_var]          = "var"

    , [m_sort]         = "sort"
    , [m_sort_rev]     = "sort_rev"
    , [m_ctgroup]      = "CTgroup"
    , [m_ctmap]        = "CTmap"
    , [m_ctextend]     = "CTextend"
    , [m_ctrefine]     = "CTrefine"
    , [m_ctrefine_rev] = "CTrefine_rev"
    , [m_ctderive]     = "CTderive"
    , [m_texist]       = "texist"

    , [m_add]          = "+"
    , [m_madd]         = "[+]"
#ifdef HAVE_GEOXML
    , [m_mgeo_create_wkb]   = "[geo_wkb_from_text]"
    , [m_mgeo_point]        = "[wkb_point]"
    , [m_mgeo_distance]     = "[Distance]"
    , [m_mgeo_intersection] = "[Intersection]"
    , [m_mgeo_relate]       = "[Relate]"
    , [m_wkb_geometry]      = "wkb_geometry"
#endif
    , [m_sub]          = "-"
    , [m_msub]         = "[-]"
    , [m_mmult]        = "[*]"
    , [m_div]          = "/"
    , [m_mdiv]         = "[/]"
    , [m_mmod]         = "[%]"
    , [m_mmax]         = "[max]"
    , [m_mabs]         = "[abs]"
    , [m_mceiling]     = "[ceil]"
    , [m_mfloor]       = "[floor]"
    , [m_mlog]         = "[log]"
    , [m_msqrt]        = "[sqrt]"
    , [m_mround_up]    = "[round_up]"
    , [m_gt]           = ">"
    , [m_le]           = "<="
    , [m_eq]           = "="
    , [m_meq]          = "[=]"
    , [m_mgt]          = "[>]"
    , [m_mge]          = "[>=]"
    , [m_mlt]          = "[<]"
    , [m_mle]          = "[<=]"
    , [m_mne]          = "[!=]"
    , [m_not]          = "not"
    , [m_mnot]         = "[not]"
    , [m_mneg]         = "[-]"
    , [m_and]          = "and"
    , [m_mand]         = "[and]"
    , [m_mor]          = "[or]"
    , [m_mifthenelse]  = "[ifthenelse]"
    , [m_msearch]      = "[search]"
    , [m_mstring]      = "[string]"
    , [m_mstring2]     = "[string]"
    , [m_mstarts_with] = "[startsWith]"
    , [m_starts_with]  = "startsWith"
    , [m_mends_with]   = "[endsWith]"
    , [m_mlength]      = "[length]"
    , [m_mtoUpper]     = "[toUpper]"
    , [m_mtoLower]     = "[toLower]"
    , [m_mtranslate]   = "[translate]"
    , [m_mnorm_space]  = "[normSpace]"
    , [m_mpcre_match]  = "[pcre_match]"
    , [m_mpcre_match_flag] = "[pcre_match]"
    , [m_mpcre_replace]    = "[pcre_replace]"
    , [m_isnil]        = "isnil"
    , [m_misnil]       = "[isnil]"
    , [m_usec]         = "usec"
    , [m_new_ws]       = "ws_create"
    , [m_destroy_ws]   = "ws_destroy"
    , [m_mposjoin]     = "mposjoin"
    , [m_mvaljoin]     = "mvaljoin"
    , [m_doc_tbl]      = "doc_tbl"
    , [m_attr_constr]  = "attr_constr"
    , [m_elem_constr]  = "elem_constr"
    , [m_elem_constr_e]= "elem_constr_empty"
    , [m_text_constr]  = "text_constr"
    , [m_add_qname]    = "add_qname"
    , [m_add_qnames]   = "add_qnames"
    , [m_add_content]  = "add_content"
    , [m_chk_qnames]   = "invalid_qname"
    , [m_step]         = "step"
    , [m_ws_collection_root] = "ws_collection_root"
    , [m_ws_documents]       = "ws_documents"
    , [m_ws_documents_str]   = "ws_documents"
    , [m_ws_docname]         = "ws_docname"
    , [m_ws_collections]     = "ws_collections"
    , [m_ws_docavailable]    = "ws_docavailable"
    , [m_ws_findnodes]       = "ws_findnodes"
    , [m_vx_lookup]          = "vx_lookup"

    , [m_mdate]              = "[date]"
    , [m_mdaytime]           = "[daytime]"
    , [m_myear]              = "[year]"
    , [m_mmonth]             = "[month]"
    , [m_mday]               = "[day]"
    , [m_mhour]              = "[hours]"
    , [m_mminutes]           = "[minutes]"
    , [m_mseconds]           = "[seconds]"
    , [m_mmilliseconds]      = "[milliseconds]"
    , [m_msecmsec]           = "[sec_msec]"

    , [m_merge_adjacent]   = "merge_adjacent_text_nodes"
    , [m_string_join]      = "string_join"

    , [m_get_fragment]    = "get_fragment"
    , [m_set_kind]        = "set_kind"
    , [m_materialize]     = "materialize"
    , [m_assert_order]    = "assert_order"
    , [m_chk_order]       = "chk_order"

    , [m_sc_desc]  = "sc_desc"

    , [m_enum]     = "enumerate"
    , [m_count]    = "count"
    , [m_gcount]   = "{count}"
    , [m_egcount]  = "{count}"
    , [m_avg]      = "avg"
    , [m_gavg]     = "{avg}"
    , [m_max]      = "max"
    , [m_gmax]     = "{max}"
    , [m_min]      = "min"
    , [m_gmin]     = "{min}"
    , [m_gsum]     = "{sum}"
    , [m_egsum]    = "{sum}"
    , [m_prod]     = "prod"
    , [m_gprod]    = "{prod}"
    , [m_gprod]    = "{prod}"
    , [m_bat]      = "bat"
    , [m_catch]    = "CATCH"
    , [m_error]    = "ERROR"
    , [m_col_name] = "col_name"
#ifdef HAVE_PFTIJAH
    , [m_tj_pfop]          = "ALG_tj_pfop"
    , [m_tj_query_score]   = "ALG_tj_query_score"
    , [m_tj_query_nodes]   = "ALG_tj_query_nodes"
    , [m_tj_tokenize]      = "[tijah_tokenize]"
    , [m_tj_ft_index_info] = "ALG_tj_ft_index_info"
    , [m_tj_query_handler] = "ALG_tj_query_handler"
    , [m_tj_add_fti_tape]  = "ALG_tj_add_fti_tape"
    , [m_tj_docmgmt_tape ] = "ALG_tj_docmgmt_tape"
#endif

};

/** The string we print to */
static PFarray_t *out = NULL;

/* Wrapper to print stuff */
static void milprintf (char *, ...)
    __attribute__ ((format (printf, 1, 2)));

/* forward declarations for left sides of grammar rules */
static void print_statements (PFmil_t *);
static void print_statement (PFmil_t *);
static void print_variable (PFmil_t *);
static void print_expression (PFmil_t *);
static void print_literal (PFmil_t *);
static void print_type (PFmil_t *);
static void print_args (PFmil_t *);

#ifdef NDEBUG
#define debug_output
#else
/**
 * In our debug versions we want to have meaningful error messages when
 * generating MIL output failed. So we print the MIL script as far as
 * we already generated it.
 */
#define debug_output \
  PFinfo (OOPS_FATAL, "I encountered problems while generating MIL output."); \
  PFinfo (OOPS_FATAL, "This is possibly due to an illegal MIL tree, "         \
                      "not conforming to the grammar in milprint.c");         \
  PFinfo (OOPS_FATAL, "This is how far I was able to generate the script:");  \
  fprintf (stderr, "%s", (char *) out->base);
#endif

/**
 * @brief Implementation of the grammar rules for `statements'.
 *
 * @param n MIL tree node
 */
static void
print_statements (PFmil_t *n)
{
    switch (n->kind) {

        /* statements : statements statements */
        case m_seq:
            print_statements (n->child[0]);
            print_statements (n->child[1]);
            break;

        case m_if:
            milprintf ("if (");
            print_expression (n->child[0]);
            milprintf (") {\n");
            print_statements (n->child[1]);
            milprintf ("} else {\n");
            print_statements (n->child[2]);
            milprintf ("}\n");
            break;

        case m_while:
            milprintf ("while (");
            print_expression (n->child[0]);
            milprintf (") {\n");
            print_statements (n->child[1]);
            milprintf ("}\n");
            break;

        case m_nop:
            break;

        case m_comment:
            milprintf ("# ");
            /* FIXME: What if c contains \n's? */
            milprintf ("%s\n", n->sem.s);
            break;

        case m_use:
            break;

        /* statements : statement ';' */
        default:
            print_statement (n);
            milprintf (";\n");
            break;
    }
}

/**
 * Implementation of the grammar rules for `statement'.
 *
 * @param n MIL tree node
 */
static void
print_statement (PFmil_t * n)
{
    switch (n->kind) {

        /* statement : 'module (' Literal ')' */
        case m_module:
            milprintf ("module (");
            print_literal (n->child[0]);
            milprintf (")");
            break;

        /* statement : variable ':=' expression */
        case m_assgn:
            print_variable (n->child[0]);
            milprintf (" := ");
            print_expression (n->child[1]);
            break;

        /* statement : variable ':= CATCH ({' statements '})' */
        case m_catch:
            print_variable (n->child[0]);
            milprintf (" := CATCH ({\n");
            print_statements (n->child[1]);
            milprintf ("})");
            break;

        case m_break:
            milprintf ("break");
            break;

        /* statement : 'var' Variable */
        case m_declare:
            milprintf ("var ");
            print_variable (n->child[0]);
            break;

        /* expr '.insert (' expr ',' expr ')' */
        case m_insert:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;

        /* expression '.insert (' expression ')' */
        case m_binsert:
        /* expression '.append (' expression ')' */
        case m_bappend:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (")");
            break;

        /* expression '.access (' restriction ')' */
        case m_access:
            print_expression (n->child[0]);
            switch (n->sem.access) {
                case BAT_READ:   milprintf (".access (BAT_READ)"); break;
                case BAT_APPEND: milprintf (".access (BAT_APPEND)"); break;
                case BAT_WRITE:  milprintf (".access (BAT_WRITE)"); break;
            }
            break;

        case m_order:
            print_expression (n->child[0]);
            milprintf (".%s", ID[n->kind]);
            break;

        /* `nop' nodes (`no operation') may be produced during compilation */
        /*
        case m_nop:
            break;
        */

        /* statement: 'destroy_ws (' expression ')' */
        case m_destroy_ws:
        /* statement: 'ERROR(' expression ')' */
        case m_error:
            milprintf ("%s (", ID[n->kind]);
            print_args (n->child[0]);
            milprintf (")");
            break;

        /* statement: 'print (' expression ')' */
        case m_print:
            milprintf ("print (");
            print_args (n->child[0]);
            milprintf (")");
            break;

        /* statement: 'printf (' expression ')' */
        case m_printf:
            milprintf ("printf (");
            print_args (n->child[0]);
            milprintf (")");
            break;

        case m_col_name:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (")");
            break;

        case m_serialize:
            milprintf ("print_result (");
            print_args (n->child[0]);
            milprintf (")");
            break;

        case m_trace:
            milprintf ("trace (");
            print_args (n->child[0]);
            milprintf (")");
            break;

        case m_update_tape:
            milprintf ("UpdateTape (");
            print_args (n->child[0]);
            milprintf (")");
            break;

        case m_docmgmt_tape:
            milprintf ("DocmgmTape (");
            print_args (n->child[0]);
            milprintf (")");
            break;
#ifdef HAVE_PFTIJAH
        case m_tj_docmgmt_tape:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (")");
            break;
#endif
        default:
            debug_output;     /* Print MIL code so far when in debug mode. */
#ifndef NDEBUG
            PFinfo (OOPS_NOTICE, "node: %s", ID[n->kind]);
#endif
            PFoops (OOPS_FATAL,
                    "Illegal MIL tree. MIL printer screwed up (kind: %u).",
                    n->kind);
    }
}

static void
print_args (PFmil_t *n)
{
    switch (n->kind) {

        case m_arg:   print_args (n->child[0]);
                      milprintf (", ");
                      print_args (n->child[1]);
                      break;

        default:      print_expression (n);
                      break;
    }
}

/**
 * Implementation of the grammar rules for `expression'.
 *
 * @param n MIL tree node
 */
static void
print_expression (PFmil_t * n)
{
    assert(n);
    switch (n->kind) {

        /* expression : Variable */
        case m_var:
            print_variable (n);
            break;

        /* expression : 'new (' Type ',' Type ')' */
        case m_new:
            milprintf ("new (");
            print_type (n->child[0]);
            milprintf (", ");
            print_type (n->child[1]);
            milprintf (")");
            break;

        /* expression : expression '.materialize (' expression ')' */
        case m_materialize:
        /* expression : expression '.seqbase (' expression ')' */
        case m_seqbase:
        /* expression : expression '.select (' expression ')' */
        case m_select:
        /* expression : expression '.ord_uselect (' expression ')' */
        case m_uselect:
        /* expression : expression '.exist (' expression ')' */
        case m_exist:
        /* expression : expression '.project (' expression ')' */
        case m_project:
        /* expression : expression '.mark (' expression ')' */
        case m_mark:
        /* expression : expression '.hmark (' expression ')' */
        case m_hmark:
        /* expression : expression '.tmark (' expression ')' */
        case m_tmark:
        /* expression : expression '.mark_grp (' expression ')' */
        case m_mark_grp:
        /* expression : expression '.cross (' expression ')' */
        case m_cross:
        /* expression : expression '.join (' expression ')' */
        case m_join:
        /* expression : expression '.leftjoin (' expression ')' */
        case m_leftjoin:
        /* expression : expression '.outerjoin (' expression ')' */
        case m_outerjoin:
        /* expression : expression '.leftfetchjoin (' expression ')' */
        case m_leftfetchjoin:
        /* expression : expression '.CTrefine (' expression ')' */
        case m_ctrefine:
        /* expression : expression '.CTrefine_rev (' expression ')' */
        case m_ctrefine_rev:
        /* expression : expression '.CTderive (' expression ')' */
        case m_ctderive:
        /* expression : expression '.texist (' expression ')' */
        case m_texist:
        /* expression : expression '.insert (' expression ')' */
        case m_binsert:
        /* expression : expression '.append (' expression ')' */
        case m_bappend:
        /* expression : expression '.fetch (' expression ')' */
        case m_fetch:
        /* expression : expression '.kunion (' expression ')' */
        case m_kunion:
        /* expression : expression '.kdiff (' expression ')' */
        case m_kdiff:
        /* expression : expression '.kintersect (' expression ')' */
        case m_kintersect:
        /* expression : expression '.sintersect (' expression ')' */
        case m_sintersect:
        /* expression : expression '.set_kind (' expression ')' */
        case m_set_kind:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (")");
            break;

        /* expression : expression '.seqbase ()' */
        case m_sseqbase:
        /* expression : expression '.reverse' */
        case m_reverse:
        /* expression : expression '.mirror' */
        case m_mirror:
        /* expression : expression '.kunique' */
        case m_kunique:
        /* expression : expression '.tunique' */
        case m_tunique:
        /* expression : expression '.copy' */
        case m_copy:
        /* expression : expression '.sort' */
        case m_sort:
        /* expression : expression '.sort_rev' */
        case m_sort_rev:
         /* expression : expression '.count' */
        case m_count:
        /* expression : expression '.avg' */
        case m_avg:
        /* expression : expression '.max' */
        case m_max:
        /* expression : expression '.min' */
        case m_min:
        /* expression : expression '.sum' */
        case m_sum:
        /* expression : expression '.prod' */
        case m_prod:
        /* expression : expression 'bat()' */
        case m_bat:
        /* expression '.CTgroup ()' */
        case m_ctgroup:
        /* expression '.CTmap ()' */
        case m_ctmap:
        /* expression '.CTextend ()' */
        case m_ctextend:
        /* expression '.get_fragment ()' */
        case m_get_fragment:
        /* 'invalid_qname (' expression ')' */
        case m_chk_qnames:
        /* expression '.assert_order ()' */
        case m_assert_order:
        /* expression '.chk_order ()' */
        case m_chk_order:
        /* expression : 'multi_merged_union (' expr ')' */
        case m_multi_mu:
            print_expression (n->child[0]);
            milprintf (".%s ()", ID[n->kind]);
            break;

        case m_access:
            print_expression (n->child[0]);
            switch (n->sem.access) {
                case BAT_READ:   milprintf (".access (BAT_READ)"); break;
                case BAT_APPEND: milprintf (".access (BAT_APPEND)"); break;
                case BAT_WRITE:  milprintf (".access (BAT_WRITE)"); break;
            }
            break;

        /* expression '.key (' bool ')' */
        case m_key:
            print_expression (n->child[0]);
            milprintf (".key (%s)", n->sem.b ? "true" : "false");
            break;

        /* expression : Type '(' expression ')' */
        case m_cast:
            print_type (n->child[0]);
            milprintf ("(");
            print_expression (n->child[1]);
            milprintf (")");
            break;

        /* expression : '[' Type '](' expression ')' */
        case m_mcast:
            milprintf ("[");
            print_type (n->child[0]);
            milprintf ("](");
            print_expression (n->child[1]);
            milprintf (")");
            break;

        /* expression : 'string_join(' exp ',' exp)' */
        case m_string_join:
        /* expression : '[search](' exp ',' exp)' */
        case m_msearch:
        /* expression : '[string](' exp ',' exp)' */
        case m_mstring:
        /* expression : '[startsWith](' exp ',' exp)' */
        case m_mstarts_with:
        /* expression : 'startsWith(' exp ',' exp)' */
        case m_starts_with:
        /* expression : '[endsWith](' exp ',' exp)' */
        case m_mends_with:
        /* expression : '[pcre_match](' exp ',' exp)' */
        case m_mpcre_match:
        /* expression : '+(' expression ',' expression ')' */
        case m_add:
        /* expression : '[+](' expression ',' expression ')' */
        case m_madd:
#ifdef HAVE_GEOXML
        /* expression : '[wkb_point] expression ',' expression ')' */
	case m_mgeo_point: 
	case m_mgeo_distance: 
	case m_mgeo_intersection: 
#endif
        /* expression : '-(' expression ',' expression ')' */
        case m_sub:
        /* expression : '[-](' expression ',' expression ')' */
        case m_msub:
        /* expression : '[*](' expression ',' expression ')' */
        case m_mmult:
        /* expression : '/(' expression ',' expression ')' */
        case m_div:
        /* expression : '[/](' expression ',' expression ')' */
        case m_mdiv:
        /* expression : '[%](' expression ',' expression ')' */
        case m_mmod:
        /* expression : '[max](' expression ',' expression ')' */
        case m_mmax:
        /* expression : '>(' expression ',' expression ')' */
        case m_gt:
        /* expression : '<=(' expression ',' expression ')' */
        case m_le:
        /* expression : '=(' expression ',' expression ')' */
        case m_eq:
        /* expression : '[=](' expression ',' expression ')' */
        case m_meq:
        /* expression : '[>](' expression ',' expression ')' */
        case m_mgt:
        /* expression : '[>=](' expression ',' expression ')' */
        case m_mge:
        /* expression : '[<](' expression ',' expression ')' */
        case m_mlt:
        /* expression : '[<=](' expression ',' expression ')' */
        case m_mle:
        /* expression : '[!=](' expression ',' expression ')' */
        case m_mne:
        /* expression : 'and(' expression ',' expression ')' */
        case m_and:
        /* expression : '[and](' expression ',' expression ')' */
        case m_mand:
        /* expression : '[or](' expression ',' expression ')' */
        case m_mor:
        /* expression : 'enumerate(' expression ',' expression ')' */
        case m_enum:
        /* expression : 'ws_collection_root(' expression ',' expression ')' */
        case m_ws_collection_root:
        /* expression : 'ws_documents(' expression ',' expression ')' */
        case m_ws_documents:
        /* expression : 'ws_collections(' expression ',' expression ')' */
        case m_ws_collections:
        /* expression : 'ws_docavailable(' expression ',' expression ')' */
        case m_ws_docavailable:
            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (")");
            break;
#ifdef HAVE_GEOXML
        case m_mgeo_relate:
#endif
        /* expression : '[pcre_match](' exp ',' exp ',' exp)' */
        case m_mpcre_match_flag:
        /* expression : '[string](' exp ',' exp ',' exp)' */
        case m_mstring2:
        /* expression : '[ifthenelse](' expr ',' expr ',' expr ')' */
        case m_mifthenelse:
        /* expression : 'ws_documents(' expr ',' expr ',' expr ')' */
        case m_ws_documents_str:
            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;

        /* expression: '[pcre_replace](' expr ',' expr ',' expr ',' expr ')' */
        case m_mpcre_replace:
        /* expression: 'ws_docname(' expr ',' expr ',' expr ',' expr ')' */
        case m_ws_docname:
            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (")");
            break;
#ifdef HAVE_GEOXML
        /* expression: 'wkb_geometry(' expr ',' expr ',' expr ',' expr ')' */
        case m_wkb_geometry:
            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (")");
            break;
#endif

        /* expression: '{count}(' expression ')' */
        case m_gcount:
        /* expression: '{avg}(' expression ')' */
        case m_gavg:
        /* expression: '{max}(' expression ')' */
        case m_gmax:
        /* expression: '{min}(' expression ')' */
        case m_gmin:
        /* expression: '{sum}(' expression ')' */
        case m_gsum:
        /* expression: '{prod}(' expression ')' */
        case m_gprod:
#ifdef HAVE_GEOXML
        /* expression : '[create_wkb] '(' expression ')' */
        case m_mgeo_create_wkb:
#endif
        /* expression : [date] (' expression ')' */
        case m_mdate:
        /* expression : [daytime] (' expression ')' */
        case m_mdaytime:
        /* expression : [year] (' expression ')' */
        case m_myear:
        /* expression : [month] (' expression ')' */
        case m_mmonth:
        /* expression : [day] (' expression ')' */
        case m_mday:
        /* expression : [hour] (' expression ')' */
        case m_mhour:
        /* expression : [minutes] (' expression ')' */
        case m_mminutes:
         /* expression : [seconds] (' expression ')' */
        case m_mseconds:
       /* expression : [milliseconds] (' expression ')' */
        case m_mmilliseconds:
       /* expression : [sec_msec] (' expression ')' */
        case m_msecmsec:

            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (")");
            break;

        /* expr '.slice (' expr ',' expr ')' */
        case m_slice:
        /* expr '.select (' expr ',' expr ')' */
        case m_select2:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;

        /* expression : '[abs](' expression ')' */
        case m_mabs:
        /* expression : '[ceil](' expression ')' */
        case m_mceiling:
        /* expression : '[floor](' expression ')' */
        case m_mfloor:
        /* expression : '[log](' expression ')' */
        case m_mlog:
        /* expression : '[sqrt](' expression ')' */
        case m_msqrt:
        /* expression : '[round_up](' expression ')' */
        case m_mround_up:
        /* expression : 'not(' expression ')' */
        case m_not:
        /* expression : '[not](' expression ')' */
        case m_mnot:
        /* expression : '[-](' expression ')' */
        case m_mneg:
        /* expression : 'isnil(' expression ')' */
        case m_isnil:
        /* expression : '[isnil](' expression ')' */
        case m_misnil:
        /* expression : '[length](' expression ')' */
        case m_mlength:
        /* expression : '[toUpper](' expression ')' */
        case m_mtoUpper:
        /* expression : '[toLower](' expression ')' */
        case m_mtoLower:
        /* expression : '[normSpace](' expression ')' */
        case m_mnorm_space:
        /* expression : 'new_ws ('expresion')' */
        case m_new_ws:
            milprintf ("%s(", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (")");
            break;

        /* expression : 'usec ()' */
        case m_usec:
            milprintf ("%s ()", ID[n->kind]);
            break;

        /* expression : '[translate] (' expr ',' expr ',' expr ')' */
        case m_mtranslate:
        /* expression : 'attr_constr (' expr ',' expr ',' expr ')' */
        case m_attr_constr:
        /* expression : 'mposjoin (' exp ',' exp ',' exp ')' */
        case m_mposjoin:
        /* expression : 'mvaljoin (' exp ',' exp ',' exp ')' */
        case m_mvaljoin:
        /* expression : 'add_content (' exp ',' exp ',' exp ')' */
        case m_add_content:
        /* expression : 'get_attr_own (' exp ',' exp ',' exp ')' */
        case m_attr_own:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;

        /* expression: '{count}(' expression ',' expression ')' */
        case m_egcount:
        /* expression: '{sum}(' expression ',' expression ')' */
        case m_egsum:
        /* expression : 'doc_tbl (' expr ',' expr ')' */
        case m_doc_tbl:
        /* expression : 'elem_constr_empty (' expr ',' expr ')' */
        case m_elem_constr_e:
        /* expression : 'text_constr (' expr ',' expr ')' */
        case m_text_constr:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (")");
            break;


        /* expression : 'merged_adjacent_text_nodes
                             (' ex ',' ex ',' ex ',' ex ')' */
        case m_merge_adjacent:
        /* expression : 'add_qname (' expr ',' expr ',' expr ',' expr ')' */
        case m_add_qname:
        /* expression : 'add_qnames (' expr ',' expr ',' expr ',' expr ')' */
        case m_add_qnames:
        /* expression : 'sc_desc (' expr ',' expr ',' expr ',' expr ')' */
        case m_sc_desc:
        /* expression : 'thetajoin ('exp','exp','exp','exp')' */
        case m_thetajoin:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (")");
            break;

        /* expression : 'elem_constr (' e ',' e ',' e ',' e ','
                                        e ',' e ',' e ',' e ')' */
        case m_elem_constr:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (", ");
            print_expression (n->child[6]);
            milprintf (", ");
            print_expression (n->child[7]);
            milprintf (")");
            break;

        /* expression : 'ws_findnodes (' e ',' e ',' e ',' e ','
                                        e ',' e ',' e ')' */
        case m_ws_findnodes:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (", ");
            print_expression (n->child[6]);
            milprintf (")");
            break;

        /* expression : 'vx_lookup (' e ',' e ',' e ',' e ',' e ','
         *                            e ',' e ',' e ',' e ',' e ')' */
        case m_vx_lookup:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (", ");
            print_expression (n->child[6]);
            milprintf (", ");
            print_expression (n->child[7]);
            milprintf (", ");
            print_expression (n->child[8]);
            milprintf (", ");
            print_expression (n->child[9]);
            milprintf (")");
            break;

        /* expression : 'htordered_unique_thetajoin (' exp ',' exp ','
                                                       exp ', nil, nil)' */
        case m_unq2_tjoin:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[2]); /* mode */
            milprintf (", ");
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", nil, nil)");
            break;

        /* expression : 'll_htordered_unique_thetajoin ('
                            exp ',' exp ',' exp ',' exp ',' exp ', nil, nil)' */
        case m_unq1_tjoin:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[4]); /* mode */
            milprintf (", ");
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", nil, nil)");
            break;

        /* expression : combine_node_info(' exp ',' exp ',' exp ','
                                            exp ',' exp ',' exp ')' */
        case m_zip_nodes:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (")");
            break;

        case m_merged_union:
        case m_mc_intersect:
            milprintf ("%s (", ID[n->kind]);
            print_args (n->child[0]);
            milprintf (")");
            break;

        /* expression : literal */
        case m_lit_int:
        case m_lit_lng:
        case m_lit_str:
        case m_lit_oid:
        case m_lit_dbl:
        case m_lit_bit:
        case m_nil:
            print_literal (n);
            break;

        case m_insert:
            print_expression (n->child[0]);
            milprintf (".%s (", ID[n->kind]);
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;

        case m_step:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (", ");
            print_expression (n->child[6]);
            milprintf (", ");
            print_expression (n->child[7]);
            milprintf (", ");
            print_expression (n->child[8]);
            milprintf (", ");
            print_expression (n->child[9]);
            milprintf (", ");
            print_expression (n->child[10]);
            milprintf (", ");
            print_expression (n->child[11]);
            milprintf (")");
            break;

#ifdef HAVE_PFTIJAH
        case m_tj_tokenize:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (")");
	    break;
        case m_tj_ft_index_info:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
	    break;
        case m_tj_query_score:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (")");
            break;
        case m_tj_query_nodes:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (")");
            break;
        case m_tj_pfop:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (")");
            break;
        case m_tj_query_handler:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (", ");
            print_expression (n->child[6]);
            milprintf (")");
            break;
        case m_tj_add_fti_tape:
            milprintf ("%s (", ID[n->kind]);
            print_expression (n->child[0]);
            milprintf (", ");
            print_expression (n->child[1]);
            milprintf (", ");
            print_expression (n->child[2]);
            milprintf (", ");
            print_expression (n->child[3]);
            milprintf (", ");
            print_expression (n->child[4]);
            milprintf (", ");
            print_expression (n->child[5]);
            milprintf (")");
            break;

#endif
        default:
            debug_output;     /* Print MIL code so far when in debug mode. */
#ifndef NDEBUG
            PFinfo (OOPS_NOTICE, "node: %s", ID[n->kind]);
#endif
            PFoops (OOPS_FATAL, "Illegal MIL tree. MIL printer screwed up.");
    }
}


/**
 * Create MIL script output for variables.
 *
 * @param n MIL tree node of type #m_var.
 */
static void
print_variable (PFmil_t * n)
{
    assert (n->kind == m_var);

    milprintf ("%s", PFmil_var_str (n->sem.ident));
}

/**
 * Implementation of the grammar rules for `literal'.
 *
 * @param n MIL tree node
 */
static void
print_literal (PFmil_t * n)
{
    switch (n->kind) {

        /* literal : IntegerLiteral */
        case m_lit_int:
            milprintf ("%i", n->sem.i);
            break;

        /* literal : LongIntegerLiteral */
        case m_lit_lng:
            milprintf (LLFMT "LL", n->sem.l);
            break;

        /* literal : StringLiteral */
        case m_lit_str:
            assert (n->sem.s);
            milprintf ("\"%s\"", PFesc_string (n->sem.s));
            break;

        /* literal : OidLiteral */
        case m_lit_oid:
            milprintf ("%u@0", n->sem.o);
            break;

        /* literal : DblLiteral */
        case m_lit_dbl:
            milprintf ("dbl(%gLL)", n->sem.d);
            break;

        /* literal : BitLiteral */
        case m_lit_bit:
            milprintf (n->sem.b ? "true" : "false");
            break;

        /* literal : 'nil' */
        case m_nil:
            milprintf ("nil");
            break;

        default:
            debug_output;     /* Print MIL code so far when in debug mode. */
#ifndef NDEBUG
            PFinfo (OOPS_NOTICE, "node: %s", ID[n->kind]);
#endif
            PFoops (OOPS_FATAL, "Illegal MIL tree, literal expected. "
                                "MIL printer screwed up.");
    }
}

static void
print_type (PFmil_t *n)
{
    char *types[] = {
          [mty_oid]          = "oid"
        , [mty_void]         = "void"
        , [mty_int]          = "int"
        , [mty_str]          = "str"
        , [mty_lng]          = "lng"
        , [mty_dbl]          = "dbl"
        , [mty_bit]          = "bit"
        , [mty_chr]          = "chr"
        , [mty_bat]          = "bat"
        , [mty_timestamp]    = "timestamp"
        , [mty_date]         = "date"
        , [mty_daytime]      = "daytime"
        , [mty_ymduration]   = "ymduration"
        , [mty_dtduration]   = "dtduration"
    };

    if (n->kind != m_type) {
        debug_output;     /* Print MIL code so far when in debug mode. */
#ifndef NDEBUG
        PFinfo (OOPS_NOTICE, "node: %s", ID[n->kind]);
#endif
        PFoops (OOPS_FATAL, "Illegal MIL tree, type expected. "
                            "MIL printer screwed up.");
    }

    milprintf (types[n->sem.t]);
}

/**
 * output a single chunk of MIL code to the output character
 * array @a out. Uses @c printf style syntax.
 * @param fmt printf style format string, followed by an arbitrary
 *            number of arguments, according to format string
 */
static void
milprintf (char * fmt, ...)
{
    va_list args;

    assert (out);

    /* print string */
    va_start (args, fmt);

    if (PFarray_vprintf (out, fmt, args) == -1)
        PFoops (OOPS_FATAL, "unable to print MIL output");

    va_end (args);
}

/**
 * Serialize the internal representation of a MIL program into a
 * string representation that can serve as an input to Monet.
 *
 * @param m   The MIL tree to print
 * @return Dynamic (character) array holding the generated MIL script.
 */
PFarray_t *
PFmil_serialize (PFmil_t * m)
{
    out = PFarray (sizeof (char), 64000);

    /* `statements' is the top rule of our grammar */
    print_statements (m);

    return out;
}

/**
 * Print the generated MIL script in @a milprg to the output stream
 * @a stream, while indenting it nicely.
 *
 * Most characters of the MIL script will be output 1:1 (using fputc).
 * If we encounter a newline, we add spaces according to our current
 * indentation level. If we see curly braces, we increase or decrease
 * the indentation level. Spaces are not printed immediately, but
 * `buffered' (we only increment the counter @c spaces for that).
 * If we see an opening curly brace, we can `redo' some of these
 * spaces to make the opening curly brace be indented less than the
 * block it surrounds.
 *
 * @param stream The output stream to print to (usually @c stdout)
 * @param milprg The dynamic (character) array holding the MIL script.
 */
void
PFmilprint (FILE *stream, PFarray_t * milprg)
{
    char         c;              /* the current character  */
    unsigned int pos;            /* current position in input array */
    unsigned int spaces = 0;     /* spaces accumulated in our buffer */
    unsigned int indent = 0;     /* current indentation level */

    for (pos = 0; (c = *((char *) PFarray_at (milprg, pos))) != '\0'; pos++) {

        switch (c) {

            case '\n':                     /* print newline and spaces       */
                fputc ('\n', stream);      /* according to indentation level */
                spaces = indent;
                break;

            case ' ':                      /* buffer spaces                  */
                spaces++;
                break;

            case '}':                      /* `undo' some spaces when we see */
                                           /* an opening curly brace         */
                spaces = spaces > INDENT_WIDTH ? spaces - INDENT_WIDTH : 0;
                indent -= 2 * INDENT_WIDTH;
                /* Double indentation, as we will reduce indentation when
                 * we fall through next. */

            case '{':
                indent += INDENT_WIDTH;
                /* fall through */

            default:
                while (spaces > 0) {
                    spaces--;
                    fputc (' ', stream);
                }
                fputc (c, stream);
                break;
        }
    }
}

/* vim:set shiftwidth=4 expandtab: */
