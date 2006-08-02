/**
 * @file
 *
 * Map relational algebra expression DAG with unique attribute names 
 * into an equivalent one with bit-encoded attribute names.
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

#include "map_names.h"
#include "properties.h"
#include "mem.h"          /* PFmalloc() */
#include "oops.h"

/** mnemonic algebra constructors */
#include "logical_mnemonic.h"

/*
 * Easily access subtree-parts.
 */
/** starting from p, make a step left */
#define L(p) ((p)->child[0])
/** starting from p, make a step right */
#define R(p) ((p)->child[1])

#define SEEN(p) ((p)->bit_dag)

/* lookup subtree with original attribute names */
#define O(p) (lookup (map, (p)))
/* shortcut for function PFprop_ori_name */
#define ONAME(p,att) (PFprop_ori_name ((p)->prop,(att)))

/* helper macros for renaming projection */
#define LEFT 0
#define RIGHT 1
#define C_UNAME(p,att,s) ((s) ? PFprop_unq_name_right ((p)->prop,(att)) \
                              : PFprop_unq_name_left  ((p)->prop,(att)))

struct ori_unq_map {
    PFla_op_t *ori;
    PFla_op_t *unq;
};
typedef struct ori_unq_map ori_unq_map;

/* worker for macro 'O(p)': based on an original subtree
   looks up the corresponding subtree with original attribute names */
static PFla_op_t *
lookup (PFarray_t *map, PFla_op_t *unq)
{
    for (unsigned int i = 0; i < PFarray_last (map); i++)
        if (((ori_unq_map *) PFarray_at (map, i))->unq == unq)
            return ((ori_unq_map *) PFarray_at (map, i))->ori;

    assert (!"could not look up node");

    return NULL;
}

/**
 * Add a projection above the @a side child of operator @a p
 * whenever some columns needs to be renamed or if the attribute
 * @a free_attr is bound without projection.
 * (see also macros using the function below)
 */
static PFla_op_t *
add_renaming_projection (PFla_op_t *p, 
                         unsigned int side,
                         PFalg_att_t free_attr,
                         PFarray_t *map)
{
    PFalg_att_t ori_new, ori_old, unq, ori_free;
    PFla_op_t *c = O(p->child[side]);
    PFalg_proj_t *projlist = PFmalloc (c->schema.count *
                                       sizeof (PFalg_proj_t));
    bool renamed = false;
    unsigned int count = 0;
    
    ori_free = free_attr ? ONAME(p, free_attr) : att_NULL;

    for (unsigned int i = 0; i < c->schema.count; i++) {
        ori_old = c->schema.items[i].name;

        /* Enforce projection if column free_attr 
           is not free without projection */
        if (ori_old == ori_free)
            renamed = true;
            
        /* lookup unique name for column @a ori_old */
        unq = C_UNAME (p, ori_old, side);

        /* column ori_old is not referenced by operator @a p 
           and thus does not appear in the projection */
        if (!unq) continue;

        /* lookup corresponding new name for column @a ori_old */
        ori_new = ONAME(p, unq);

        /* don't allow missing matches */
        assert (ori_new);

        projlist[count++] = proj (ori_new, ori_old);
        renamed = renamed || (ori_new != ori_old);
    }

    if (renamed)
        return PFla_project_ (c, count, projlist);
    else
        return c;
}
/* shortcut for simplified function add_renaming_projection */
#define PROJ(s,p) add_renaming_projection ((p),(s), att_NULL, map)
/* 'SECure PROJection': shortcut for function add_renaming_projection
   that ensures that column 'a; does not appear in the 's'.th child
   of 'p' */
#define SEC_PROJ(s,p,a) add_renaming_projection ((p),(s), (a), map)

/* worker for unary operators */
static PFla_op_t *
unary_op (PFla_op_t *(*OP) (const PFla_op_t *,
                            PFalg_att_t, PFalg_att_t),
          PFla_op_t *p,
          PFarray_t *map)
{
    return OP (SEC_PROJ(LEFT, p, p->sem.unary.res),
               ONAME(p, p->sem.unary.res),
               ONAME(p, p->sem.unary.att));
}

/* worker for binary operators */
static PFla_op_t *
binary_op (PFla_op_t *(*OP) (const PFla_op_t *, PFalg_att_t,
                             PFalg_att_t, PFalg_att_t),
           PFla_op_t *p,
           PFarray_t *map)
{
    return OP (SEC_PROJ(LEFT, p, p->sem.binary.res),
               ONAME(p, p->sem.binary.res),
               ONAME(p, p->sem.binary.att1),
               ONAME(p, p->sem.binary.att2));
}

/* worker for PFmap_ori_names */
static void
map_ori_names (PFla_op_t *p, PFarray_t *map)
{
    PFla_op_t *res = NULL;

    assert (p);

    /* rewrite each node only once */
    if (SEEN(p))
        return;
    else
        SEEN(p) = true;

    /* apply name mapping for children bottom up */
    for (unsigned int i = 0; i < PFLA_OP_MAXCHILD && p->child[i]; i++)
        map_ori_names (p->child[i], map);

    /* action code */
    switch (p->kind) {
        case la_serialize:
            res = serialize (O(L(p)),
                             PROJ(RIGHT, p),
                             ONAME(p, p->sem.serialize.pos),
                             ONAME(p, p->sem.serialize.item));
            break;

        case la_lit_tbl:
        {
            PFalg_attlist_t attlist;
            attlist.count = p->schema.count;
            attlist.atts  = PFmalloc (attlist.count *
                                      sizeof (PFalg_attlist_t));

            for (unsigned int i = 0; i < p->schema.count; i++)
                attlist.atts[i] = ONAME(p, p->schema.items[i].name);
                                                   
            res = PFla_lit_tbl_ (attlist,
                                 p->sem.lit_tbl.count,
                                 p->sem.lit_tbl.tuples);
        }   break;

        case la_empty_tbl:
        {
            PFalg_schema_t schema;
            schema.count = p->schema.count;
            schema.items  = PFmalloc (schema.count *
                                      sizeof (PFalg_schema_t));

            for (unsigned int i = 0; i < p->schema.count; i++)
                schema.items[i] = 
                    (struct PFalg_schm_item_t)
                        { .name = ONAME(p, p->schema.items[i].name),
                          .type = p->schema.items[i].type };
                                                   
            res = PFla_empty_tbl_ (schema);
        }   break;

        case la_attach:
            res = attach (SEC_PROJ(LEFT, p, p->sem.attach.attname),
                          ONAME(p, p->sem.attach.attname),
                          p->sem.attach.value);
            break;

        case la_cross:
            res = cross (PROJ(LEFT, p), PROJ(RIGHT, p));
            break;

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
        {
            PFalg_proj_t *projlist;
            PFalg_att_t ori;
            unsigned int count;
            
            /* cope with special case where unique names
               of the join arguments conflict */
            if (p->sem.eqjoin_unq.att1 == 
                p->sem.eqjoin_unq.att2) {
                /* translation is almost identical to function
                   add_renaming_projection(). The only difference
                   is the special unique name used for the right
                   join argument. */
                PFalg_att_t ori_new, ori_old, unq, ori_join = att_NULL;
                PFla_op_t *right = O(R(p));
                bool renamed = false;
                
                projlist = PFmalloc (right->schema.count *
                                     sizeof (PFalg_proj_t));
                count = 0;
                
                for (unsigned int i = 0; i < right->schema.count; i++) {
                    ori_old = right->schema.items[i].name;

                    /* lookup unique name for column @a ori_old */
                    unq = C_UNAME (p, ori_old, RIGHT);

                    /* column ori_old is not referenced by operator @a p 
                       and thus does not appear in the projection */
                    if (!unq) continue;

                    if (unq == p->sem.eqjoin_unq.att2) {
                        /* use special name to lookup original
                           attribute name proposed for the join
                           argument */
                        unq = PFalg_unq_name (att_item, 0);
                        ori_join = PFprop_ori_name (p->prop, unq);
                        ori_new = ori_join;
                    }
                    else
                        /* lookup corresponding new name for column @a ori_old */
                        ori_new = ONAME(p, unq);

                    /* don't allow missing matches */
                    assert (ori_new);
                    
                    projlist[count++] = proj (ori_new, ori_old);
                    renamed = renamed || (ori_new != ori_old);
                }
                if (renamed)
                    right = PFla_project_ (right, count, projlist);
                    
                res = eqjoin (PROJ(LEFT, p), right,
                              ONAME(p, p->sem.eqjoin_unq.att1),
                              ori_join);

            }
            else
                res = eqjoin (PROJ(LEFT, p), PROJ(RIGHT, p),
                              ONAME(p, p->sem.eqjoin_unq.att1),
                              ONAME(p, p->sem.eqjoin_unq.att2));
                              
            /* As some operators may rely on the schema of its operands
               we introduce a projection that removes the second join
               attribute thus maintaining the schema of the duplicate
               aware eqjoin operator. */
            projlist = PFmalloc (p->schema.count *
                                 sizeof (PFalg_proj_t));
            for (unsigned int i = 0; i < p->schema.count; i++) {
                ori = ONAME(p, p->schema.items[i].name);
                projlist[i] = proj (ori, ori);
            }
            res = PFla_project_ (res, p->schema.count, projlist);
        }   break;

        case la_project:
        {
            PFla_op_t *left;
            PFalg_proj_t *projlist = PFmalloc (p->schema.count *
                                               sizeof (PFalg_proj_t));
            PFalg_att_t new, old;
            unsigned int count = 0;
            bool renamed = false;
            
            left = O(L(p));
            
            for (unsigned int i = 0; i < left->schema.count; i++) {
                old = left->schema.items[i].name;
                for (unsigned int j = 0; j < p->sem.proj.count; j++)
                    /* we may get multiple hits */
                    if (old == PFprop_ori_name_left (
                                   p->prop,
                                   p->sem.proj.items[j].old)) {
                        new = ONAME(p, p->sem.proj.items[j].new);
                        projlist[count++] = proj (new, old);
                        renamed = renamed || (new != old);
                    }
            }
                    
            /* if the projection does not prune a column
               we may skip the projection operator */
            if (count == left->schema.count && !renamed)
                res = left;
            else
                res = PFla_project_ (left, count, projlist);
        }   break;

        case la_select:
            res = select_ (PROJ(LEFT, p), ONAME(p, p->sem.select.att));
            break;

        case la_disjunion:
            res = disjunion (PROJ(LEFT, p), PROJ(RIGHT, p));
            break;

        case la_intersect:
            res = intersect (PROJ(LEFT, p), PROJ(RIGHT, p));
            break;

        case la_difference:
            res = difference (PROJ(LEFT, p), PROJ(RIGHT, p));
            break;

        case la_distinct:
            res = distinct (PROJ(LEFT, p));
            break;

        case la_num_add:
            res = binary_op (PFla_add, p, map);
            break;
        case la_num_subtract:
            res = binary_op (PFla_subtract, p, map);
            break;
        case la_num_multiply:
            res = binary_op (PFla_multiply, p, map);
            break;
        case la_num_divide:
            res = binary_op (PFla_divide, p, map);
            break;
        case la_num_modulo:
            res = binary_op (PFla_modulo, p, map);
            break;
        case la_num_eq:
            res = binary_op (PFla_eq, p, map);
            break;
        case la_num_gt:
            res = binary_op (PFla_gt, p, map);
            break;
        case la_num_neg:
            res = unary_op (PFla_neg, p, map);
            break;
        case la_bool_and:
            res = binary_op (PFla_and, p, map);
            break;
        case la_bool_or:
            res = binary_op (PFla_or, p, map);
            break;
        case la_bool_not:
            res = unary_op (PFla_not, p, map);
            break;

        case la_avg:
        case la_max:
        case la_min:
        case la_sum:
            res = aggr (p->kind, PROJ(LEFT, p), 
                        ONAME(p, p->sem.aggr.res),
                        ONAME(p, p->sem.aggr.att),
                        p->sem.aggr.part?ONAME(p, p->sem.aggr.part):att_NULL);
            break;
            
        case la_count:
            res = count (PROJ(LEFT, p),
                         ONAME(p, p->sem.aggr.res),
                         p->sem.aggr.part?ONAME(p, p->sem.aggr.part):att_NULL);
            break;
                           
        case la_rownum:
        {
            PFalg_attlist_t sortby;
            sortby.count = p->sem.rownum.sortby.count;
            sortby.atts  = PFmalloc (sortby.count *
                                      sizeof (PFalg_attlist_t));

            for (unsigned int i = 0; i < sortby.count; i++)
                sortby.atts[i] = ONAME(p, p->sem.rownum.sortby.atts[i]);
                                                   
            res = rownum (SEC_PROJ(LEFT, p, p->sem.rownum.attname),
                          ONAME(p, p->sem.rownum.attname),
                          sortby,
                          ONAME(p, p->sem.rownum.part));
        }   break;
        
        case la_number:
            res = number (SEC_PROJ(LEFT, p, p->sem.number.attname),
                          ONAME(p, p->sem.number.attname),
                          ONAME(p, p->sem.number.part));
            break;
        
        case la_type:
            res = type (SEC_PROJ(LEFT, p, p->sem.type.res),
                        ONAME(p, p->sem.type.res),
                        ONAME(p, p->sem.type.att),
                        p->sem.type.ty);
            break;

        case la_type_assert:
            res = type_assert_pos (PROJ(LEFT, p),
                                   ONAME(p, p->sem.type.att),
                                   p->sem.type.ty);
            break;
        
        case la_cast:
            res = cast (SEC_PROJ(LEFT, p, p->sem.type.res),
                        ONAME(p, p->sem.type.res),
                        ONAME(p, p->sem.type.att),
                        p->sem.type.ty);
            break;
        
        case la_seqty1:
            res = seqty1 (PROJ(LEFT, p),
                          ONAME(p, p->sem.aggr.res),
                          ONAME(p, p->sem.aggr.att),
                          p->sem.aggr.part?ONAME(p, p->sem.aggr.part):att_NULL);
            break;
            
        case la_all:
            res = all (PROJ(LEFT, p),
                       ONAME(p, p->sem.aggr.res),
                       ONAME(p, p->sem.aggr.att),
                       p->sem.aggr.part?ONAME(p, p->sem.aggr.part):att_NULL);
            break;

        case la_scjoin:
            res = scjoin (O(L(p)), PROJ(RIGHT, p),
                          p->sem.scjoin.axis,
                          p->sem.scjoin.ty,
                          ONAME(p, p->sem.scjoin.iter),
                          ONAME(p, p->sem.scjoin.item),
                          ONAME(p, p->sem.scjoin.item_res));
            break;
                           
        case la_doc_tbl:
            res = doc_tbl (PROJ(LEFT, p),
                           ONAME(p, p->sem.doc_tbl.iter),
                           ONAME(p, p->sem.doc_tbl.item),
                           ONAME(p, p->sem.doc_tbl.item_res));
            break;
                           
        case la_doc_access:
            res = doc_access (O(L(p)), 
                              SEC_PROJ(RIGHT, p, p->sem.doc_access.res),
                              ONAME(p, p->sem.doc_access.res),
                              ONAME(p, p->sem.doc_access.att),
                              p->sem.doc_access.doc_col);
            break;

        case la_element:
            res = element (
                      O(L(p)), 
                      PROJ(LEFT, R(p)),
                      PROJ(RIGHT, R(p)),
                      ONAME(p, p->sem.elem.iter_qn),
                      ONAME(p, p->sem.elem.item_qn),
                      ONAME(p, p->sem.elem.iter_val),
                      ONAME(p, p->sem.elem.pos_val),
                      ONAME(p, p->sem.elem.item_val),
                      ONAME(p, p->sem.elem.iter_res),
                      ONAME(p, p->sem.elem.item_res));
            break;
        
        case la_element_tag:
            return; /* skip element tag */

        case la_attribute:
            res = attribute (SEC_PROJ(LEFT, p, p->sem.attr.res),
                             ONAME(p, p->sem.attr.res),
                             ONAME(p, p->sem.attr.qn),
                             ONAME(p, p->sem.attr.val));
            break;

        case la_textnode:
            res = textnode (SEC_PROJ(LEFT, p, p->sem.textnode.res),
                            ONAME(p, p->sem.textnode.res),
                            ONAME(p, p->sem.textnode.item));
            break;

        case la_docnode:
        case la_comment:
        case la_processi:
            break;

        case la_merge_adjacent:
            res = merge_adjacent (
                      O(L(p)), PROJ(RIGHT, p),
                      ONAME(p, p->sem.merge_adjacent.iter_in),
                      ONAME(p, p->sem.merge_adjacent.pos_in),
                      ONAME(p, p->sem.merge_adjacent.item_in),
                      ONAME(p, p->sem.merge_adjacent.iter_res),
                      ONAME(p, p->sem.merge_adjacent.pos_res),
                      ONAME(p, p->sem.merge_adjacent.item_res));
            break;

        case la_roots:
            res = roots (O(L(p)));
            break;

        case la_fragment:
            res = fragment (O(L(p)));
            break;

        case la_frag_union:
            res = PFla_frag_union (O(L(p)), O(R(p)));
            break;

        case la_empty_frag:
            res = empty_frag ();
            break;

        case la_cond_err:
            res = cond_err (PROJ(LEFT, p), O(R(p)), 
                            PFprop_ori_name_right (p->prop, p->sem.err.att),
                            p->sem.err.str);
            break;
        
        case la_proxy:
        case la_proxy_base:
            PFoops (OOPS_FATAL,
                    "PROXY EXPANSION MISSING");
            break;

        case la_concat:
            res = binary_op (PFla_fn_concat, p, map);
            break;

        case la_contains:
            res = binary_op (PFla_fn_contains, p, map);
            break;
            
        case la_string_join:
            res = fn_string_join (
                      PROJ(LEFT, p), PROJ(RIGHT, p),
                      ONAME(p, p->sem.string_join.iter),
                      ONAME(p, p->sem.string_join.pos),
                      ONAME(p, p->sem.string_join.item),
                      ONAME(p, p->sem.string_join.iter_sep),
                      ONAME(p, p->sem.string_join.item_sep),
                      ONAME(p, p->sem.string_join.iter_res),
                      ONAME(p, p->sem.string_join.item_res));
            break;
    }

    assert(res);

    /* Add pair (p, res) to the environment map
       to allow lookup of already generated subplans. */
    *(ori_unq_map *) PFarray_add (map) = 
        (ori_unq_map) { .ori = res, .unq = p};
}

/**
 * Invoke name mapping.
 */
PFla_op_t *
PFmap_ori_names (PFla_op_t *root)
{
    PFarray_t *map = PFarray (sizeof (ori_unq_map));

    /* infer original bit-encoded names */
    PFprop_infer_ori_names (root);
 
    /* generate equivalent algebra DAG */
    map_ori_names (root, map);

    /* return algebra DAG with original bit-encoded names */
    return O (root);
}

/* vim:set shiftwidth=4 expandtab filetype=c: */
