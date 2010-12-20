/**
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
 * 2008-2010 Eberhard Karls Universitaet Tuebingen, respectively.  All
 * Rights Reserved.
 *
 * $Id$
 */

#ifndef ENCODING_H__
#define ENCODING_H__

#include <stdio.h> 

/* SAX parser interface (libxml2) */
#include "libxml/parser.h"

#include "shred_helper.h"

/**
 * XML node kinds
 */
enum kind_t {
      elem = 1    /** < element node           */
    , attr = 2    /** < attribute              */
    , text = 3    /** < text node              */
    , comm = 4    /** < comment                */
    , pi   = 5    /** < processing instruction */
    , doc  = 6    /** < document node          */
};
typedef enum kind_t kind_t;

/**
 * Properties of a guide tree node (see guides.h)
 */
typedef struct guide_tree_t guide_tree_t;

/** 
 * Properties of an encoded XML node 
 */
typedef struct node_t node_t;

struct node_t {
    nat           root;                 /* root preorder rank */
    nat           pre;                  /* preorder rank */
    nat           post;                 /* postorder rank */
    nat           pre_stretched;        /* preorder in stretched plane */
    nat           post_stretched;       /* postorder in stretched plane */
    node_t       *parent;               /* pointer to parent */
    nat           size;                 /* # of nodes in subtree */
    nat           children;             /* # of children nodes collected so far */
    int           level;                /* length of path from node to root */
    kind_t        kind;                 /* XML node kind */
    char         *prefix;               /* namespace prefix of element/attribute */
    int           prefix_id;            /* unique ID of namespace prefix */
    char         *localname;            /* localname of element/attribute */
    int           localname_id;         /* unique ID of localname */
    char         *uri;                  /* namespace URI of element/attribute */
    int           uri_id;               /* unique ID of namespace URI */
    char         *value;                /* node content (text, value) */
    guide_tree_t *guide;                /* pointer to this node's guide entry */
};


/**
 * Print decoded kind
 */
void print_kind (FILE *f, kind_t kind);


/**
 * Main shredding procedure 
 */
void SHshredder (const char *s, 
                 FILE *shout, 
                 FILE *attout, 
                 FILE *namesout, 
                 FILE *prefixesout,
                 FILE *urisout,
                 FILE *guideout, 
                 shred_state_t *status);

/**
 * Table shredding procedure 
 */
void SHshredder_table (const char *s, 
                       FILE *shout, 
                       FILE *attout, 
                       FILE *namesout, 
                       FILE *prefixesout,
                       FILE *urisout,
                       FILE *guideout, 
                       FILE *tableout, 
                       shred_state_t *status);

#endif
