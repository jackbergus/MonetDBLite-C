/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 * Compiler Driver interface defs for external usage
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
 */

#ifndef COMPILEINT_H
#define COMPILEINT_H

/* main compiler call from the Monet runtime environment */
char* PFcompile_MonetDB (char* xquery, char* mode, char** prologue, char** query, char** epilogue);

/* get a document by URL (if not in cache, fetch it) */
char* PFurlcache(char *url);

/* flush the url cache */
void PFurlcache_flush();

const char* PFinitMIL();   /* MIL pattern for global variable definitions */
const char* PFstartMIL();  /* MIL pattern for starting query execution */
const char* PFdocbatMIL(); /* MIL pattern for adding a shredded document to the ws */
const char* PFudfMIL();    /* MIL pattern for calling a UDF */
const char* PFstopMIL();   /* MIL pattern for stopping query execution (and print) */

#endif

/* vim:set shiftwidth=4 expandtab: */
