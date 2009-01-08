/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 *
 * Functions and data structures to support environments for various
 * Pathfinder modules.
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
 * the Database Group at the Technische Universitaet Muenchen, Germany.
 * It is now maintained by the Database Systems Group at the Eberhard
 * Karls Universitaet Tuebingen, Germany.  Portions created by the
 * University of Konstanz, the Technische Universitaet Muenchen, and the
 * Universitaet Tuebingen are Copyright (C) 2000-2005 University of
 * Konstanz, (C) 2005-2008 Technische Universitaet Muenchen, and (C)
 * 2008-2009 Eberhard Karls Universitaet Tuebingen, respectively.  All
 * Rights Reserved.
 *
 * $Id$
 */

#ifndef ENV_H
#define ENV_H

/* PFqname_t */
#include "qname.h"

/* PFarray_t */
#include "array.h"

typedef PFarray_t PFenv_t;

/* create a new environment */
PFenv_t *PFenv_ (unsigned int initial_slots);
#define PFenv() (PFenv_ (20))

/* bind key to value in environment 
 * (return 0 if key was unbound, value otherwise) 
 */
PFarray_t *PFenv_bind (PFenv_t *, PFqname_t, void *);

/* lookup given key in environment (returns array of bindings or 0) */
PFarray_t *PFenv_lookup (PFenv_t *, PFqname_t);

/** iterate over all bound values in an environment */
void PFenv_iterate (PFenv_t *, void (*) (PFqname_t, void *));

#endif /* ENV_H */


/* vim:set shiftwidth=4 expandtab: */
