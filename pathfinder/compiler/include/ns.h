/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 *
 * Resolve XML namespaces (NS) in the abstract syntax tree.
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
 * The Initial Developer of the Original Code is the Database &
 * Information Systems Group at the University of Konstanz, Germany.
 * Portions created by the University of Konstanz are Copyright (C)
 * 2000-2006 University of Konstanz.  All Rights Reserved.
 *
 * $Id$
 */

#ifndef NS_H
#define NS_H

/** representation of an XML Namespace */
typedef struct PFns_t PFns_t;

/**
 * Representation of an XML NS:
 * (1) @a ns:  the namespace prefix
 * (2) @a uri: the URI @a ns has been mapped to,
 *             either via an XQuery namespace declaration, e.g.
 *
 *                           declare namespace foo = "http://bar"
 *                
 *             or a namespace declaration (xmlns) attribute, e.g.,
 *
 *                           <a xmlns:foo="http://bar"> ... </a>
 *
 *             or by definition, see the W3C standard documents, e.g.
 *             W3C XQuery, 4.1 (Namespace Declarations):
 *                          
 *                    "xs" |-> "http://www.w3.org/2001/XMLSchema"
 */
struct PFns_t {
  char *ns;    /**< namespace prefix */
  char *uri;   /**< URI this namespace has been mapped to */
};

/*
 * XML NS that are predefined for any query (may be used without
 * prior declaration) in XQuery, see W3C XQuery, 4.1
 */
/** Predefined namespace `xml' for any query */
extern PFns_t PFns_xml;
/** Predefined namespace `xs' (XML Schema) for any query */
extern PFns_t PFns_xs; 
/** Predefined namespace `xsi' (XML Schema Instance) for any query */
extern PFns_t PFns_xsi;
/** Predefined namespace `xdt' (XPath Data Types) for any query */
extern PFns_t PFns_xdt;
/** Predefined namespace `local' (XQuery Local Functions) for any query */
extern PFns_t PFns_local;

/**
 * XQuery default function namespace (fn:..., this may be overridden 
 * via `default function namespace = "..."')
 * (see W3C XQuery 1.0 and XPath 2.0 Function and Operators, 1.5).
 */
extern PFns_t PFns_fn;

/**
 * XQuery operator namespace (op:...)
 * (see W3C XQuery 1.0 and XPath 2.0 Function and Operators, 1.5).
 */
extern PFns_t PFns_op;

/** 
 * Pathfinder's own internal NS (pf:...).
 */ 
extern PFns_t PFns_pf;

/**
 * Wildcard namespace (used in QNames of the form *:loc)
 */
extern PFns_t PFns_wild;

/** 
 * NS equality (URI-based, then prefix-based)
 */
int PFns_eq (PFns_t, PFns_t);

#endif /* NS_H */


/* vim:set shiftwidth=4 expandtab: */
