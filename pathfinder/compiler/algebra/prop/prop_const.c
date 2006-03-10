/**
 * @file
 *
 * Inference of constant properties of logical algebra expressions.
 *
 * Copyright Notice:
 * -----------------
 *
 *  The contents of this file are subject to the MonetDB Public
 *  License Version 1.0 (the "License"); you may not use this file
 *  except in compliance with the License. You may obtain a copy of
 *  the License at http://monetdb.cwi.nl/Legal/MonetDBLicense-1.0.html
 *
 *  Software distributed under the License is distributed on an "AS
 *  IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  The Original Code is the ``Pathfinder'' system. The Initial
 *  Developer of the Original Code is the Database & Information
 *  Systems Group at the University of Konstanz, Germany. Portions
 *  created by U Konstanz are Copyright (C) 2000-2004 University
 *  of Konstanz. All Rights Reserved.
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
/** starting from p, make a step right, then a step left */
#define RL(p) L(R(p))

/**
 * Test if @a attr is marked constant in property container @a prop.
 */
bool
PFprop_const (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);

    for (unsigned int i = 0; i < PFarray_last (prop->constants); i++)
        if (attr == ((const_t *) PFarray_at (prop->constants, i))->attr)
            return true;

    return false;
}

/**
 * Test if @a attr is marked constant in the left child
 * (information is stored in property container @a prop)
 */
bool
PFprop_const_left (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);

    for (unsigned int i = 0; i < PFarray_last (prop->l_constants); i++)
        if (attr == ((const_t *) PFarray_at (prop->l_constants, i))->attr)
            return true;

    return false;
}

/**
 * Test if @a attr is marked constant in the left child
 * (information is stored in property container @a prop)
 */
bool
PFprop_const_right (const PFprop_t *prop, PFalg_att_t attr)
{
    assert (prop);

    for (unsigned int i = 0; i < PFarray_last (prop->r_constants); i++)
        if (attr == ((const_t *) PFarray_at (prop->r_constants, i))->attr)
            return true;

    return false;
}

/* worker for PFprop_const_val(_left|_right)? */
static PFalg_atom_t
const_val (PFarray_t *constants, PFalg_att_t attr) {
    for (unsigned int i = 0; i < PFarray_last (constants); i++)
        if (attr == ((const_t *) PFarray_at (constants, i))->attr)
            return ((const_t *) PFarray_at (constants, i))->value;

    PFoops (OOPS_FATAL,
            "could not find attribute that is supposed to be constant: `%s'",
            PFatt_str (attr));

    assert(0); /* never reached due to "exit" in PFoops */
    return PFalg_lit_int (0); /* pacify picky compilers */
}

/**
 * Lookup value of @a attr in property container @a prop.  Attribute
 * @a attr must be marked constant, otherwise the function will fail.
 */
PFalg_atom_t
PFprop_const_val (const PFprop_t *prop, PFalg_att_t attr)
{
    return const_val (prop->constants, attr);
}

/**
 * Lookup value of @a attr in the list of constants of the left
 * child. (Information resides in property container @a prop.)
 * Attribute @a attr must be marked constant, otherwise
 * the function will fail.
 */
PFalg_atom_t
PFprop_const_val_left (const PFprop_t *prop, PFalg_att_t attr)
{
    return const_val (prop->l_constants, attr);
}

/**
 * Lookup value of @a attr in the list of constants of the right
 * child. (Information resides in property container @a prop.)
 * Attribute @a attr must be marked constant, otherwise
 * the function will fail.
 */
PFalg_atom_t
PFprop_const_val_right (const PFprop_t *prop, PFalg_att_t attr)
{
    return const_val (prop->r_constants, attr);
}

/* the following 3 functions are used for debug printing */
/**
 * Return number of attributes marked const.
 */
unsigned int
PFprop_const_count (const PFprop_t *prop)
{
    return PFarray_last (prop->constants);
}

/**
 * Return name of constant attribute number @a i (in container @a prop).
 * (Needed, e.g., to iterate over constant columns.)
 */
PFalg_att_t
PFprop_const_at (const PFprop_t *prop, unsigned int i)
{
    return ((const_t *) PFarray_at (prop->constants, i))->attr;
}

/**
 * Return value of constant attribute number @a i (in container @a prop).
 * (Needed, e.g., to iterate over constant columns.)
 */
PFalg_atom_t
PFprop_const_val_at (const PFprop_t *prop, unsigned int i)
{
    return ((const_t *) PFarray_at (prop->constants, i))->value;
}

/**
 * Mark @a attr as constant with value @a value in node @a n.
 */
static void
PFprop_mark_const (PFprop_t *prop, PFalg_att_t attr, PFalg_atom_t value)
{
    assert (prop);

#ifndef NDEBUG
    if (PFprop_const (prop, attr))
        PFoops (OOPS_FATAL,
                "attribute `%s' already declared constant",
                PFatt_str (attr));
#endif

    *(const_t *) PFarray_add (prop->constants)
        = (const_t) { .attr = attr, .value = value };
}

/* copy the constant columns of the childs of node @a n
   into its property container */
static void
copy_child_constants (PFla_op_t *n)
{
    switch (n->kind) {
        /* do not copy constant property
           of the children as we either have
           base relations or fragments */
        case la_lit_tbl:
        case la_empty_tbl:
        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
            break;

        /* copy constant properties of
           both children */
        case la_cross:
        case la_eqjoin:
        case la_disjunion:
        case la_intersect:
        case la_difference:
        case la_element_tag:
        case la_cond_err:
        case la_string_join:
            assert(L(n));
            assert(R(n));
            n->prop->l_constants = PFarray_copy (L(n)->prop->constants);
            n->prop->r_constants = PFarray_copy (R(n)->prop->constants);
            break;

        /* copy constant properties of
           left child */
        case la_attach:
        case la_project:
        case la_select:
        case la_distinct:
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
        case la_sum:
        case la_count:
        case la_rownum:
        case la_number:
        case la_type:
        case la_type_assert:
        case la_cast:
        case la_seqty1:
        case la_all:
        case la_doc_tbl:
        case la_attribute:
        case la_textnode:
        case la_docnode:
        case la_comment:
        case la_processi:
        case la_roots:
        case la_concat:
        case la_contains:
            assert(L(n));
            n->prop->l_constants = PFarray_copy (L(n)->prop->constants);
            break;

        /* copy constant properties of
           right child */
        case la_serialize:
        case la_scjoin:
        case la_doc_access:
        case la_element:
        case la_merge_adjacent:
            assert(R(n));
            n->prop->r_constants = PFarray_copy (R(n)->prop->constants);
            break;
    }
}

/**
 * Infer properties about constant columns; worker for prop_infer().
 */
static void
infer_const (PFla_op_t *n)
{
    /* first get the properties of the children */
    copy_child_constants (n);

    /*
     * Several operates (at least) propagate constant columns
     * to their output 1:1.
     */
    switch (n->kind) {

        case la_attach:
        case la_cross:
        case la_eqjoin:
        case la_select:
        case la_distinct:
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
        case la_doc_access:
        case la_textnode:
        case la_roots:
        case la_concat:
        case la_contains:

            /* propagate information from both input operators */
            for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
                for (unsigned int j = 0;
                        j < PFprop_const_count (n->child[i]->prop); j++)
                    if (!PFprop_const (n->prop,
                                       PFprop_const_at (n->child[i]->prop, j)))
                        PFprop_mark_const (
                                n->prop,
                                PFprop_const_at (n->child[i]->prop, j),
                                PFprop_const_val_at (n->child[i]->prop, j));
            break;

        default:
            break;
    }

    /*
     * Now consider more specific stuff from various rules.
     */
    switch (n->kind) {

        case la_lit_tbl:

            /* check for constant columns */
            for (unsigned int col = 0; col < n->schema.count; col++) {

                bool          constant = true;
                PFalg_atom_t  val;

                for (unsigned int row = 0; row < n->sem.lit_tbl.count; row++)
                    if (row == 0)
                        val = n->sem.lit_tbl.tuples[row].atoms[col];
                    else
                        if (!PFalg_atom_comparable (
                                 val,
                                 n->sem.lit_tbl.tuples[row].atoms[col]) ||
                            PFalg_atom_cmp (
                                val,
                                n->sem.lit_tbl.tuples[row].atoms[col])) {
                            constant = false;
                            break;
                        }

                if (constant)
                    PFprop_mark_const (n->prop, n->schema.items[col].name, val);
            }
            break;

        case la_attach:
            /* attached column is always constant */
            if (!PFprop_const (n->prop, n->sem.attach.attname))
                PFprop_mark_const (n->prop,
                                   n->sem.attach.attname,
                                   n->sem.attach.value);
            break;

        case la_project:
            /*
             * projection does not affect properties, except for the
             * column name change.
             */
            for (unsigned int i = 0; i < n->sem.proj.count; i++)
                if (PFprop_const (L(n)->prop, n->sem.proj.items[i].old))
                    PFprop_mark_const (n->prop,
                                       n->sem.proj.items[i].new,
                                       PFprop_const_val (
                                           L(n)->prop,
                                           n->sem.proj.items[i].old));
            break;

        case la_select:
            /* the selection criterion itself will now also be const */
            if (!PFprop_const (n->prop, n->sem.select.att))
                PFprop_mark_const (
                        n->prop, n->sem.select.att, PFalg_lit_bln (true));
            break;

        case la_disjunion:
        case la_intersect:
            /*
             * add all attributes that are constant in both input relations
             * and additionally both contain the same value
             */
            for (unsigned int i = 0; i < PFprop_const_count (L(n)->prop); i++)
                for (unsigned int j = 0;
                        j < PFprop_const_count (R(n)->prop); j++)
                    if (PFprop_const_at (L(n)->prop, i) ==
                        PFprop_const_at (R(n)->prop, j) &&
                        PFalg_atom_comparable (
                            PFprop_const_val_at (L(n)->prop, i),
                            PFprop_const_val_at (R(n)->prop, j)) &&
                        !PFalg_atom_cmp (
                            PFprop_const_val_at (L(n)->prop, i),
                            PFprop_const_val_at (R(n)->prop, j))) {
                        PFprop_mark_const (
                                n->prop,
                                PFprop_const_at (L(n)->prop, i),
                                PFprop_const_val_at (L(n)->prop, i));
                        break;
                    }
            break;

        case la_difference:
        case la_attribute:
        case la_cond_err:
            /* propagate information from the first input operator */
                for (unsigned int j = 0;
                        j < PFprop_const_count (L(n)->prop); j++)
                    if (!PFprop_const (n->prop,
                                       PFprop_const_at (L(n)->prop, j)))
                        PFprop_mark_const (
                                n->prop,
                                PFprop_const_at (L(n)->prop, j),
                                PFprop_const_val_at (L(n)->prop, j));
            break;

        case la_num_eq:
        case la_num_gt:
        case la_bool_and:
        case la_bool_or:
            /* if both involved attributes are constant and
               we can be sure that the result is the same on all
               plattforms we mark the result as constant and calculate
               its value. (Note: Avoid inferring values that are
               ambiguous e.g. +(dbl, dbl) as the runtime might
               calculate a differing result.) */
            if (PFprop_const (L(n)->prop, n->sem.binary.att1) &&
                PFprop_const (L(n)->prop, n->sem.binary.att2)) {
                PFalg_att_t att1, att2;
                PFalg_simple_type_t ty;

                att1 = n->sem.binary.att1;
                att2 = n->sem.binary.att2;
                ty = 0;

                for (unsigned int i = 0; i < n->schema.count; i++)
                    if (n->schema.items[i].name == n->sem.binary.att1) {
                        ty = n->schema.items[i].type;
                        break;
                    }

                if (n->kind == la_num_eq &&
                    (ty == aat_nat || ty == aat_int ||
                     ty == aat_bln || ty == aat_qname)) {

                    !PFalg_atom_cmp (PFprop_const_val (L(n)->prop, att1),
                                     PFprop_const_val (L(n)->prop, att2))
                    ?
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (true))
                    :
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (false));
                }
                else if (n->kind == la_num_gt &&
                         (ty == aat_nat || ty == aat_int)) {

                    (PFalg_atom_cmp (PFprop_const_val (L(n)->prop, att1),
                                     PFprop_const_val (L(n)->prop, att2))
                    > 0)
                    ?
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (true))
                    :
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (false));
                }
                else if (n->kind == la_bool_and && ty == aat_bln) {
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (
                            (PFprop_const_val (L(n)->prop, att1)).val.bln &&
                            (PFprop_const_val (L(n)->prop, att2)).val.bln));
                }
                else if (n->kind == la_bool_or && ty == aat_bln) {
                    PFprop_mark_const (
                        n->prop,
                        n->sem.binary.res,
                        PFalg_lit_bln (
                            (PFprop_const_val (L(n)->prop, att1)).val.bln ||
                            (PFprop_const_val (L(n)->prop, att2)).val.bln));
                }
            }
            /* if one argument of the and operator has constant value
               false the result will be false as well */
            else if (n->kind == la_bool_and &&
                     PFprop_const (L(n)->prop, n->sem.binary.att1) &&
                     !(PFprop_const_val (L(n)->prop,
                                         n->sem.binary.att1)).val.bln)
                PFprop_mark_const (
                    n->prop,
                    n->sem.binary.res,
                    PFalg_lit_bln (false));
            /* if one argument of the or operator has constant value
               true the result will be true as well */
            else if (n->kind == la_bool_or &&
                     PFprop_const (L(n)->prop, n->sem.binary.att1) &&
                     (PFprop_const_val (L(n)->prop,
                                        n->sem.binary.att1)).val.bln)
                PFprop_mark_const (
                    n->prop,
                    n->sem.binary.res,
                    PFalg_lit_bln (true));
            break;

        case la_sum:
            if (n->sem.sum.part &&
                PFprop_const (L(n)->prop, n->sem.sum.part))
                PFprop_mark_const (
                        n->prop,
                        n->sem.sum.part,
                        PFprop_const_val (L(n)->prop, n->sem.sum.part));
            break;

        case la_count:
            if (n->sem.count.part &&
                PFprop_const (L(n)->prop, n->sem.count.part))
                PFprop_mark_const (
                        n->prop,
                        n->sem.count.part,
                        PFprop_const_val (L(n)->prop, n->sem.count.part));
            break;

        case la_cast:
            /* Inference of the constant result columns 
               is not possible as a cast is required. */

            /* if the cast does not change the type res equals att */
            if (PFprop_const (L(n)->prop, n->sem.cast.att) &&
                (PFprop_const_val (L(n)->prop, 
                                   n->sem.cast.att)).type == n->sem.cast.ty)
                PFprop_mark_const (
                        n->prop,
                        n->sem.cast.res,
                        PFprop_const_val (L(n)->prop, n->sem.cast.att));
            /* In special cases a stable cast (in respect to different
               implementations) is possible (see e.g. from int to dbl). */
            else if (PFprop_const (L(n)->prop, n->sem.cast.att) &&
                     (PFprop_const_val (L(n)->prop, 
                                        n->sem.cast.att)).type == aat_int &&
                     n->sem.cast.ty == aat_dbl)
                PFprop_mark_const (
                        n->prop,
                        n->sem.cast.res,
                        PFalg_lit_dbl ((PFprop_const_val (
                                            L(n)->prop,
                                            n->sem.cast.att)).val.int_));
            break;

        case la_seqty1:
        case la_all:
            if (n->sem.blngroup.part &&
                PFprop_const (L(n)->prop, n->sem.blngroup.part))
                PFprop_mark_const (
                        n->prop,
                        n->sem.blngroup.part,
                        PFprop_const_val (L(n)->prop, n->sem.blngroup.part));
            break;

        case la_scjoin:
            if (PFprop_const (R(n)->prop, att_iter))
                PFprop_mark_const (
                        n->prop,
                        att_iter,
                        PFprop_const_val (R(n)->prop, att_iter));
            break;

        case la_doc_tbl:
        case la_string_join:
            if (PFprop_const (L(n)->prop, att_iter))
                PFprop_mark_const (
                        n->prop,
                        att_iter,
                        PFprop_const_val (L(n)->prop, att_iter));
            break;

        case la_element:
            if (PFprop_const (RL(n)->prop, att_iter))
                PFprop_mark_const (
                        n->prop,
                        att_iter,
                        PFprop_const_val (RL(n)->prop, att_iter));
            break;


        case la_serialize:
        case la_empty_tbl:
        case la_cross:
        case la_eqjoin:
        case la_distinct:
        /* we also might calculate some result constants.
           Leave it out as it isn't a common case */
        case la_num_add:
        case la_num_subtract:
        case la_num_multiply:
        case la_num_divide:
        case la_num_modulo:
        case la_num_neg:
        case la_bool_not:
        case la_rownum:
        case la_number:
        case la_type:
        case la_type_assert:
        case la_doc_access:
        case la_element_tag:
        case la_textnode:
        case la_docnode:
        case la_comment:
        case la_processi:
        case la_merge_adjacent:
        case la_roots:
        case la_fragment:
        case la_frag_union:
        case la_empty_frag:
        case la_concat:
        case la_contains:
            break;
    }
}

/* worker for PFprop_infer_const */
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

    /* create new constant property */
    n->prop->constants = PFarray (sizeof (const_t));
    n->prop->l_constants = NULL;
    n->prop->r_constants = NULL;

    /* infer information on constant columns */
    infer_const (n);
}

/**
 * Infer constant property for a DAG rooted in root
 */
void
PFprop_infer_const (PFla_op_t *root) {
    prop_infer (root);
    PFla_dag_reset (root);
}

/* vim:set shiftwidth=4 expandtab: */
