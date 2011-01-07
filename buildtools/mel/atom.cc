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
#include "atom.h"
#include "language.h"

Atom::Atom(int t, char *n, int size, int align, Atom *parent, Ops **cmds) 
	: Symbol(t,n)
{
	_size = size;
	_align = align;
	_parent = parent;
	_type = NULL;
	_cmds = cmds;
}

Atom::Atom(int t, char *n, int size, int align, Arg *type, Ops **cmds) 
	: Symbol(t,n)
{
	_size = size;
	_align = align;
	_parent = NULL;
	_type = type;
	_cmds = cmds;
}

int
Atom::isFixed() const
{
	if (_parent)
		return _parent->isFixed();
	if (_type)
		return _type->isFixed();
	return _size>=0;
}

int
Atom::size() const
{
	if (_parent)
		return _parent->size();
	return _size;
}

int
Atom::align() const
{
	if (_parent)
		return _parent->align();
	return _align;
}

Atom *
Atom::parent() const
{
	return _parent;
}

Atom *
Atom::top_parent() const
{
	Atom *a = parent();
	while(a && a->parent())
		a = a->parent();
	return a;
}

Arg *
Atom::type() const
{
	return _type;
}

Arg *
Atom::top_type() const
{
   	Atom *a = top_parent();
	if (a)
	   	return a->type();
	return _type;
}

Ops **
Atom::cmds() const
{
	return _cmds;
}

ostream &
Atom::print(language *l, ostream &o) const
{
	return l->gen_atom(o, *this);
}
