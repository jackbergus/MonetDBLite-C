/**
 * @file
 *
 * Push down equi-join operators as much as possible.
 * This optimization removes a number of mapping joins.
 *
 * The patterns of the transformation rules consist of an equi-join
 * and one child operator. The child operators can be splitted into
 * seven groups:
 * 1.) operators that do not support equi-join pushdown (e.g. the ones
 *     with a fixed schema or leaf operators)
 * 2.) operators that always support the transformation (select,
 *     conditional error, roots, and type assertion)
 * 3.) operators that support the transformation if the do not create
 *     a join column (e.g. comparisons and calculations)
 * 4.) operators that fit into the 4. category and additionally require
 *     the cardinality to stay the same (rownum, number, attribute, and
 *     textnode constructor)
 * 5.) cross product operator
 * 6.) equi-join operator
 * 7.) project operator
 * The last four groups (4.-7.) require special treatment (for details
 * on the transformation please look into the code).
 *
 * In addition a transformation rule that combines adjacent projections
 * is copied from opt_general.brg to keep the plans small. One more
 * transformation rule removes equi-joins that join the same relation
 * on the same attribute whose values are unique.
 *
 * As pushing down equi-joins may result in an equi-join referencing the
 * same operator twice the equi-join operator has to cope with duplicate
 * columns that would appear in its schema. Because no operator except the
 * eqjoin_unq can cope with duplicate columns this operator prunes all
 * these (based on the name) and returns a schema with distinct column
 * names.
 * We can be sure that these column are always the same as the mapping
 * from original names to unique names introduced renaming projections
 * whenever the same unique names would have been chosen for a column.
 * In addition we ensure that during this phase no such projection is
 * ignored and the duplicate unique columns are indeed the same column.
 *
 * An cleaning phase in the end removes all these duplicate column by
 * introducing projections whenever necessary.
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
 * is now maintained by the Database Systems Group at the Technische
 * Universitaet Muenchen, Germany.  Portions created by the University of
 * Konstanz and the Technische Universitaet Muenchen are Copyright (C)
 * 2000-2005 University of Konstanz and (C) 2005-2006 Technische
 * Universitaet Muenchen, respectively.  All Rights Reserved.
 *
 * $Id$
 */

/* always include pathfinder.h first! */
#include "pathfinder.h"
#include <assert.h>
#include <stdio.h>

#include "oops.h"
#include "algopt.h"
#include "properties.h"
#include "alg_dag.h"
#include "mem.h"          /* PFmalloc() */

/* mnemonic algebra constructors */
#include "logical_mnemonic.h"

/*
 * Easily access subtree-parts.
 */
/** starting from p, make a step left */
#define L(p) ((p)->child[0])
/** starting from p, make a step right */
#define R(p) ((p)->child[1])
/** starting from p, make two steps left */
#define LL(p) L(L(p))
/** starting from p, make a step left, then a step right */
#define LR(p) R(L(p))
/** starting from p, make a step right, then a step left */
#define RL(p) L(R(p))
/** starting from p, make two steps right */
#define RR(p) R(R(p))

#define SEEN(p) ((p)->bit_dag)

/**
 * Use equi-join implementation that replaces
 * both join argument by a result column.
 */
#define eqjoin_unq(a,b,c,d,e) PFla_eqjoin_clone ((a),(b),(c),(d),(e))

/* abbreviation for attribute dependency test */
static bool
is_join_att (PFla_op_t *p, PFalg_att_t att)
{
    assert (p && p->kind == la_eqjoin_unq);

    return (p->sem.eqjoin_unq.att1 == (att) || 
            p->sem.eqjoin_unq.att2 == (att));
}

/* worker for node containment test */
static bool
contains_node_worker (PFla_op_t *n, PFla_op_t *m)
{
    if (n == m)
        return true;

    if (n->bit_in)
        return false;

    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
        if (contains_node_worker (n->child[i], m))
            return true;

    n->bit_in = true;

    return false;
}

/* check if a node @a m appears in the sub-DAG of node @a n */
static bool
contains_node (PFla_op_t *n, PFla_op_t *m)
{
    bool cons = contains_node_worker (n, m);
    /* use IN bit to avoid a tree traversal
       as the DAG bit is already in use */
    PFla_in_reset (n);

    return cons;
}

/* worker for binary operators */
static bool
modify_binary_op (PFla_op_t *p,
                  PFla_op_t *lp,
                  PFla_op_t *rp,
                  PFla_op_t * (* op) (const PFla_op_t *,
                                      PFalg_att_t,
                                      PFalg_att_t,
                                      PFalg_att_t))
{
    PFalg_att_t latt, ratt;
    bool modified = false;

    /* parametrize optimization to use the same code
       for the left and the right operand of the equi-join */
    if (L(p) == lp) {
        latt = p->sem.eqjoin_unq.att1;
        ratt = p->sem.eqjoin_unq.att2;
    } else {
        latt = p->sem.eqjoin_unq.att2;
        ratt = p->sem.eqjoin_unq.att1;
    }

    if (!is_join_att (p, lp->sem.binary.res)) {
        *p = *(op (eqjoin_unq (L(lp), rp, latt, ratt,
                               p->sem.eqjoin_unq.res),
                   lp->sem.binary.res,
                   is_join_att (p, lp->sem.binary.att1)
                      ? p->sem.eqjoin_unq.res
                      : lp->sem.binary.att1,
                   is_join_att (p, lp->sem.binary.att2)
                      ? p->sem.eqjoin_unq.res
                      : lp->sem.binary.att2));
        modified = true;
    }
    return modified;
}

/* worker for unary operators */
static bool
modify_unary_op (PFla_op_t *p,
                 PFla_op_t *lp,
                 PFla_op_t *rp,
                 PFla_op_t * (* op) (const PFla_op_t *,
                                     PFalg_att_t,
                                     PFalg_att_t))
{
    PFalg_att_t latt, ratt;
    bool modified = false;

    /* parametrize optimization to use the same code
       for the left and the right operand of the equi-join */
    if (L(p) == lp) {
        latt = p->sem.eqjoin_unq.att1;
        ratt = p->sem.eqjoin_unq.att2;
    } else {
        latt = p->sem.eqjoin_unq.att2;
        ratt = p->sem.eqjoin_unq.att1;
    }

    if (!is_join_att (p, lp->sem.unary.res)) {
        *p = *(op (eqjoin_unq (L(lp), rp, latt, ratt,
                               p->sem.eqjoin_unq.res),
                   lp->sem.unary.res,
                   is_join_att (p, lp->sem.unary.att)
                      ? p->sem.eqjoin_unq.res
                      : lp->sem.unary.att));
        modified = true;
    }
    return modified;
}

/**
 * top-down worker for PFalgopt_join_pd
 *
 * join_pushdown looks up an equi-join and
 * tries to push it down the DAG as much as possible.
 */
static bool
join_pushdown (PFla_op_t *p)
{
    PFla_op_t *lp, *rp;
    PFalg_att_t latt, ratt;
    bool modified = false;

    assert (p);

    /* rewrite each node only once */
    if (SEEN(p))
        return false;

    /* combine multiple projections */
    if (p->kind == la_project &&
        L(p)->kind == la_project) {
        /* copy of code located in algebra/opt/opt_general.brg */
        PFalg_proj_t *proj = PFmalloc (p->schema.count *
                                           sizeof (PFalg_proj_t));

        unsigned int i, j, count = 0;
        for (i = 0; i < p->schema.count; i++)
            for (j = 0; j < L(p)->schema.count; j++)
                if (p->sem.proj.items[i].old ==
                    L(p)->sem.proj.items[j].new) {
                    proj[count++] = PFalg_proj (
                                        p->sem.proj.items[i].new,
                                        L(p)->sem.proj.items[j].old);
                    break;
                }

        /* ensure that at least one column remains! */
        if (!count)
            for (j = 0; j < L(p)->schema.count; j++)
                if (p->sem.proj.items[0].old ==
                    L(p)->sem.proj.items[j].new) {
                    proj[count++] = PFalg_proj (
                                        p->sem.proj.items[0].new,
                                        L(p)->sem.proj.items[j].old);
                    break;
                }

        *p = *(PFla_project_ (LL(p), count, proj));
        modified = true;
    }

    /* remove unnecessary joins */
    if (p->kind == la_eqjoin_unq &&
        L(p) == R(p) &&
        p->sem.eqjoin_unq.att1 == p->sem.eqjoin_unq.att2 &&
        PFprop_key (L(p)->prop, p->sem.eqjoin_unq.att1)) {
        /* the join does nothing -- it only applies a key-join
           with itself and the schema stays the same.
           Thus replace it by a dummy projection */
        PFalg_proj_t *proj_list = PFmalloc (p->schema.count *
                                            sizeof (PFalg_proj_t));
                                            
        for (unsigned int i = 0; i < p->schema.count; i++)
            proj_list[i] = proj (p->schema.items[i].name,
                                 p->schema.items[i].name);
                                 
        *p = *(PFla_project_ (L(p), p->schema.count, proj_list));
        modified = true;
    }

    /* action code that tries to push an equi-join underneath
       its operands */
    for (unsigned int c = 0; c < 2; c++) {
        /* only process equi-joins */
        if (p->kind != la_eqjoin_unq)
            break;
        
        /* parametrize optimization to use the same code
           for the left and the right operand of the equi-join */
        if (c) {
            lp = L(p);
            rp = R(p);
            latt = p->sem.eqjoin_unq.att1;
            ratt = p->sem.eqjoin_unq.att2;
        } else {
            lp = R(p);
            rp = L(p);
            latt = p->sem.eqjoin_unq.att2;
            ratt = p->sem.eqjoin_unq.att1;
        }
     
        switch (lp->kind) {
            case la_serialize:
            case la_lit_tbl:
            case la_empty_tbl:
            case la_intersect:
            case la_difference:
            case la_distinct:
            case la_avg:
            case la_max:
            case la_min:
            case la_sum:
            case la_count:
            case la_seqty1:
            case la_all:
            case la_scjoin:
            case la_doc_tbl:
            case la_element:
            case la_element_tag:
            case la_attribute: /* treated in case la_root */
            case la_textnode: /* treated in case la_root */
            case la_docnode:
            case la_comment:
            case la_processi:
            case la_merge_adjacent:
            case la_fragment:
            case la_frag_union:
            case la_empty_frag:
            case la_string_join:
            case la_dummy:
                /* nothing to do -- can't push down the equi-join */
                break;

            case la_attach:
                if (!is_join_att (p, lp->sem.attach.attname)) {
                    *p = *(attach (eqjoin_unq (L(lp), rp, latt, ratt,
                                               p->sem.eqjoin_unq.res),
                                   lp->sem.attach.attname,
                                   lp->sem.attach.value));
                    modified = true;
                }
                break;
                
            case la_cross:
            {
                /* choose the correct operand of the cross product
                   (the one with the join argument) to push down
                   the equi-join */
                bool in_left = false;
                for (unsigned int i = 0; i < L(lp)->schema.count; i++)
                    if (L(lp)->schema.items[i].name == latt) {
                        in_left = true;
                        break;
                    }
                    
                if (in_left)
                    *p = *(cross (eqjoin_unq (L(lp), rp, latt, ratt,
                                              p->sem.eqjoin_unq.res),
                                  R(lp)));
                else
                    *p = *(cross (eqjoin_unq (R(lp), rp, latt, ratt,
                                              p->sem.eqjoin_unq.res),
                                  L(lp)));
                modified = true;
            }   break;

            case la_cross_mvd:
                PFoops (OOPS_FATAL,
                        "clone column aware cross product operator is "
                        "only allowed inside mvd optimization!");
                break;

            case la_eqjoin:
                PFoops (OOPS_FATAL,
                        "clone column unaware eqjoin operator is "
                        "only allowed with original attribute names!");
                    
            case la_eqjoin_unq:
                /* Rewriting joins is only effective if we push
                   joins further down that have different join columns.
                   The correct choice of the branch is however not
                   directly clear. 

                   We thus only optimze only the patterns
                         |X|_1          |X|_1           |X|   
                        /   \          /   \           /   \
                       |X|   1        |X|   1         #     2
                      /   \    and   /   \     into   |
                      #    2        #     2          |X|_1 
                      |             |               /   \
                      3             3              3     1
    
                   whenever possible (e.g., only if no columns references
                   are missing). For all other directly following equi-joins
                   we discard any rewriting. */
                if (PFprop_subdom (lp->prop,
                                   PFprop_dom (lp->prop, latt),
                                   PFprop_dom (lp->prop, 
                                               lp->sem.eqjoin_unq.res))
                    ||
                    PFprop_subdom (lp->prop,
                                   PFprop_dom (lp->prop,
                                               lp->sem.eqjoin_unq.res),
                                   PFprop_dom (lp->prop, latt)))
                    break;

                if (L(lp)->kind == la_number &&
                    L(lp)->sem.number.attname == lp->sem.eqjoin_unq.att1 &&
                    !contains_node (rp, L(lp))) {
                    /* ensure that column of upper eqjoin is not created on the
                       other side */
                    unsigned int i;
                    PFla_op_t *new_number;
                    PFalg_proj_t *proj = PFmalloc (L(lp)->schema.count *
                                                   sizeof (PFalg_proj_t));

                    for (i = 0; i < L(lp)->schema.count; i++)
                        if (L(lp)->schema.items[i].name == latt)
                            break;
                    if (i == L(lp)->schema.count)
                        break;

                    for (i = 0; i < L(lp)->schema.count; i++)
                        if (L(lp)->schema.items[i].name != latt)
                            proj[i] = PFalg_proj (L(lp)->schema.items[i].name,
                                                  L(lp)->schema.items[i].name);
                        else
                            proj[i] = PFalg_proj (L(lp)->schema.items[i].name,
                                                  p->sem.eqjoin_unq.res);

                    new_number = number (
                                     eqjoin_unq (LL(lp), rp,
                                                 latt, ratt,
                                                 p->sem.eqjoin_unq.res),
                                     L(lp)->sem.number.attname,
                                     L(lp)->sem.number.part);

                    *L(lp) = *PFla_project_ (new_number, 
                                             L(lp)->schema.count,
                                             proj);

                    *p = *eqjoin_unq (new_number, R(lp),
                                      lp->sem.eqjoin_unq.att1,
                                      lp->sem.eqjoin_unq.att2,
                                      lp->sem.eqjoin_unq.res);
                    break;    
                }
                if (R(lp)->kind == la_number &&
                    R(lp)->sem.number.attname == lp->sem.eqjoin_unq.att2 &&
                    !contains_node (rp, R(lp))) {
                    /* ensure that column of upper eqjoin is not created on the
                       other side */
                    unsigned int i;
                    PFla_op_t *new_number;
                    PFalg_proj_t *proj = PFmalloc (R(lp)->schema.count *
                                                   sizeof (PFalg_proj_t));

                    for (i = 0; i < R(lp)->schema.count; i++)
                        if (R(lp)->schema.items[i].name == latt)
                            break;
                    if (i == R(lp)->schema.count)
                        break;

                    for (i = 0; i < R(lp)->schema.count; i++)
                        if (R(lp)->schema.items[i].name != latt)
                            proj[i] = PFalg_proj (R(lp)->schema.items[i].name,
                                                  R(lp)->schema.items[i].name);
                        else
                            proj[i] = PFalg_proj (R(lp)->schema.items[i].name,
                                                  p->sem.eqjoin_unq.res);

                    new_number = number (
                                     eqjoin_unq (RL(lp), rp,
                                                 latt, ratt,
                                                 p->sem.eqjoin_unq.res),
                                     R(lp)->sem.number.attname,
                                     R(lp)->sem.number.part);

                    *R(lp) = *PFla_project_ (new_number,
                                             R(lp)->schema.count,
                                             proj);

                    *p = *eqjoin_unq (new_number, L(lp),
                                      lp->sem.eqjoin_unq.att2,
                                      lp->sem.eqjoin_unq.att1,
                                      lp->sem.eqjoin_unq.res);
                    break;    
                }
                break;

            case la_project:
                /* Here we apply transformations in two different cases.
                   First we rewrite equi-joins followed by a project that
                   do not apply renaming on the arguments. This ensures
                   that equally named columns are indeed identical columns.
                   This is furthermore enforced by the fact that we only
                   transform key joins.
                   The second case applys a transformation of an equi-join
                   followed by a renaming projection with the additional
                   constraints that the second join relation and the 
                   projection both reference the same operator and join
                   on the same (possibly renamed) column.

                   A possible third alternative would be an equi-join
                   together with a renaming projection where the old as
                   well as the new column names do not conflict with the
                   column names of the right join operand. For a similar
                   reason as the missing transformation of join-join 
                   patterns we skip this alternative here. */
            {
                bool renamed = false;
                
                /* ensure that the equi-joins are key joins and
                   not fake cross products */
                if ((!PFprop_key (lp->prop, latt) ||
                     !PFprop_subdom (lp->prop,
                                     PFprop_dom (rp->prop, ratt),
                                     PFprop_dom (lp->prop, latt)))
                    &&
                    (!PFprop_key (rp->prop, ratt) ||
                     !PFprop_subdom (rp->prop,
                                     PFprop_dom (lp->prop, latt),
                                     PFprop_dom (rp->prop, ratt))))
                    break;
                    
                /* check for renaming */
                for (unsigned int i = 0; i < lp->sem.proj.count; i++)
                    renamed = renamed || 
                              (lp->sem.proj.items[i].new
                               != lp->sem.proj.items[i].old);

                if (!renamed) {
                    PFalg_att_t cur;
                    PFalg_proj_t *proj_list;
                    unsigned int count = 0;

                    /* create projection list */
                    proj_list = PFmalloc (p->schema.count *
                                          sizeof (*(proj_list)));
                                          
                    /* add result column of equi-join */
                    proj_list[count++] = proj (p->sem.eqjoin_unq.res,
                                               p->sem.eqjoin_unq.res);
                                               
                    /* add all columns of the left argument
                       (without the join arguments) */
                    for (unsigned int i = 0; i < lp->schema.count; i++) {
                        cur = lp->schema.items[i].name;
                        if (!is_join_att (p, cur))
                            proj_list[count++] = proj (cur, cur);
                    }
                    /* add all columns of the right argument
                       (without duplicates and join arguments) */
                    for (unsigned int i = 0; i < rp->schema.count; i++) {
                        cur = rp->schema.items[i].name;
                        if (!is_join_att (p, cur)) {
                            unsigned int j;
                            for (j = 0; j < count; j++)
                                if (proj_list[j].new == cur)
                                    break;
                            /* skip columns with duplicate names */
                            if (j == count)
                                proj_list[count++] = proj (cur, cur);
                        }
                    }
                    assert (count <= p->schema.count);
                                          
                    *p = *(PFla_project_ (eqjoin_unq (L(lp), rp, latt, ratt,
                                                      p->sem.eqjoin_unq.res),
                                          count,
                                          proj_list));
                    modified = true;
                }
                else if (L(lp) == rp) {
                    unsigned int i;
                    PFalg_proj_t proj;
                    bool same_join_col = false;
                    
                    for (i = 0; i < lp->sem.proj.count; i++) {
                        proj = lp->sem.proj.items[i];
                        if (proj.new == latt && proj.old == ratt) {
                            same_join_col = true;
                            break;
                        }
                    }
                    /* match the pattern:   |X|
                                           /   \
                                          |  project
                                          |     |
                                           \   /
                                             op

                       where both join attributes refer to the same
                       column (which contains only unique values -
                       see check above) */                             
                    if (same_join_col) {
                        PFalg_att_t cur;
                        PFalg_proj_t *proj_list;
                        unsigned int count = 0;

                        /* create projection list */
                        proj_list = PFmalloc (p->schema.count *
                                              sizeof (*(proj_list)));
                                              
                        /* add result column of equi-join */
                        proj_list[count++] = proj (p->sem.eqjoin_unq.res,
                                                   p->sem.eqjoin_unq.res);
                                                   
                        /* add all columns of the right argument
                           (without the join arguments) */
                        for (i = 0; i < rp->schema.count; i++) {
                            cur = rp->schema.items[i].name;
                            if (!is_join_att (p, cur))
                                proj_list[count++] = proj (cur, cur);
                        }
                        
                        /* add all columns of the left argument
                           (without the join arguments and duplicates) */
                        for (i = 0; i < lp->sem.proj.count; i++) {
                            proj = lp->sem.proj.items[i];
                            if (!is_join_att (p, proj.new)) {
                                unsigned int j;
                                for (j = 0; j < count; j++)
                                    if (proj_list[j].new == proj.new)
                                        break;

                                if (j == count)
                                    proj_list[count++] = proj;
                            }
                        }
                        assert (count <= p->schema.count);
                                              
                        *p = *(PFla_project_ (L(lp), count, proj_list));
                        modified = true;
                    }
                    break;
                }
            }   break;

            case la_select:
                *p = *(select_ (eqjoin_unq (L(lp), rp, latt, ratt,
                                            p->sem.eqjoin_unq.res),
                                is_join_att(p, lp->sem.select.att)
                                   ? p->sem.eqjoin_unq.res
                                   : lp->sem.select.att));
                modified = true;
                break;

            case la_disjunion:
            {
                /* In situations where we apply actions on the
                   empty sequence and append the generated rows with a union
                   a join pushdown does not help (-- it will be stopped at
                   the difference operator anyway).
                   Thus we avoid to rewrite any union that uses the outcome
                   of a difference operation. */
                PFla_op_t *cur;
                bool diff;
                
                /* check for difference in left subtree */
                cur = L(lp);
                diff = false;
                while (cur) {
                    switch (cur->kind)
                    {
                        case la_project:
                        case la_attach:
                            cur = L(cur);
                            break;
                        case la_difference:
                            diff = true;
                            /* continue */
                        default:
                            cur = NULL; /* stop processing */
                            break;
                    }
                }
                /* stop rewriting if difference was discovered */
                if (diff)
                    break;
                
                /* check for difference in left subtree */
                cur = R(lp);
                diff = false;
                while (cur) {
                    switch (cur->kind)
                    {
                        case la_project:
                        case la_attach:
                            cur = L(cur);
                            break;
                        case la_difference:
                            diff = true;
                            /* continue */
                        default:
                            cur = NULL; /* stop processing */
                            break;
                    }
                }
                /* stop rewriting if difference was discovered */
                if (diff)
                    break;
                
                /* This rewrite is only correct if the union operator
                   is implemented as a union all operation. */
                *p = *disjunion (eqjoin_unq (L(lp), rp, latt, ratt,
                                             p->sem.eqjoin_unq.res),
                                 eqjoin_unq (R(lp), rp, latt, ratt,
                                             p->sem.eqjoin_unq.res));
                modified = true;
            } break;
                
            case la_num_add:
                modified = modify_binary_op (p, lp, rp, PFla_add);
                break;
            case la_num_subtract:
                modified = modify_binary_op (p, lp, rp, PFla_subtract);
                break;
            case la_num_multiply:
                modified = modify_binary_op (p, lp, rp, PFla_multiply);
                break;
            case la_num_divide:
                modified = modify_binary_op (p, lp, rp, PFla_divide);
                break;
            case la_num_modulo:
                modified = modify_binary_op (p, lp, rp, PFla_modulo);
                break;
            case la_num_eq:
                modified = modify_binary_op (p, lp, rp, PFla_eq);
                break;
            case la_num_gt:
                modified = modify_binary_op (p, lp, rp, PFla_gt);
                break;
            case la_num_neg:
                modified = modify_unary_op (p, lp, rp, PFla_neg);
                break;
            case la_bool_and:
                modified = modify_binary_op (p, lp, rp, PFla_and);
                break;
            case la_bool_or:
                modified = modify_binary_op (p, lp, rp, PFla_or);
                break;
            case la_bool_not:
                modified = modify_unary_op (p, lp, rp, PFla_not);
                break;

            case la_rownum:
                if (!PFprop_key (rp->prop, ratt) ||
                    !PFprop_subdom (rp->prop,
                                    PFprop_dom (lp->prop, latt),
                                    PFprop_dom (rp->prop, ratt)))
                    /* Ensure that the values of the left join argument
                       are a subset of the values of the right join argument
                       and that the right join argument is keyed. These
                       two tests make sure that we have exactly one match per
                       tuple in the left relation and thus the result of the
                       rownum operator stays stable. */
                    break;

                if (!is_join_att (p, lp->sem.rownum.attname) &&
                    !contains_node (rp, lp)) {
                    PFalg_proj_t *proj_list;
                    PFalg_attlist_t sortby;
                    PFalg_att_t cur;
                    unsigned int count = 0;
                    /* create projection list */
                    proj_list = PFmalloc (lp->schema.count *
                                          sizeof (*(proj_list)));
                                          
                    for (unsigned int i = 0; i < lp->schema.count; i++) {
                        cur = lp->schema.items[i].name;
                        if (cur != latt)
                            proj_list[count++] = proj (cur, cur);
                    }
                    /* add join column with original name
                       the projection list */
                    proj_list[count++] = proj (latt,
                                               p->sem.eqjoin_unq.res);
                                               
                    /* copy sortby criteria and change name of
                       sort column to equi-join result if it is
                       also a join argument */
                    sortby.count = lp->sem.rownum.sortby.count;
                    sortby.atts = PFmalloc (sortby.count *
                                            sizeof (PFalg_att_t));
                    for (unsigned int i = 0; i < sortby.count; i++) {
                        cur = lp->sem.rownum.sortby.atts[i];
                        if (cur != latt)
                            sortby.atts[i] = cur;
                        else
                            sortby.atts[i] = p->sem.eqjoin_unq.res;
                    }
                                            
                    /* make sure that frag and roots see
                       the new attribute node */
                    *p = *(rownum (eqjoin_unq (L(lp), rp, latt, ratt,
                                               p->sem.eqjoin_unq.res),
                                   lp->sem.rownum.attname,
                                   sortby,
                                   lp->sem.rownum.part
                                       ? is_join_att(p,
                                                     lp->sem.rownum.part)
                                             ? p->sem.eqjoin_unq.res
                                             : lp->sem.rownum.part
                                       : att_NULL));
                    /* the schema of the new rownum operator has to
                       be pruned to maintain the schema of the original
                       rownum operator -- its pointer is replaced */
                    *lp = *(PFla_project_ (p, count, proj_list));
                    
                    modified = true;
                    break;
                }
                
                break;

            case la_number:
                if (!PFprop_key (rp->prop, ratt) ||
                    !PFprop_subdom (rp->prop,
                                    PFprop_dom (lp->prop, latt),
                                    PFprop_dom (rp->prop, ratt)))
                    /* Ensure that the values of the left join argument
                       are a subset of the values of the right join argument
                       and that the right join argument is keyed. These
                       two tests make sure that we have exactly one match per
                       tuple in the left relation and thus the result of the
                       number operator stays stable. */
                    break;

                if (!is_join_att (p, lp->sem.number.attname) &&
                    !contains_node (rp, lp)) {
                    PFalg_proj_t *proj_list;
                    PFalg_att_t cur;
                    unsigned int count = 0;
                    /* create projection list */
                    proj_list = PFmalloc (lp->schema.count *
                                          sizeof (*(proj_list)));
                                          
                    for (unsigned int i = 0; i < lp->schema.count; i++) {
                        cur = lp->schema.items[i].name;
                        if (cur != latt)
                            proj_list[count++] = proj (cur, cur);
                    }
                    /* add join column with original name
                       the projection list */
                    proj_list[count++] = proj (latt,
                                               p->sem.eqjoin_unq.res);
                                               
                    /* make sure that frag and roots see
                       the new attribute node */
                    *p = *(number (eqjoin_unq (L(lp), rp, latt, ratt,
                                               p->sem.eqjoin_unq.res),
                                   lp->sem.number.attname,
                                   lp->sem.number.part
                                       ? is_join_att(p,
                                                     lp->sem.number.part)
                                             ? p->sem.eqjoin_unq.res
                                             : lp->sem.number.part
                                       : att_NULL));
                    /* the schema of the new number operator has to
                       be pruned to maintain the schema of the original
                       number operator -- its pointer is replaced */
                    *lp = *(PFla_project_ (p, count, proj_list));
                    
                    modified = true;
                    break;
                }
                
                break;

            case la_type:
                if (!is_join_att (p, lp->sem.type.res)) {
                    *p = *(type (eqjoin_unq (L(lp), rp, latt, ratt,
                                             p->sem.eqjoin_unq.res),
                                 lp->sem.type.res,
                                 is_join_att(p, lp->sem.type.att)
                                    ? p->sem.eqjoin_unq.res
                                    : lp->sem.type.att,
                                 lp->sem.type.ty));
                    modified = true;
                }
                break;
                
            case la_type_assert:
                *p = *(type_assert_pos (eqjoin_unq (L(lp), rp, latt, ratt,
                                                    p->sem.eqjoin_unq.res),
                                        is_join_att(p, lp->sem.type.att)
                                           ? p->sem.eqjoin_unq.res
                                           : lp->sem.type.att,
                                        lp->sem.type.ty));
                modified = true;
                break;
                
            case la_cast:
                if (!is_join_att (p, lp->sem.type.res)) {
                    *p = *(cast (eqjoin_unq (L(lp), rp, latt, ratt,
                                             p->sem.eqjoin_unq.res),
                                 lp->sem.type.res,
                                 is_join_att(p, lp->sem.type.att)
                                    ? p->sem.eqjoin_unq.res
                                    : lp->sem.type.att,
                                 lp->sem.type.ty));
                    modified = true;
                }
                break;
                
            case la_dup_scjoin:
                if (!is_join_att (p, lp->sem.scjoin.item_res)) {
                    *p = *(dup_scjoin (L(lp),
                                       eqjoin_unq (R(lp), rp, latt, ratt,
                                                   p->sem.eqjoin_unq.res),
                                       lp->sem.scjoin.axis,
                                       lp->sem.scjoin.ty,
                                       is_join_att(p, lp->sem.scjoin.item)
                                          ? p->sem.eqjoin_unq.res
                                          : lp->sem.scjoin.item,
                                       lp->sem.scjoin.item_res));
                    modified = true;
                }
                break;

            case la_doc_access:
                if (!is_join_att (p, lp->sem.doc_access.res)) {
                    *p = *(doc_access (L(lp),
                                       eqjoin_unq (R(lp), rp, latt, ratt,
                                                   p->sem.eqjoin_unq.res),
                                       lp->sem.doc_access.res,
                                       is_join_att(p, lp->sem.doc_access.att)
                                          ? p->sem.eqjoin_unq.res
                                          : lp->sem.doc_access.att,
                                       lp->sem.doc_access.doc_col));
                    modified = true;
                }
                break;

            case la_roots:
                if (!PFprop_key (rp->prop, ratt) ||
                    !PFprop_subdom (rp->prop,
                                    PFprop_dom (lp->prop, latt),
                                    PFprop_dom (rp->prop, ratt)))
                    /* Ensure that the values of the left join argument
                       are a subset of the values of the right join argument
                       and that the right join argument is keyed. These
                       two tests make sure that we have exactly one match per
                       tuple in the left relation and thus the result of the
                       attribute/textnode constructor stays stable. */
                    break;

                /* attributes */
                if (L(lp)->kind == la_attribute &&
                    !is_join_att (p, L(lp)->sem.attr.res) &&
                    !contains_node (rp, lp) &&
                    !contains_node (rp, L(lp))) {

                    PFalg_proj_t *proj_list;
                    PFalg_att_t cur;
                    unsigned int count = 0;
                    /* create projection list */
                    proj_list = PFmalloc (lp->schema.count *
                                          sizeof (*(proj_list)));
                                          
                    for (unsigned int i = 0; i < lp->schema.count; i++) {
                        cur = lp->schema.items[i].name;
                        if (cur != latt)
                            proj_list[count++] = proj (cur, cur);
                    }
                    /* add join column with its original name
                       to the projection list */
                    proj_list[count++] = proj (latt,
                                               p->sem.eqjoin_unq.res);
                                               
                    /* make sure that frag and roots see
                       the new attribute node */
                    *L(lp) = *(attribute (eqjoin_unq (LL(lp), rp, latt, ratt,
                                                      p->sem.eqjoin_unq.res),
                                          L(lp)->sem.attr.res,
                                          is_join_att(p, L(lp)->sem.attr.qn)
                                             ? p->sem.eqjoin_unq.res
                                             : L(lp)->sem.attr.qn,
                                          is_join_att(p, L(lp)->sem.attr.val)
                                             ? p->sem.eqjoin_unq.res
                                             : L(lp)->sem.attr.val));
                    *p = *(roots (L(lp)));
                    /* the schema of the new roots operator has to
                       be pruned to maintain the schema of the original
                       roots operator -- its pointer is replaced */
                    *lp = *(PFla_project_ (p, count, proj_list));
                    
                    modified = true;
                    break;
                }
                
                /* textnodes */
                if (L(lp)->kind == la_textnode &&
                    !is_join_att (p, L(lp)->sem.textnode.res) &&
                    !contains_node (rp, lp) &&
                    !contains_node (rp, L(lp))) {

                    PFalg_proj_t *proj_list;
                    PFalg_att_t cur;
                    unsigned int count = 0;
                    /* create projection list */
                    proj_list = PFmalloc (lp->schema.count *
                                          sizeof (*(proj_list)));
                                          
                    for (unsigned int i = 0; i < lp->schema.count; i++) {
                        cur = lp->schema.items[i].name;
                        if (cur != latt)
                            proj_list[count++] = proj (cur, cur);
                    }
                    /* add join column with its original name
                       to the projection list */
                    proj_list[count++] = proj (latt,
                                               p->sem.eqjoin_unq.res);
                                               
                    /* make sure that frag and roots see
                       the new textnode node */
                    *(L(lp)) = *(textnode (eqjoin_unq (LL(lp), rp, latt, ratt,
                                                       p->sem.eqjoin_unq.res),
                                           L(lp)->sem.textnode.res,
                                           is_join_att(p,
                                                       L(lp)->sem.textnode.item)
                                              ? p->sem.eqjoin_unq.res
                                              : L(lp)->sem.textnode.item));
                    *p = *(roots (L(lp)));
                    /* the schema of the new roots operator has to
                       be pruned to maintain the schema of the original
                       roots operator -- its pointer is replaced */
                    *lp = *(PFla_project_ (p, count, proj_list));
                    
                    modified = true;
                    break;
                }
                break;
                
            case la_cond_err:
                /* this breaks proxy generation - thus don't 
                   rewrite conditional errors */
                /* 
                *p = *(cond_err (eqjoin_unq (L(lp), rp, latt, ratt,
                                             p->sem.eqjoin_unq.res),
                                 R(lp),
                                 lp->sem.err.att,
                                 lp->sem.err.str));
                modified = true;
                */
                break;
                
            case la_rec_fix:
            case la_rec_param:
            case la_rec_nil:
            case la_rec_arg:
            case la_rec_base:
                /* do not rewrite anything that has to do with recursion */
                break;
                
            case la_proxy:
            case la_proxy_base:
                PFoops (OOPS_FATAL,
                        "cannot cope with proxy nodes");
                break;

            case la_concat:
                modified = modify_binary_op (p, lp, rp, PFla_fn_concat);
                break;
                
            case la_contains:
                modified = modify_binary_op (p, lp, rp, PFla_fn_contains);
                break;

        }
    }

    SEEN(p) = true;

    /* apply join_pushdown for the children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && p->child[i]; i++)
        modified = join_pushdown (p->child[i]) || modified;

    return modified;
}

/**
 * clean_up_eqjoin introduces additional project operators
 * whenever there are duplicate columns that are not join
 * attributes.
 */
static void
clean_up_eqjoin (PFla_op_t *p)
{
    unsigned int i;

    /* rewrite each node only once */
    if (SEEN(p))
        return;
    else
        SEEN(p) = true;

    /* clean up equ-joins in the subtrees */
    for (i = 0; i < PFLA_OP_MAXCHILD && p->child[i]; i++)
        clean_up_eqjoin (p->child[i]);

    if (p->kind == la_eqjoin_unq) {
        PFla_op_t *left, *right;
        PFalg_proj_t *proj_list;
        PFalg_att_t cur;
        unsigned int j, count;
        bool prune;
        
        /* as the equi-join may be pushed down that far that it
           references the same relation we have to remove 
           every duplicate except the first join column from 
           the first operand and project away the first join column
           from the second operand. */
           
        /* first operand */
        
        /* check for duplicate columns */
        prune = false;
        for (i = 0; i < L(p)->schema.count; i++) {
            cur = L(p)->schema.items[i].name;
            if (cur != p->sem.eqjoin_unq.att1)
                for (j = 0; j < R(p)->schema.count; j++)
                    if (R(p)->schema.items[j].name == cur) {
                        prune = true;
                        break;
                    }
            if (prune)
                break;
        }

        /* if duplicate columns appeared add a projection */
        if (prune) {
            count = 0;
            /* create projection list (at maximum it has the same size) */
            proj_list = PFmalloc ((L(p)->schema.count) 
                                  * sizeof (*(proj_list)));
            
            /* keep first join attribute */
            proj_list[count++] = proj (p->sem.eqjoin_unq.att1,
                                       p->sem.eqjoin_unq.att1);

            /* create projection list */
            for (i = 0; i < L(p)->schema.count; i++) {
                cur = L(p)->schema.items[i].name;
                for (j = 0; j < R(p)->schema.count; j++)
                    if (R(p)->schema.items[j].name == cur)
                        /* we detected a cloned column */ break;

                /* No clone column found ... */
                if (j == R(p)->schema.count &&
                    /* ... and it is not a join argument ... */
                    !is_join_att (p, cur))
                    /* ... then add it to the projection list. */
                    proj_list[count++] = proj (cur, cur);
            }
            left = PFla_project_ (L(p), count, proj_list);
        }
        else
            left = L(p);

        /* second operand */
        
        /* check for duplicate columns */
        prune = false;
        if (p->sem.eqjoin_unq.att1 != p->sem.eqjoin_unq.att2)
            for (j = 0; j < R(p)->schema.count; j++)
                /* The first join column appeared - we have to introduce
                   the projection. */
                if (R(p)->schema.items[i].name == p->sem.eqjoin_unq.att1) {
                    prune = true;
                    break;
                }

        /* if duplicate columns appeared add a projection */
        if (prune) {
            count = 0;
            /* create projection list (at maximum it has the same size) */
            proj_list = PFmalloc ((R(p)->schema.count)
                                  * sizeof (*(proj_list)));
            
            /* keep second join attribute */
            proj_list[count++] = proj (p->sem.eqjoin_unq.att2,
                                       p->sem.eqjoin_unq.att2);
                                       
            for (i = 0; i < R(p)->schema.count; i++) {
                cur = R(p)->schema.items[i].name;
                /* Throw out join columns we already added it
                   separately */
                if (!is_join_att (p, cur))
                    proj_list[count++] = proj (cur, cur);
            }
            right = PFla_project_ (R(p), count, proj_list);
        }
        else
            right = R(p);

        /* replace eqjoin if a projection was introduced */
        if (left != L(p) || right != R(p))
            *p = *(eqjoin_unq (left, right,
                               p->sem.eqjoin_unq.att1,
                               p->sem.eqjoin_unq.att2,
                               p->sem.eqjoin_unq.res));
    }
}

/**
 * Invoke algebra optimization.
 */
PFla_op_t *
PFalgopt_join_pd (PFla_op_t *root)
{
    unsigned int tries = 0, max_tries = 0;
    bool modified = true;
    
    /* Optimize algebra tree */
    while (modified || tries < max_tries) {
        PFprop_infer_key (root);
        /* key property inference already requires 
           the domain property inference. Thus we can
           skip it:
        PFprop_infer_dom (root);
        */

        modified = join_pushdown (root);
        PFla_dag_reset (root);
        if (!modified) tries++;
    }
    /* remove duplicate columns introduced
       during rewriting */
    clean_up_eqjoin (root);
    PFla_dag_reset (root);

    return root;
}

/* vim:set shiftwidth=4 expandtab filetype=c: */
