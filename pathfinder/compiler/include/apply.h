/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 *
 * Declarations for semantics/functions.c; Data structures and access
 * functions for XQuery function calls and definitions.
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
 * 2000-2005 University of Konstanz.  All Rights Reserved.
 *
 * $Id$
 */

#ifndef APPLY_H
#define APPLY_H

/**
 * SOAP EXTENSION (Boncz/Zhang CWI 2005)
 *
 * when a UDF is called (applied) with the namespace identifier 'soap' it is a soap rpc
 *
 * soap:fcn(p0,p1,..,pn)     ==>    call fcn(p1,..,pn) at URI=p0
 *
 * The below structure is used in parse trees for function applications. it records
 * whether the function is being called in 'soap' mode. This has consequences for type
 * checking, mainly the first actual parameter should be of type string (URI destination)
 * and the function is resolved by excluding the first parameter from the parameter list.
 */
typedef struct {
    struct PFfun_t *fun;
    int rpc;
} PFapply_t;

PFapply_t *PFapply(struct PFfun_t *fun);

#endif
