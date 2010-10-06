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

#ifndef HASH_H__
#define HASH_H__

/* code for no key */
#define NO_KEY -1 

/* returns true if no such key is found */
#define NOKEY(k) ((k) == NO_KEY)

/* a hashtable bucket */
typedef struct bucket_t bucket_t;

/* definition for hashtable_t */
typedef struct bucket_t** hashtable_t;

/**
 * Create a new Hashtable.
 */
hashtable_t new_hashtable (void);

/**
 * Find element in hashtable.
 */
int hashtable_find (hashtable_t, const char*);

/**
 * Insert key and id to hashtable.
 */
void hashtable_insert (hashtable_t, const char*, int);

/**
 * Free memory assigned to hash_table.
 */
void free_hashtable (hashtable_t);

#endif /* HASH_H__ */
