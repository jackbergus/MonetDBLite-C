/**
 * @file
 *
 * Inference of cardinality property of logical algebra expressions.
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

/* always include pathfinder.h first! */
#include "pathfinder.h"
#include <assert.h>

#include "properties.h"
#include "alg_dag.h"
#include "oops.h"
#include "mem.h"

/*
 * Easily access subtree-parts.
 */
/** starting from p, make a step left */
#define L(p) ((p)->child[0])
/** starting from p, make a step right */
#define R(p) ((p)->child[1])

/**
 * Return cardinality stored in property container @a prop.
 */
unsigned int
PFprop_card (const PFprop_t *prop)
{
    assert (prop);

    return prop->card;
}

/**
 * Infer properties about cardinalities; worker for prop_infer().
 */
static void
infer_card (PFla_op_t *n)
{
    /*
     * Several operates (at least) propagate constant columns
     * to their output 1:1.
     */
    switch (n->kind) {
        case la_serialize:
        case la_doc_access:
        case la_element:
            /* cardinality stays the same */
            n->prop->card = R(n)->prop->card;
            break;

        case la_lit_tbl:
            /* number of tuples */
            n->prop->card = n->sem.lit_tbl.count;
            break;

        case la_empty_tbl:
            /* zero tuples */
            n->prop->card = 0;
            break;

        case la_attach:
        case la_project:
        case la_num_add:
        case la_num_subtract:
        case la_num_multiply:
        case la_num_divide:
        case la_num_modulo:
        case la_num_eq:
        case la_num_gt:
        case la_num_neg:
        case la_bool_and:
        case la_bool_or:
        case la_bool_not:
        case la_rownum:
        case la_number:
        case la_type:
        case la_type_assert:
        case la_cast:
        case la_doc_tbl:
        case la_element_tag:
        case la_attribute:
        case la_textnode:
        case la_roots:
        case la_cond_err:
        case la_concat:
        case la_contains:
            /* cardinality stays the same */
            n->prop->card = L(n)->prop->card;
            break;

        case la_cross:
            /* multiply both children cardinalities */
            n->prop->card = L(n)->prop->card * R(n)->prop->card;
            break;

        case la_eqjoin:
        case la_select:
        case la_intersect:
        case la_difference:
        case la_distinct:
        case la_scjoin:
        case la_merge_adjacent:
        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
        case la_string_join:
            /* can't say something specific about cardinality */
            n->prop->card = 0;
            break;

        case la_disjunion:
            /* add cardinalities of both children if we know
               both of them */
            n->prop->card = L(n)->prop->card && R(n)->prop->card ?
                            L(n)->prop->card + R(n)->prop->card : 0;
            break;

        case la_avg:
	case la_max:
	case la_min:
        case la_sum:
            /* if part is not present the
               aggregation yields only one tuple */
            n->prop->card = n->sem.aggr.part ? 0 : 1;
            break;

        case la_count:
            /* if part is not present the
               aggregation yields only one tuple */
            n->prop->card = n->sem.count.part ? 0 : 1;
            break;

        case la_seqty1:
        case la_all:
            /* if part is not present the
               aggregation yields only one tuple */
            n->prop->card = n->sem.blngroup.part ? 0 : 1;
            break;

        case la_docnode:
        case la_comment:
        case la_processi:
            PFoops (OOPS_FATAL,
                    "no solution yet for cardinality "
                    "of remaining constructors");
            break;
    }
}

/* worker for PFprop_infer_card */
static void
prop_infer (PFla_op_t *n)
{
    assert (n);

    /* nothing to do if we already visited that node */
    if (n->bit_dag)
        return;

    /* infer properties for children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
        prop_infer (n->child[i]);

    n->bit_dag = true;

    /* infer information on constant columns */
    infer_card (n);
}

/**
 * Infer cardinality property for a DAG rooted in @a root
 */
void
PFprop_infer_card (PFla_op_t *root) {
    prop_infer (root);
    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
