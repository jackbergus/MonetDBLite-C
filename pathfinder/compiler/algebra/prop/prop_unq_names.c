/**
 * @file
 *
 * Inference of unique column names in logical algebra expressions.
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
#include <stdio.h>

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
/** starting from p, make a step right, then a step left */
#define RL(p) L(R(p))

/* worker for PFprop_unq_name* */
static PFalg_att_t
find_unq_name (PFarray_t *np_list, PFalg_att_t attr)
{
    if (!np_list) return 0;

    for (unsigned int i = 0; i < PFarray_last (np_list); i++)
        if (attr == ((name_pair_t *) PFarray_at (np_list, i))->ori)
            return ((name_pair_t *) PFarray_at (np_list, i))->unq;

    return 0;
}

/**
 * Return unique name of attribute @a attr stored
 * in property container @a prop.
 */
PFalg_att_t
PFprop_unq_name (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);
    return find_unq_name (prop->name_pairs, attr);
}

/**
 * Return unique name of attribute @a attr stored
 * in the left name mapping field of property container @a prop.
 */
PFalg_att_t
PFprop_unq_name_left (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);
    return  find_unq_name (prop->l_name_pairs, attr);
}

/**
 * Return unique name of attribute @a attr stored
 * in the right name mapping field of property container @a prop.
 */
PFalg_att_t
PFprop_unq_name_right (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);
    return  find_unq_name (prop->r_name_pairs, attr);
}

/**
 * Add a new original name/unique name pair to the list of name pairs
 * (@a np_list).
 */
static void
add_name_pair (PFarray_t *np_list, PFalg_att_t ori, PFalg_att_t unq)
{
    assert (np_list);
    
    *(name_pair_t *) PFarray_add (np_list)
        = (name_pair_t) { .ori = ori, .unq = unq };
}

/**
 * Create new unique name and add it together with the original name
 * to the name pair list (@a np_list).
 */ 
static void
new_name_pair (PFarray_t *np_list, PFalg_att_t ori, unsigned int id)
{
    add_name_pair (np_list, ori, PFalg_unq_name (ori, id));
}

/**
 * Add all original name/unique name pairs of the node @a child to
 * the list of name pairs (@a np_list).
 */
static void
bulk_add_name_pairs (PFarray_t *np_list, PFla_op_t *child)
{
    assert (np_list);
    assert (child);
    assert (child->prop);

    for (unsigned int i = 0; i < child->schema.count; i++) {
        add_name_pair (np_list, 
                       child->schema.items[i].name,
                       PFprop_unq_name (child->prop,
                                        child->schema.items[i].name));
    }
}

/**
 * Infer unique name properties; worker for prop_infer().
 */
static unsigned int
infer_unq_names (PFla_op_t *n, unsigned int id)
{
    PFarray_t *np_list = n->prop->name_pairs;

    switch (n->kind) {
        case la_serialize:
            bulk_add_name_pairs (np_list, R(n));
            break;

        case la_lit_tbl:
        case la_empty_tbl:
            /* create new unique names for all attributes */
            for (unsigned int i = 0; i < n->schema.count; i++)
                new_name_pair (np_list, n->schema.items[i].name, id++);
            break;
            
        case la_attach:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.attach.attname, id++);
            break;

        case la_cross:
        {
            /* To avoid name collisions that arise from applying
               a cross product on input relations with identical
               names we create new attribute names.
               The correspondence between the unique names of the
               operands and the new unique names is stored in
               a list of name pairs for each operand. */
            PFalg_att_t ori, ori_prev, unq, child_unq;
            PFarray_t *left_np_list, *right_np_list;

            /* initialize left and right name pair list */
            n->prop->l_name_pairs = PFarray (sizeof (name_pair_t));
            n->prop->r_name_pairs = PFarray (sizeof (name_pair_t));
            
            left_np_list  = n->prop->l_name_pairs;
            right_np_list = n->prop->r_name_pairs;
            
            for (unsigned int i = 0; i < L(n)->schema.count; i++) {
                ori = L(n)->schema.items[i].name;
                child_unq = PFprop_unq_name (L(n)->prop, ori);
                
                /* Check for multiple occurrences of the same unique
                   column name. (Use check function of variable
                   backmapping as it works on the same array) */
                if ((ori_prev = PFprop_ori_name_left (n->prop, child_unq)))
                    /* we already have mapped this unique name
                       - so look up new unique name */
                    unq = find_unq_name (np_list, ori_prev);
                else
                    /* no match */
                    unq = PFalg_unq_name (ori, id++);

                add_name_pair (np_list, ori, unq);
                add_name_pair (left_np_list, ori, child_unq);
            }
            for (unsigned int i = 0; i < R(n)->schema.count; i++) {
                ori = R(n)->schema.items[i].name;
                child_unq = PFprop_unq_name (R(n)->prop, ori);

                /* Check for multiple occurrences of the same unique
                   column name. (Use check function of variable
                   backmapping as it works on the same array) */
                if ((ori_prev = PFprop_ori_name_right (n->prop, child_unq)))
                    /* we already have mapped this unique name 
                       - so look up new unique name */
                    unq = find_unq_name (np_list, ori_prev);
                else
                    /* no match */
                    unq = PFalg_unq_name (ori, id++);
                                           
                add_name_pair (np_list, ori, unq);
                add_name_pair (right_np_list, ori, child_unq);
            }
        }   break;

        case la_eqjoin:
        {
            PFalg_att_t ori, join_unq, att1_unq, att2_unq, child_unq;
            PFarray_t *left_np_list, *right_np_list;

            att1_unq = PFprop_unq_name (L(n)->prop, n->sem.eqjoin.att1);
            att2_unq = PFprop_unq_name (R(n)->prop, n->sem.eqjoin.att2);
            /* always use smaller (hopefully original) unique name
               as name of the both join arguments */
            if (att1_unq <= att2_unq)
                join_unq = att1_unq;
            else
                join_unq = att2_unq;

            /* initialize left and right name pair list */
            n->prop->l_name_pairs = PFarray (sizeof (name_pair_t));
            n->prop->r_name_pairs = PFarray (sizeof (name_pair_t));
            
            left_np_list  = n->prop->l_name_pairs;
            right_np_list = n->prop->r_name_pairs;
            
            for (unsigned int i = 0; i < L(n)->schema.count; i++) {
                ori = L(n)->schema.items[i].name;
                child_unq = PFprop_unq_name (L(n)->prop, ori);

                /* Inside a relation we don't have any naming
                   conflicts and thus only have to assign new
                   names for all columns that are identical to
                   the join argument column */
                if (child_unq == att1_unq)
                    add_name_pair (np_list, ori, join_unq);
                else
                    add_name_pair (np_list, ori, child_unq);

                add_name_pair (left_np_list, ori, child_unq);
            }

            for (unsigned int i = 0; i < R(n)->schema.count; i++) {
                ori = R(n)->schema.items[i].name;
                child_unq = PFprop_unq_name (R(n)->prop, ori);

                /* In comparison to the first argument we may
                   now hit some equally named columns even if they
                   are not identical to the second join argument
                   column. In this case we rename the conflicting
                   columns by introducing a new unique name. */
                if (child_unq == att2_unq)
                    add_name_pair (np_list, ori, join_unq);
                else if (PFprop_ori_name_left (n->prop, child_unq)) {
                    PFalg_att_t ori_prev, unq;

                    /* like in the cross product case we map equally
                       named conflicting names to the same replacement */
                    if ((ori_prev = PFprop_ori_name_right (n->prop, 
                                                           child_unq)))
                        /* we already have mapped this unique name 
                           - so look up new unique name */
                        unq = find_unq_name (np_list, ori_prev);
                    else
                        /* no match */
                        unq = PFalg_unq_name (ori, id++);

                    add_name_pair (np_list, ori, unq);
                }
                else
                    add_name_pair (np_list, ori, child_unq);

                add_name_pair (right_np_list, ori, child_unq);
            }
        }   break;

        case la_project:
            /* bind all existing unique names to the possibly new names */
            for (unsigned int i = 0; i < n->schema.count; i++)
                add_name_pair (np_list, 
                               n->sem.proj.items[i].new, 
                               PFprop_unq_name (L(n)->prop,
                                                n->sem.proj.items[i].old));
            break;

        case la_select:
        case la_distinct:
            bulk_add_name_pairs (np_list, L(n));
            break;
            
        case la_disjunion:
        case la_intersect:
        case la_difference:
        {
            /* To avoid name collisions that arise from applying
               a set operation on input relations with identical
               names we create new attribute names.
               The correspondence between the unique names of the
               operands and the new unique names is stored in
               a list of name pairs for each operand. */
            PFalg_att_t ori, unq, l_unq, r_unq;

            n->prop->l_name_pairs = PFarray (sizeof (name_pair_t));
            n->prop->r_name_pairs = PFarray (sizeof (name_pair_t));

            for (unsigned int i = 0; i < n->schema.count; i++) {
                ori = n->schema.items[i].name;
                l_unq = PFprop_unq_name (L(n)->prop, ori);
                r_unq = PFprop_unq_name (R(n)->prop, ori);

                /* maintain unique name if it the same for both operands */
                /*
                if (n->kind == la_disjunion && l_unq == r_unq)
                    unq = l_unq;
                else
                */
                    unq = PFalg_unq_name (ori, id++);
                    
                add_name_pair (np_list, ori, unq);
                add_name_pair (n->prop->l_name_pairs, ori, l_unq);
                add_name_pair (n->prop->r_name_pairs, ori, r_unq);
            }
        }   break;

        case la_num_add:
        case la_num_subtract:
        case la_num_multiply:
        case la_num_divide:
        case la_num_modulo:
        case la_num_eq:
        case la_num_gt:
        case la_bool_and:
        case la_bool_or:
        case la_concat:
        case la_contains:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.binary.res, id++);
            break;

        case la_num_neg:
        case la_bool_not:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.unary.res, id++);
            break;

        case la_avg:
	case la_max:
	case la_min:
        case la_sum:
        case la_count:
        case la_seqty1:
        case la_all:
            new_name_pair (np_list, n->sem.aggr.res, id++);
            if (n->sem.aggr.part)
                add_name_pair (np_list,
                               n->sem.aggr.part, 
                               PFprop_unq_name (L(n)->prop,
                                                n->sem.aggr.part));
            break;

        case la_rownum:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.rownum.attname, id++);
            break;

        case la_number:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.number.attname, id++);
            break;

        case la_type:
        case la_cast:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.type.res, id++);
            break;

        case la_type_assert:
            bulk_add_name_pairs (np_list, L(n));
            break;

        case la_scjoin:
            add_name_pair (np_list, 
                           n->sem.scjoin.iter,
                           PFprop_unq_name (R(n)->prop,
                                            n->sem.scjoin.iter));
            new_name_pair (np_list, n->sem.scjoin.item_res, id++);
            break;
            
        case la_doc_tbl:
            add_name_pair (np_list,
                           n->sem.doc_tbl.iter,
                           PFprop_unq_name (L(n)->prop,
                                            n->sem.doc_tbl.iter));
            new_name_pair (np_list, n->sem.doc_tbl.item_res, id++);
            break;
            
        case la_doc_access:
            bulk_add_name_pairs (np_list, R(n));
            new_name_pair (np_list, n->sem.doc_access.res, id++);
            break;

        case la_element:
            add_name_pair (np_list,
                           n->sem.elem.iter_res,
                           PFprop_unq_name (RL(n)->prop, 
                                            n->sem.elem.iter_qn));
            new_name_pair (np_list, n->sem.elem.item_res, id++);
            break;
        
        case la_element_tag:
            break;
            
        case la_attribute:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.attr.res, id++);
            break;

        case la_textnode:
            bulk_add_name_pairs (np_list, L(n));
            new_name_pair (np_list, n->sem.textnode.res, id++);
            break;

        case la_docnode:
        case la_comment:
        case la_processi:
            break;
            
        case la_merge_adjacent:
            add_name_pair (np_list,
                           n->sem.merge_adjacent.iter_res,
                           PFprop_unq_name (R(n)->prop, 
                                            n->sem.merge_adjacent.iter_in));
            add_name_pair (np_list,
                           n->sem.merge_adjacent.pos_res,
                           PFprop_unq_name (R(n)->prop, 
                                            n->sem.merge_adjacent.pos_in));
            new_name_pair (np_list, n->sem.merge_adjacent.item_res, id++);
            break;
            
        case la_roots:
            bulk_add_name_pairs (np_list, L(n));
            break;

        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
            break;
            
        case la_cond_err:
            bulk_add_name_pairs (np_list, L(n));
            break;

        case la_string_join:
            add_name_pair (np_list,
                           n->sem.string_join.iter_res,
                           PFprop_unq_name (R(n)->prop,
                                            n->sem.string_join.iter_sep));
            new_name_pair (np_list, n->sem.string_join.item_res, id++);
            break;

        case la_cross_mvd:
            PFoops (OOPS_FATAL,
                    "clone column aware cross product operator is "
                    "only allowed inside mvd optimization!");
        case la_eqjoin_unq:
            PFoops (OOPS_FATAL,
                    "clone column aware equi-join operator is "
                    "only allowed with unique attribute names!");
    }
    return id;
}

/* worker for PFprop_infer_unq_names */
static unsigned int
prop_infer (PFla_op_t *n, unsigned int cur_col_id)
{
    assert (n);

    /* nothing to do if we already visited that node */
    if (n->bit_dag)
        return cur_col_id;

    /* infer properties for children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
        cur_col_id = prop_infer (n->child[i], cur_col_id);

    n->bit_dag = true;

    /* reset the unique name information */
    n->prop->name_pairs = PFarray (sizeof (name_pair_t));
    n->prop->l_name_pairs = NULL;
    n->prop->r_name_pairs = NULL;
    
    /* infer unique name columns */
    cur_col_id = infer_unq_names (n, cur_col_id);

    return cur_col_id;
}

/**
 * Infer unique names for a DAG rooted in root
 */
void
PFprop_infer_unq_names (PFla_op_t *root)
{
    prop_infer (root, 1);
    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
