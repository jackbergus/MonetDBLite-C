/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file abssynprint.h 
 * 
 * Debugging: dump XQuery abstract syntax tree in
 * AY&T dot format or human readable
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

#ifndef ABSSYNPRINT_H
#define ABSSYNPRINT_H

/* FILE */
#include <stdio.h>

/* PFpnode_t */
#include "abssyn.h"

/** Node names to print out for all the abstract syntax tree nodes. */
extern char *p_id[];

void PFabssyn_dot (FILE *f, PFpnode_t *root);

void PFabssyn_pretty (FILE *f, PFpnode_t *root);

#endif

/* vim:set shiftwidth=4 expandtab: */
