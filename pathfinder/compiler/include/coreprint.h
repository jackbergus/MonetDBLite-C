/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 * 
 * Declarations for coreprint.c; dump XQuery core language
 * tree in AY&T dot format or human readable
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

#ifndef COREPRINT_H
#define COREPRINT_H

/* FILE, ... */
#include <stdio.h>

/* node, ... */
#include "core.h"

extern char *c_id[];

void PFcore_dot (FILE *f, PFcnode_t *root);

void PFcore_pretty (FILE *f, PFcnode_t *root);

#endif     /* COREPRINT_H */

/* vim:set shiftwidth=4 expandtab: */
