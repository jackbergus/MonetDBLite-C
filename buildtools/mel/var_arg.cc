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
#include "var_arg.h"
#include "iterator.h"
#include "language.h"
#include <string.h>


VarArg::VarArg(int t, char *n, const Symbol *arg) : Arg(t,n)
{
	_arg = arg;
}

const Symbol *
VarArg::arg() const
{
	return _arg;
}

ostream &
VarArg::print(language *l, ostream &o) const
{
	return l->gen_var_arg(o, *this);
}

const char *
VarArg::toString() const
{
	char *buf = new char[80];
	const char *arg = _arg?_arg->toString():"any";

	if (strcmp(arg, "BAT") == 0) {
		BatArg *ba = (BatArg*) _arg;
        	sprintf(buf, "*BAT[%s,%s]",
                	ba->atom1()?ba->atom1()->toString():"void",
                	ba->atom2()?ba->atom2()->toString():"void");
	} else {
		sprintf(buf, "*%s", arg);
	}
	return buf;
}
