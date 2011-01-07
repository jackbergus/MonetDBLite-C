// The contents of this file are subject to the MonetDB Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is the MonetDB Database System.
//
// The Initial Developer of the Original Code is CWI.
// Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
// Copyright August 2008-2011 MonetDB B.V.
// All Rights Reserved.

#include <monetdb_config.h>
#include "atomops.h"
#include "language.h"
#include <string.h>


Atomops::Atomops(int t, char *n, int op) : Ops(t,n,op)
{
}

const char *
Atomops::string(int op)
{
	switch (op) {
	case OP_TOSTR:
		return "tostr";
	case OP_FROMSTR:
		return "fromstr";
	case OP_READ:
		return "read";
	case OP_WRITE:
		return "write";
	case OP_COMP:
		return "cmp";
	case OP_NEQUAL:
		return "cmp";
	case OP_HASH:
		return "hash";
	case OP_NULL:
		return "null";
	case OP_LEN:
		return "length";
	case OP_CONVERT:
		return "convert";
	case OP_PUT:
		return "put";
	case OP_FIX:
		return "fix";
	case OP_UNFIX:
		return "unfix";
	case OP_DEL:
		return "del";
	case OP_CHECK:
		return "check";
	case OP_HEAP:
		return "heap";
	case OP_HCONVERT:
		return "heap_convert";
	}
	return "";
}

ostream &
Atomops::print(language *l, ostream &o) const
{
	return l->gen_atomops(o, *this);
}
