/**
 * @file
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
 * 2000-2005 University of Konstanz.  All Rights Reserved.
 *
 * $Id$
 */

#ifndef MILALGEBRA_H
#define MILALGEBRA_H

#include "mil.h"

#define MILALGEBRA_MAXCHILD 2

enum PFma_kind_t {
      ma_lit_oid  =  1
    , ma_lit_int  =  2
    , ma_lit_dbl  =  3
    , ma_lit_str  =  4
    , ma_lit_bit  =  5

    , ma_new      =  6   /**< new BAT constructor */
    , ma_insert   =  7   /**< add BUN to a BAT */
    , ma_bun      =  8   /**< Binary UNit (a pair of atomic values) */

    , ma_seqbase  =  9   /**< set seqbase for BAT with void head */
    , ma_project  = 10   /**< MIL project() operator */
    , ma_reverse  = 11   /**< MIL reverse() operator */
    , ma_sort     = 12   /**< MIL sort() operator */
    , ma_ctrefine = 13   /**< CTrefine() operator: refine sorting */
    , ma_join     = 14   /**< Join tow BATs */
    , ma_leftjoin = 15   /**< Join and keep order of left argument */
    , ma_cross    = 16   /**< Cross product */
    , ma_mirror   = 17   /**< mirror(): copy head into tail */
    , ma_kunique  = 18   /**< kunique(): Eliminate dupl., look at heads only */
    , ma_mark_grp = 19   /**< mark_grp(): grouped row-numbering */
    , ma_mark     = 20   /**< mark() generate ascending (oid) values */
    , ma_count    = 21   /**< count number of BUNs */
    , ma_append   = 22   /**< append BAT to another one */
    , ma_oid      = 23   /**< cast atomic value to oid */
    , ma_moid     = 24   /**< Multiplexed cast to oid */
    , ma_mint     = 25   /**< Multiplexed cast to int */
    , ma_mstr     = 26   /**< Multiplexed cast to str */
    , ma_mdbl     = 27   /**< Multiplexed cast to dbl */
    , ma_mbit     = 28   /**< Multiplexed cast to bit */
    , ma_madd     = 29   /**< Multiplexed arithmetic plus */
    , ma_msub     = 30   /**< Multiplexed arithmetic subtraction */
    , ma_mmult    = 31   /**< Multiplexed arithmetic multiplication */
    , ma_mdiv     = 32   /**< Multiplexed arithmetic division */

    , ma_serialize = 33  /**< will be the root node of our MIL algebra tree */
    , ma_ser_args  = 34  /**< serialization arguments */

    , ma_MAX       = 35  /**< keep this always at the end */
};


struct PFma_val_t {
    enum PFmil_type_t type;
    union {
        oid     o;
        int     i;
        double  d;
        char   *s;
        bool    b;
    } val;
};
typedef struct PFma_val_t PFma_val_t;

union PFma_sem_t {

    struct {
        PFmil_type_t htype;
        PFmil_type_t ttype;
    } new;

    PFma_val_t lit_val;

};

struct PFma_type_t {

    enum { type_bat, type_atom, type_none } kind;

    union {

        struct {
            enum PFmil_type_t htype;
            enum PFmil_type_t ttype;
        } bat;

        enum PFmil_type_t atom;

    } ty;
};
typedef struct PFma_type_t PFma_type_t;

struct PFma_op_t {
    enum PFma_kind_t   kind;
    struct PFma_type_t type;
    unsigned int       refctr;   /**< reference counter */
    unsigned int       usectr;   /**< usage counter */
    char              *varname;  /**< BAT name the result is assigned to */
    union PFma_sem_t   sem;      /**< semantic content */
    unsigned int       node_id;  /**< ID for AT&T dot printing */
    unsigned int       state_label;
    struct PFma_op_t  *child[MILALGEBRA_MAXCHILD];
};

typedef struct PFma_op_t PFma_op_t;

PFma_op_t *PFma_lit_oid (oid);
PFma_op_t *PFma_lit_int (long long int);
PFma_op_t *PFma_lit_str (char *);
PFma_op_t *PFma_lit_bit (bool);
PFma_op_t *PFma_lit_dbl (double);

PFma_op_t *PFma_new (PFmil_type_t htype, PFmil_type_t ttype);
PFma_op_t *PFma_seqbase (const PFma_op_t *, const PFma_op_t *seqbase);
PFma_op_t *PFma_insert (const PFma_op_t *,
                        const PFma_op_t *hvalue, const PFma_op_t *tvalue);
PFma_op_t *PFma_project (const PFma_op_t *, const PFma_op_t *value);
PFma_op_t *PFma_reverse (const PFma_op_t *n);
PFma_op_t *PFma_sort (const PFma_op_t *n);
PFma_op_t *PFma_ctrefine (const PFma_op_t *a, const PFma_op_t *b);
PFma_op_t *PFma_join (const PFma_op_t *left, const PFma_op_t *right);
PFma_op_t *PFma_leftjoin (const PFma_op_t *left, const PFma_op_t *right);
PFma_op_t *PFma_cross (const PFma_op_t *left, const PFma_op_t *right);
PFma_op_t *PFma_mirror (const PFma_op_t *n);
PFma_op_t *PFma_kunique (const PFma_op_t *n);
PFma_op_t *PFma_mark_grp (const PFma_op_t *b, const PFma_op_t *g);
PFma_op_t *PFma_mark (const PFma_op_t *n, const PFma_op_t *base);
PFma_op_t *PFma_count (const PFma_op_t *n);
PFma_op_t *PFma_append (const PFma_op_t *, const PFma_op_t *);

PFma_op_t *PFma_oid (const PFma_op_t *);
PFma_op_t *PFma_moid (const PFma_op_t *);
PFma_op_t *PFma_mint (const PFma_op_t *);
PFma_op_t *PFma_mstr (const PFma_op_t *);
PFma_op_t *PFma_mdbl (const PFma_op_t *);
PFma_op_t *PFma_mbit (const PFma_op_t *);
PFma_op_t *PFma_madd (const PFma_op_t *, const PFma_op_t *);
PFma_op_t *PFma_msub (const PFma_op_t *, const PFma_op_t *);
PFma_op_t *PFma_mmult (const PFma_op_t *, const PFma_op_t *);
PFma_op_t *PFma_mdiv (const PFma_op_t *, const PFma_op_t *);

PFma_op_t *PFma_serialize (const PFma_op_t *pos,
                           const PFma_op_t *item_int,
                           const PFma_op_t *item_str,
                           const PFma_op_t *item_dec,
                           const PFma_op_t *item_dbl,
                           const PFma_op_t *item_bln,
                           const PFma_op_t *item_node);

#endif  /* MILALGEBRA_H */

/* vim:set shiftwidth=4 expandtab: */
