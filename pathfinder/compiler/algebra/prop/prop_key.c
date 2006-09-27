/**
 * @file
 *
 * Inference of key property of logical algebra expressions.
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

#include "properties.h"
#include "alg_dag.h"
#include "oops.h"
#include "mem.h"
#include "qname.h"

/*
 * Easily access subtree-parts.
 */
/** starting from p, make a step left */
#define L(p) ((p)->child[0])
/** starting from p, make a step right */
#define R(p) ((p)->child[1])

/**
 * worker for PFprop_key;
 * Test if @a attr is in the list of key columns in array @a keys
 */
static bool
key_worker (PFarray_t *keys, PFalg_att_t attr)
{
    if (!keys) return false;

    for (unsigned int i = 0; i < PFarray_last (keys); i++)
        if (attr == *(PFalg_att_t *) PFarray_at (keys, i))
            return true;

    return false;
}

/**
 * Test if @a attr is in the list of key columns in container @a prop
 */
bool
PFprop_key (const PFprop_t *prop, PFalg_att_t attr)
{
    return key_worker (prop->keys, attr);
}

/**
 * Test if @a attr is in the list of key columns of the left child
 * (information is stored in property container @a prop)
 */
bool
PFprop_key_left (const PFprop_t *prop, PFalg_att_t attr)
{
    return key_worker (prop->l_keys, attr);
}

/**
 * Test if @a attr is in the list of key columns of the right child
 * (information is stored in property container @a prop)
 */
bool
PFprop_key_right (const PFprop_t *prop, PFalg_att_t attr)
{
    return key_worker (prop->r_keys, attr);
}

/**
 * worker for PFprop_keys_count and PFprop_keys_to_attlist
 */
static unsigned int
keys_count (const PFprop_t *prop)
{
    if (!prop->keys)
        return 0;
    else
        return PFarray_last (prop->keys);
}

/*
 * count number of key attributes
 */
unsigned int
PFprop_keys_count (const PFprop_t *prop)
{
    return keys_count (prop);
}

/**
 * Return key attributes in an attlist.
 */
PFalg_attlist_t
PFprop_keys_to_attlist (const PFprop_t *prop)
{
    PFalg_attlist_t new_list;

    new_list.count = keys_count (prop);
    new_list.atts = PFmalloc (new_list.count * sizeof (*(new_list.atts)));

    if (!prop->keys)
        return new_list;

    for (unsigned int i = 0; i < PFarray_last (prop->keys); i++)
        new_list.atts[i] = *(PFalg_att_t *) PFarray_at (prop->keys, i);

    return new_list;
}

/**
 * Extends key list @a with attribute @a b
 * if @a b is not in the list.
 */
static void
union_ (PFarray_t *a, PFalg_att_t b)
{
    assert (a);

    if (!key_worker (a, b))
        *(PFalg_att_t *) PFarray_add (a) = b;
}

/**
 * Extends key list @a with all the items
 * of the key list @a b that are not in @a a/
 */
static void
union_list (PFarray_t *a, PFarray_t *b)
{
    PFalg_att_t cur;

    assert (a && b);

    for (unsigned int i = 0; i < PFarray_last (b); i++) {
        cur = *(PFalg_att_t *) PFarray_at (b, i);
        if (!key_worker (a, cur))
            *(PFalg_att_t *) PFarray_add (a) = cur;
    }
}

static void
copy (PFarray_t *base, PFarray_t *content)
{
    for (unsigned int i = 0; i < PFarray_last (content); i++)
        *(PFalg_att_t *) PFarray_add (base) =
            *(PFalg_att_t *) PFarray_at (content, i);
}

/**
 * Infer key property of a given node @a n; worker for prop_infer().
 */
static void
infer_key (PFla_op_t *n)
{
    /* copy key properties of children into current node */
    if (L(n)) copy (n->prop->l_keys, L(n)->prop->keys);
    if (R(n)) copy (n->prop->r_keys, R(n)->prop->keys);

    switch (n->kind) {
        case la_serialize:
            /* just copy keys from left child */
            copy (n->prop->keys, R(n)->prop->keys);
            break;

        case la_lit_tbl:
            /* all columns are key */
            if (n->sem.lit_tbl.count == 1)
                for (unsigned int i = 0; i < n->schema.count; i++)
                    union_ (n->prop->keys, n->schema.items[i].name);
            else
                for (unsigned int i = 0; i < n->schema.count; i++) {
                    unsigned int j = 0;
                    unsigned int k = 0;

                    /* skip all columns where the comparison
                       might be unstable in respect to
                       differing implementations */
                    if (n->schema.items[i].type != aat_nat &&
                        n->schema.items[i].type != aat_int)
                        continue;

                    /* compare each tuple with all others */
                    while (j < n->sem.lit_tbl.count) {
                        if (!PFalg_atom_cmp (n->sem.lit_tbl.tuples[j].atoms[i],
                                             n->sem.lit_tbl.tuples[k].atoms[i]))
                            break;
                        else if (k == n->sem.lit_tbl.count)
                            { k = 0; j++; }
                        else
                            k++;
                    }
                    /* all values are unique thus also key */
                    if (j == n->sem.lit_tbl.count)
                        union_ (n->prop->keys, n->schema.items[i].name);

                }
            break;

        case la_disjunion:
            /*
             * If
             *  (a) an attribute a is key in both arguments and
             *  (b) the domains of a in the two arguments are disjoint
             * a will be key in the result as well.
             *
             * (We need domain information for this, though.)
             */
            if (L(n)->prop->domains && R(n)->prop->domains
                && n->prop->disjdoms) {

                for (unsigned int i = 0;
                        i < PFarray_last (L(n)->prop->keys); i++) {

                    PFalg_att_t key_att
                        = *(PFalg_att_t *) PFarray_at (L(n)->prop->keys, i);

                    if (key_worker (R(n)->prop->keys, key_att)
                        && PFprop_disjdom (n->prop,
                                           PFprop_dom (L(n)->prop, key_att),
                                           PFprop_dom (R(n)->prop, key_att)))
                        union_ (n->prop->keys, key_att);
                }
            }
            break;

        case la_empty_tbl:
        case la_element_tag:
        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
        case la_docnode:
        case la_comment:
        case la_processi:
        case la_merge_adjacent:
            /* no keys */
            break;

        case la_attach:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            if (PFprop_card (n->prop) == 1)
                union_ (n->prop->keys, n->sem.attach.attname);
            break;

        case la_cross:
            /* keys of one side can be retained
               if the other side has a cardinality of 1.
               Otherwise no information about keys
               is available */
            if (PFprop_card (L(n)->prop) == 1)
                copy (n->prop->keys, R(n)->prop->keys);
            else if (PFprop_card (R(n)->prop) == 1)
                copy (n->prop->keys, L(n)->prop->keys);
            break;

        case la_eqjoin:
        case la_eqjoin_unq:
            /* only a key-join retains all key properties */
            if (PFprop_key (L(n)->prop, n->sem.eqjoin.att1) &&
                PFprop_key (R(n)->prop, n->sem.eqjoin.att2)) {
                copy (n->prop->keys, L(n)->prop->keys);
                union_list (n->prop->keys, R(n)->prop->keys);
            }
            else if (PFprop_key (L(n)->prop, n->sem.eqjoin.att1))
                copy (n->prop->keys, R(n)->prop->keys);
            else if (PFprop_key (R(n)->prop, n->sem.eqjoin.att2))
                copy (n->prop->keys, L(n)->prop->keys);
            break;

        case la_project:
            /* rename keys columns from old to new */
            for (unsigned int i = 0; i < n->sem.proj.count; i++)
                if (key_worker (L(n)->prop->keys, n->sem.proj.items[i].old))
                    union_ (n->prop->keys, n->sem.proj.items[i].new);
            break;

        case la_select:
        case la_difference:
        case la_type_assert:
        case la_roots:
        case la_cond_err:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);
            break;

        case la_intersect:
            copy (n->prop->keys, L(n)->prop->keys);
            union_list (n->prop->keys, R(n)->prop->keys);
            break;

        case la_distinct:
            if (n->schema.count == 1)
                /* if distinct works on a single column,
                   this column is key afterwards. */
                union_ (n->prop->keys, n->schema.items[0].name);
            else
                /* key columns stay the same */
                copy (n->prop->keys, L(n)->prop->keys);
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
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1)
                union_ (n->prop->keys, n->sem.binary.res);
            break;

        case la_num_neg:
        case la_bool_not:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1)
                union_ (n->prop->keys, n->sem.unary.res);
            break;

        case la_avg:
        case la_max:
        case la_min:
        case la_sum:
        case la_count:
        case la_seqty1:
        case la_all:
            /* either the partition is key or if not
               present the aggregated result as it
               contains only one tuple */
            if (n->sem.aggr.part)
                union_ (n->prop->keys, n->sem.aggr.part);
            else
                union_ (n->prop->keys, n->sem.aggr.res);
            break;

        case la_rownum:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1 || !n->sem.rownum.part)
                union_ (n->prop->keys, n->sem.rownum.attname);
            break;

        case la_number:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1 || !n->sem.number.part)
                union_ (n->prop->keys, n->sem.number.attname);
            break;

        case la_type:
        case la_cast:
            /* key columns are propagated */
            copy (n->prop->keys, L(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1)
                union_ (n->prop->keys, n->sem.type.res);
            break;

        case la_scjoin:
            /*
            if (n->sem.scjoin.axis == alg_attr &&
                ! (PFQNAME_NS_WILDCARD (n->sem.scjoin.ty.name)
                   || PFQNAME_LOC_WILDCARD (n->sem.scjoin.ty.name)) &&
                PFprop_key (R(n)->prop, n->sem.scjoin.iter))
                union_ (n->prop->keys, n->sem.scjoin.iter);
            else */ if (PFprop_const (n->prop, n->sem.scjoin.iter))
                union_ (n->prop->keys, n->sem.scjoin.item_res);
            break;

        case la_doc_tbl:
            if (PFprop_card (n->prop) == 1) {
                /* If the cardinality is equal to one
                   the result is key itself. */
                union_ (n->prop->keys, n->sem.doc_tbl.iter);
                union_ (n->prop->keys, n->sem.doc_tbl.item_res);
            } else
                /* Otherwise at least column iter is key. */
                union_ (n->prop->keys, n->sem.doc_tbl.iter);
            break;

        case la_doc_access:
            /* key columns are propagated */
            copy (n->prop->keys, R(n)->prop->keys);

            /* if the cardinality is equal to one
               the result is key itself */
            if (PFprop_card (n->prop) == 1)
                union_ (n->prop->keys, n->sem.doc_access.res);
            break;

        case la_element:
            /* Element construction builds exactly
               one element in each iteration. */
            union_ (n->prop->keys, n->sem.elem.iter_res);
            union_ (n->prop->keys, n->sem.elem.item_res);
            break;

        case la_attribute:
            copy (n->prop->keys, L(n)->prop->keys);
            union_ (n->prop->keys, n->sem.attr.res);
            break;

        case la_textnode:
            copy (n->prop->keys, L(n)->prop->keys);
            union_ (n->prop->keys, n->sem.textnode.res);
            break;

        case la_rec_fix:
            /* get the keys of the overall result */
            copy (n->prop->keys, n->sem.rec_fix.res->prop->keys);
            break;

        case la_rec_param:
        case la_rec_nil:
            /* recursion parameters do not have properties */
            break;

        case la_rec_arg:
            copy (n->prop->keys, R(n)->prop->keys);
            break;

        case la_rec_base:
            /* infer no properties of the seed */
            break;

        case la_proxy:
        case la_proxy_base:
            copy (n->prop->keys, L(n)->prop->keys);
            break;

        case la_string_join:
            /* Every iteration yields exactly one
               tuple. Iterations iter are thus key. */
            union_ (n->prop->keys, n->sem.string_join.iter_res);
            break;

        case la_cross_mvd:
            PFoops (OOPS_FATAL,
                    "clone column aware cross product operator is "
                    "only allowed inside mvd optimization!");

        case la_dummy:
            copy (n->prop->keys, L(n)->prop->keys);
            break;
    }
}

/* worker for PFprop_infer_key */
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

    /* reset key information
       (reuse already existing lists if already available
        as this increases the performance of the compiler a lot) */
    if (n->prop->keys)
        PFarray_last (n->prop->keys) = 0;
    else
        n->prop->keys   = PFarray (sizeof (PFalg_att_t));

    if (n->prop->l_keys)
        PFarray_last (n->prop->l_keys) = 0;
    else
        n->prop->l_keys = PFarray (sizeof (PFalg_att_t));

    if (n->prop->r_keys)
        PFarray_last (n->prop->r_keys) = 0;
    else
        n->prop->r_keys = PFarray (sizeof (PFalg_att_t));

    /* infer information on key columns */
    infer_key (n);
}

/**
 * Infer key property for a DAG rooted in root
 */
void
PFprop_infer_key (PFla_op_t *root) {
    /* infer cardinalities and constant column to
       discover more key columns */
    PFprop_infer_card (root);
    PFprop_infer_const (root);
    PFprop_infer_dom (root);

    prop_infer (root);
    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
