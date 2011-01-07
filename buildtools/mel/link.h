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
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef _LINK_H_
#define _LINK_H_

#include "language.h"
#include "list.h"
#include <string.h>

#ifdef NATIVE_WIN32
/* The POSIX name for this item is deprecated. Instead, use the ISO
   C++ conformant name: _strdup. See online help for details. */
#define strdup _strdup
#endif

class Link:public language {
      private:
	List *monet_mod_path;
      public:
	Link() {
		libsfx = strdup("");
	}
	const char *get_name() const {
		return "Link";
	}
	virtual int handle_args(int, char **);
	int generate_code(ostream &o, Symbol *root);

	ostream &gen_module(ostream &o, const Module &m);
	ostream &gen_dependency(ostream &o, const Dependency &m);

      public:
	char *libsfx;
};

#endif //_LINK_H_
