/**
 * @file
 *
 * Inference of domain property of all native type columns
 * of logical algebra expressions. (Here we avoid the domain
 * property inference for all columns that have an XQuery type as
 * a large number of optimizations use the domain property only
 * for equi-join rewrites. This restricted variant is cheaper to infer
 * and to use -- in PFprop_subdom -- while still providing enough
 * information to optimize.)
 *
 * We use abstract domain identifiers (implemented as integers)
 * that stand for the value domains of relational columns.  We
 * introduce a new domain identifier whenever the active value
 * domain may be changed by an operator.  Some operators guarantee
 * the _inclusion_ or _disjointness_ of involved domains.  We
 * record those in the @subdoms@ and @disjdoms@ fields of the
 * #PFprop_t property container.  Subdomain relationships will
 * also be printed in the dot debugging output.  Both aspects will
 * be printed in the XML debugging output.
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
 * 2000-2005 University of Konstanz and (C) 2005-2008 Technische
 * Universitaet Muenchen, respectively.  All Rights Reserved.
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

/* Easily access subtree-parts */
#include "child_mnemonic.h"

/** Identifier for the (statically known) empty domain */
#define EMPTYDOM 1

/**
 * common_super_dom finds the lowest common domain of @a dom1 and
 * @a dom2 (using the domain relationship list in property container
 * @a prop).
 */
static dom_t
common_super_dom (const PFprop_t *prop, dom_t dom1, dom_t dom2)
{
    PFarray_t *domains1, *domains2, *merge_doms;
    bool insert, duplicate;
    dom_t subdom, dom, subitem;

    assert (prop);
    assert (prop->subdoms);

    /* check trivial case of identity */
    if (dom1 == dom2)
        return dom1;

    /* collect all the super domains for each input */

    /* start with the input domains as seed */
    domains1 = PFarray (sizeof (dom_t), 10);
    *(dom_t *) PFarray_add (domains1) = dom1;
    domains2 = PFarray (sizeof (dom_t), 10);
    *(dom_t *) PFarray_add (domains2) = dom2;

    for (unsigned int i = PFarray_last (prop->subdoms); i > 0; i--) {
        subdom = ((subdom_t *) PFarray_at (prop->subdoms, i-1))->subdom;
        dom = ((subdom_t *) PFarray_at (prop->subdoms, i-1))->dom;

        insert = false;
        duplicate = false;
        for (unsigned int j = 0; j < PFarray_last (domains1); j++) {
            subitem = *(dom_t *) PFarray_at (domains1, j);
            if (subdom == subitem)
                insert = true;
            if (dom == subitem)
                duplicate = true;
        }
        if (insert && !duplicate)
            *(dom_t *) PFarray_add (domains1) = dom;

        insert = false;
        duplicate = false;
        for (unsigned int j = 0; j < PFarray_last (domains2); j++) {
            subitem = *(dom_t *) PFarray_at (domains2, j);
            if (subdom == subitem)
                insert = true;
            if (dom == subitem)
                duplicate = true;
        }
        if (insert && !duplicate)
            *(dom_t *) PFarray_add (domains2) = dom;
    }

    /* intersect both domain lists */
    merge_doms = PFarray (sizeof (dom_t), 10);
    for (unsigned int i = 0; i < PFarray_last (domains1); i++) {
        dom1 = *(dom_t *) PFarray_at (domains1, i);
        for (unsigned int j = 0; j < PFarray_last (domains2); j++) {
            dom2 = *(dom_t *) PFarray_at (domains2, j);
            if (dom1 == dom2) *(dom_t *) PFarray_add (merge_doms) = dom1;
        }
    }

    /* no common super domain exists */
    if (!PFarray_last (merge_doms))
        return 0;

    dom1 = *(dom_t *) PFarray_at (merge_doms, 0);

    /* trivial case -- only one common domain */
    if (PFarray_last (merge_doms) == 1)
        return dom1;

    /* find the leaf node (of the domain tree) */
    for (unsigned int i = 1; i < PFarray_last (merge_doms); i++) {
        dom2 = *(dom_t *) PFarray_at (merge_doms, i);
        if (!dom1 /* undecided */ ||
            PFprop_subdom (prop, dom2, dom1))
            dom1 = dom2;
        else if (PFprop_subdom (prop, dom1, dom2))
            dom1 = dom1;
        else
            /* undecided */
            dom1 = 0;
    }
    /* If we still stay undecided just report no
       common super domain. The only consequence is
       that we then might detect less subdomain
       relationships. */

    return dom1;
}

/**
 * Copy domains of children nodes to the property container.
 */
static void
copy_child_domains (PFla_op_t *n)
{
    if (L(n))
        for (unsigned int i = 0; i < L(n)->schema.count; i++) {
            *(dom_pair_t *) PFarray_add (n->prop->l_domains)
                = (dom_pair_t) { .col = L(n)->schema.items[i].name,
                                 .dom = PFprop_dom (
                                            L(n)->prop,
                                            L(n)->schema.items[i].name)};
        }

    if (R(n))
        for (unsigned int i = 0; i < R(n)->schema.count; i++) {
            *(dom_pair_t *) PFarray_add (n->prop->r_domains)
                = (dom_pair_t) { .col = R(n)->schema.items[i].name,
                                 .dom = PFprop_dom (
                                            R(n)->prop,
                                            R(n)->schema.items[i].name)};
        }
}

/**
 * Add a domain-subdomain relationship.
 */
static void
add_subdom (PFprop_t *prop, dom_t dom, dom_t subdom)
{
    assert (prop);
    assert (prop->subdoms);

    *(subdom_t *) PFarray_add (prop->subdoms)
        = (subdom_t) { .dom = dom, .subdom = subdom };
}

/**
 * Add disjointness information for domains @a a and @a b.
 */
static void
add_disjdom (PFprop_t *prop, dom_t a, dom_t b)
{
    assert (prop);
    assert (prop->disjdoms);

    *(disjdom_t *) PFarray_add (prop->disjdoms)
        = (disjdom_t) { .dom1 = a, .dom2 = b };
}

/**
 * Add a new domain to the list of domains
 * (stored in property container @a prop).
 */
static void
add_dom (PFprop_t *prop, PFalg_col_t col, dom_t dom)
{
    assert (prop);
    assert (prop->domains);

    *(dom_pair_t *) PFarray_add (prop->domains)
        = (dom_pair_t) { .col = col, .dom = dom };
}

/**
 * Add all domains of the node @a child to the list of domains
 * (stored in property container @a prop).
 */
static void
bulk_add_dom (PFprop_t *prop, PFla_op_t *child)
{
    dom_t cur_dom;
    assert (prop);
    assert (child);
    assert (child->prop);

    for (unsigned int i = 0; i < child->schema.count; i++)
        if ((cur_dom = PFprop_dom (child->prop,
                                   child->schema.items[i].name)))
            add_dom (prop, child->schema.items[i].name, cur_dom);
}

/**
 * Infer domain properties; worker for prop_infer().
 */
static unsigned int
infer_dom (PFla_op_t *n, unsigned int id)
{
    switch (n->kind) {
        case la_serialize_seq:
        case la_serialize_rel:
            bulk_add_dom (n->prop, R(n));
            break;

        case la_side_effects:
            break;

        case la_lit_tbl:
            /* create new domains for all columns */
            for (unsigned int i = 0; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop, n->schema.items[i].name, id++);
            break;

        case la_empty_tbl:
            /* assign each column the empty domain (1) */
            for (unsigned int i = 0; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop, n->schema.items[i].name, EMPTYDOM);
            break;

        case la_ref_tbl:
            /* create new domains for all columns */
            for (unsigned int i = 0; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop, n->schema.items[i].name, id++);
            break;


        case la_attach:
            bulk_add_dom (n->prop, L(n));
            if (n->sem.attach.value.type == aat_nat)
                add_dom (n->prop, n->sem.attach.res, id++);
            break;

        case la_cross:
            /* we have to make sure to assign subdomains as otherwise
               dynamic empty relations might be ignored */
        case la_thetajoin:
            /* As we do not know how multiple predicates interact
               we assign subdomains for all columns. */
        {

            dom_t cur_dom;

            /* create new subdomains for all columns */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if ((cur_dom = PFprop_dom (L(n)->prop,
                                           L(n)->schema.items[i].name))) {
                    add_subdom (n->prop, cur_dom, id);
                    add_dom (n->prop, L(n)->schema.items[i].name, id);
                    id++;
                }
            /* create new subdomains for all columns */
            for (unsigned int i = 0; i < R(n)->schema.count; i++)
                if ((cur_dom = PFprop_dom (R(n)->prop,
                                           R(n)->schema.items[i].name))) {
                    add_subdom (n->prop, cur_dom, id);
                    add_dom (n->prop, R(n)->schema.items[i].name, id);
                    id++;
                }
        }   break;

        case la_eqjoin:
        {   /**
             * Infering the domains of the join columns results
             * in a common schema, that is either the more general
             * domain if the are in a subdomain relationship or a
             * new subdomain. The domains of all other columns
             * (whose domain is different from the domains of the
             * join arguments) remain unchanged.
             */
            dom_t col1_dom = PFprop_dom (L(n)->prop,
                                         n->sem.eqjoin.col1);
            dom_t col2_dom = PFprop_dom (R(n)->prop,
                                         n->sem.eqjoin.col2);
            dom_t join_dom;
            dom_t cur_dom;

            if (col1_dom == col2_dom)
                join_dom = col1_dom;
            else if (PFprop_subdom (n->prop, col1_dom, col2_dom))
                join_dom = col1_dom;
            else if (PFprop_subdom (n->prop, col2_dom, col1_dom))
                join_dom = col2_dom;
            else {
                join_dom = id++;
                if (col1_dom) {
                    add_subdom (n->prop, col1_dom, join_dom);
                    add_subdom (n->prop, col2_dom, join_dom);
                }
            }

            /* copy domains and update domains of join arguments */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {
                    if ((cur_dom = PFprop_dom (
                                       L(n)->prop,
                                       L(n)->schema.items[i].name))
                        == col1_dom)
                        add_dom (n->prop, L(n)->schema.items[i].name, join_dom);
                    else if (join_dom == col1_dom)
                        add_dom (n->prop, L(n)->schema.items[i].name, cur_dom);
                    else {
                        add_subdom (n->prop, cur_dom, id);
                        add_dom (n->prop, L(n)->schema.items[i].name, id++);
                    }
                }

            for (unsigned int i = 0; i < R(n)->schema.count; i++)
                if (R(n)->schema.items[i].type == aat_nat) {
                    if ((cur_dom = PFprop_dom (
                                       R(n)->prop,
                                       R(n)->schema.items[i].name))
                        == col2_dom)
                        add_dom (n->prop, R(n)->schema.items[i].name, join_dom);
                    else if (join_dom == col2_dom)
                        add_dom (n->prop, R(n)->schema.items[i].name, cur_dom);
                    else {
                        add_subdom (n->prop, cur_dom, id);
                        add_dom (n->prop, R(n)->schema.items[i].name, id++);
                    }
                }
        }   break;

        case la_internal_op:
            /* interpret this operator as internal join */
            if (n->sem.eqjoin_opt.kind == la_eqjoin) {
                /* do the same as for normal joins and
                   correctly update the columns names */
#define proj_at(l,i) (*(PFalg_proj_t *) PFarray_at ((l),(i)))
                /**
                 * Infering the domains of the join columns results
                 * in a common domain, that is either the more general
                 * domain if the are in a subdomain relationship or a
                 * new subdomain. The domains of all other columns
                 * (whose domain is different from the domains of the
                 * join arguments) remain unchanged.
                 */
                PFarray_t  *lproj = n->sem.eqjoin_opt.lproj,
                           *rproj = n->sem.eqjoin_opt.rproj;
                PFalg_col_t col1  = proj_at(lproj, 0).old,
                            col2  = proj_at(rproj, 0).old,
                            res   = proj_at(lproj, 0).new;
                
                dom_t col1_dom = PFprop_dom (L(n)->prop, col1),
                      col2_dom = PFprop_dom (R(n)->prop, col2),
                      join_dom,
                      cur_dom;

                if (col1_dom == col2_dom)
                    join_dom = col1_dom;
                else if (PFprop_subdom (n->prop, col1_dom, col2_dom))
                    join_dom = col1_dom;
                else if (PFprop_subdom (n->prop, col2_dom, col1_dom))
                    join_dom = col2_dom;
                else {
                    join_dom = id++;
                    add_subdom (n->prop, col1_dom, join_dom);
                    add_subdom (n->prop, col2_dom, join_dom);
                }
                add_dom (n->prop, res, join_dom);

                /* copy domains and update domains of join arguments */
                for (unsigned int i = 1; i < PFarray_last (lproj); i++)
                    if (PFprop_type_of (L(n), proj_at (lproj, i).old) == aat_nat) {
                        if ((cur_dom = PFprop_dom (
                                           L(n)->prop,
                                           proj_at (lproj, i).old))
                            == col1_dom)
                            add_dom (n->prop, proj_at (lproj, i).new, join_dom);
                        else if (join_dom == col1_dom)
                            add_dom (n->prop, proj_at (lproj, i).new, cur_dom);
                        else {
                            add_subdom (n->prop, cur_dom, id);
                            add_dom (n->prop, proj_at (lproj, i).new, id++);
                        }
                    }

                for (unsigned int i = 1; i < PFarray_last (rproj); i++)
                    if (PFprop_type_of (R(n), proj_at (rproj, i).old) == aat_nat) {
                        if ((cur_dom = PFprop_dom (
                                           R(n)->prop,
                                           proj_at (rproj, i).old))
                            == col2_dom)
                            add_dom (n->prop, proj_at (rproj, i).new, join_dom);
                        else if (join_dom == col2_dom)
                            add_dom (n->prop, proj_at (rproj, i).new, cur_dom);
                        else {
                            add_subdom (n->prop, cur_dom, id);
                            add_dom (n->prop, proj_at (rproj, i).new, id++);
                        }
                    }
            }
            else
                PFoops (OOPS_FATAL,
                        "internal optimization operator is not allowed here");
            break;

        case la_semijoin:
        {   /**
             * Infering the domains of the join columns results
             * in a common schema, that is either the more general
             * domain if the are in a subdomain relationship or a
             * new subdomain. The domains of all other columns
             * (whose domain is different from the domains of the
             * join arguments) remain unchanged.
             */
            dom_t col1_dom = PFprop_dom (L(n)->prop,
                                         n->sem.eqjoin.col1);
            dom_t col2_dom = PFprop_dom (R(n)->prop,
                                         n->sem.eqjoin.col2);
            dom_t join_dom;
            dom_t cur_dom;

            if (col1_dom == col2_dom)
                join_dom = col1_dom;
            else if (PFprop_subdom (n->prop, col1_dom, col2_dom))
                join_dom = col1_dom;
            else if (PFprop_subdom (n->prop, col2_dom, col1_dom))
                join_dom = col2_dom;
            else {
                join_dom = id++;
                if (col1_dom) {
                    add_subdom (n->prop, col1_dom, join_dom);
                    add_subdom (n->prop, col2_dom, join_dom);
                }
            }

            /* copy domains and update domains of join arguments */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {
                    if ((cur_dom = PFprop_dom (
                                       L(n)->prop,
                                       L(n)->schema.items[i].name))
                        == col1_dom)
                        add_dom (n->prop, L(n)->schema.items[i].name, join_dom);
                    else if (join_dom == col1_dom)
                        add_dom (n->prop, L(n)->schema.items[i].name, cur_dom);
                    else {
                        add_subdom (n->prop, cur_dom, id);
                        add_dom (n->prop, L(n)->schema.items[i].name, id++);
                    }
                }
        }   break;

        case la_project:
            /* bind all existing domains to the possibly new names */
            for (unsigned int i = 0; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop,
                             n->sem.proj.items[i].new,
                             PFprop_dom (L(n)->prop,
                                         n->sem.proj.items[i].old));
            break;

        case la_select:
        case la_pos_select:
            /* create new subdomains for all columns */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {
                    add_subdom (n->prop,
                                PFprop_dom (L(n)->prop,
                                            L(n)->schema.items[i].name),
                                id);
                    add_dom (n->prop, L(n)->schema.items[i].name, id);
                    id++;
                }
            break;

        case la_disjunion:
            /* create new superdomains for all existing columns */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {
                    unsigned int j;
                    dom_t dom1, dom2, union_dom, cdom;

                    for (j = 0; j < R(n)->schema.count; j++)
                        if (L(n)->schema.items[i].name ==
                            R(n)->schema.items[j].name) {
                            if (R(n)->schema.items[j].type != aat_nat)
                                break;

                            dom1 = PFprop_dom (L(n)->prop,
                                               L(n)->schema.items[i].name);
                            dom2 = PFprop_dom (R(n)->prop,
                                               R(n)->schema.items[j].name);

                            if (dom1 == dom2)
                                union_dom = dom1;
                            else if (PFprop_subdom (n->prop, dom1, dom2) ||
                                     dom1 == EMPTYDOM)
                                union_dom = dom2;
                            else if (PFprop_subdom (n->prop, dom2, dom1) ||
                                     dom2 == EMPTYDOM)
                                union_dom = dom1;
                            else {
                                union_dom = id++;
                                /* add an edge to the new domain from the
                                   lowest common subdomain of its input */
                                cdom = common_super_dom (n->prop, dom1, dom2);
                                if (cdom)
                                    add_subdom (n->prop, cdom, union_dom);

                                add_subdom (n->prop, union_dom, dom1);
                                add_subdom (n->prop, union_dom, dom2);
                            }
                            add_dom (n->prop,
                                     L(n)->schema.items[i].name,
                                     union_dom);
                            break;
                        }
                    if (j == R(n)->schema.count)
                        PFoops (OOPS_FATAL,
                                "can't find matching columns in "
                                "domain property inference.");
                }
            break;

        case la_intersect:
            /* create new subdomains for all existing columns */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {
                    unsigned int j;
                    for (j = 0; j < R(n)->schema.count; j++)
                        if (L(n)->schema.items[i].name ==
                            R(n)->schema.items[j].name) {
                            assert (R(n)->schema.items[j].type == aat_nat);
                            add_subdom (
                                n->prop,
                                PFprop_dom (L(n)->prop,
                                            L(n)->schema.items[i].name),
                                id);
                            add_subdom (
                                n->prop,
                                PFprop_dom (R(n)->prop,
                                            R(n)->schema.items[j].name),
                                id);
                            add_dom (n->prop, L(n)->schema.items[i].name, id);
                            id++;
                            break;
                        }
                    if (j == R(n)->schema.count)
                        PFoops (OOPS_FATAL,
                                "can't find matching columns in "
                                "domain property inference.");
                }
            break;

        case la_difference:
            /*
             * In case of the difference operator we know that
             *
             *  -- the domains for all columns must be subdomains
             *     in the left argument and
             *  -- the domains for all columns are disjoint from
             *     those in the right argument.
             */
            /* create new subdomains for all existing columns */
            for (unsigned int i = 0; i < L(n)->schema.count; i++)
                if (L(n)->schema.items[i].type == aat_nat) {

                    add_dom (n->prop, L(n)->schema.items[i].name, id);

                    add_subdom (n->prop,
                                PFprop_dom (L(n)->prop,
                                            L(n)->schema.items[i].name),
                                id);

                    add_disjdom (n->prop,
                                 id,
                                 PFprop_dom (R(n)->prop,
                                             L(n)->schema.items[i].name));

                    id++;
                }
            break;

        case la_distinct:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_fun_1to1:
        case la_num_eq:
        case la_num_gt:
        case la_bool_and:
        case la_bool_or:
        case la_bool_not:
        case la_to:
        case la_type:
        case la_cast:
        case la_type_assert:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_avg:
        case la_max:
        case la_min:
        case la_sum:
        case la_count:
        case la_seqty1:
        case la_all:
            if (n->sem.aggr.part) {
                PFalg_simple_type_t join_ty = 0;
                /* find the partition type */
                for (unsigned int i = 0; i < n->schema.count; i++)
                    if (n->schema.items[i].name == n->sem.aggr.part) {
                        join_ty = n->schema.items[i].type;
                        break;
                    }
                assert (join_ty);

                if (join_ty == aat_nat)
                    add_dom (n->prop,
                             n->sem.aggr.part,
                             PFprop_dom (L(n)->prop, n->sem.aggr.part));
            }
            break;

        case la_rownum:
        case la_rowrank:
        case la_rank:
            bulk_add_dom (n->prop, L(n));
            add_dom (n->prop, n->sem.sort.res, id++);
            break;

        case la_rowid:
            bulk_add_dom (n->prop, L(n));
            add_dom (n->prop, n->sem.rowid.res, id++);
            break;

        case la_step:
        case la_guide_step:
            /* create new subdomain for column iter */
            add_subdom (n->prop, PFprop_dom (R(n)->prop,
                                             n->sem.step.iter), id);
            add_dom (n->prop, n->sem.step.iter, id++);
            break;

        case la_step_join:
        case la_guide_step_join:
            for (unsigned int i = 0; i < R(n)->schema.count; i++)
                if (R(n)->schema.items[i].type == aat_nat) {
                    add_subdom (n->prop,
                                PFprop_dom (R(n)->prop,
                                            R(n)->schema.items[i].name),
                                id);
                    add_dom (n->prop, R(n)->schema.items[i].name, id++);
                }
            break;

        case la_doc_index_join:
            for (unsigned int i = 0; i < R(n)->schema.count; i++)
                if (R(n)->schema.items[i].type == aat_nat) {
                    add_subdom (n->prop,
                                PFprop_dom (R(n)->prop,
                                            R(n)->schema.items[i].name),
                                id);
                    add_dom (n->prop, R(n)->schema.items[i].name, id++);
                }
            break;

        case la_doc_tbl:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_doc_access:
            bulk_add_dom (n->prop, R(n));
            break;

        case la_twig:
            /* retain domain for column iter */
            switch (L(n)->kind) {
                case la_docnode:
                    add_dom (n->prop,
                             n->sem.iter_item.iter,
                             PFprop_dom (L(n)->prop,
                                         L(n)->sem.docnode.iter));
                    break;

                case la_element:
                case la_comment:
                    add_dom (n->prop,
                             n->sem.iter_item.iter,
                             PFprop_dom (L(n)->prop,
                                         L(n)->sem.iter_item.iter));
                    break;

                case la_textnode:
                    /* because of empty textnode constructors
                       create new subdomain for column iter */
                    add_subdom (n->prop,
                                PFprop_dom (L(n)->prop,
                                            L(n)->sem.iter_item.iter),
                                id);
                    add_dom (n->prop, n->sem.iter_item.iter, id++);
                    break;
                    
                case la_attribute:
                case la_processi:
                    add_dom (n->prop,
                             n->sem.iter_item.iter,
                             PFprop_dom (L(n)->prop,
                                         L(n)->sem.iter_item1_item2.iter));
                    break;

                case la_content:
                    add_dom (n->prop,
                             n->sem.iter_item.iter,
                             PFprop_dom (L(n)->prop,
                                         L(n)->sem.iter_pos_item.iter));
                    break;

                default:
                    break;
            }
            break;

        case la_fcns:
            break;

        case la_docnode:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.docnode.iter,
                     PFprop_dom (L(n)->prop, n->sem.docnode.iter));
            break;

        case la_element:
        case la_comment:
        case la_textnode:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.iter_item.iter,
                     PFprop_dom (L(n)->prop, n->sem.iter_item.iter));
            break;

        case la_attribute:
        case la_processi:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.iter_item1_item2.iter,
                     PFprop_dom (L(n)->prop, n->sem.iter_item1_item2.iter));
            break;

        case la_content:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.iter_pos_item.iter,
                     PFprop_dom (R(n)->prop, n->sem.iter_pos_item.iter));
            break;

        case la_merge_adjacent:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.merge_adjacent.iter_res,
                     PFprop_dom (R(n)->prop,
                                 n->sem.merge_adjacent.iter_in));
            /* create new subdomain for column pos */
            add_subdom (n->prop,
                        PFprop_dom (L(n)->prop,
                                    n->sem.merge_adjacent.pos_in),
                        id);
            add_dom (n->prop, n->sem.merge_adjacent.pos_res, id++);
            break;

        case la_roots:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_fragment:
        case la_frag_extract:
        case la_frag_union:
        case la_empty_frag:
        case la_fun_frag_param:
            break;

        case la_error:
            bulk_add_dom (n->prop, R(n));
            break;

        case la_nil:
        case la_trace:
            /* we have no properties */
            break;

        case la_trace_items:
        case la_trace_msg:
        case la_trace_map:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_rec_fix:
            /* get the domains of the overall result */
            bulk_add_dom (n->prop, R(n));
            break;

        case la_rec_param:
            /* recursion parameters do not have properties */
            break;

        case la_rec_arg:
            bulk_add_dom (n->prop, R(n));
            break;

        case la_rec_base:
            /* create new domains for all columns */
            for (unsigned int i = 0; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop, n->schema.items[i].name, id++);
            break;

        case la_fun_call:
        {
            unsigned int i = 0;
            if (n->sem.fun_call.occ_ind == alg_occ_exactly_one &&
                n->sem.fun_call.kind == alg_fun_call_xrpc &&
                n->schema.items[0].type == aat_nat) {
                add_dom (n->prop,
                         n->schema.items[0].name,
                         PFprop_dom (L(n)->prop, n->sem.fun_call.iter));
                i++;
            } else if (n->sem.fun_call.occ_ind == alg_occ_zero_or_one &&
                       n->sem.fun_call.kind == alg_fun_call_xrpc &&
                       n->schema.items[0].type == aat_nat) {
                add_subdom (n->prop,
                            PFprop_dom (L(n)->prop, n->sem.fun_call.iter),
                            id);
                add_dom (n->prop, n->schema.items[0].name, id++);
                i++;
            }

            /* create new domains for all (remaining) columns */
            for (; i < n->schema.count; i++)
                if (n->schema.items[i].type == aat_nat)
                    add_dom (n->prop, n->schema.items[i].name, id++);
        }   break;

        case la_fun_param:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_proxy:
        case la_proxy_base:
            bulk_add_dom (n->prop, L(n));
            break;

        case la_string_join:
            /* retain domain for column iter */
            add_dom (n->prop,
                     n->sem.string_join.iter_res,
                     PFprop_dom (R(n)->prop, n->sem.string_join.iter_sep));
            break;

        case la_dummy:
            bulk_add_dom (n->prop, L(n));
            break;
    }
    return id;
}

/* worker for PFprop_infer_dom */
static unsigned int
prop_infer (PFla_op_t *n, PFarray_t *subdoms, PFarray_t *disjdoms,
            unsigned int cur_dom_id)
{
    assert (n);

    /* nothing to do if we already visited that node */
    if (n->bit_dag)
        return cur_dom_id;

    /* infer properties for children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
        cur_dom_id = prop_infer (n->child[i], subdoms, disjdoms, cur_dom_id);

    n->bit_dag = true;

    /* assign all nodes the same domain relation */
    n->prop->subdoms   = subdoms;
    n->prop->disjdoms  = disjdoms;

    /* reset the domain information
       (reuse already existing lists if already available
        as this increases the performance of the compiler a lot) */
    if (n->prop->domains)
        PFarray_last (n->prop->domains) = 0;
    else
        /* prepare the property for 10 columns */
        n->prop->domains   = PFarray (sizeof (dom_pair_t), 10);

    if (L(n)) {
        if (n->prop->l_domains)
            PFarray_last (n->prop->l_domains) = 0;
        else
            /* prepare the property for 10 columns */
            n->prop->l_domains = PFarray (sizeof (dom_pair_t), 10);
    }

    if (R(n)) {
        if (n->prop->r_domains)
            PFarray_last (n->prop->r_domains) = 0;
        else
            /* prepare the property for 10 columns */
            n->prop->r_domains = PFarray (sizeof (dom_pair_t), 10);
    }

    /* copy all children domains */
    copy_child_domains (n);

    /* infer information on domain columns */
    cur_dom_id = infer_dom (n, cur_dom_id);

    return cur_dom_id;
}

/**
 * Infer domain property for the columns of type nat in a DAG rooted in root
 */
void
PFprop_infer_nat_dom (PFla_op_t *root)
{
    /*
     * Initialize domain property inference with an empty domain
     * relation list,
     */
    PFarray_t *subdoms  = PFarray (sizeof (subdom_t), 50);
    PFarray_t *disjdoms = PFarray (sizeof (disjdom_t), 50);

    prop_infer (root, subdoms, disjdoms, 2);

    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
