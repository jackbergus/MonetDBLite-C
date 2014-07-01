/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2014 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * (author) R Cijvat
 * This file contains some global definitions, used by multiple bam
 * library files
 */

#ifndef _BAM_GLOBALS_H
#define _BAM_GLOBALS_H

#include <string.h>
#include "gdk.h"
#include "stream.h"



/* Macro that enables writing to a log. If the debug flag is not set,
 * it does not do anything */
#ifndef NDEBUG
#define BAM_DEBUG /* We are in 'debug-mode' if --enable-assert was set during configuration, since in that case NDEBUG will not be set. */
#endif


#ifdef BAM_DEBUG

/**
 * Function prepares a string for the log by adding hashes in front of every line
 * Returned string has to be freed
 */
static inline char *
prepare_for_log(const char *str, bit first_line_hash) {
	int l = strlen(str);
	char *prepared = (char *)GDKmalloc(3 * l * sizeof(char)); /* Worst case: every character is newline */
	int i, j = 0;

	if(prepared == NULL) return NULL;

	if(first_line_hash) {
		prepared[j++] = '#';
		prepared[j++] = ' ';
	}
	for(i=0; i<l; ++i) {
		prepared[j++] = str[i];
		if(str[i] == '\n') {
			prepared[j++] = '#';
			prepared[j++] = ' ';
		}
	}
	prepared[j] = '\0';
	return prepared;
}

/* Function that adds a hash before every printed line, so Mtest.py will not notice a difference in whether or not we are debugging. Arguments to this function should  */
static inline int
hash_fprintf(FILE *f, const char *format, ...) __attribute__ ((format (printf, 2, 3) ));

static inline int
hash_fprintf(FILE *f, const char *format, ...) {
	va_list arg;
	int done;

	char *format_prepared = prepare_for_log(format, TRUE);

	if(format_prepared == NULL) return -1;

	va_start(arg, format);
	done = vfprintf(f, format_prepared, arg);
	va_end(arg);

	GDKfree(format_prepared);
	return done;
}


/* Macro that enables writing to a log. If the debug flag is not set, it does not do anything */
#define TO_LOG(...) hash_fprintf(stderr, __VA_ARGS__)

/* We are in 'debug-mode' if --enable-assert was set during
 * configuration, since in that case NDEBUG will not be set. */
#else
#define TO_LOG(...) (void)0
#endif

/* Macro to create an exception that uses a previously allocated
 * exception as format parameter. Makes sure that the old one is freed
 * and that msg points to the new exception afterwards.  I had a look
 * at rethrow but this does not achieve the right thing.
 */
#define REUSE_EXCEPTION(msg, type, fnc, ...)				\
	do {								\
		str msg_tmp = createException(type, fnc, __VA_ARGS__);	\
		GDKfree(msg);						\
		msg = msg_tmp;						\
	} while (0)



#define BSTREAM_CHUNK_SIZE BUFSIZ


stream *
bsopen(str filepath);

#endif
