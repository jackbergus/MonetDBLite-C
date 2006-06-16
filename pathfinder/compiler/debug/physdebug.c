/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 * 
 * Debugging: dump physical algebra tree in AY&T dot format.
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
 * The Initial Developer of the Original Code is the Database &
 * Information Systems Group at the University of Konstanz, Germany.
 * Portions created by the University of Konstanz are Copyright (C)
 * 2000-2006 University of Konstanz.  All Rights Reserved.
 *
 * $Id$
 */

#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "pathfinder.h"
#include "physdebug.h"

#include "mem.h"
/* #include "pfstrings.h" */
#include "prettyp.h"
#include "oops.h"
#include "properties.h"

/** Node names to print out for all the Algebra tree nodes. */
static char *a_id[]  = {
      [pa_serialize]       = "SERIALIZE"
    , [pa_lit_tbl]         = "TBL"
    , [pa_empty_tbl]       = "EMPTY_TBL"
    , [pa_attach]          = "@"
      /* note: dot does not like the sequence "�\nfoo", so we put spaces
       * around the cross symbol.
       */
    , [pa_cross]           = " � "              /* \"#00FFFF\" */
    , [pa_leftjoin]        = "LEFTJOIN"         /* \"#00FF00\" */
    , [pa_eqjoin]          = "EQJOIN"           /* \"#00FF00\" */
    , [pa_project]         = "� "
    , [pa_select]          = "SEL"
    , [pa_append_union]    = "APPEND_UNION"
    , [pa_merge_union]     = "MERGE_UNION"
    , [pa_intersect]       = "INTERSECT"        /* \"#FFA500\" */
    , [pa_difference]      = "DIFF"             /* \"#FFA500\" */
    , [pa_sort_distinct]   = "SORT_DISTINCT"
    , [pa_std_sort]        = "SORT"
    , [pa_refine_sort]     = "refine_sort"
    , [pa_num_add]         = "num-add"
    , [pa_num_add_atom]    = "num-add (atom)"
    , [pa_num_sub]         = "num-sub"
    , [pa_num_sub_atom]    = "num-sub (atom)"
    , [pa_num_mult]        = "num-mult"
    , [pa_num_mult_atom]   = "num-mult (atom)"
    , [pa_num_div]         = "num-div"
    , [pa_num_div_atom]    = "num-div (atom)"
    , [pa_num_mod]         = "num-mod"
    , [pa_num_mod_atom]    = "num-mod (atom)"
    , [pa_eq]              = "="
    , [pa_eq_atom]         = "= (atom)"
    , [pa_gt]              = ">"
    , [pa_gt_atom]         = "> (atom)"
    , [pa_num_neg]         = "-"
    , [pa_bool_and]        = "AND"
    , [pa_bool_or]         = "OR"
    , [pa_bool_not]        = "NOT"
    , [pa_bool_and_atom]   = "AND (atom)"
    , [pa_bool_or_atom]    = "OR (atom)"
    , [pa_avg]             = "AVG"
    , [pa_min]             = "MAX"
    , [pa_max]             = "MIN"
    , [pa_sum]             = "SUM"
    , [pa_hash_count]      = "HASH_COUNT"
    , [pa_merge_rownum]    = "MROW#"             /* \"#FF0000\" */
    , [pa_hash_rownum]     = "HROW#"             /* \"#FF0000\" */
    , [pa_number]          = "NUMBER"            /* \"#FF0000\" */
    , [pa_type]            = "TYPE"
    , [pa_type_assert]     = "type assertion"
    , [pa_cast]            = "CAST"
    , [pa_llscj_anc]       = "//| ancestor"
    , [pa_llscj_anc_self]  = "//| anc-self"
    , [pa_llscj_attr]      = "//| attr"
    , [pa_llscj_child]     = "//| child"
    , [pa_llscj_desc]      = "//| descendant"
    , [pa_llscj_desc_self] = "//| desc-self"
    , [pa_llscj_foll]      = "//| following"
    , [pa_llscj_foll_sibl] = "//| foll-sibl"
    , [pa_llscj_parent]    = "//| parent"
    , [pa_llscj_prec]      = "//| preceding"
    , [pa_llscj_prec_sibl] = "//| prec-sibl"
    , [pa_doc_tbl]         = "DOC"
    , [pa_doc_access]      = "access"
    , [pa_element]         = "ELEM"             /* lawn \"#00FF00\" */
    , [pa_element_tag]     = "ELEM_TAG"         /* lawn \"#00FF00\" */
    , [pa_attribute]       = "ATTR"             /* lawn \"#00FF00\" */
    , [pa_textnode]        = "TEXT"             /* lawn \"#00FF00\" */
    , [pa_docnode]         = "DOC"              /* lawn \"#00FF00\" */
    , [pa_comment]         = "COMMENT"          /* lawn \"#00FF00\" */
    , [pa_processi]        = "PI"               /* lawn \"#00FF00\" */
    , [pa_merge_adjacent]  = "#pf:merge-adjacent-text-nodes"
    , [pa_roots]           = "ROOTS"
    , [pa_fragment]        = "FRAGs"
    , [pa_frag_union]      = "FRAG_UNION"
    , [pa_empty_frag]      = "EMPTY_FRAG"
    , [pa_cond_err]        = "!ERROR"
    , [pa_concat]          = "fn:concat"
    , [pa_contains]        = "fn:contains"
    , [pa_string_join]     = "fn:string-join"
};

/** string representation of algebra atomic types */
static char *atomtype[] = {
      [aat_int]   = "int"
    , [aat_str]   = "str"
    , [aat_uA]    = "aU"
    , [aat_node]  = "node"
    , [aat_anode] = "attr"
    , [aat_pnode] = "pnode"
    , [aat_dec]   = "dec"
    , [aat_dbl]   = "dbl"
    , [aat_bln]   = "bool"
    , [aat_qname] = "qname"
};

/** Current node id */
/* static unsigned no = 0; */
/** Temporary variable to allocate mem for node names */
static char    *child;
/** Temporary variable for node labels in dot tree */
/*static char     label[32];*/

static char * literal (PFalg_atom_t a);

/**
 * Print algebra tree in AT&T dot notation.
 * @param dot Array into which we print
 * @param n The current node to print (function is recursive)
 * @param node Name of the parent node.
 */
static void 
pa_dot (PFarray_t *dot, PFpa_op_t *n, char *node)
{
    unsigned int c;
    static int node_id = 1;

    static char *color[] = {
          [pa_serialize]       = "\"#C0C0C0\""
        , [pa_lit_tbl]         = "\"#C0C0C0\""
        , [pa_empty_tbl]       = "\"#C0C0C0\""
        , [pa_attach]          = "\"#EEEEEE\""
        , [pa_cross]           = "\"#990000\""
        , [pa_leftjoin]        = "\"#00FF00\""
        , [pa_eqjoin]          = "\"#00FF00\""
        , [pa_project]         = "\"#EEEEEE\""
        , [pa_select]          = "\"#00DDDD\""
        , [pa_append_union]    = "\"#909090\""
        , [pa_merge_union]     = "\"#909090\""
        , [pa_intersect]       = "\"#FFA500\""
        , [pa_difference]      = "\"#FFA500\""
        , [pa_sort_distinct]   = "\"#FFA500\""
        , [pa_std_sort]        = "red"
        , [pa_refine_sort]     = "red"
        , [pa_num_add]         = "\"#C0C0C0\""
        , [pa_num_add_atom]    = "\"#C0C0C0\""
        , [pa_num_sub]         = "\"#C0C0C0\""
        , [pa_num_sub_atom]    = "\"#C0C0C0\""
        , [pa_num_mult]        = "\"#C0C0C0\""
        , [pa_num_mult_atom]   = "\"#C0C0C0\""
        , [pa_num_div]         = "\"#C0C0C0\""
        , [pa_num_div_atom]    = "\"#C0C0C0\""
        , [pa_num_mod]         = "\"#C0C0C0\""
        , [pa_num_mod_atom]    = "\"#C0C0C0\""
        , [pa_eq]              = "\"#00DDDD\""
        , [pa_eq_atom]         = "\"#00DDDD\""
        , [pa_gt]              = "\"#00DDDD\""
        , [pa_gt_atom]         = "\"#00DDDD\""
        , [pa_num_neg]         = "\"#C0C0C0\""
        , [pa_bool_not]        = "\"#C0C0C0\""
        , [pa_bool_and]        = "\"#C0C0C0\""
        , [pa_bool_or]         = "\"#C0C0C0\""
        , [pa_bool_and_atom]   = "\"#C0C0C0\""
        , [pa_bool_or_atom]    = "\"#C0C0C0\""
        , [pa_avg]             = "\"#A0A0A0\""
        , [pa_max]             = "\"#A0A0A0\""
        , [pa_min]             = "\"#A0A0A0\""
        , [pa_sum]             = "\"#A0A0A0\""
        , [pa_hash_count]      = "\"#A0A0A0\""
        , [pa_hash_rownum]     = "\"#FF0000\""
        , [pa_merge_rownum]    = "\"#FF0000\""
        , [pa_number]          = "\"#FF9999\""
        , [pa_type]            = "\"#C0C0C0\""
        , [pa_type_assert]     = "\"#C0C0C0\""
        , [pa_cast]            = "\"#C0C0C0\""
        , [pa_llscj_anc]       = "\"#1E90FF\""
        , [pa_llscj_anc_self]  = "\"#1E90FF\""
        , [pa_llscj_attr]      = "\"#1E90FF\""
        , [pa_llscj_child]     = "\"#1E90FF\""
        , [pa_llscj_desc]      = "\"#1E90FF\""
        , [pa_llscj_desc_self] = "\"#1E90FF\""
        , [pa_llscj_foll]      = "\"#1E90FF\""
        , [pa_llscj_foll_sibl] = "\"#1E90FF\""
        , [pa_llscj_parent]    = "\"#1E90FF\""
        , [pa_llscj_prec]      = "\"#1E90FF\""
        , [pa_llscj_prec_sibl] = "\"#1E90FF\""
        , [pa_doc_tbl]         = "\"#C0C0C0\""
        , [pa_doc_access]      = "\"#CCCCFF\""
        , [pa_element]         = "\"#00FC59\""
        , [pa_element_tag]     = "\"#00FC59\""
        , [pa_attribute]       = "\"#00FC59\""
        , [pa_textnode]        = "\"#00FC59\""
        , [pa_docnode]         = "\"#00FC59\""
        , [pa_comment]         = "\"#00FC59\""
        , [pa_processi]        = "\"#00FC59\""
        , [pa_merge_adjacent]  = "\"#00D000\""
        , [pa_roots]           = "\"#E0E0E0\""
        , [pa_fragment]        = "\"#E0E0E0\""
        , [pa_frag_union]      = "\"#E0E0E0\""
        , [pa_empty_frag]      = "\"#E0E0E0\""
        , [pa_cond_err]        = "\"#C0C0C0\""
        , [pa_concat]          = "\"#C0C0C0\""
        , [pa_contains]        = "\"#C0C0C0\""
        , [pa_string_join]     = "\"#C0C0C0\""
    };

    n->node_id = node_id;
    node_id++;

    /* open up label */
    PFarray_printf (dot, "%s [label=\"", node);

    /* create label */
    switch (n->kind)
    {
        case pa_lit_tbl:
            /* list the attributes of this table */
            PFarray_printf (dot, "%s: (%s", a_id[n->kind],
                            PFatt_str (n->schema.items[0].name));

            for (c = 1; c < n->schema.count;c++)
                PFarray_printf (dot, " | %s", 
                                PFatt_str (n->schema.items[c].name));

            PFarray_printf (dot, ")");

            /* print out tuples in table, if table is not empty */
            for (unsigned int d = 0; d < n->sem.lit_tbl.count; d++) {
                PFarray_printf (dot, "\\n[");
                for (c = 0; c < n->sem.lit_tbl.tuples[d].count; c++) {
                    PFarray_printf (
                            dot, "%s%s",
                            c == 0 ? "" : ",",
                            literal (n->sem.lit_tbl.tuples[d].atoms[c]));
                }
                PFarray_printf (dot, "]");
            }
            break;

        case pa_empty_tbl:
            /* list the attributes of this table */
            PFarray_printf (dot, "%s: (%s", a_id[n->kind],
                            PFatt_str (n->schema.items[0].name));

            for (c = 1; c < n->schema.count;c++)
                PFarray_printf (dot, " | %s", 
                                PFatt_str (n->schema.items[c].name));

            PFarray_printf (dot, ")");
            break;

        case pa_attach:
            PFarray_printf (dot, "%s (%s), val: %s", a_id[n->kind],
                            PFatt_str (n->sem.attach.attname),
                            literal (n->sem.attach.value));
            break;

        case pa_leftjoin:
        case pa_eqjoin:
            PFarray_printf (dot, "%s: (%s= %s)", a_id[n->kind],
                            PFatt_str (n->sem.eqjoin.att1),
                            PFatt_str (n->sem.eqjoin.att2));
            break;

        case pa_project:
            if (n->sem.proj.items[0].new != n->sem.proj.items[0].old)
                PFarray_printf (dot, "%s (%s:%s", a_id[n->kind],
                                PFatt_str (n->sem.proj.items[0].new),
                                PFatt_str (n->sem.proj.items[0].old));
            else
                PFarray_printf (dot, "%s (%s", a_id[n->kind],
                                PFatt_str (n->sem.proj.items[0].old));

            for (c = 1; c < n->sem.proj.count; c++)
                if (n->sem.proj.items[c].new != n->sem.proj.items[c].old)
                    PFarray_printf (dot, ",%s:%s",
                                    PFatt_str (n->sem.proj.items[c].new),
                                    PFatt_str (n->sem.proj.items[c].old));
                else
                    PFarray_printf (dot, ",%s", 
                                    PFatt_str (n->sem.proj.items[c].old));

            PFarray_printf (dot, ")");
            break;

        case pa_select:
            PFarray_printf (dot, "%s (%s)", a_id[n->kind],
                            PFatt_str (n->sem.select.att));
            break;

        case pa_merge_union:
            PFarray_printf (dot, "%s: (%s)", a_id[n->kind],
                            PFord_str (n->sem.merge_union.ord));
            break;

        case pa_sort_distinct:
            PFarray_printf (dot, "%s: (%s)", a_id[n->kind],
                            PFord_str (n->sem.sort_distinct.ord));
            break;

        case pa_std_sort:
        case pa_refine_sort:
            PFarray_printf (dot, "%s: (%s)", a_id[n->kind],
                            PFord_str (n->sem.sortby.required));
            break;

        case pa_num_add:
        case pa_num_sub:
        case pa_num_mult:
        case pa_num_div:
        case pa_num_mod:
        case pa_eq:
        case pa_gt:
        case pa_bool_and:
        case pa_bool_or:
        case pa_concat:
        case pa_contains:
            PFarray_printf (dot, "%s (%s:<%s, %s>)", a_id[n->kind],
                            PFatt_str (n->sem.binary.res),
                            PFatt_str (n->sem.binary.att1),
                            PFatt_str (n->sem.binary.att2));
            break;

        case pa_num_add_atom:
        case pa_num_sub_atom:
        case pa_num_mult_atom:
        case pa_num_div_atom:
        case pa_num_mod_atom:
        case pa_eq_atom:
        case pa_gt_atom:
        case pa_bool_and_atom:
        case pa_bool_or_atom:
            PFarray_printf (dot, "%s (%s:<%s, %s>)", a_id[n->kind],
                            PFatt_str (n->sem.bin_atom.res),
                            PFatt_str (n->sem.bin_atom.att1),
                            literal (n->sem.bin_atom.att2));
            break;

        case pa_num_neg:
        case pa_bool_not:
            PFarray_printf (dot, "%s (%s:<%s>)", a_id[n->kind],
                            PFatt_str (n->sem.unary.res),
                            PFatt_str (n->sem.unary.att));
            break;

        case pa_hash_count:
            if (n->sem.count.part == att_NULL)
                PFarray_printf (dot, "%s (%s)", a_id[n->kind],
                                PFatt_str (n->sem.count.res));
            else
                PFarray_printf (dot, "%s (%s:/%s)", a_id[n->kind],
                                PFatt_str (n->sem.count.res),
                                PFatt_str (n->sem.count.part));
            break;

        case pa_avg:
        case pa_max:
        case pa_min:
        case pa_sum:
            if (n->sem.aggr.part == att_NULL)
                PFarray_printf (dot, "%s (%s:<%s>)", a_id[n->kind],
                                PFatt_str (n->sem.aggr.res),
                                PFatt_str (n->sem.aggr.att));
            else
                PFarray_printf (dot, "%s (%s:<%s>/%s)", a_id[n->kind],
                                PFatt_str (n->sem.aggr.res),
                                PFatt_str (n->sem.aggr.att),
                                PFatt_str (n->sem.aggr.part));
            break;

        case pa_hash_rownum:
        case pa_merge_rownum:
            if (n->sem.count.part != att_NULL)
                PFarray_printf (dot, "%s (%s:/%s)", a_id[n->kind],
                                PFatt_str (n->sem.rownum.attname),
                                PFatt_str (n->sem.rownum.part));
            else
                PFarray_printf (dot, "%s (%s)", a_id[n->kind],
                                PFatt_str (n->sem.rownum.attname));
            break;

        case pa_number:
            PFarray_printf (dot, "%s (%s", a_id[n->kind],
                            PFatt_str (n->sem.number.attname));
            if (n->sem.number.part != att_NULL)
                PFarray_printf (dot, "/%s", 
                                PFatt_str (n->sem.number.part));

            PFarray_printf (dot, ")");
            break;

        case pa_type:
            if (atomtype[n->sem.type.ty])
                PFarray_printf (dot, "%s (%s:<%s>), type: %s", a_id[n->kind],
                                PFatt_str (n->sem.type.res),
                                PFatt_str (n->sem.type.att),
                                atomtype[n->sem.type.ty]);
            else
                PFarray_printf (dot, "%s (%s:<%s>), type: %i", a_id[n->kind],
                                PFatt_str (n->sem.type.res),
                                PFatt_str (n->sem.type.att),
                                n->sem.type.ty);
            break;

        case pa_type_assert:
            if (atomtype[n->sem.type_a.ty])
                PFarray_printf (dot, "%s (%s), type: %s", a_id[n->kind],
                                PFatt_str (n->sem.type_a.att),
                                atomtype[n->sem.type_a.ty]);
            else
                PFarray_printf (dot, "%s (%s), type: %i", a_id[n->kind],
                                PFatt_str (n->sem.type_a.att),
                                n->sem.type_a.ty);
                
            break;

        case pa_cast:
            PFarray_printf (dot, "%s (%s%s%s%s), type: %s", a_id[n->kind],
                            n->sem.cast.res?PFatt_str(n->sem.cast.res):"",
                            n->sem.cast.res?":<":"",
                            PFatt_str (n->sem.cast.att),
                            n->sem.cast.res?">":"",
                            atomtype[n->sem.cast.ty]);
            break;

        case pa_llscj_anc:
        case pa_llscj_anc_self:
        case pa_llscj_attr:
        case pa_llscj_child:
        case pa_llscj_desc:
        case pa_llscj_desc_self:
        case pa_llscj_foll:
        case pa_llscj_foll_sibl:
        case pa_llscj_parent:
        case pa_llscj_prec:
        case pa_llscj_prec_sibl:
            PFarray_printf (dot, "%s", a_id[n->kind]);
            PFarray_printf (dot, "::%s", PFty_str (n->sem.scjoin.ty));
            break;

        case pa_doc_access:
            PFarray_printf (dot, "%s ", a_id[n->kind]);

            switch (n->sem.doc_access.doc_col)
            {
                case doc_atext:
                    PFarray_printf (dot, "attribute value");
                    break;
                case doc_text:
                    PFarray_printf (dot, "textnode content");
                    break;
                case doc_comm:
                    PFarray_printf (dot, "comment text");
                    break;
                case doc_pi_text:
                    PFarray_printf (dot, "processing instruction");
                    break;
                default: PFoops (OOPS_FATAL,
                        "unknown document access in dot output");
            }

            PFarray_printf (dot, " (%s:<%s>)",
                            PFatt_str (n->sem.doc_access.res),
                            PFatt_str (n->sem.doc_access.att));
            break;

        case pa_attribute:
            PFarray_printf (dot, "%s (%s:<%s, %s>)", a_id[n->kind],
                            PFatt_str (n->sem.attr.res),
                            PFatt_str (n->sem.attr.qn),
                            PFatt_str (n->sem.attr.val));
            break;

        case pa_textnode:
            PFarray_printf (dot, "%s (%s:<%s>)", a_id[n->kind],
                            PFatt_str (n->sem.textnode.res),
                            PFatt_str (n->sem.textnode.item));
            break;

        case pa_cond_err:
            PFarray_printf (dot, "%s (%s)\\n%s ...", a_id[n->kind],
                            PFatt_str (n->sem.err.att),
                            PFstrndup (n->sem.err.str, 16));
            break;

        case pa_serialize:
        case pa_cross:
        case pa_append_union:
        case pa_intersect:
        case pa_difference:
        case pa_doc_tbl:
        case pa_element:
        case pa_element_tag:
        case pa_docnode:
        case pa_comment:
        case pa_processi:
        case pa_merge_adjacent:
        case pa_roots:
        case pa_fragment:
        case pa_frag_union:
        case pa_empty_frag:
        case pa_string_join:
            PFarray_printf (dot, "%s", a_id[n->kind]);
            break;
    }

    if (PFstate.format) {

        char *fmt = PFstate.format;
        bool all = false;

        while (*fmt) { 
            if (*fmt == '+')
            {
                PFalg_attlist_t icols = PFprop_icols_to_attlist (n->prop);
                PFalg_attlist_t keys = PFprop_keys_to_attlist (n->prop);

                /* list costs if requested */
                PFarray_printf (dot, "\\ncost: %lu", n->cost);

                /* if present print cardinality */
                if (PFprop_card (n->prop))
                    PFarray_printf (dot, "\\ncard: %i", PFprop_card (n->prop));

                /* list attributes marked const */
                for (unsigned int i = 0;
                        i < PFprop_const_count (n->prop); i++)
                    PFarray_printf (dot, i ? ", %s" : "\\nconst: %s",
                                    PFatt_str (
                                        PFprop_const_at (n->prop, i)));

                /* list icols attributes */
                for (unsigned int i = 0; i < icols.count; i++)
                    PFarray_printf (dot, i ? ", %s" : "\\nicols: %s",
                                    PFatt_str (icols.atts[i]));

                /* list keys attributes */
                for (unsigned int i = 0; i < keys.count; i++)
                    PFarray_printf (dot, i ? ", %s" : "\\nkeys: %s",
                                    PFatt_str (keys.atts[i]));

                /* list required value columns and their values */
                for (unsigned int pre = 0, i = 0; i < n->schema.count; i++) {
                    PFalg_att_t att = n->schema.items[i].name;
                    if (PFprop_reqval (n->prop, att))
                        PFarray_printf (
                            dot, 
                            pre++ ? ", %s=%s " : "\\nreq. val: %s=%s ",
                            PFatt_str (att),
                            PFprop_reqval_val (n->prop, att)?"true":"false");
                }

                /* list attributes and their corresponding domains */
                for (unsigned int i = 0; i < n->schema.count; i++)
                    if (PFprop_dom (n->prop, n->schema.items[i].name)) {
                        PFarray_printf (dot, i ? ", %s " : "\\ndom: %s ",
                                        PFatt_str (n->schema.items[i].name));
                        PFprop_write_domain (
                            dot, 
                            PFprop_dom (n->prop, n->schema.items[i].name));
                    }

                /* list orderings if requested */
                PFarray_printf (dot, "\\norderings:");
                for (unsigned int i = 0;
                        i < PFarray_last (n->orderings); i++)
                    PFarray_printf (
                            dot, "\\n%s",
                            PFord_str (
                                *(PFord_ordering_t *)
                                        PFarray_at (n->orderings,i)));

                all = true;
            }
            fmt++;
        }
        fmt = PFstate.format;

        while (!all && *fmt) {
            switch (*fmt) {

                /* list costs if requested */
                case 'C':
                    PFarray_printf (dot, "\\ncost: %lu", n->cost);
                    break;

                /* list attributes marked const if requested */
                case 'c':
                    for (unsigned int i = 0;
                            i < PFprop_const_count (n->prop); i++)
                        PFarray_printf (dot, i ? ", %s" : "\\nconst: %s",
                                        PFatt_str (
                                            PFprop_const_at (n->prop, i)));
                    break;

                /* list icols attributes if requested */
                case 'i':
                {
                    PFalg_attlist_t icols =
                                    PFprop_icols_to_attlist (n->prop);
                    for (unsigned int i = 0;
                            i < icols.count; i++)
                        PFarray_printf (dot, i ? ", %s" : "\\nicols: %s",
                                        PFatt_str (icols.atts[i]));
                } break;

                /* list orderings if requested */
                case 'o':
                    PFarray_printf (dot, "\\norderings:");
                    for (unsigned int i = 0;
                            i < PFarray_last (n->orderings); i++)
                        PFarray_printf (
                                dot, "\\n%s",
                                PFord_str (
                                    *(PFord_ordering_t *)
                                            PFarray_at (n->orderings,i)));
                    break;
            }
            fmt++;
        }
    }

    /* close up label */
    PFarray_printf (dot, "\", color=%s ];\n", color[n->kind]);

    for (c = 0; c < PFPA_OP_MAXCHILD && n->child[c] != 0; c++) {      
        child = (char *) PFmalloc (sizeof ("node4294967296"));

        /*
         * Label for child node has already been built, such that
         * only the edge between parent and child must be created
         */
        if (n->child[c]->node_id != 0) {
            sprintf (child, "node%i", n->child[c]->node_id);
            PFarray_printf (dot, "%s -> %s;\n", node, child);
        }
        else {
            sprintf (child, "node%i", node_id);
            PFarray_printf (dot, "%s -> %s;\n", node, child);

            pa_dot (dot, n->child[c], child);
        }
    }
}

static char *
literal (PFalg_atom_t a)
{
    PFarray_t *s = PFarray (sizeof (char));

    if (a.special == amm_min)
        return "MIN";
    else if (a.special == amm_max)
        return "MAX";

    switch (a.type) {

        case aat_nat:
            PFarray_printf (s, "#%u", a.val.nat);
            break;

        case aat_int:
            PFarray_printf (s, "%i", a.val.int_);
            break;
            
        case aat_str:
        case aat_uA:
            PFarray_printf (s, "\\\"%s\\\"", a.val.str);
            break;

        case aat_dec:
            PFarray_printf (s, "%g", a.val.dec);
            break;

        case aat_dbl:
            PFarray_printf (s, "%g", a.val.dbl);
            break;

        case aat_bln:
            PFarray_printf (s, a.val.bln ? "true" : "false");
            break;

        default:
            PFarray_printf (s, "?");
            break;
    }

    return (char *) s->base;
}


/**
 * Dump physical algebra tree in AT&T dot format
 * (pipe the output through `dot -Tps' to produce a Postscript file).
 *
 * @param f file to dump into
 * @param root root of abstract syntax tree
 */
void
PFpa_dot (FILE *f, PFpa_op_t *root)
{
    if (root) {
        /* initialize array to hold dot output */
        PFarray_t *dot = PFarray (sizeof (char));

        PFarray_printf (dot, "digraph XQueryPhysicalAlgebra {\n"
                             "ordering=out;\n"
                             "node [shape=box];\n"
                             "node [height=0.1];\n"
                             "node [width=0.2];\n"
                             "node [style=filled];\n"
                             "node [color=\"#C0C0C0\"];\n"
                             "node [fontsize=10];\n");

        pa_dot (dot, root, "node1");

        /* add domain subdomain relationships if required */
        if (PFstate.format) {
            char *fmt = PFstate.format;
            while (*fmt) { 
                if (*fmt == '+') {
                        PFprop_write_dom_rel_dot (dot, root->prop);
                        break;
                }
                fmt++;
            }
        }

        /* put content of array into file */
        PFarray_printf (dot, "}\n");
        fprintf (f, "%s", (char *) dot->base);
    }
}

/* vim:set shiftwidth=4 expandtab: */
