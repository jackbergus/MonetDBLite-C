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
#include "operator.h"
#include "language.h"
#include <string.h>

List *
oplist(Symbol *op1, Symbol *op2)
{
	List *l = new List(3);
	if (op1)
		l->insert(op1);
	if (op2)
		l->insert(op2);
	return l;
}

Operator::Operator(int t, char *n, char *fcn,
		Symbol *result, Symbol *op1, Symbol *op2, char *hlp) 
	: Command(t, n, fcn, NORMAL, result, oplist(op1, op2), hlp)
{
	if (op1 == NULL) {
		_op1 = op2;
		_op2 = NULL;
	} else {
		_op1 = op1;
		_op2 = op2;
	}
	set_op_names();
	level = t;
}

void
Operator::set_op_names()
{
	if (!_op1->Name() && _op2)
		_op1->Name("op1");
	else if (!_op1->Name())
		_op1->Name("op");
	if (_op2 && !_op2->Name())
		_op2->Name("op2");
}

Symbol *
Operator::op1() const
{
	return _op1;
}

Symbol *
Operator::op2() const
{
	return _op2;
}

const char *
Operator::Token() const
{
	if (level == MEL_OPERATOR0)
		return "TOK_OPERATOR0";
	if (level == MEL_OPERATOR1)
		return "TOK_OPERATOR1";
        return "TOK_OPERATOR";
}

ostream &
Operator::print(language *l, ostream &o) const
{
	return l->gen_operator(o, *this);
}
