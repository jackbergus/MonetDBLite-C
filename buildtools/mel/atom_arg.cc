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
#include "atom_arg.h"
#include "language.h"
#include <string.h>


AtomArg::AtomArg(int t, const char *n, const Atom *arg, char* v) : Arg(t,n,v)
{
	_arg = arg;
}

const Atom *
AtomArg::arg() const
{
	return _arg;
}

const char *
AtomArg::toString() const
{
	// return this->Name();
	return _arg->toString();
}
 
ostream &
AtomArg::print(language *l, ostream &o) const
{
	return l->gen_atom_arg(o, *this);
}
