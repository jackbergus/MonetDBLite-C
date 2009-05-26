/**
 * @file
 *
 * Introduce the borders of recursion and branch bodies..
 * (This enables the MIL generation to detect expressions
 *  that are invariant to the recursion or branch body.)
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

/* always include pf_config.h first! */
#include "pf_config.h"
#include "pathfinder.h"

#include "intro_borders.h"
#include "alg_dag.h"

#include <assert.h>

/* Easily access subtree-parts */
#include "child_mnemonic.h"

#define SEEN(n) n->bit_dag
#define pfIN(n) n->bit_in

/**
 * Worker that introduces border operators and 'in' flags.
 * Nodes are marked 'inside' as soon as one child reports
 * that one of its descendants is a base operator belonging
 * to the current recursion.
 */
static bool
introduce_rec_borders_worker (PFpa_op_t *n, PFarray_t *bases)
{
    unsigned int i;
    bool base_path = false;

    /* short-cut in case n is already determined as 'inside' */
    if (pfIN(n))
        return true;

    switch (n->kind)
    {
        /* ignore nested recursions and only collect the path */
        case pa_rec_fix:
            base_path = introduce_rec_borders_worker (L(n), bases);
            break;
        case pa_side_effects:
            base_path = introduce_rec_borders_worker (R(n), bases);
            break;
        case pa_rec_param:
            base_path = introduce_rec_borders_worker (L(n), bases);
            base_path = introduce_rec_borders_worker (R(n), bases)
                        || base_path;
            break;
        case pa_nil:
            break;
        case pa_rec_arg:
            base_path = introduce_rec_borders_worker (L(n), bases);
            break;

        /* if the base operator belongs to the currently searched
           recursion mark the node as inside the recursion */
        case pa_rec_base:
            for (i = 0; i < PFarray_last (bases); i++)
                if (n == *(PFpa_op_t **) PFarray_at (bases, i)) {
                    base_path = true;
                    break;
                }
            break;

        case pa_fun_call:
             base_path = introduce_rec_borders_worker (L(n), bases) ||
                         introduce_rec_borders_worker (R(n), bases);

             /* the complete function call resides in the recursion */
             if (base_path) {
                 /* If one argument of the function call resides in the
                    recursion the loop relation certainly does as well. */

                 /* Introduce a recursion border for all arguments
                    that reside outside the recursion. */
                 PFpa_op_t *param = R(n);
                 while (param->kind != pa_nil) {
                     if (param->kind == pa_fun_param && !pfIN(L(param))) {
                         L(param) = PFpa_rec_border (L(param));
                         L(param)->prop = L(L(param))->prop;
                     }
                     param = R(param);
                 }
             }
             break;

        case pa_fun_param:
             /* only collect the base paths */
             base_path = introduce_rec_borders_worker (L(n), bases) ||
                         introduce_rec_borders_worker (R(n), bases);
             break;

        case pa_fcns:
            /* this also skips the introduction of a rec_border
               operator for the content of an empty elements:
               elem (fcns (nil, nil)). */
            if (R(n)->kind == pa_nil)
                break;
            /* else fall through */
        default:
            /* follow the children until a base or a leaf is reached */
            for (unsigned int i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
                base_path = introduce_rec_borders_worker (n->child[i], bases)
                            || base_path;

            /* Introduce border if the current node is 'inside'
               the recursion while its left child is not.
               Make sure that no borders are introduced along the
               fragment information edge. */
            if (base_path && L(n) && !pfIN(L(n))) {
                L(n) = PFpa_rec_border (L(n));
                L(n)->prop = L(L(n))->prop;
            }
            /* Introduce border if the current node is 'inside'
               the recursion while its right child is not. */
            if (base_path && R(n) && !pfIN(R(n)) &&
                R(n)->kind != pa_fcns) {
                R(n) = PFpa_rec_border (R(n));
                R(n)->prop = L(R(n))->prop;
            }
            break;
    }
    if (base_path)
        pfIN(n) = true;

    return base_path;
}

/**
 * reset the 'in' bits.
 * (We know that these 'in' bits are set for the seed
 *  and all lie on a path starting from the seed.)
 */
static void
in_reset (PFpa_op_t *n)
{
    unsigned int i;

    if (!pfIN(n))
        return;
    else
        pfIN(n) = false;

    for (i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
        in_reset (n->child[i]);
}

/**
 * Introduce boundary operators for every recursion
 * such that the MIL generation detects expressions
 * that are invariant to the recursion body.
 *
 * Walk down the DAG and for each recursion operator
 * introduce border operators.
 *
 * We mark all operators that lie on the path from the
 * result (or the recursion arguments) to the base
 * operators of the recursion as inside the recursion body.
 *
 * A border is introduced between nodes (a) and (b) where
 * (a) is the parent of (b), (a) lies in the set of nodes marked
 * as inside, and (b) lies in the set of nodes marked as outside
 * of the recursion body.
 */
static void
introduce_rec_borders (PFpa_op_t *n)
{
    if (SEEN(n))
        return;
    else
        SEEN(n) = true;

    switch (n->kind)
    {
        case pa_rec_fix:
        {
            PFarray_t *bases = PFarray (sizeof (PFpa_op_t *), 3);
            PFpa_op_t *cur;

            /* collect base operators */
            assert (L(n)->kind == pa_side_effects);
            cur = LR(n);
            while (cur->kind != pa_nil) {
                assert (cur->kind == pa_rec_param &&
                        L(cur)->kind == pa_rec_arg);
                *(PFpa_op_t **) PFarray_add (bases) = L(cur)->sem.rec_arg.base;
                cur = R(cur);
            }

            /* call the path traversal worker, that introduces
               the border operator and marks all 'inside' nodes,
               for all recursion arguments as well as the result */
            cur = LL(n);
            while (cur->kind != pa_nil) {
                introduce_rec_borders_worker (R(cur), bases);
                cur = L(cur);
            }
            cur = LR(n);
            while (cur->kind != pa_nil) {
                introduce_rec_borders_worker (LR(cur), bases);
                cur = R(cur);
            }
            introduce_rec_borders_worker (R(n), bases);

            /* Remove the 'in' flag for all nodes */
            cur = LL(n);
            while (cur->kind != pa_nil) {
                in_reset (R(cur));
                cur = L(cur);
            }
            cur = LR(n);
            while (cur->kind != pa_nil) {
                in_reset (LR(cur));
                cur = R(cur);
            }
            in_reset (R(n));
        } break;

        default:
            for (unsigned int i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
                introduce_rec_borders (n->child[i]);
            break;
    }
}

/**
 * Traverse the complete plan and annotate all operators
 * except for the operators we want to evaluate in dependence.
 */
static void
mark_plan (PFpa_op_t *n, PFpa_op_t *dep_op)
{
    if (pfIN(n))
        return;
    else
        pfIN(n) = true;

    if (n == dep_op) {
        assert (n->kind == pa_dep_cross);

        mark_plan (L(n), dep_op);

        /* don't mark the right side */
    }
    else
        for (unsigned int i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
            mark_plan (n->child[i], dep_op);
}

/**
 * Worker for introduce_dep_borders.
 */ 
static void
introduce_dep_borders_worker (PFpa_op_t *n)
{
    /* We mark only the independent operators as SEEN as we stop
       as soon as we reach a boundary to an dependent operator. */
    if (SEEN(n))
        return;
    else
        SEEN(n) = true;

    for (unsigned int i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
        if (!pfIN(n) && pfIN(n->child[i]) &&
            n->child[i]->kind != pa_nil) {
            /* Introduce a border if a boundary is reached
               and stop the traversal. */
            n->child[i] = PFpa_dep_border (n->child[i]);
            n->child[i]->prop = L(n->child[i])->prop;
        }
        else
            /* Recursively traverse the plan otherwise. */
            introduce_dep_borders_worker (n->child[i]);

    /* Rewrite dependent cross products that are nested in
       the right side of another dependent cross into normal
       cross products again. */
    if (n->kind == pa_dep_cross)
        /* we can replace the kind as the two cross
           product operators behave exactly the same */
        n->kind = pa_cross;
}

/**
 * Traverse the query plan and find operators that
 * introduce dependencies.
 */
static void
introduce_dep_borders (PFpa_op_t *n, PFpa_op_t *root)
{
    if (SEEN(n))
        return;
    else
        SEEN(n) = true;

    /* Detect borders for this operator. */
    if (n->kind == pa_dep_cross) {
        /* Traverse the query plan for the left argument */
        introduce_dep_borders (L(n), root);

        /* Mark all operators that are reachable from the
           root (except for the right side of n) to detect
           which operators are referenced from both in-/outside. */
        mark_plan (root, n);

        /* Dependent cross products that have no operators
           that can be evaluated in dependence are rewritten
           into normal cross products again. */
        if (pfIN(R(n)))
            /* we can replace the kind as the two cross
               product operators behave exactly the same */
            n->kind = pa_cross;
        else
            /* Introduce the borders for this operator. */
            introduce_dep_borders_worker (R(n));
        in_reset (root);
    }
    else
        for (unsigned int i = 0; i < PFPA_OP_MAXCHILD && n->child[i]; i++)
            introduce_dep_borders (n->child[i], root);
}

/**
 * Introduce boundary operators.
 */
PFpa_op_t *
PFpa_intro_borders (PFpa_op_t *n)
{
    /* Introduce border operators
       for recursions. */
    introduce_rec_borders (n);
    PFpa_dag_reset (n);

    /* Introduce border operators
       for dependency generating operators */
    introduce_dep_borders (n, n);
    PFpa_dag_reset (n);

    return n;
}
