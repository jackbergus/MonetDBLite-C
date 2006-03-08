/**
 * @file
 *
 * Inference of icols property of logical algebra expressions.
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
/** starting from p, make two steps left */
#define RL(p) L(R(p))
/** starting from p, make two steps right */
#define RR(p) R(R(p))

/**
 * Test if @a attr is in the list of icol columns in container @a prop
 */
bool
PFprop_icol (const PFprop_t *prop, PFalg_att_t attr)
{
    return prop->icols & attr;
}

/**
 * Test if @a attr is in the list of icol columns of the left child
 * (information is stored in property container @a prop)
 */
bool
PFprop_icol_left (const PFprop_t *prop, PFalg_att_t attr)
{
    return prop->l_icols & attr;
}

/**
 * Test if @a attr is in the list of icol columns of the right child
 * (information is stored in property container @a prop)
 */
bool
PFprop_icol_right (const PFprop_t *prop, PFalg_att_t attr)
{
    return prop->r_icols & attr;
}

/**
 * worker for PFprop_icols_count and PFprop_icols_to_attlist
 */
static unsigned int
icols_count (const PFprop_t *prop)
{
    PFalg_att_t icols = prop->icols;
    unsigned int counter = 0;

    while (icols) {
        counter += icols & 1;
        icols >>= 1;
    }
    return counter;
}

/*
 * count number of icols attributes
 */
unsigned int
PFprop_icols_count (const PFprop_t *prop)
{
    return icols_count (prop);
}

/**
 * Return icols attributes in an attlist.
 */
PFalg_attlist_t
PFprop_icols_to_attlist (const PFprop_t *prop)
{
    PFalg_attlist_t new_list;
    PFalg_att_t icols = prop->icols;
    unsigned int counter = 0, bit_shift = 1;

    new_list.count = icols_count (prop);
    new_list.atts = PFmalloc (new_list.count * sizeof (*(new_list.atts)));

    /* unfold icols into a list of attributes */
    while (icols && counter < new_list.count) {
        new_list.atts[counter] = prop->icols & bit_shift;
        bit_shift <<= 1;

        counter += icols & 1;
        icols >>= 1;
    }
    return new_list;
}

/**
 * Returns the intersection of an icols list @a icols and a schema
 * @a schema_ocols
 */
static PFalg_att_t
intersect_ocol (PFalg_att_t icols, PFalg_schema_t schema_ocols)
{
    PFalg_att_t ocols = 0;

    /* intersect attributes */
    for (unsigned int j = 0; j < schema_ocols.count; j++)
        ocols |= schema_ocols.items[j].name;

    return icols & ocols;
}

/**
 * Returns union of two icols lists
 */
static PFalg_att_t
union_ (PFalg_att_t a, PFalg_att_t b)
{
    return a | b;
}

/**
 * Returns difference of two icols lists
 */
static PFalg_att_t
diff (PFalg_att_t a, PFalg_att_t b)
{
    return a & (~b);
}

/**
 * worker for PFprop_infer
 * infers the icols property during the second run
 * (uses edge counter stored in n->state_label from the first run)
 */
static void
prop_infer_icols (PFla_op_t *n, PFalg_att_t icols)
{
    /* for element construction we need a special translation
       and therefore skip the default inference of the children */
    bool skip_children = false;

    assert (n);

    /* collect the icols properties of all parents*/
    n->prop->icols = union_ (n->prop->icols, icols);

    /* nothing to do if we haven't collected
       all incoming icols lists of that node */
    if (n->state_label > 1) {
        n->state_label--;
        return;
    }

    /* remove all unnecessary columns from icols */
    n->prop->icols = intersect_ocol (n->prop->icols, n->schema);

    /* infer icols property for children */
    switch (n->kind) {
        case la_serialize:
            /* infer empty list for fragments */
            n->prop->l_icols = 0;
            n->prop->r_icols = union_ (att_pos, att_item);
            break;

        case la_lit_tbl:
        case la_empty_tbl:
            break;

        case la_attach:
            n->prop->l_icols = diff (n->prop->icols,
                                     n->sem.attach.attname);
            break;

        case la_cross:
            n->prop->l_icols = n->prop->icols;
            n->prop->r_icols = n->prop->icols;
            break;

        case la_eqjoin:
            /* add both join columns to the inferred icols */
            n->prop->l_icols = union_ (n->prop->icols, n->sem.eqjoin.att1);
            n->prop->r_icols = union_ (n->prop->icols, n->sem.eqjoin.att2);
            break;

        case la_project:
            n->prop->l_icols = 0;
            /* rename icols columns from new to old */
            for (unsigned int i = 0; i < n->sem.proj.count; i++)
                if (n->prop->icols & n->sem.proj.items[i].new)
                    n->prop->l_icols = union_ (n->prop->l_icols,
                                               n->sem.proj.items[i].old);
            break;

        case la_select:
            /* add selected column to the inferred icols */
            n->prop->l_icols = union_ (n->prop->icols, n->sem.select.att);
            break;

        case la_disjunion:
            n->prop->l_icols = n->prop->icols;

            /* ensure that we have at least one icols column
               otherwise we get into trouble as icols optimization
               might infer non-matching columns */
            if (!n->prop->l_icols) {
                /* try to use a constant as it might get pruned later */
                for (unsigned int i = 0; i < n->schema.count; i++)
                    if (PFprop_const (n->prop, n->schema.items[i].name)) {
                        n->prop->l_icols = n->schema.items[i].name;
                        break;
                    }
                if (!n->prop->l_icols)
                    n->prop->l_icols = n->schema.items[0].name;
            }

            /* disjoint union also works with less columns */
            n->prop->r_icols = n->prop->l_icols;
            break;

        case la_intersect:
            /* add both intersect columns to the inferred icols */
            n->prop->l_icols = union_ (union_ (n->prop->icols, att_iter),
                                       att_item);
            n->prop->r_icols = n->prop->l_icols;
            break;

        case la_difference:
            /* to support both scenarios where difference is
               used ((a) missing iterations and (b) except)
               extend the icols with all ocols */
        case la_distinct:
            /* to support both scenarios where distinct is
               used ((a) distinct and (b) unique iterations)
               extend the icols with all ocols */
            n->prop->l_icols = n->prop->icols;

            for (unsigned int i = 0; i < n->schema.count; i++)
                n->prop->l_icols = union_ (n->prop->l_icols,
                                           n->schema.items[i].name);

            n->prop->r_icols = n->prop->l_icols;
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
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.binary.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.binary.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.binary.att1);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.binary.att2);
            break;

        case la_num_neg:
        case la_bool_not:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.unary.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.unary.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.unary.att);
            break;

        case la_sum:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.sum.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.sum.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.sum.att);
            /* only infer part if available */
            if (n->sem.sum.part != att_NULL)
                n->prop->l_icols = union_ (n->prop->l_icols, n->sem.sum.part);
            break;

        case la_count:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.count.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.count.res);
            /* only infer part if available */
            if (n->sem.count.part != att_NULL)
                n->prop->l_icols = union_ (n->prop->l_icols, n->sem.count.part);
            break;

        case la_rownum:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.rownum.attname))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.rownum.attname);

            for (unsigned int i = 0; i < n->sem.rownum.sortby.count; i++)
                n->prop->l_icols = union_ (n->prop->l_icols,
                                           n->sem.rownum.sortby.atts[i]);

            /* only infer part if available */
            if (n->sem.rownum.part != att_NULL)
                n->prop->l_icols = union_ (n->prop->l_icols,
                                           n->sem.rownum.part);
            break;

        case la_number:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.number.attname))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.number.attname);
            /* only infer part if available */
            if (n->sem.number.part != att_NULL)
                n->prop->l_icols = union_ (n->prop->l_icols,
                                           n->sem.number.part);
            break;

        case la_type:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.type.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.type.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.type.att);
            break;

        case la_type_assert:
            /* if n->sem.type_a.att is not present this operator
               has to be pruned -- therefore we do not care about
               inferrring this column in icols. */
            n->prop->l_icols = n->prop->icols;
            break;

        case la_cast:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.cast.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.cast.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.cast.att);
            break;

        case la_seqty1:
        case la_all:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.blngroup.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.blngroup.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.blngroup.att);
            /* only infer part if available */
            if (n->sem.blngroup.part != att_NULL)
                n->prop->l_icols = union_ (n->prop->l_icols,
                                           n->sem.blngroup.part);
            break;

        case la_scjoin:
            /* infer empty list for fragments */
            n->prop->l_icols = 0;
            /* infer iter|item schema for input relation */
            n->prop->r_icols = union_ (att_iter, att_item);
            break;

        case la_doc_tbl:
            /* infer iter|item schema for input relation */
            n->prop->l_icols = union_ (att_iter, att_item);
            break;

        case la_doc_access:
            n->prop->l_icols = 0;
            n->prop->r_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.doc_access.res))
                break;

            n->prop->r_icols = diff (n->prop->r_icols, n->sem.doc_access.res);
            n->prop->r_icols = union_ (n->prop->r_icols, n->sem.doc_access.att);
            break;

        case la_element:
            /* whenever the element itself is not needed column item
               is missing and therefore the name expression can be
               used as replacement */

            /* infer empty list for fragments */
            prop_infer_icols (L(n), 0);

            /* do only infer input columns if operator is not required */
            if (!(n->prop->icols & att_item))
            {
                /* infer current icols schema for the qnames as replacement */
                prop_infer_icols (RL(n), n->prop->icols);

                /* infer empty list for missing content */
                prop_infer_icols (RR(n), 0);
            } else {
                /* infer iter|item schema for element name relation */
                prop_infer_icols (RL(n), union_ (att_iter, att_item));

                /* infer iter|pos|item schema for element content relation */
                prop_infer_icols (RR(n),
                                  union_ (union_ (att_iter, att_item),
                                          att_pos));
            }

            skip_children = true;
            break;

        case la_attribute:
            /* whenever the attribute itself is not needed column item
               is missing and therefore the name expression can be
               used as replacement (introduce projection res:qn instead) */

            /* do only infer input columns if operator is required */
            if ((n->prop->icols & n->sem.attr.res))
            {
                n->prop->l_icols = diff (n->prop->icols, n->sem.attr.res);
                n->prop->l_icols = union_ (n->prop->l_icols, n->sem.attr.qn);

                n->prop->r_icols = union_ (att_iter, n->sem.attr.val);
            } else {
                n->prop->l_icols = diff (n->prop->icols, n->sem.attr.res);
                n->prop->r_icols = 0;
            }
            break;

        case la_textnode:
            n->prop->l_icols = n->prop->icols;

            /* do not infer input columns if operator is not required */
            if (!(n->prop->icols & n->sem.textnode.res))
                break;

            n->prop->l_icols = diff (n->prop->l_icols, n->sem.textnode.res);
            n->prop->l_icols = union_ (n->prop->l_icols, n->sem.textnode.item);
            break;

        case la_docnode:
        case la_comment:
        case la_processi:
            assert (!"not implemented yet?");

        case la_merge_adjacent:
            /* infer empty list for fragments */
            n->prop->l_icols = 0;
            /* infer iter|pos|item schema for element content relation */
            n->prop->r_icols = union_ (union_ (att_iter, att_item), att_pos);
            break;

        case la_roots:
            /* infer incoming icols for input relation */
            n->prop->l_icols = n->prop->icols;
            break;

        case la_frag_union:
            n->prop->r_icols = 0;
        case la_fragment:
        case la_empty_frag:
            /* infer empty list for fragments */
            n->prop->l_icols = 0;
            break;

        case la_cond_err:
            /* infer incoming icols for input relation */
            n->prop->l_icols = n->prop->icols;
            /* infer attribute that triggers error generation
               for error checking relation  */
            n->prop->r_icols = n->sem.err.att;
            break;

        case la_string_join:
            /* infer iter|pos|item schema for first input relation */
            n->prop->l_icols = union_ (union_ (att_iter, att_item), att_pos);
            /* infer iter|item schema for second input relation */
            n->prop->r_icols = union_ (att_iter, att_item);
            break;

        default:
            PFoops (OOPS_FATAL,
                    "kind %i not supported in icols property inference.",
                    n->kind);
    }

    if (!skip_children)
        /* infer properties for children */
        for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
            prop_infer_icols (n->child[i],
                              /* infer the respective icols property */
                              i==0?n->prop->l_icols:n->prop->r_icols);
}

/* worker for PFprop_infer_icol */
static void
prop_infer (PFla_op_t *n)
{
    assert (n);

    /* count number of incoming edges
       (during first run) */
    n->state_label++;

    /* nothing to do if we already visited that node */
    if (n->bit_dag)
        return;
    /* otherwise initialize edge counter (first occurrence) */
    else
        n->state_label = 1;

    /* infer properties for children */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && n->child[i]; i++)
        prop_infer (n->child[i]);

    n->bit_dag = true;

    /* reset icols property */
    n->prop->icols = 0;
    n->prop->l_icols = 0;
    n->prop->r_icols = 0;
}

/**
 * Infer icols property for a DAG rooted in root
 */
void
PFprop_infer_icol (PFla_op_t *root) {
    /* collect number of incoming edges (parents) */
    prop_infer (root);
    PFla_dag_reset (root);

    /* second run infers icols property */
    prop_infer_icols (root, 0);
}


