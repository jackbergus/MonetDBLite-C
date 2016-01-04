/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

#ifndef _MAL_BUILDER_
#define _MAL_BUILDER_

#include "mal.h"
#include "mal_instruction.h"

mal_export InstrPtr newStmt(MalBlkPtr mb, char *module, char *name);
mal_export InstrPtr newStmt1(MalBlkPtr mb, str module, char *name);
mal_export InstrPtr newStmt2(MalBlkPtr mb, str module, char *name);
mal_export InstrPtr newAssignment(MalBlkPtr mb);
mal_export InstrPtr newComment(MalBlkPtr mb, const char *val);
mal_export InstrPtr newCatchStmt(MalBlkPtr mb, str nme);
mal_export InstrPtr newRaiseStmt(MalBlkPtr mb, str nme);
mal_export InstrPtr newExitStmt(MalBlkPtr mb, str nme);
mal_export InstrPtr newReturnStmt(MalBlkPtr mb);
mal_export InstrPtr newFcnCall(MalBlkPtr mb, char *mod, char *fcn);
mal_export InstrPtr pushSht(MalBlkPtr mb, InstrPtr q, sht val);
mal_export InstrPtr pushInt(MalBlkPtr mb, InstrPtr q, int val);
mal_export InstrPtr pushLng(MalBlkPtr mb, InstrPtr q, lng val);
#ifdef HAVE_HGE
mal_export InstrPtr pushHge(MalBlkPtr mb, InstrPtr q, hge val);
#endif
mal_export InstrPtr pushWrd(MalBlkPtr mb, InstrPtr q, wrd val);
mal_export InstrPtr pushBte(MalBlkPtr mb, InstrPtr q, bte val);
mal_export InstrPtr pushOid(MalBlkPtr mb, InstrPtr q, oid val);
mal_export InstrPtr pushVoid(MalBlkPtr mb, InstrPtr q);
mal_export InstrPtr pushDbl(MalBlkPtr mb, InstrPtr q, dbl val);
mal_export InstrPtr pushFlt(MalBlkPtr mb, InstrPtr q, flt val);
mal_export InstrPtr pushStr(MalBlkPtr mb, InstrPtr q, const char *val);
mal_export InstrPtr pushBit(MalBlkPtr mb, InstrPtr q, bit val);
mal_export InstrPtr pushNil(MalBlkPtr mb, InstrPtr q, int tpe);
mal_export InstrPtr pushType(MalBlkPtr mb, InstrPtr q, int tpe);
mal_export InstrPtr pushNilType(MalBlkPtr mb, InstrPtr q, char *tpe);
mal_export InstrPtr pushZero(MalBlkPtr mb, InstrPtr q, int tpe);
mal_export InstrPtr pushEmptyBAT(MalBlkPtr mb, InstrPtr q, int tpe);
mal_export InstrPtr pushValue(MalBlkPtr mb, InstrPtr q, ValPtr cst);

#endif /* _MAL_BUILDER_ */

