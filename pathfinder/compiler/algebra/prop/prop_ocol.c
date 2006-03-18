/**
 * @file
 *
 * Inference of schema information (ocol property) of logical
 * algebra expressions.
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

/*
 * access ocol information
 */
#define ocols_count(p) (p)->schema.count
#define ocols(p)       (p)->schema
#define ocol_at(p,i)   (p)->schema.items[i]
#define new_ocols(p,i) ocols_count (p) = (i); \
                       (p)->schema.items = PFmalloc ((i) * \
                                           sizeof (*((p)->schema.items)))

/**
 * Test if @a attr is in the list of ocol columns of node @a n
 */
bool
PFprop_ocol (const PFla_op_t *n, PFalg_att_t attr)
{
    assert (n);

    for (unsigned int i = 0; i < n->schema.count; i++)
        if (attr == n->schema.items[i].name)
            return true;

    return false;
}

/**
 * worker for ocol property inference;
 * Copies schema using size as array size
 */
static PFalg_schema_t
copy_ocols (PFalg_schema_t ori, unsigned int size)
{
    PFalg_schema_t ret;

    assert (ori.count <= size);

    ret.items = PFmalloc (size * sizeof (*(ret.items)));
    ret.count = ori.count;

    for (unsigned int i = 0; i < ori.count; i++)
        ret.items[i] = ori.items[i];

    return ret;
}

/**
 * Infer schema (ocol property).
 * (schema inference should be aligned to logical.c)
 */
static void
infer_ocol (PFla_op_t *n)
{
    switch (n->kind)
    {
        case la_serialize:
            ocols (n) = copy_ocols (ocols (R(n)), ocols_count (R(n)));

        /* only a rewrite can change the ocol property
           - thus update schema (property) during rewrite */
        case la_lit_tbl:
        case la_empty_tbl:
            break;

        case la_attach:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.attach.attname;
            ocol_at (n, ocols_count (n)).type = n->sem.attach.value.type;
            ocols_count (n)++;
            break;

        case la_cross:
        case la_eqjoin:
            ocols (n) = copy_ocols (ocols (L(n)), 
                                    ocols_count (L(n)) +
                                    ocols_count (R(n)));
            for (unsigned int i = 0; i < ocols_count (R(n)); i++) {
                ocol_at (n, ocols_count(n)) = ocol_at (R(n), i);
                ocols_count (n)++;
            }
            break;
            
        case la_project:
        {
            PFarray_t *proj_list = PFarray (sizeof (PFalg_proj_t));

            /* prune projection list according to
               the ocols of its argument */
            for (unsigned int i = 0; i < n->sem.proj.count; i++)
                for (unsigned int j = 0; j < ocols_count (L(n)); j++)
                    if (n->sem.proj.items[i].old == 
                        ocol_at (L(n), j).name) {
                        *(PFalg_proj_t *) PFarray_add (proj_list)
                            = n->sem.proj.items[i];
                        break;
                    }

            /* allocate space for new ocol property and projection list */
            n->sem.proj.count = PFarray_last (proj_list);
            n->sem.proj.items = PFmalloc (n->sem.proj.count * 
                                          sizeof (*(n->sem.proj.items)));
            new_ocols (n, PFarray_last (proj_list));

            /* copy ocols and projection list during the second pass */
            for (unsigned int i = 0; i < PFarray_last (proj_list); i++)
                for (unsigned int j = 0; j < ocols_count (L(n)); j++)
                    if ((*(PFalg_proj_t *) PFarray_at (proj_list, i)).old ==
                        ocol_at (L(n), j).name) {
                        n->sem.proj.items[i] = 
                            *(PFalg_proj_t *) PFarray_at (proj_list, i);
                        (ocol_at (n, i)).type = (ocol_at (L(n), j)).type;
                        (ocol_at (n, i)).name = n->sem.proj.items[i].new;
                        break;
                    }

        } break;

        case la_select:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));
            break;

        case la_disjunion:
        {
            unsigned int  i, j;

            /* see if both operands have same number of attributes */
            if (ocols_count (L(n)) != ocols_count (R(n)))
                PFoops (OOPS_FATAL,
                        "Schema of two arguments of UNION do not match");

            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));

            /* combine types of the both arguments */
            for (i = 0; i < ocols_count (n); i++) {
                for (j = 0; j < ocols_count (R(n)); j++)
                    if ((ocol_at (n, i)).name == (ocol_at (R(n), j)).name) {
                        /* The two attributes match, so include their name
                         * and type information into the result. This allows
                         * for the order of schema items in n1 and n2 to be
                         * different.
                         */
                        (ocol_at (n, i)).type = (ocol_at (n, i)).type
                                                | (ocol_at (R(n), j)).type;
                        break;
                    }

                if (j == ocols_count (R(n)))
                    PFoops (OOPS_FATAL,
                            "Schema of two arguments of "
                            "UNION do not match");
            }
        } break;

        case la_intersect:
        {
            unsigned int  i, j;

            /* see if both operands have same number of attributes */
            if (ocols_count (L(n)) != ocols_count (R(n)))
                PFoops (OOPS_FATAL,
                        "Schema of two arguments of INTERSECTION do not match");

            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));

            /* combine types of the both arguments */
            for (i = 0; i < ocols_count (n); i++) {
                for (j = 0; j < ocols_count (R(n)); j++)
                    if ((ocol_at (n, i)).name == (ocol_at (R(n), j)).name) {
                        /* The two attributes match, so include their name
                         * and type information into the result. This allows
                         * for the order of schema items in n1 and n2 to be
                         * different.
                         */
                        (ocol_at (n, i)).type = (ocol_at (n, i)).type
                                                & (ocol_at (R(n), j)).type;
                        break;
                    }

                if (j == ocols_count (R(n)))
                    PFoops (OOPS_FATAL,
                            "Schema of two arguments of "
                            "INTERSECTION do not match");
            }
        } break;

        case la_difference:
        case la_distinct:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));
            break;

        case la_num_add:
        case la_num_subtract:
        case la_num_multiply:
        case la_num_divide:
        case la_num_modulo:
        {
            int ix1 = -1;
            int ix2 = -1;
            /* verify that 'att1' and 'att2' are attributes of n ... */
            for (unsigned int i = 0; i < ocols_count (L(n)); i++) {
                if (n->sem.binary.att1 == ocol_at (L(n), i).name)
                    ix1 = i;                /* remember array index of att1 */
                else if (n->sem.binary.att2 == ocol_at (L(n), i).name)
                    ix2 = i;                /* remember array index of att2 */
            }
            /* did we find attribute 'att1' and 'att2'? */
            if (ix1 < 0)
                PFoops (OOPS_FATAL,
                        "attribute `%s' referenced in binary operation "
                        "not found", PFatt_str (n->sem.binary.att1));
            else if (ix2 < 0)
                PFoops (OOPS_FATAL,
                        "attribute `%s' referenced in binary operation "
                        "not found", PFatt_str (n->sem.binary.att2));

            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.binary.res;
            ocol_at (n, ocols_count (n)).type = ocol_at (L(n), ix1).type;
            ocols_count (n)++;
        }
            break;

        case la_num_neg:
        {
            int ix = -1;
            /* verify that 'att1' and 'att2' are attributes of n ... */
            for (unsigned int i = 0; i < ocols_count (L(n)); i++) {
                if (n->sem.unary.att == ocol_at (L(n), i).name)
                    ix = i;                /* remember array index of att */
            }
            /* did we find attribute 'att'? */
            if (ix < 0)
                PFoops (OOPS_FATAL,
                        "attribute `%s' referenced in unary operation "
                        "not found", PFatt_str (n->sem.unary.att));

            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.unary.res;
            ocol_at (n, ocols_count (n)).type = ocol_at (L(n), ix).type;
            ocols_count (n)++;
        }
            break;

        case la_num_eq:
        case la_num_gt:
        case la_bool_and:
        case la_bool_or:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.binary.res;
            ocol_at (n, ocols_count (n)).type = aat_bln;
            ocols_count (n)++;
            break;

        case la_bool_not:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.unary.res;
            ocol_at (n, ocols_count (n)).type = aat_bln;
            ocols_count (n)++;
            break;

        case la_avg:
	case la_max:
	case la_min:
        case la_sum:
            /* set number of schema items in the result schema:
             * result attribute plus partitioning attribute 
             * (if available -- constant optimizations may
             *  have removed it).
             */
            new_ocols (n, n->sem.aggr.part ? 2 : 1);

            /* verify that attributes 'att' and 'part' are attributes of n
             * and include them into the result schema
             */
            for (unsigned int i = 0; i < ocols_count (L(n)); i++) {
                if (n->sem.aggr.att == ocol_at (L(n), i).name) {
                    ocol_at (n, 0) = ocol_at (L(n), i);
                    ocol_at (n, 0).name = n->sem.aggr.res;
                }
                if (n->sem.aggr.part &&
                    n->sem.aggr.part == ocol_at (L(n), i).name) {
                    ocol_at (n, 1) = ocol_at (L(n), i);
                }
            }
            break;
            
        case la_count:
            /* set number of schema items in the result schema:
             * result attribute plus partitioning attribute 
             * (if available -- constant optimizations may
             *  have removed it).
             */
            new_ocols (n, n->sem.count.part ? 2 : 1);

            /* insert result attribute into schema */
            ocol_at (n, 0).name = n->sem.count.res;
            ocol_at (n, 0).type = aat_int;

            /* copy the partitioning attribute */
            if (n->sem.count.part)
                for (unsigned int i = 0; i < ocols_count (L(n)); i++)
                    if (ocol_at (L(n), i).name == n->sem.count.part) {
                        ocol_at (n, 1) = ocol_at (L(n), i);
                        break;
                    }
            break;

        case la_rownum:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.rownum.attname;
            ocol_at (n, ocols_count (n)).type = aat_nat;
            ocols_count (n)++;
            break;

        case la_number:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.number.attname;
            ocol_at (n, ocols_count (n)).type = aat_nat;
            ocols_count (n)++;
            break;

        case la_type:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.type.res;
            ocol_at (n, ocols_count (n)).type = aat_bln;
            ocols_count (n)++;
            break;

        case la_type_assert:
            new_ocols (n, ocols_count (L(n)));

            /* copy schema from 'n' argument */
            for (unsigned int i = 0; i < ocols_count (L(n)); i++)
            {
                if (n->sem.type_a.att == ocol_at (L(n), i).name)
                {
                    ocol_at (n, i).name = n->sem.type_a.att;
                    ocol_at (n, i).type = n->sem.type_a.ty;
                }
                else
                    ocol_at (n, i) = ocol_at (L(n), i);
            }
            break;

        case la_cast:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.cast.res;
            ocol_at (n, ocols_count (n)).type = n->sem.cast.ty;
            ocols_count (n)++;
            break;

        case la_seqty1:
        case la_all:
            new_ocols (n, n->sem.blngroup.part ? 2 : 1);
            
            ocol_at (n, 0).name = n->sem.blngroup.res;
            ocol_at (n, 0).type = aat_bln;
            if (n->sem.blngroup.part) {
                ocol_at (n, 1).name = n->sem.blngroup.part;
                ocol_at (n, 1).type = aat_nat;
            }
            break;

        case la_scjoin:
            new_ocols (n, 2);

            ocol_at (n, 0)
                = (PFalg_schm_item_t) { .name = att_iter, .type = aat_nat };

            if (n->sem.scjoin.axis == alg_attr) 
                ocol_at (n, 1)
                    = (PFalg_schm_item_t) { .name = att_item,
                                            .type = aat_anode };
            else
                ocol_at (n, 1)
                    = (PFalg_schm_item_t) { .name = att_item,
                                            .type = aat_pnode };
            break;

        case la_doc_access:
            ocols (n) = copy_ocols (ocols (R(n)), ocols_count (R(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.doc_access.res;
            ocol_at (n, ocols_count (n)).type = aat_str;
            ocols_count (n)++;
            break;

        /* operators with static iter|item schema */
        case la_doc_tbl:
        case la_element:
        case la_docnode:
        case la_comment:
        case la_processi:
            new_ocols (n, 2);

            ocol_at (n, 0)
                = (PFalg_schm_item_t) { .name = att_iter, .type = aat_nat };
            ocol_at (n, 1)
                = (PFalg_schm_item_t) { .name = att_item, .type = aat_pnode };
            break;

        case la_attribute:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.attr.res;
            ocol_at (n, ocols_count (n)).type = aat_anode;
            ocols_count (n)++;
            break;

        case la_textnode:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.textnode.res;
            ocol_at (n, ocols_count (n)).type = aat_pnode;
            ocols_count (n)++;
            break;

        /* operator with static iter|pos|item schema */
        case la_merge_adjacent:
            new_ocols (n, 3);

            ocol_at (n, 0)
                = (PFalg_schm_item_t) { .name = att_iter, .type = aat_nat };
            ocol_at (n, 1)
                = (PFalg_schm_item_t) { .name = att_pos,  .type = aat_nat };
            ocol_at (n, 2)
                = (PFalg_schm_item_t) { .name = att_item, .type = aat_node };
            break;

        case la_roots:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));
            break;

        /* operators without schema */
        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
        case la_element_tag:
            /* keep empty schema */
            break;

        case la_cond_err:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)));
            break;

        case la_concat:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.binary.res;
            ocol_at (n, ocols_count (n)).type = aat_str;
            ocols_count (n)++;
            break;

        case la_contains:
            ocols (n) = copy_ocols (ocols (L(n)), ocols_count (L(n)) + 1);
            ocol_at (n, ocols_count (n)).name = n->sem.binary.res;
            ocol_at (n, ocols_count (n)).type = aat_bln;
            ocols_count (n)++;
            break;

        case la_string_join:
            new_ocols (n, 2);

            ocol_at (n, 0)
                = (PFalg_schm_item_t) { .name = att_iter, .type = aat_nat };
            ocol_at (n, 1)
                = (PFalg_schm_item_t) { .name = att_item, .type = aat_str };
            break;

    }
}

/* worker for PFprop_infer_ocol */
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

    /* infer information on resulting columns */
    infer_ocol (n);
}

/**
 * Infer ocol property for a single node based on 
 * the schemas of its children
 */
void
PFprop_update_ocol (PFla_op_t *n) {
    infer_ocol (n);
}

/**
 * Infer ocol property for a DAG rooted in root
 */
void
PFprop_infer_ocol (PFla_op_t *root) {
    prop_infer (root);
    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
