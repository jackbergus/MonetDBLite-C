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
 * Copyright August 2008-2012 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * M.L.Kersten
 * BAT Algebra Extensions
 * The kernel libraries are unaware of the MAL runtime semantics.
 * This calls for declaring some operations in the MAL module section
 * and register them in the kernel modules explicitly.
 *
 * A good example of this borderline case are BAT creation operations,
 * which require a mapping of the type identifier to the underlying
 * implementation type.
 *
 * Another example concerns the (un)pack operations, which direct
 * access the runtime stack to (push)pull the values needed.
 */
#include "batExtensions.h"

/*
 * @+ BAT enhancements
 * The code to enhance the kernel.
 */
str
CMDBATclone(Client cntxt, MalBlkPtr m, MalStkPtr s, InstrPtr p)
{
	BAT *b, *bn;
	int bid = 0, ht, tt;
	int *res;
	BUN cap;

	(void) m;
	(void) cntxt;

	bid = *(int *) getArgReference(s, p, 3);
	if ((b = BATdescriptor(bid)) == NULL) {
		throw(MAL, "bat.new", INTERNAL_BAT_ACCESS);
	}
	res = (int *) getArgReference(s, p, 0);
	ht = getArgType(m, p, 1);
	tt = getArgType(m, p, 2);
	cap = BATcount(b) + 64;
	/*
	 * @-
	 * Cloning should include copying of the properties.
	 */
	BBPunfix(b->batCacheid);
	bn= BATnew(ht,tt,cap);
	if( bn == NULL){
		BBPunfix(b->batCacheid);
		throw(MAL,"bat.new", INTERNAL_OBJ_CREATE);
	}
	if( b->hseqbase)
		BATseqbase(bn, b->hseqbase);
	bn->hkey= b->hkey;
	bn->tkey= b->tkey;
	bn->hsorted= b->hsorted;
	bn->hrevsorted= b->hrevsorted;
	bn->tsorted= b->tsorted;
	bn->trevsorted= b->trevsorted;
	BBPkeepref(*res = bn->batCacheid);
	return MAL_SUCCEED;
}

str
CMDBATnew(Client cntxt, MalBlkPtr m, MalStkPtr s, InstrPtr p)
{
	int ht, tt;
	BUN cap = 0;
	int *res;

	(void) cntxt;
	res = (int *) getArgReference(s, p, 0);
	ht = getArgType(m, p, 1);
	tt = getArgType(m, p, 2);
	if (p->argc > 3) {
		lng lcap = *(lng*) getArgReference(s, p, 3);
		if (lcap < 0)
			throw(MAL, "bat.new", POSITIVE_EXPECTED);
		if (lcap > (lng) BUN_MAX)
			throw(MAL, "bat.new", ILLEGAL_ARGUMENT " Capacity too large");
		cap = (BUN) lcap;
	}

	if (ht == TYPE_any || tt == TYPE_any)
		throw(MAL, "bat.new", SEMANTIC_TYPE_ERROR);
	if (isaBatType(ht))
		ht = TYPE_bat;
	if (isaBatType(tt))
		tt = TYPE_bat;
	return (str) BKCnewBAT(res, &ht, &tt, &cap);
}

str
CMDBATnewDerived(Client cntxt, MalBlkPtr mb, MalStkPtr s, InstrPtr p)
{
	int bid, ht, tt;
	BUN cap = 0;
	int *res;
	BAT *b;
	str msg;
	oid o;

	(void) mb;
	(void) cntxt;
	res = (int *) getArgReference(s, p, 0);
	bid = *(int *) getArgReference(s, p, 1);
	if ((b = BATdescriptor(bid)) == NULL) {
		throw(MAL, "bat.new", INTERNAL_BAT_ACCESS);
	}

	if (bid > 0) {
		ht = b->htype;
		tt = b->ttype;
	} else {
		tt = b->htype;
		ht = b->ttype;
	}

	if (p->argc > 2) {
		lng lcap = *(lng *) getArgReference(s, p, 2);
		if (lcap < 0)
			throw(MAL, "bat.new", POSITIVE_EXPECTED);
		if (lcap > (lng) BUN_MAX)
			throw(MAL, "bat.new", ILLEGAL_ARGUMENT " Capacity too large");
		cap = (BUN) lcap;
	}
	else
		cap = BATcount(b);
	o = b->hseqbase;
	BBPunfix(b->batCacheid);

	res = (int *) getArgReference(s, p, 0);
	msg = (str) BKCnewBAT(res, &ht, &tt, &cap);
	if (msg == MAL_SUCCEED && ht == TYPE_void) {
		b = BATdescriptor(*res);
		if ( b == NULL )
			throw(MAL, "bat.new", RUNTIME_OBJECT_MISSING);
		BATseqbase(b, o);
		BBPunfix(b->batCacheid);
	}

	return msg;
}

str
CMDBATderivedByName(int *ret, str *nme)
{
	BAT *bn;
	int bid;

	bid = BBPindex(*nme);
	if (bid <= 0 || (bn = BATdescriptor(bid)) == 0)
		throw(MAL, "bat.new", INTERNAL_BAT_ACCESS);
	BBPincref(*ret = bn->batCacheid, TRUE);
	BBPunfix(bid);
	return MAL_SUCCEED;
}

str
CMDBATnewint(Client cntxt, MalBlkPtr m, MalStkPtr s, InstrPtr p)
{
	int ht, tt, icap;
	BUN cap = 0;
	int *res;

	(void) cntxt;
	res = (int *) getArgReference(s, p, 0);
	ht = getArgType(m, p, 1);
	tt = getArgType(m, p, 2);
	icap = *(int *) getArgReference(s, p, 3);
	if (icap < 0)
		throw(MAL, "bat.new", POSITIVE_EXPECTED);
	cap = (BUN) icap;
	res = (int *) getArgReference(s, p, 0);

	return (str) BKCnewBAT(res, &ht, &tt, &cap);
}

str
CMDBBPproject(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int *result, *bid, tt;
	ptr *p;
	BAT *b, *bn;

	(void) cntxt;
	result = (int *) getArgReference(stk, pci, 0);
	bid = (int *) getArgReference(stk, pci, 1);
	p = (ptr *) getArgReference(stk, pci, 2);
	tt = getArgType(mb, pci, 2);
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.project", INTERNAL_BAT_ACCESS);
	}

	if (tt >= TYPE_str) {
		if (p == 0 || *(str *) p == 0)
			p = (ptr *) str_nil;
		else
			p = *(ptr **) p;
	}
	bn = BATconst(b, tt, p);
	BBPunfix(b->batCacheid);
	if (bn) {
		*result = bn->batCacheid;
		BBPkeepref(bn->batCacheid);
		return MAL_SUCCEED;
	}
	throw(MAL, "bat.project", INTERNAL_OBJ_CREATE);
}

str
CMDBBPprojectNil(int *ret, int *bid)
{
	BAT *b, *bn;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.project", INTERNAL_BAT_ACCESS);
	}

	bn = BATconst(b, TYPE_void, (ptr) &int_nil);
	BBPunfix(b->batCacheid);
	if (bn) {
		*ret = bn->batCacheid;
		BBPkeepref(bn->batCacheid);
		return MAL_SUCCEED;
	}
	throw(MAL, "bat.project", INTERNAL_OBJ_CREATE);
}

/*
 * @-
 * If the optimizer has not determined the partition bounds we derive one here.
 */
str
CMDbatpartition(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	BAT *b,*bn;
	int *ret,i,bid;
	VarPtr low, hgh;
	oid lval,hval=0, step;

	(void) mb;
	(void) cntxt;
	bid = *(int *) getArgReference(stk, pci, pci->retc);

	if ((b = BATdescriptor(bid)) == NULL) {
		throw(MAL, "bat.partition", INTERNAL_BAT_ACCESS);
	}
	step = BATcount(b) / pci->retc + 1;

	/* create the slices slightly overshoot to make sure it all is taken*/
	for(i=0; i<pci->retc; i++){
		low= varGetProp(mb, getArg(pci,i),PropertyIndex("hlb") );
		if (low== NULL )
			lval = i*step;
		else
			lval = low->value.val.oval;
		hgh= varGetProp(mb, getArg(pci,i),PropertyIndex("hub") );
		if (hgh== NULL )
			hval = lval + step;
		else
			hval = hgh->value.val.oval;
		if (i == pci->retc-1)
			hval = BATcount(b);
		bn =  BATslice(b, lval,hval);
		if (bn== NULL){
			BBPunfix(b->batCacheid);
			throw(MAL, "bat.partition", MAL_MALLOC_FAIL);
		}
		BATseqbase(bn, lval);
		stk->stk[getArg(pci,i)].val.bval = bn->batCacheid;
		ret= (int *) getArgReference(stk,pci,i);
		BBPkeepref(*ret = bn->batCacheid);
		low= hgh;
	}
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}
str
CMDbatpartition2(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	BAT *b,*bn;
	int *ret,bid;
	int pieces= *(int*) getArgReference(stk, pci, 2);
	int idx = *(int*) getArgReference(stk, pci, 3);
	oid lval,hval=0, step;

	(void) mb;
	(void) cntxt;
	if ( pieces <=0 )
		throw(MAL, "bat.partition", POSITIVE_EXPECTED);
	if ( idx >= pieces || idx <0 )
		throw(MAL, "bat.partition", ILLEGAL_ARGUMENT " Illegal piece index");

	bid = *(int *) getArgReference(stk, pci, pci->retc);

	if ((b = BATdescriptor(bid)) == NULL) {
		throw(MAL, "bat.partition", INTERNAL_BAT_ACCESS);
	}
	step = BATcount(b) / pieces + 1;

	lval = idx * step;
	if ( idx == pieces-1)
		hval = BATcount(b);
	else
		hval = lval+step;
	bn =  BATslice(b, lval,hval);
	BATseqbase(bn, lval);
	if (bn== NULL){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.partition",  INTERNAL_OBJ_CREATE);
	}
	stk->stk[getArg(pci,0)].val.bval = bn->batCacheid;
	ret= (int *) getArgReference(stk,pci,0);
	BBPkeepref(*ret = bn->batCacheid);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
CMDsetBase(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int i;
	oid o= 0;
	BAT *b;
	(void) mb;
	(void) cntxt;

	for( i= pci->retc; i < pci->argc; i++){
		b= BATdescriptor(*(int*) getArgReference(stk,pci,i));
		if( b == NULL)
			throw(MAL,"bat.setBase",INTERNAL_BAT_ACCESS);
		BATseqbase(b,o);
		o= o + (oid) BATcount(b);
		BBPunfix(b->batCacheid);
	}
	return MAL_SUCCEED;
}

/*
 * The fetch operations are all pretty straight forward, provided
 * you know the underlying type. Often it is cheaper to use
 * the extended BAT iterator, because then it can re-use the
 * BAT descriptor.
 */
str
CMDgetHead(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	BAT *b;
	oid *cursor;
	int *bid;
	BUN limit;
	ValPtr head;
	oid o;

	(void) cntxt;
	cursor = (oid *) getArgReference(stk, pci, 2);
	bid = (int *) getArgReference(stk, pci, 1);
	head = getArgReference(stk,pci,0);

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "chop.getHead", INTERNAL_BAT_ACCESS);
	}
	limit = BUNlast(b);
	if (*cursor == oid_nil || *cursor >= (oid) limit) {
		BBPunfix(b->batCacheid);
		throw(MAL, "mal.getHead", RANGE_ERROR);
	}

	/* get head = ... */
	if( getArgType(mb,pci,3) == TYPE_void){
		o = (oid)*cursor +  b->hseqbase;
		VALinit(head, TYPE_oid, &o);
	} else {
 		BATiter bi = bat_iterator(b);
		VALinit(head, getArgType(mb, pci, 3), BUNhead(bi, (BUN)*cursor));
	}
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
CMDgetTail(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
 	BATiter bi;
	BAT *b;
	oid *cursor;
	int *bid;
	BUN limit;
	ValPtr tail;

	(void) cntxt;
	cursor = (oid *) getArgReference(stk, pci, 2);
	bid = (int *) getArgReference(stk, pci, 1);
	tail = getArgReference(stk,pci,0);

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "chop.getTail", INTERNAL_BAT_ACCESS);
	}
	limit = BUNlast(b);
	if (*cursor == oid_nil || *cursor >= (oid) limit) {
		BBPunfix(b->batCacheid);
		throw(OUTOFBNDS, "mal.getTail", RANGE_ERROR);
	}

	/* get tail = ... */
	bi = bat_iterator(b);
	VALinit(tail, getArgType(mb, pci, 3), BUNtail(bi, (BUN)*cursor));
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
ALGprojectCstBody(bat *result, int *bid, ptr *p, int tt){
	BAT *b, *bn;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bbp.project", INTERNAL_BAT_ACCESS);
	}

	if (ATOMvarsized(tt)) {
		if (p == 0 || *(str *) p == 0)
			p = (ptr *) str_nil;
		else
			p = *(ptr **) p;
	}
	bn = BATconst(b, tt, p);
	BBPunfix(b->batCacheid);
	if (bn) {
		*result = bn->batCacheid;
		BBPkeepref(bn->batCacheid);
		return MAL_SUCCEED;
	}
	throw(MAL, "bbp.project", INTERNAL_OBJ_CREATE);
}

str
ALGprojectCst(Client cntxt,MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int *result = (int *) getArgReference(stk, pci, 0);
	int *bid = (int *) getArgReference(stk, pci, 1);
	ptr *p = (ptr *) getArgReference(stk, pci, 2);
	int tt = getArgType(mb, pci, 2);

	(void) cntxt;
	return ALGprojectCstBody(result, bid, p, tt);
}
