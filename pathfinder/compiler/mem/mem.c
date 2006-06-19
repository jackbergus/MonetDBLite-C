/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file mem.c
 * Garbage collected memory and string allocation 
 * (@a no allocation of specific objects [parse tree nodes, etc.] here!)
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

#include "pathfinder.h"

#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "mem.h"

#include "oops.h"

#define PA_MALLOC(n)	        pa_alloc(pf_alloc, n)
#define PA_REALLOC(p, n)	pa_realloc(pf_alloc, p, n)

#define SA_BLOCK (4*1024*1024)

pf_allocator *pf_alloc = NULL;

pf_allocator *pa_create(void)
{
	pf_allocator *pa = (pf_allocator*)malloc(sizeof(pf_allocator));
	
	pa->size = 64;
	pa->nr = 1;
	pa->blks = (char**)malloc(pa->size*sizeof(char*));
	pa->blks[0] = (char*)malloc(SA_BLOCK);
	pa->used = 0;
	return pa;
}

char *
pa_realloc(pf_allocator *pa, char *p, size_t n ) 
{
        char *r = pa_alloc( pa, n);
        memcpy(r, p, n);
        return r;
}

#define round16(sz) ((sz+15)&~15)
char *pa_alloc( pf_allocator *pa, size_t sz )
{
	char *r;
	sz = round16(sz);
	if (sz > SA_BLOCK) {
		char *t;
		char *r = malloc(sz);
		if (pa->nr >= pa->size) {
			pa->size *=2;
			pa->blks = (char**)realloc(pa->blks,pa->size*sizeof(char*));
		}
		t = pa->blks[pa->nr-1];
		pa->blks[pa->nr-1] = r;
		pa->blks[pa->nr] = t;
		pa->nr ++;
		return r;
	}
	if (sz > (SA_BLOCK-pa->used)) {
		char *r = malloc(SA_BLOCK);
		if (pa->nr >= pa->size) {
			pa->size *=2;
			pa->blks = (char**)realloc(pa->blks,pa->size*sizeof(char*));
		}
		pa->blks[pa->nr] = r;
		pa->nr ++;
		pa->used = sz;
		return r;
	}
	r = pa->blks[pa->nr-1] + pa->used;
	pa->used += sz;
	return r;
}

void pa_destroy( pf_allocator *pa ) 
{
	unsigned int i ;

	for (i = 0; i<pa->nr; i++) {
		free(pa->blks[i]);
	}
	free(pa->blks);
	free(pa);
}

/**
 * Worker for #PFmalloc ().
 */
void *
PFmalloc_ (size_t n, const char *file, const char *func, const int line) 
{
    void *mem;
    /* allocate garbage collected heap memory of requested size */
    mem = PA_MALLOC (n);

    if (mem == 0) {
        /* don't use PFoops () here as it tries to allocate even more memory */
        PFlog ("fatal error: insufficient memory in %s (%s), line %d", 
                file, func, line);
        PFexit(-OOPS_FATAL);
    }

    return mem;
}

/**
 * Worker for #PFrealloc ().
 */
void *
PFrealloc_ (size_t n, void *mem, 
	    const char *file, const char *func, const int line) 
{
    /* resize garbage collected heap memory to requested size */
    mem = PA_REALLOC (mem, n);

    if (mem == 0) {
        /* don't use PFoops () here as it tries to allocate even more memory */
        PFlog ("fatal error: insufficient memory in %s (%s), line %d", 
                file, func, line);
        PFexit(-OOPS_FATAL);
    }

    return mem;
}

/**
 * Allocates enough memory to hold a copy of @a str
 * and return a pointer to this copy 
 * If you specify @a n != 0, the copy will hold @a n characters (+ the
 * trailing '\\0') only.
 * @param str string to copy
 * @param len copy @a len characters only
 * @return pointer to newly allocated (partial) copy of @a str
 */
char *
PFstrndup (const char *str, size_t len)
{
    char *copy;

    /* + 1 to hold end of string marker '\0' */
    copy = (char *) PFmalloc (len + 1);

    (void) strncpy (copy, str, len);

    /* force end of string marker '\0' */
    copy[len] = '\0';

    return copy;
}

/**
 * Allocates enough memory to copy @a str and return a pointer to it
 * (calls #PFcopyStrn with @a n == 0),
 * @param str string to copy
 * @return pointer to newly allocated copy of @a str
 */
char *
PFstrdup (const char *str)
{
    return PFstrndup (str, strlen (str));
}


/* vim:set shiftwidth=4 expandtab: */
