/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
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
 * Copyright August 2008-2009 MonetDB B.V.
 * All Rights Reserved.
 */

/**
 * glob
 * Fabian Groffen
 * Limited globbing within merovingian's tags.
 * The rules are kept simple for the time being:
 * - * expands to an arbitrary string
 */

#include "glob.h"

/**
 * Returns if haystack matches expr, using tag globbing.
 */
char
glob(const char *expr, const char *haystack)
{
	/* probably need to implement this using libpcre once we get
	 * advanced users, doing even more advanced things */

	while (*expr != '\0') {
		switch (*expr) {
			case '*':
				/* skip over haystack till the next char from expr */
				expr++;
				if (*expr == '\0')
					/* this will always match the rest */
					return(1);
				while (*haystack != '\0' && *haystack != *expr)
					haystack++;
				if (*haystack == '\0')
					/* couldn't find it, so no match */
					return(0);
			break;
			default:
				if (*expr != *haystack)
					return(0);
			break;
		}
		expr++;
		haystack++;
	}
	return(*haystack == '\0');
}
