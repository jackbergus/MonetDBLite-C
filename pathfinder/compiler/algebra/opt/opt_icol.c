/**
 * @file
 *
 * Optimize relational algebra expression DAG
 * based on the icols property.
 * (This requires no burg pattern matching as we 
 *  apply optimizations in a peep-hole style on 
 *  single nodes only.)
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

#include "algopt.h"
#include "properties.h"
#include "alg_dag.h"
#include "mem.h"          /* PFmalloc() */

/*
 * Easily access subtree-parts.
 */
/** starting from p, make a step left */
#define L(p) ((p)->child[0])
/** starting from p, make a step right */
#define R(p) ((p)->child[1])
/** starting from p, make two steps left */
#define LL(p) L(L(p))
/** and so on... */
#define LRL(p) L(R(L(p)))

#define SEEN(p) ((p)->bit_dag)

/* worker for PFalgopt_icol */
static void
opt_icol (PFla_op_t *p)
{
    assert (p);

    /* rewrite each node only once */
    if (SEEN(p))
        return;
    else
        SEEN(p) = true;

    /* apply icol optimization for children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && p->child[i]; i++)
        opt_icol (p->child[i]);

    /* action code */
    switch (p->kind) {
        case la_lit_tbl:
        case la_empty_tbl:
        {
            unsigned int count = PFprop_icols_count (p->prop);

            /* prune columns that are not required as long as
               at least one column remains. */
            if (count && count < p->schema.count) {
                PFla_op_t *res;

                /* create new list of attributes */
                PFalg_att_t   *atts = PFmalloc (count * sizeof (PFalg_att_t));

                /* create list of tuples each containing a list of atoms */
                PFalg_tuple_t *tuples = PFmalloc (p->sem.lit_tbl.count *
                                                  sizeof (*(tuples)));;
                for (unsigned int i = 0; i < p->sem.lit_tbl.count; i++)
                    tuples[i].atoms = PFmalloc (count *
                                                sizeof (*(tuples[i].atoms)));
                count = 0;

                for (unsigned int i = 0; i < p->schema.count; i++)
                    if (PFprop_icol (p->prop, p->schema.items[i].name)) {
                        /* retain matching values in literal table */
                        atts[count] = p->schema.items[i].name;
                        for (unsigned int j = 0; j < p->sem.lit_tbl.count; j++)
                            tuples[j].atoms[count] =
                                    p->sem.lit_tbl.tuples[j].atoms[i];
                        count++;
                    }

                for (unsigned int i = 0; i < p->sem.lit_tbl.count; i++)
                    tuples[i].count = count;

                if (p->kind == la_empty_tbl)
                    res = PFla_empty_tbl (PFalg_attlist_ (count, atts));
                else
                    res = PFla_lit_tbl_ (PFalg_attlist_ (count, atts),
                                         p->sem.lit_tbl.count,
                                         tuples);
                *p = *res;
                SEEN(p) = true;
            } else if (!count && p->schema.count > 1) {
                /* prune everything except one column */
                PFla_op_t *res;

                /* create new list of attributes */
                PFalg_att_t   *atts = PFmalloc (1 * sizeof (PFalg_att_t));

                /* create list of tuples each containing a list of atoms */
                PFalg_tuple_t *tuples = PFmalloc (p->sem.lit_tbl.count *
                                                  sizeof (*(tuples)));;
                for (unsigned int i = 0; i < p->sem.lit_tbl.count; i++)
                    tuples[i].atoms = PFmalloc (1 *
                                                sizeof (*(tuples[i].atoms)));

                /* retain matching values in literal table */
                atts[0] = p->schema.items[0].name;
                for (unsigned int j = 0; j < p->sem.lit_tbl.count; j++) {
                    tuples[j].atoms[0] = PFalg_lit_nat (42);
                    tuples[j].count = 1;
                }

                if (p->kind == la_empty_tbl)
                    res = PFla_empty_tbl (PFalg_attlist_ (1, atts));
                else
                    res = PFla_lit_tbl_ (PFalg_attlist_ (1, atts), 1, tuples);
                *p = *res;
                SEEN(p) = true;
            }
        } break;

        case la_attach:
            /* prune attach if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.attach.attname)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_project:
        {   /* Because the icols columns are intersected with the
               ocol columns we can replace the current projection
               list with the icols columns. */
            unsigned int count = PFprop_icols_count (p->prop);
            if (count < p->schema.count) {
                PFla_op_t *ret;
                PFalg_proj_t *proj;

                /* ensure that at least one column remains! */
                count = count?count:1;
                proj = PFmalloc (count * sizeof (PFalg_proj_t));

                count = 0;
                for (unsigned int j = 0; j < p->sem.proj.count; j++)
                    if (PFprop_icol (p->prop, p->sem.proj.items[j].new))
                        proj[count++] = p->sem.proj.items[j];

                /* Ensure that at least one column remains!
                   Because the projection list may reference 
                   only columns that are discarded because of
                   the icols property, a new projection
                   mapping arbitrary columns is generated */
                if (!count)
                    proj[count++] = PFalg_proj (p->sem.proj.items[0].new,
                                                L(p)->schema.items[0].name);

                ret = PFla_project_ (L(p), count, proj);

                *p = *ret;
                SEEN(p) = true;
                break;
            }

        }   break;

        case la_disjunion:
            /* prune unnecessary columns before the union */
            if (PFprop_icols_count (p->prop) < p->schema.count) {
                /* introduce a projection for the left and right
                   union argument */
                if (PFprop_icols_count (p->prop)) {
                    PFla_op_t *ret;
                    PFalg_attlist_t icols =
                                    PFprop_icols_to_attlist (p->prop);
                    PFalg_proj_t *atts = PFmalloc (icols.count *
                                                   sizeof (PFalg_proj_t));

                    for (unsigned int i = 0; i < icols.count; i++)
                        atts[i] = PFalg_proj (icols.atts[i], icols.atts[i]);

                    ret = PFla_project_ (L(p), icols.count, atts);
                    PFprop_update_ocol (ret);
                    L(p) = ret;

                    ret = PFla_project_ (R(p), icols.count, atts);
                    PFprop_update_ocol (ret);
                    R(p) = ret;

                    break;
                }
                /* use the left and right icols information
                   for generating the projection list (one item) */
                else {
                    PFla_op_t *ret;
                    PFalg_proj_t *atts = PFmalloc (1 * sizeof (PFalg_proj_t));

                    for (unsigned int i = 0; i < p->schema.count; i++)
                        if (PFprop_icol_left (p->prop,
                                              p->schema.items[i].name)) {
                            atts[0] = PFalg_proj (p->schema.items[i].name,
                                                  p->schema.items[i].name);

                            ret = PFla_project_ (L(p), 1, atts);
                            PFprop_update_ocol (ret);
                            L(p) = ret;

                            ret = PFla_project_ (R(p), 1, atts);
                            PFprop_update_ocol (ret);
                            R(p) = ret;

                            break;
                        }
                    break;
                }
            }
            break;

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
            /* prune binary operation if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.binary.res)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_num_neg:
        case la_bool_not:
            /* prune unary operation if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.unary.res)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_avg:
	case la_max:
	case la_min:
        case la_sum:
        case la_count:
        case la_seqty1:
        case la_all:
            /* replace aggregate function if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.aggr.res)) {
                PFla_op_t *ret;
                /* as an aggregate is required we either
                   (a) evaluate a distinct on the partition (if present) or
                   (b) create a one tuple literal table with a bogus value
                       (as it is never referenced) */
                if (p->sem.aggr.part) {
                    PFalg_proj_t *proj = PFmalloc (sizeof (PFalg_proj_t));
                    proj[0] = PFalg_proj (p->sem.aggr.part, p->sem.aggr.part);
                    ret = PFla_distinct (PFla_project_ (L(p), 1, proj));
                    PFprop_update_ocol (L(ret));
                } else {
                    ret = PFla_lit_tbl (PFalg_attlist (p->sem.aggr.res),
                                        PFalg_tuple (PFalg_lit_nat (42)));
                }
                *p = *ret;
                SEEN(p) = true;
                break;
            }
            break;

        case la_rownum:
            /* prune rownum if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.rownum.attname)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_number:
            /* prune number if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.number.attname)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_type:
            /* prune type if result column is not required */
        case la_cast:
            /* prune cast if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.type.res)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_type_assert:
            /* prune type assertion if restricted column is not
               used afterwards */
            if (!PFprop_icol (p->prop, p->sem.type.att)) {
                *p = *(L(p));
                break;
            }
            break;

        case la_scjoin:
            break;

        case la_doc_access:
            /* prune doc_access if result column is not required */
            if (!PFprop_icol (p->prop, p->sem.doc_access.res)) {
                *p = *(R(p));
                break;
            }
            break;

        case la_roots:
            switch (L(p)->kind) {
                case la_element:
                    /* prune element if result column is not required */
                    if (!PFprop_icol (p->prop, L(p)->sem.elem.item_res)) {
                        *p = *(LRL(p));
                        break;
                    }
                    break;

                case la_attribute:
                    /* prune attribute if result column is not required */
                    if (!PFprop_icol (p->prop, L(p)->sem.attr.res)) {
                        *p = *(LL(p));
                        break;
                    }
                    break;

                case la_textnode:
                    /* prune textnode if result column is not required */
                    if (!PFprop_icol (p->prop, L(p)->sem.textnode.res)) {
                        *p = *(LL(p));
                        break;
                    }
                    break;
                    
                default:
                    break;
            } 
            break;
            
        default:
            break;
    }

    /* ensure that we have the correct schema */
    PFprop_update_ocol (p);
}

/**
 * Invoke algebra optimization.
 */
PFla_op_t *
PFalgopt_icol (PFla_op_t *root)
{
    /* Infer icol properties first */
    PFprop_infer_icol (root);

    /* Optimize algebra tree */
    opt_icol (root);
    PFla_dag_reset (root);
    /* ensure that each operator has its own properties */
    PFprop_create_prop (root);

    return root;
}

/* vim:set shiftwidth=4 expandtab filetype=c: */
