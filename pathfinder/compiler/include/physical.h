/**
 * @file
 *
 * Declarations specific to logical algebra.
 *
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
 *  created by U Konstanz are Copyright (C) 2000-2005 University
 *  of Konstanz. All Rights Reserved.
 *
 * $Id$
 */

#ifndef PHYSICAL_H
#define PHYSICAL_H

#include <stdbool.h>

#include "variable.h"
#include "algebra.h"
#include "mil.h"

#include "ordering.h"


/* .............. algebra operators (operators on relations) .............. */

/** algebra operator kinds */
enum PFpa_op_kind_t {
      pa_serialize      =   1
    , pa_lit_tbl        =   2 /**< literal table */
    , pa_empty_tbl      =   3 /**< empty literal table */
    , pa_attach         =   4 /**< ColumnAttach */
    , pa_cross          =  10 /**< Cross */
    , pa_leftjoin       =  11 /**< LeftJoin */
#if 0                        
    , pa_nljoin         =  12 /**< NestedLoopJoin */
    , pa_merge_join     =  13 /**< MergeJoin */
#endif                       
    , pa_eqjoin         =  14 /**< Generic join implementation */
    , pa_project        =  15 /**< Project */
    , pa_select         =  16 /**< Select: filter rows by value in given att */
    , pa_append_union   =  20 /**< AppendUnion */
    , pa_merge_union    =  21 /**< MergeUnion */
    , pa_intersect      =  22 /**< Intersect */
    , pa_difference     =  23 /**< Difference */
    , pa_sort_distinct  =  24 /**< SortDistinct */
    , pa_std_sort       =  25 /**< StdSort */
    , pa_refine_sort    =  26 /**< RefineSort */
    , pa_num_add        =  30 /**< Arithmetic + */
    , pa_num_add_atom   =  31 /**< Arithmetic +, where one arg is an atom */
    , pa_num_sub        =  32 /**< Arithmetic - */
    , pa_num_sub_atom   =  33 /**< Arithmetic -, where one arg is an atom */
    , pa_num_mult       =  34 /**< Arithmetic * */
    , pa_num_mult_atom  =  35 /**< Arithmetic *, where one arg is an atom */
    , pa_num_div        =  36 /**< Arithmetic / */
    , pa_num_div_atom   =  37 /**< Arithmetic /, where one arg is an atom */
    , pa_num_mod        =  38 /**< Arithmetic mod */
    , pa_num_mod_atom   =  39 /**< Arithmetic mod, where one arg is an atom */
    , pa_eq             =  40 /**< Numeric or String Equality */
    , pa_eq_atom        =  41 /**< Numeric or String Equality */
    , pa_gt             =  42 /**< Numeric or String GreaterThan */
    , pa_gt_atom        =  43 /**< Numeric or String GreaterThan */
    , pa_num_neg        =  44 /**< Numeric negation */
    , pa_bool_not       =  45 /**< Boolean negation */
    , pa_bool_and       =  46 /**< Boolean and */
    , pa_bool_or        =  47 /**< Boolean or */
    , pa_hash_count     =  48 /**< Hash-based count operator */
    , pa_merge_rownum   =  50 /**< MergeRowNumber */
    , pa_hash_rownum    =  51 /**< HashRowNumber */
    , pa_number         =  52 /**< Number */
    , pa_type           =  60 /**< selection of rows where a column is of a
                                   certain type */
    , pa_type_assert    =  61 /**< restriction of the type of a given column */
    , pa_cast           =  62 /**< cast a table to a given type */
    , pa_llscj_anc      = 100 /**< Loop-Lifted StaircaseJoin Ancestor */
    , pa_llscj_anc_self = 101 /**< Loop-Lifted StaircaseJoin AncestorOrSelf */
    , pa_llscj_attr     = 102 /**< Loop-Lifted StaircaseJoin AncestorOrSelf */
    , pa_llscj_child    = 103 /**< Loop-Lifted StaircaseJoin Child */
    , pa_llscj_desc     = 104 /**< Loop-Lifted StaircaseJoin Descendant */
    , pa_llscj_desc_self= 105 /**< Loop-Lifted StaircaseJoin DescendantOrSelf */
    , pa_llscj_foll     = 106 /**< Loop-Lifted StaircaseJoin Following */
    , pa_llscj_foll_sibl= 107 /**< Loop-Lifted StaircaseJoin FollowingSibling */
    , pa_llscj_parent   = 108 /**< Loop-Lifted StaircaseJoin Parent */
    , pa_llscj_prec     = 109 /**< Loop-Lifted StaircaseJoin Preceding */
    , pa_llscj_prec_sibl= 110 /**< Loop-Lifted StaircaseJoin PrecedingSibling */
    , pa_doc_tbl        = 120 /**< Access to persistent document relation */
    , pa_doc_access     = 121 /**< Access to string content of loaded docs */
    , pa_element        = 122 /**< element-constructing operator */
    , pa_element_tag    = 123 /**< part of the element-constructing operator;
                                  connecting element tag and content;
                                  due to Burg we use two "wire2" operators
                                  now instead of one "wire3 operator "*/
    , pa_attribute      = 124 /**< attribute-constructing operator */
    , pa_textnode       = 125 /**< text node-constructing operator */
    , pa_docnode        = 126 /**< document node-constructing operator */
    , pa_comment        = 127 /**< comment-constructing operator */
    , pa_processi       = 128 /**< processing instruction-constr. operator */
    , pa_merge_adjacent = 129
    , pa_roots          = 130
    , pa_fragment       = 131
    , pa_frag_union     = 132
    , pa_empty_frag     = 133
    , pa_cond_err       = 140 /**< conditional error operator */
    , pa_concat         = 150 /**< Concatenation of two strings (fn:concat) */
    , pa_string_join    = 151 /**< Concatenation of multiple strings */
};
/** algebra operator kinds */
typedef enum PFpa_op_kind_t PFpa_op_kind_t;

/** semantic content in algebra operators */
union PFpa_op_sem_t {

    /* semantic content for literal table constr. */
    struct {
        unsigned int    count;    /**< number of tuples */
        PFalg_tuple_t  *tuples;   /**< array holding the tuples */
    } lit_tbl;                    /**< semantic content for literal table
                                       constructor */

    struct {
        PFalg_att_t     attname;  /**< names of new attribute */
        PFalg_atom_t    value;    /**< value for the new attribute */
    } attach;                     /**< semantic content for column attachment
                                       operator (ColumnAttach) */

    /* semantic content for equi-join operator */
    struct {
        PFalg_att_t     att1;     /**< name of attribute from "left" rel */
        PFalg_att_t     att2;     /**< name of attribute from "right" rel */
    } eqjoin;

    /* semantic content for projection operator */
    struct {
        unsigned int    count;    /**< length of projection list */
        PFalg_proj_t   *items;    /**< projection list */
    } proj;

    /** semantic content for selection operator */
    struct {
        PFalg_att_t     att;     /**< name of selected attribute */
    } select;

    struct {
        PFord_ordering_t ord;     /**< ``grouping'' parameter for
                                       MergeUnion */
    } merge_union;

    /** semantic content for SortDistinct operator */
    struct {
        PFord_ordering_t ord;    /**< ordering to consider for duplicate
                                      elimination */
    } sort_distinct;

    /** semantic content for sort operators */
    struct {
        PFord_ordering_t required;
        PFord_ordering_t existing;
    } sortby;

    /* semantic content for binary (arithmetic and boolean) operators */
    struct {
        PFalg_att_t     att1;     /**< first operand */
        PFalg_att_t     att2;     /**< second operand */
        PFalg_att_t     res;      /**< attribute to hold the result */
    } binary;

    /* semantic content for binary (arithmetic and boolean) operators
     * where the second argument is an atom (if we know that an
     * attribute will be constant) */
    struct {
        PFalg_att_t     att1;     /**< first operand */
        PFalg_atom_t    att2;     /**< second operand */
        PFalg_att_t     res;      /**< attribute to hold the result */
    } bin_atom;

    /**
     * semantic content for unary (numeric or Boolean) operators
     * (e.g. numeric/Boolean negation)
     */
    struct {
        PFalg_att_t     att;      /**< argument attribute */
        PFalg_att_t     res;      /**< attribute to hold the result */
    } unary;

    /** semantic content for Count operators */
    struct {
        PFalg_att_t         res;  /**< Name of result attribute */
        PFalg_att_t         part; /**< Partitioning attribute */
    } count;

    /* semantic content for rownum operator */
    struct {
        PFalg_att_t     attname;  /**< name of generated (integer) attribute */
        PFalg_att_t     part;     /**< optional partitioning attribute,
                                       otherwise NULL */
    } rownum;

    /* semantic content for number operator */
    struct {
        PFalg_att_t     attname;  /**< name of generated (integer) attribute */
        PFalg_att_t     part;     /**< optional partitioning attribute,
                                       otherwise NULL */
    } number;

    /* semantic content for type test operator */
    struct {
        PFalg_att_t     att;     /**< name of type-tested attribute */
        PFalg_simple_type_t ty;  /**< comparison type */
        PFalg_att_t     res;     /**< column to store result of type test */
    } type;

    /* semantic content for type_assert operator */
    struct {
        PFalg_att_t     att;     /**< name of the asserted attribute */
        PFalg_simple_type_t ty;  /**< restricted type */
    } type_a;

    /** semantic content for Cast operator */
    struct {
        PFalg_att_t         att; /**< attribute to cast */
        PFalg_simple_type_t ty;  /**< target type */
        PFalg_att_t         res; /**< column to store result of the cast */
    } cast;

    /** semantic content for staircase join operator */
    struct {
        PFty_t           ty;      /**< sequence type that describes the
                                       node test */
        PFord_ordering_t in;      /**< input ordering */
        PFord_ordering_t out;     /**< output ordering */
    } scjoin;

    /* reference columns for document access */
    struct {
        PFalg_att_t     att;      /**< name of the reference attribute */
        PFalg_doc_t     doc_col;  /**< referenced column in the document */
    } doc_access;

    /* reference columns of attribute constructor */
    struct {
        PFalg_att_t     qn;       /**< name of the qname item column */
        PFalg_att_t     val;      /**< name of the value item column */
        PFalg_att_t     res;      /**< attribute to hold the result */
    } attr;

    /* reference columns of text constructor */
    struct {
        PFalg_att_t     item;     /**< name of the item column */
        PFalg_att_t     res;      /**< attribute to hold the result */
    } textnode;

    /* semantic content for conditional error */
    struct {
        PFalg_att_t     att;     /**< name of the boolean attribute */
        char *          str;     /**< error message */
    } err;
};
/** semantic content in physical algebra operators */
typedef union PFpa_op_sem_t PFpa_op_sem_t;

/**
 * A ``plan list'' is an array of plans.
 */
typedef PFarray_t PFplanlist_t;


/** maximum number of children of a #PFpa_op_t node */
#define PFPA_OP_MAXCHILD 2

/** algebra operator node */
struct PFpa_op_t {
    PFpa_op_kind_t     kind;       /**< operator kind */
    PFpa_op_sem_t      sem;        /**< semantic content for this operator */
    PFalg_schema_t     schema;     /**< result schema */

    PFord_set_t        orderings;
    unsigned long      cost;       /**< costs estimated for this subexpress. */
    struct PFprop_t   *prop;

    PFarray_t         *env;        /**< environment to store the corresponding
                                        MIL variable bindings (see milgen.brg)
                                        */
    short              state_label;/**< Burg puts its state information here. */

    unsigned     bit_mil_ctr   :1; /**< used in milgen.brg to allow the
                                        refctr generation on a DAG */
    unsigned     bit_mil_label :1; /**< used in milgen.brg to prune the
                                        DAG labeling. */

    struct PFpa_op_t  *child[PFPA_OP_MAXCHILD];
    unsigned int       refctr;
    int                node_id;    /**< specifies the id of this operator
                                        node; required exclusively to
                                        create dot output. */
};
/** algebra operator node */
typedef struct PFpa_op_t PFpa_op_t;



/* ***************** Constructors ******************* */

/**
 * A `serialize' node will be placed on the very top of the algebra
 * expression tree.
 */
PFpa_op_t * PFpa_serialize (const PFpa_op_t *doc, const PFpa_op_t *alg);

/****************************************************************/

PFpa_op_t *PFpa_lit_tbl (PFalg_attlist_t attlist,
                         unsigned int count, PFalg_tuple_t *tuples);

/**
 * Empty table constructor.  Use this instead of an empty table
 * without any tuples to facilitate optimization.
 */
PFpa_op_t *PFpa_empty_tbl (PFalg_attlist_t attlist);

PFpa_op_t *PFpa_attach (const PFpa_op_t *n,
                        PFalg_att_t attname, PFalg_atom_t value);

/**
 * Cross product (Cartesian product) of two relations.
 *
 * Cross product is defined as the result of
 *  
 *@verbatim
    foreach $a in a
      foreach $b in b
        return ($a, $b) .
@verbatim
 *
 * That is, the left operand is in the *outer* loop.
 */
PFpa_op_t * PFpa_cross (const PFpa_op_t *n1, const PFpa_op_t *n2);

/**
 * LeftJoin: Equi-Join on two relations, preserving the ordering
 *           of the left operand.
 */
PFpa_op_t *
PFpa_leftjoin (PFalg_att_t att1, PFalg_att_t att2,
               const PFpa_op_t *n1, const PFpa_op_t *n2);

/**
 * EqJoin: Equi-Join. Does not provide any ordering guarantees.
 */
PFpa_op_t *
PFpa_eqjoin (PFalg_att_t att1, PFalg_att_t att2,
             const PFpa_op_t *n1, const PFpa_op_t *n2);

/**
 * Project.
 *
 * Note that projection does @b not eliminate duplicates. If you
 * need duplicate elimination, explictly use a Distinct operator.
 */
PFpa_op_t *PFpa_project (const PFpa_op_t *n, unsigned int count,
                         PFalg_proj_t *proj);

/**
 * Select: Filter rows by Boolean value in attribute @a att
 */
PFpa_op_t *PFpa_select (const PFpa_op_t *n, PFalg_att_t att);

/**
 * Construct AppendUnion operator node.
 *
 * AppendUnion simply appends relation @a b to @a a. It does not
 * require any specific order. The output has an order that is
 * typically not really useful.
 */
PFpa_op_t *PFpa_append_union (const PFpa_op_t *, const PFpa_op_t *);

PFpa_op_t *PFpa_merge_union (const PFpa_op_t *, const PFpa_op_t *,
                             PFord_ordering_t);

/**
 * Intersect: No specialized implementations here; always applicable.
 */
PFpa_op_t *PFpa_intersect (const PFpa_op_t *, const PFpa_op_t *);

/**
 * Difference: No specialized implementations here; always applicable.
 */
PFpa_op_t *PFpa_difference (const PFpa_op_t *, const PFpa_op_t *);

/**
 * SortDistinct: Eliminate duplicate tuples.
 *
 * Requires the input to be fully sorted.  Specify this ordering
 * in the second argument (should actually be redundant, but we
 * keep it anyway).
 */
PFpa_op_t *PFpa_sort_distinct (const PFpa_op_t *, PFord_ordering_t);

/**
 * StandardSort: Introduce given sort order as the only new order.
 *
 * Does neither benefit from any existing sort order, nor preserve
 * any such order.  Is thus always applicable.  A possible implementation
 * could be QuickSort.
 */
PFpa_op_t *PFpa_std_sort (const PFpa_op_t *, PFord_ordering_t);

/**
 * RefineSort: Introduce new ordering, but benefit from existing ordering.
 */
PFpa_op_t *PFpa_refine_sort (const PFpa_op_t *,
                             PFord_ordering_t, PFord_ordering_t);

/****************************************************************/

/**
 * Arithmetic operator +.
 *
 * This generic variant expects both operands to be available as
 * columns in the argument relation. If know one of the operands
 * to be actually a constant, we may prefer PFpa_num_add_const()
 * and avoid materialization of the constant attribute.
 */
PFpa_op_t *PFpa_num_add (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_att_t att2);

/**
 * Arithmetic operator -. See PFpa_num_add() for details.
 */
PFpa_op_t *PFpa_num_sub (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_att_t att2);

/**
 * Arithmetic operator *. See PFpa_num_add() for details.
 */
PFpa_op_t *PFpa_num_mult (const PFpa_op_t *, PFalg_att_t res,
                          PFalg_att_t att1, PFalg_att_t att2);

/**
 * Arithmetic operator /. See PFpa_num_add() for details.
 */
PFpa_op_t *PFpa_num_div (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_att_t att2);

/**
 * Arithmetic operator mod. See PFpa_num_add() for details.
 */
PFpa_op_t *PFpa_num_mod (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_att_t att2);

/**
 * Arithmetic operator +.
 *
 * This variant expects one operands to be an atomic value (which
 * is helpful if we know one attribute/argument to be constant).
 */
PFpa_op_t *PFpa_num_add_atom (const PFpa_op_t *, PFalg_att_t res,
                              PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Arithmetic operator -. See PFpa_num_add_atom() for details.
 */
PFpa_op_t *PFpa_num_sub_atom (const PFpa_op_t *, PFalg_att_t res,
                              PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Arithmetic operator *. See PFpa_num_add_atom() for details.
 */
PFpa_op_t *PFpa_num_mult_atom (const PFpa_op_t *, PFalg_att_t res,
                               PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Arithmetic operator /. See PFpa_num_add_atom() for details.
 */
PFpa_op_t *PFpa_num_div_atom (const PFpa_op_t *, PFalg_att_t res,
                              PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Arithmetic operator mod. See PFpa_num_add_atom() for details.
 */
PFpa_op_t *PFpa_num_mod_atom (const PFpa_op_t *, PFalg_att_t res,
                              PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Comparison operator eq.
 */
PFpa_op_t *PFpa_eq (const PFpa_op_t *, PFalg_att_t res,
                    PFalg_att_t att1, PFalg_att_t att2);

/**
 * Comparison operator gt.
 */
PFpa_op_t *PFpa_gt (const PFpa_op_t *, PFalg_att_t res,
                    PFalg_att_t att1, PFalg_att_t att2);

/**
 * Comparison operator eq, where one column is an atom (constant).
 */
PFpa_op_t *PFpa_eq_atom (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Comparison operator gt, where one column is an atom (constant).
 */
PFpa_op_t *PFpa_gt_atom (const PFpa_op_t *, PFalg_att_t res,
                         PFalg_att_t att1, PFalg_atom_t att2);

/**
 * Numeric negation
 */
PFpa_op_t *PFpa_num_neg (const PFpa_op_t *,
                         PFalg_att_t res, PFalg_att_t att);

/**
 * Boolean negation
 */
PFpa_op_t *PFpa_bool_not (const PFpa_op_t *,
                          PFalg_att_t res, PFalg_att_t att);

/**
 * HashCount: Hash-based Count operator. Does neither benefit from
 * any existing ordering, nor does it provide/preserve any input
 * ordering.
 */
PFpa_op_t *PFpa_hash_count (const PFpa_op_t *,
                            PFalg_att_t, PFalg_att_t);

/****************************************************************/

PFpa_op_t *PFpa_merge_rownum (const PFpa_op_t *n,
                              PFalg_att_t new_att,
                              PFalg_att_t part);

/**
 * HashRowNumber: Introduce new row numbers.
 *
 * HashRowNumber uses a hash table to implement partitioning. Hence,
 * it does not require any specific input ordering.
 *
 * @param n        Argument relation.
 * @param new_att  Name of newly introduced attribute.
 * @param part     Partitioning attribute. @c NULL if partitioning
 *                 is not requested.
 */
PFpa_op_t *PFpa_hash_rownum (const PFpa_op_t *n,
                             PFalg_att_t new_att,
                             PFalg_att_t part);

PFpa_op_t *PFpa_number (const PFpa_op_t *n, PFalg_att_t new_att,
                        PFalg_att_t part);

/**
 * Type operator
 */
PFpa_op_t *PFpa_type (const PFpa_op_t *,
                      PFalg_att_t,
                      PFalg_simple_type_t, PFalg_att_t);

/**
 * Constructor for type assertion check. The result is the
 * input relation n where the type of attribute att is replaced
 * by ty
 */
PFpa_op_t * PFpa_type_assert (const PFpa_op_t *n, PFalg_att_t att,
                              PFalg_simple_type_t ty);

/**
 * Cast operator
 */
PFpa_op_t *PFpa_cast (const PFpa_op_t *,
                      PFalg_att_t, PFalg_att_t, 
                      PFalg_simple_type_t);

/****************************************************************/

/**
 * StaircaseJoin operator.
 *
 * Input must have iter|item schema, and be sorted on iter.
 */
PFpa_op_t *PFpa_llscj_anc (const PFpa_op_t *frag,
                           const PFpa_op_t *ctx,
                           const PFty_t test,
                           const PFord_ordering_t in,
                           const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_anc_self (const PFpa_op_t *frag,
                                const PFpa_op_t *ctx,
                                const PFty_t test,
                                const PFord_ordering_t in,
                                const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_attr (const PFpa_op_t *frag,
                            const PFpa_op_t *ctx,
                            const PFty_t test,
                            const PFord_ordering_t in,
                            const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_child (const PFpa_op_t *frag,
                             const PFpa_op_t *ctx,
                             const PFty_t test,
                             const PFord_ordering_t in,
                             const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_desc (const PFpa_op_t *frag,
                            const PFpa_op_t *ctx,
                            const PFty_t test,
                            const PFord_ordering_t in,
                            const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_desc_self (const PFpa_op_t *frag,
                                 const PFpa_op_t *ctx,
                                 const PFty_t test,
                                 const PFord_ordering_t in,
                                 const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_foll (const PFpa_op_t *frag,
                            const PFpa_op_t *ctx,
                            const PFty_t test,
                            const PFord_ordering_t in,
                            const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_foll_sibl (const PFpa_op_t *frag,
                                 const PFpa_op_t *ctx,
                                 const PFty_t test,
                                 const PFord_ordering_t in,
                                 const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_parent (const PFpa_op_t *frag,
                              const PFpa_op_t *ctx,
                              const PFty_t test,
                              const PFord_ordering_t in,
                              const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_prec (const PFpa_op_t *frag,
                            const PFpa_op_t *ctx,
                            const PFty_t test,
                            const PFord_ordering_t in,
                            const PFord_ordering_t out);
PFpa_op_t *PFpa_llscj_prec_sibl (const PFpa_op_t *frag,
                                 const PFpa_op_t *ctx,
                                 const PFty_t test,
                                 const PFord_ordering_t in,
                                 const PFord_ordering_t out);

/**
 * Access to persistently stored document table.
 *
 * Requires an iter | item schema as its input.
 */
PFpa_op_t * PFpa_doc_tbl (const PFpa_op_t *);

/**
 * Access to the string content of loaded documents
 */
PFpa_op_t * PFpa_doc_access (const PFpa_op_t *doc, 
                             const PFpa_op_t *alg,
                             PFalg_att_t att,
                             PFalg_doc_t doc_col);

/**
 * element constructor
 *
 * Requires an iter | item schema as its qname input
 * and a an iter | pos | item schema as its content input.
 */
PFpa_op_t * PFpa_element (const PFpa_op_t *, 
                          const PFpa_op_t *,
                          const PFpa_op_t *);

/**
 * Attribute constructor
 *
 * Requires iter | item schemas as its input.
 */
PFpa_op_t * PFpa_attribute (const PFpa_op_t *,
                           const PFpa_op_t *,
                           PFalg_att_t,
                           PFalg_att_t,
                           PFalg_att_t);

/**
 * Text constructor
 *
 * Requires an iter | item schema as its input.
 */
PFpa_op_t * PFpa_textnode (const PFpa_op_t *,
                           PFalg_att_t, PFalg_att_t);

PFpa_op_t * PFpa_merge_adjacent (const PFpa_op_t *fragment,
                                 const PFpa_op_t *n);

/**
 * Extract result part from a (frag, result) pair.
 */
PFpa_op_t *PFpa_roots (const PFpa_op_t *n);

/**
 * Extract fragment part from a (frag, result) pair.
 */
PFpa_op_t *PFpa_fragment (const PFpa_op_t *n);

/**
 * Form disjoint union between two fragments.
 */
PFpa_op_t *PFpa_frag_union (const PFpa_op_t *n1, const PFpa_op_t *n2);

/**
 * Empty fragment list
 */
PFpa_op_t *PFpa_empty_frag (void);

/**
 * Constructor for conditional error
 */
PFpa_op_t * PFpa_cond_err (const PFpa_op_t *n, const PFpa_op_t *err,
                           PFalg_att_t att, char *err_string);

/****************************************************************/
/* operators introduced by built-in functions */

/**
 * Constructor for builtin function fn:concat
 */
PFpa_op_t * PFpa_fn_concat (const PFpa_op_t *n, PFalg_att_t res,
                            PFalg_att_t att1, PFalg_att_t att2);

/**
 * Concatenation of multiple strings (using seperators)
 */
PFpa_op_t * PFpa_string_join (const PFpa_op_t *n1, 
                              const PFpa_op_t *n2);


#endif  /* PHYSICAL_H */

/* vim:set shiftwidth=4 expandtab: */
