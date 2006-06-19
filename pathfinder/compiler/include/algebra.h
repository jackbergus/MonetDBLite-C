/**
 * @file
 *
 * Declarations for relational algebra, generic for logical and
 * physical algebra.
 *
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

#ifndef ALGEBRA_H
#define ALGEBRA_H

#include "variable.h"
#include "stdbool.h"

/* ............... atomic values ............... */

/**
 * Simple atomic types that our algebra knows.
 *
 * Actual attribute types can be any combination of types from here
 * (polymorphism). We represent these polymorphic algebra types with
 * help of a bit-vector. Each of the bits corresponds to one of the
 * enumeration types here.
 *
 * Observe that the type #aat_node has four bits set, as nodes are split
 * in MonetDB into attribute nodes (#aat_anode) and other nodes (#aat_pnode).
 * Both node kinds require two bits each, to represented the nodes using a 
 * node id (#aat_pre/#aat_attr) and a document fragment (#aat_pfrag/#aat_afrag).
 *
 * @note
 *   The bits for #aat_pfrag and #aat_afrag @b must be lower than the bit
 *   for #aat_pre and #aat_attr, respectively. Our sort implementation will
 *   first sort by the frag BAT, then by the pre BAT this way.
 *   This implements document order across documents correctly.
 */
enum PFalg_simple_type_t {
      aat_nat   = 0x0001  /**< algebra simple atomic type natural number */
    , aat_int   = 0x0002  /**< algebra simple atomic type integer */
    , aat_str   = 0x0004  /**< algebra simple atomic type string  */
    , aat_dec   = 0x0008  /**< algebra simple atomic type decimal */
    , aat_dbl   = 0x0010  /**< algebra simple atomic type double  */
    , aat_bln   = 0x0020  /**< algebra simple atomic type boolean  */
    , aat_qname = 0x0040  /**< algebra simple atomic type QName  */
    , aat_uA    = 0x0080  /**< algebra simple atomic type untypedAtomic  */
    , aat_node  = 0x0F00  /**< algebra simple atomic type node */ 
    , aat_anode = 0x0C00  /**< algebra simple atomic type attribute */ 
    , aat_attr  = 0x0800  /**< an attribute is represented 
                               by an attr value... */
    , aat_afrag = 0x0400  /**< ...and a attribute fragment */
    , aat_pnode = 0x0300  /**< algebra simple atomic type representing
                               all other nodes */ 
    , aat_pre   = 0x0200  /**< a node is represented by a pre value... */
    , aat_pfrag = 0x0100  /**< ...and a node fragment */
};
/** Simple atomic types in our algebra */
typedef enum PFalg_simple_type_t PFalg_simple_type_t;

#define monomorphic(a) ((a) == aat_nat || (a) == aat_int || (a) == aat_str \
                        || (a) == aat_dec || (a) == aat_dbl || (a) == aat_bln \
                        || (a) == aat_qname || (a) == aat_uA \
                        || (a) == aat_anode || (a) == aat_pnode \
                        || ((a) == aat_pre || (a) == aat_pfrag) \
                        || ((a) == aat_attr || (a) == aat_afrag) \
                        || ((a) == 0))

typedef unsigned int nat;

/**
 * The types we use for attributes are combinations of the simple
 * types, represented as a bit-vector. For now, 16 bits suffice by
 * far, but we may extend this vector if desired.
 */
typedef unsigned short PFalg_type_t;


/** atomic algebra values */
union PFalg_atom_val_t {
    nat        nat;     /**< value for natural number atoms (#aat_nat) */
    int        int_;    /**< value for integer atoms (#aat_int) */
    char      *str;     /**< value for string and untyped atoms (#aat_str)  */
    float      dec;     /**< value for decimal atoms (#aat_dec) */
    double     dbl;     /**< value for double atoms (#aat_dbl) */
    bool       bln;     /**< value for boolean atoms (#aat_bln) */
    PFqname_t  qname;
};
/** algebra values */
typedef union PFalg_atom_val_t PFalg_atom_val_t;

/** value indicator of PFalg_atom_t */
enum PFalg_minmax_t {
    amm_min    = 0 /**< minimal domain value */
  , amm_normal = 1 /**< standard value */
  , amm_max    = 2 /**< maximal domain value */
};
typedef enum PFalg_minmax_t PFalg_minmax_t;

/** typed atomic value representation in our algebra */
struct PFalg_atom_t {
    PFalg_simple_type_t type;    /**< type of this atom */
    PFalg_atom_val_t    val;     /**< value */
    PFalg_minmax_t      special; /**< min/max domain value indicator */
};
/** typed atomic value representation in our algebra */
typedef struct PFalg_atom_t PFalg_atom_t;


/* ............... tuples of atomic values ............... */

/** a tuple is an array of atoms, with length specified in `count' */
struct PFalg_tuple_t {
    unsigned int  count;   /**< number of atoms in this tuple */
    PFalg_atom_t *atoms;   /**< array containing the atoms */
};

typedef struct PFalg_tuple_t PFalg_tuple_t;


/* ................ algebra attribute lists ................ */

/** An attribute (name) is represented by an enum */
enum PFalg_att_t {
      att_NULL    = 0x00000000    /**< cope with empty partions */
    , att_iter    = 0x00000001    /**< iter column */
    , att_item    = 0x00000002    /**< item column */ 
    , att_pos     = 0x00000004    /**< pos column */  
    , att_iter1   = 0x00000008    /**< iter1 column */
    , att_item1   = 0x00000010    /**< item1 column */
    , att_pos1    = 0x00000020    /**< pos1 column */
    , att_inner   = 0x00000040    /**< inner column */
    , att_outer   = 0x00000080    /**< outer column */
    , att_sort    = 0x00000100    /**< sort column */
    , att_sort1   = 0x00000200    /**< sort column 1 */
    , att_sort2   = 0x00000400    /**< sort column 2 */
    , att_sort3   = 0x00000800    /**< sort column 3 */
    , att_sort4   = 0x00001000    /**< sort column 4 */
    , att_sort5   = 0x00002000    /**< sort column 5 */
    , att_sort6   = 0x00004000    /**< sort column 6 */
    , att_sort7   = 0x00008000    /**< sort column 7 */
    , att_ord     = 0x00010000    /**< ord column */
    , att_iter2   = 0x00020000    /**< iter column 2 */
    , att_iter3   = 0x00040000    /**< iter column 3 */
    , att_iter4   = 0x00080000    /**< iter column 4 */
    , att_iter5   = 0x00100000    /**< iter column 5 */
    , att_iter6   = 0x00200000    /**< iter column 6 */
    , att_res     = 0x00400000    /**< res column */
    , att_res1    = 0x00800000    /**< res1 column */
    , att_cast    = 0x01000000    /**< cast column */
    , att_item2   = 0x02000000    /**< item2 column */
    , att_subty   = 0x04000000    /**< subty column */
    , att_itemty  = 0x08000000    /**< itemty column */
    , att_notsub  = 0x10000000    /**< notsub column */
    , att_isint   = 0x20000000    /**< isint column */
    , att_isdec   = 0x40000000    /**< isdec column */
};
/** attribute names */
typedef enum PFalg_att_t PFalg_att_t;

/** A list of attributes (actually: attribute names) */
struct PFalg_attlist_t {
    unsigned int count;    /**< number of items in this list */
    PFalg_att_t *atts;     /**< array that holds the actual list items */
};
typedef struct PFalg_attlist_t PFalg_attlist_t;

/* ............. algebra schema specification .............. */

/** An algebra schema item is a (name, type) pair */
struct PFalg_schm_item_t {
    PFalg_att_t     name;
    PFalg_type_t    type;
};
typedef struct PFalg_schm_item_t PFalg_schm_item_t;

/** A schema is then a list of schema items */
struct PFalg_schema_t {
    unsigned int               count;  /**< number of items in the list */
    struct PFalg_schm_item_t  *items;  /**< array holding the schema items */
};
typedef struct PFalg_schema_t PFalg_schema_t;


/** item in a projection list, an (new-name,old-name) pair */
struct PFalg_proj_t {
    PFalg_att_t new;   /**< new attribute name to assign */
    PFalg_att_t old;   /**< old attribute name */
};
typedef struct PFalg_proj_t PFalg_proj_t;


/* ....... staircase join specs (semantic infos of scj operators) ....... */

/** location steps */
enum PFalg_axis_t {
      alg_anc          /**< ancestor axis */
    , alg_anc_s        /**< ancestor-or-self axis */
    , alg_attr         /**< attribute axis */
    , alg_chld         /**< child axis */
    , alg_desc         /**< descendant axis */
    , alg_desc_s       /**< descendant-or-self axis */
    , alg_fol          /**< following axis */
    , alg_fol_s        /**< following-sibling axis */
    , alg_par          /**< parent axis */
    , alg_prec         /**< preceding axis */
    , alg_prec_s       /**< preceding-sibling axis */
    , alg_self         /**< self axis */
};
/** location steps */
typedef enum PFalg_axis_t PFalg_axis_t;

enum PFalg_node_kind_t {
      node_kind_elem   /**< elements */
    , node_kind_attr   /**< attributes */
    , node_kind_text   /**< text nodes */
    , node_kind_pi     /**< processing instructions */
    , node_kind_comm   /**< comments */
    , node_kind_doc    /**< document nodes */
    , node_kind_node   /**< any XML tree node */
};
typedef enum PFalg_node_kind_t PFalg_node_kind_t;

struct PFalg_scj_spec_t {
    PFalg_axis_t        axis;    /**< represented axis */
    PFalg_node_kind_t   kind;    /**< node kind to test for */
    union {
        char           *target;  /**< target specified for pi's */
        PFqname_t       qname;   /**< for name tests */
    } str;
};
typedef struct PFalg_scj_spec_t PFalg_scj_spec_t;

/* ............. document fields specification .............. */

enum PFalg_doc_t {
      doc_atext        /**< attribute content > */
    , doc_text         /**< content of a text node > */
    , doc_comm         /**< content of a comment node > */
    , doc_pi_text      /**< content of a pi node > */
/*    , doc_name   */      /**< name of element node > */
/*    , doc_local  */      /**< local part of an element node name > */
/*    , doc_uri    */      /**< uri part of an element node name > */
};
typedef enum PFalg_doc_t PFalg_doc_t;

/* ***************** Constructors ******************* */

/** construct literal natural number (atom) */
PFalg_atom_t PFalg_lit_nat (nat value);

/** construct literal integer (atom) */
PFalg_atom_t PFalg_lit_int (long long int value);

/** construct literal string (atom) */
PFalg_atom_t PFalg_lit_str (char *value);

/** construct literal float (atom) */
/* FIXME: Wouter: should be double? */
PFalg_atom_t PFalg_lit_dec (float value);

/** construct literal double (atom) */
PFalg_atom_t PFalg_lit_dbl (double value);

/** construct literal boolean (atom) */
PFalg_atom_t PFalg_lit_bln (bool value);

/** construct literal QName (atom) */
PFalg_atom_t PFalg_lit_qname (PFqname_t value);


/**
 * Construct a literal table tuple, a list of atoms.
 * (actually just a wrapper for #PFalg_tuple_()).
 *
 * Functions with a variable number of arguments need a mechanism to
 * detect the end of the argument list. We therefore wrap the actual
 * worker #PFalg_tuple_() into this macro. The macro detects the
 * number of arguments passed (using arithmetics with sizeof()) and
 * prepends a count information to the actual argument list.
 */
#define PFalg_tuple(...)                                       \
    PFalg_tuple_ ((sizeof ((PFalg_atom_t[]) { __VA_ARGS__ })   \
                      / sizeof (PFalg_atom_t)),                \
                  (PFalg_atom_t[]) { __VA_ARGS__ } )

/** Worker to construct a literal table tuple */
PFalg_tuple_t PFalg_tuple_ (unsigned int count, PFalg_atom_t *atoms);

/**
 * Construct an attribute list (list of attribute names only).
 */
#define PFalg_attlist(...)                                     \
    PFalg_attlist_ ((sizeof ((PFalg_att_t[]) { __VA_ARGS__ })   \
                       / sizeof (PFalg_att_t)),                \
                   (PFalg_att_t[]) { __VA_ARGS__ })
PFalg_attlist_t PFalg_attlist_ (unsigned int count, PFalg_att_t *atts);


/** Constructor for projection list item */
PFalg_proj_t PFalg_proj (PFalg_att_t new, PFalg_att_t old);

/**
 * Test if two atomic values are comparable
 */
bool PFalg_atom_comparable (PFalg_atom_t a, PFalg_atom_t b);

/**
 * Compare two atomic values (if possible)
 */
int PFalg_atom_cmp (PFalg_atom_t a, PFalg_atom_t b);

/**
 * Print attribute name
 */
char * PFatt_str (PFalg_att_t att);

/**
 * Create a unique name based on an id @a id and 
 * an original name @a ori that retains the usage information
 * of the new variable (iter, pos or item).
 */
PFalg_att_t PFalg_unq_name (PFalg_att_t ori, unsigned int id);

/**
 * Create an original column name based on an unique name @a unq
 * and a list of free original variables @a free.
 */
PFalg_att_t PFalg_ori_name (PFalg_att_t unq, PFalg_att_t free);

/**
 * Print simple type name
 */
char * PFsimple_type_str (PFalg_simple_type_t att);

#endif  /* ALGEBRA_H */

/* vim:set shiftwidth=4 expandtab: */
