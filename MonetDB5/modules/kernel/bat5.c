/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

/*
 * Peter Boncz, M.L. Kersten
 * Binary Association Tables
 * This module contains the commands and patterns to manage Binary
 * Association Tables (BATs). The relational operations you can execute
 * on BATs have the form of a neat algebra, described in algebra.mx
 *
 * But a database system needs more that just this algebra, since often it
 * is crucial to do table-updates (this would not be permitted in a strict
 * algebra).
 *
 * All commands needed for BAT updates, property management, basic I/O,
 * persistence, and storage options can be found in this module.
 *
 * All parameters to the modules are passed by reference.
 * In particular, this means that string values are passed to the module
 * layer as (str *)
 * and we have to de-reference them before entering the gdk library.
 * (Actual a design error in gdk to differentiate passing int/str)
 * This calls for knowledge on the underlying BAT types`s
 */

#include "monetdb_config.h"
#include "bat5.h"
#include "mal_exception.h"

/* set access mode to bat, replacing input with output */
static BAT *
setaccess(BAT *b, int mode)
{
	BAT *bn = b;

	if (BATsetaccess(b, mode) != GDK_SUCCEED) {
		if (b->batSharecnt && mode != BAT_READ) {
			bn = BATcopy(b, b->htype, b->ttype, TRUE, TRANSIENT);
			if (bn != NULL)
				BATsetaccess(bn, mode);
		} else {
			bn = NULL;
		}
		BBPunfix(b->batCacheid);
	}
	return bn;
}

static char *
pre(str s1, str s2)
{
	static char buf[64];

	snprintf(buf, 64, "%s%s", s1, s2);
	return buf;
}
static char *
local_itoa(ssize_t i)
{
	static char buf[32];

	snprintf(buf, 32, SSZFMT, i);
	return buf;
}
static char *
local_utoa(size_t i)
{
	static char buf[32];

	snprintf(buf, 32, SZFMT, i);
	return buf;
}

#define COLLISION (8 * sizeof(size_t))

static void
HASHinfo(BAT *bk, BAT *bv, Hash *h, str s)
{
	BUN i;
	BUN j;
	BUN k;
	BUN cnt[COLLISION + 1];

	BUNappend(bk, pre(s, "type"), FALSE);
	BUNappend(bv, ATOMname(h->type),FALSE);
	BUNappend(bk, pre(s, "mask"), FALSE);
	BUNappend(bv, local_utoa(h->lim),FALSE);

	for (i = 0; i < COLLISION + 1; i++) {
		cnt[i] = 0;
	}
	for (i = 0; i <= h->mask; i++) {
		j = HASHlist(h, i);
		for (k = 0; j; k++)
			j >>= 1;
		cnt[k]++;
	}

	for (i = 0; i < COLLISION + 1; i++)
		if (cnt[i]) {
			BUNappend(bk, pre(s, local_utoa(i?(((size_t)1)<<(i-1)):0)), FALSE);
			BUNappend(bv, local_utoa((size_t) cnt[i]), FALSE);
		}
}

static void
infoHeap(BAT *bk, BAT*bv, Heap *hp, str nme)
{
	char buf[1024], *p = buf;

	if (!hp)
		return;
	while (*nme)
		*p++ = *nme++;
	strcpy(p, "free");
	BUNappend(bk, buf, FALSE);
	BUNappend(bv, local_utoa(hp->free),FALSE);
	strcpy(p, "size");
	BUNappend(bk, buf, FALSE);
	BUNappend(bv, local_utoa(hp->size),FALSE);
	strcpy(p, "storage");
	BUNappend(bk, buf, FALSE);
	BUNappend(bv, (hp->base == NULL || hp->base == (char*)1) ? "absent" : (hp->storage == STORE_MMAP) ? (hp->filename ? "memory mapped" : "anonymous vm") : (hp->storage == STORE_PRIV) ? "private map" : "malloced",FALSE);
	strcpy(p, "newstorage");
	BUNappend(bk, buf, FALSE);
	BUNappend(bv, (hp->newstorage == STORE_MEM) ? "malloced" : (hp->newstorage == STORE_PRIV) ? "private map" : "memory mapped",FALSE);
	strcpy(p, "filename");
	BUNappend(bk, buf, FALSE);
	BUNappend(bv, hp->filename ? hp->filename : "no file",FALSE);
}

static char *
oidtostr(oid i)
{
	int len = 48;
	static char bf[48];
	char *p = bf;

	(void) OIDtoStr(&p, &len, &i);
	return bf;
}

static gdk_return
CMDinfo(BAT **ret1, BAT **ret2, BAT *b)
{
	BAT *bk, *bv;
	const char *mode, *accessmode;

	if (!(bk = BATnew(TYPE_void, TYPE_str, 128, TRANSIENT)))
		return GDK_FAIL;
	if (!(bv = BATnew(TYPE_void, TYPE_str, 128, TRANSIENT))) {
		BBPreclaim(bk);
		return GDK_FAIL;
	}
	BATseqbase(bk,0);
	BATseqbase(bv,0);
	*ret1 = bk;
	*ret2 = bv;

	if (b->batPersistence == PERSISTENT) {
		mode = "persistent";
	} else if (b->batPersistence == TRANSIENT) {
		mode = "transient";
	} else {
		mode ="unknown";
	}

	switch (b->batRestricted) {
	case BAT_READ:
		accessmode = "read-only";
		break;
	case BAT_WRITE:
		accessmode = "updatable";
		break;
	case BAT_APPEND:
		accessmode = "append-only";
		break;
	default:
		accessmode = "unknown";
	}

	BUNappend(bk, "batId", FALSE);
	BUNappend(bv, BATgetId(b),FALSE);
	BUNappend(bk, "batCacheid", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->batCacheid)),FALSE);
	BUNappend(bk, "hparentid", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->H->heap.parentid)),FALSE);
	BUNappend(bk, "tparentid", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->T->heap.parentid)),FALSE);
	BUNappend(bk, "batSharecnt", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->batSharecnt)),FALSE);
	BUNappend(bk, "batCount", FALSE);
	BUNappend(bv, local_utoa((size_t)b->batCount),FALSE);
	BUNappend(bk, "batCapacity", FALSE);
	BUNappend(bv, local_utoa((size_t)b->batCapacity),FALSE);
	BUNappend(bk, "head", FALSE);
	BUNappend(bv, ATOMname(b->htype),FALSE);
	BUNappend(bk, "tail", FALSE);
	BUNappend(bv, ATOMname(b->ttype),FALSE);
	BUNappend(bk, "batPersistence", FALSE);
	BUNappend(bv, mode,FALSE);
	BUNappend(bk, "batRestricted", FALSE);
	BUNappend(bv, accessmode,FALSE);
	BUNappend(bk, "batRefcnt", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BBP_refs(b->batCacheid))),FALSE);
	BUNappend(bk, "batLRefcnt", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BBP_lrefs(b->batCacheid))),FALSE);
	BUNappend(bk, "batDirty", FALSE);
	BUNappend(bv, BATdirty(b) ? "dirty" : "clean",FALSE);

	BUNappend(bk, "hsorted", FALSE);
	BUNappend(bv, local_itoa((ssize_t)BAThordered(b)),FALSE);
	BUNappend(bk, "hrevsorted", FALSE);
	BUNappend(bv, local_itoa((ssize_t)BAThrevordered(b)),FALSE);
	BUNappend(bk, "hident", FALSE);
	BUNappend(bv, b->hident,FALSE);
	BUNappend(bk, "hdense", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BAThdense(b))),FALSE);
	BUNappend(bk, "hseqbase", FALSE);
	BUNappend(bv, oidtostr(b->hseqbase),FALSE);
	BUNappend(bk, "hkey", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->hkey)),FALSE);
	BUNappend(bk, "hvarsized", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->hvarsized)),FALSE);
	BUNappend(bk, "halign", FALSE);
	BUNappend(bv, local_utoa(b->halign),FALSE);
	BUNappend(bk, "hnosorted", FALSE);
	BUNappend(bv, local_utoa(b->H->nosorted),FALSE);
	BUNappend(bk, "hnorevsorted", FALSE);
	BUNappend(bv, local_utoa(b->H->norevsorted),FALSE);
	BUNappend(bk, "hnodense", FALSE);
	BUNappend(bv, local_utoa(b->H->nodense),FALSE);
	BUNappend(bk, "hnokey[0]", FALSE);
	BUNappend(bv, local_utoa(b->H->nokey[0]),FALSE);
	BUNappend(bk, "hnokey[1]", FALSE);
	BUNappend(bv, local_utoa(b->H->nokey[1]),FALSE);
	BUNappend(bk, "hnonil", FALSE);
	BUNappend(bv, local_utoa(b->H->nonil),FALSE);
	BUNappend(bk, "hnil", FALSE);
	BUNappend(bv, local_utoa(b->H->nil),FALSE);

	BUNappend(bk, "tident", FALSE);
	BUNappend(bv, b->tident,FALSE);
	BUNappend(bk, "tdense", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BATtdense(b))), FALSE);
	BUNappend(bk, "tseqbase", FALSE);
	BUNappend(bv, oidtostr(b->tseqbase), FALSE);
	BUNappend(bk, "tsorted", FALSE);
	BUNappend(bv, local_itoa((ssize_t)BATtordered(b)), FALSE);
	BUNappend(bk, "trevsorted", FALSE);
	BUNappend(bv, local_itoa((ssize_t)BATtrevordered(b)), FALSE);
	BUNappend(bk, "tkey", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->tkey)), FALSE);
	BUNappend(bk, "tvarsized", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->tvarsized)), FALSE);
	BUNappend(bk, "talign", FALSE);
	BUNappend(bv, local_utoa(b->talign), FALSE);
	BUNappend(bk, "tnosorted", FALSE);
	BUNappend(bv, local_utoa(b->T->nosorted), FALSE);
	BUNappend(bk, "tnorevsorted", FALSE);
	BUNappend(bv, local_utoa(b->T->norevsorted), FALSE);
	BUNappend(bk, "tnodense", FALSE);
	BUNappend(bv, local_utoa(b->T->nodense), FALSE);
	BUNappend(bk, "tnokey[0]", FALSE);
	BUNappend(bv, local_utoa(b->T->nokey[0]), FALSE);
	BUNappend(bk, "tnokey[1]", FALSE);
	BUNappend(bv, local_utoa(b->T->nokey[1]), FALSE);
	BUNappend(bk, "tnonil", FALSE);
	BUNappend(bv, local_utoa(b->T->nonil), FALSE);
	BUNappend(bk, "tnil", FALSE);
	BUNappend(bv, local_utoa(b->T->nil), FALSE);

	BUNappend(bk, "batInserted", FALSE);
	BUNappend(bv, local_utoa(b->batInserted), FALSE);
	BUNappend(bk, "batDeleted", FALSE);
	BUNappend(bv, local_utoa(b->batDeleted), FALSE);
	BUNappend(bk, "batFirst", FALSE);
	BUNappend(bv, local_utoa(b->batFirst), FALSE);
	BUNappend(bk, "htop", FALSE);
	BUNappend(bv, local_utoa(b->H->heap.free), FALSE);
	BUNappend(bk, "ttop", FALSE);
	BUNappend(bv, local_utoa(b->T->heap.free), FALSE);
	BUNappend(bk, "batStamp", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->batStamp)), FALSE);
	BUNappend(bk, "lastUsed", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BBP_lastused(b->batCacheid))), FALSE);
	BUNappend(bk, "curStamp", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(BBPcurstamp())), FALSE);
	BUNappend(bk, "batCopiedtodisk", FALSE);
	BUNappend(bv, local_itoa((ssize_t)(b->batCopiedtodisk)), FALSE);
	BUNappend(bk, "batDirtydesc", FALSE);
	BUNappend(bv, b->batDirtydesc ? "dirty" : "clean", FALSE);

	BUNappend(bk, "H->heap.dirty", FALSE);
	BUNappend(bv, b->H->heap.dirty ? "dirty" : "clean", FALSE);
	BUNappend(bk, "T->heap.dirty", FALSE);
	BUNappend(bv, b->T->heap.dirty ? "dirty" : "clean", FALSE);
	infoHeap(bk, bv, &b->H->heap, "head.");
	infoHeap(bk, bv, &b->T->heap, "tail.");

	BUNappend(bk, "H->vheap->dirty", FALSE);
	BUNappend(bv, (b->H->vheap && b->H->vheap->dirty) ? "dirty" : "clean", FALSE);
	infoHeap(bk, bv, b->H->vheap, "hheap.");

	BUNappend(bk, "T->vheap->dirty", FALSE);
	BUNappend(bv, (b->T->vheap && b->T->vheap->dirty) ? "dirty" : "clean", FALSE);
	infoHeap(bk, bv, b->T->vheap, "theap.");

	/* dump index information */
	if (b->H->hash && b->H->hash != (Hash *) 1) {
		HASHinfo(bk, bv, b->H->hash, "hhash->");
	}
	if (b->T->hash && b->T->hash != (Hash *) 1) {
		HASHinfo(bk, bv, b->T->hash, "thash->");
	}
	assert(BATcount(bk) == BATcount(bv));
	return GDK_SUCCEED;
}

/*
 * BBP Management, IO
 */
static gdk_return
CMDrename(bit *retval, BAT *b, const char *s)
{
	int ret;
	int c;
	const char *t = s;

	for ( ; (c = *t) != 0; t++) {
		if (c != '_' && !GDKisalnum(c)) {
			GDKerror("CMDrename: identifier expected: %s\n", s);
			return GDK_FAIL;
		}
	}

	ret = BATname(b, s);
	*retval = FALSE;
	if (ret == 1) {
		GDKerror("CMDrename: identifier expected: %s\n", s);
		return GDK_FAIL;
	} else if (ret == BBPRENAME_ILLEGAL) {
		GDKerror("CMDrename: illegal temporary name: '%s'\n", s);
		return GDK_FAIL;
	} else if (ret == BBPRENAME_LONG) {
		GDKerror("CMDrename: name too long: '%s'\n", s);
		return GDK_FAIL;
	} else if (ret != BBPRENAME_ALREADY) {
		*retval = TRUE;
	}
	return GDK_SUCCEED;
}

static int
CMDsave(bit *res, const char *input)
{
	bat bid = BBPindex(input);
	BAT *b;

	*res = FALSE;
	if (bid) {
		BBPfix(bid);
		b = BBP_cache(bid);
		if (b && BATdirty(b)) {
			if (BBPsave(b) == GDK_SUCCEED)
				*res = TRUE;
		}
		BBPunfix(bid);
	}
	return GDK_SUCCEED;
}


/*
 * The remainder contains the wrapper code over the mserver version 4
 * InformationFunctions
 * In most cases we pass a BAT identifier, which should be unified
 * with a BAT descriptor. Upon failure we can simply abort the function.
 *
 * The logical head type :oid is mapped to a TYPE_void
 * with sequenceBase. It represents the old fashioned :vid
 */


str
BKCnewBAT(bat *res, const int *ht, const int *tt, const BUN *cap, int role)
{
	BAT *bn;

	bn = BATnew(*ht == TYPE_oid ? TYPE_void : *ht, *tt, *cap, role);
	if (bn == NULL)
		throw(MAL, "bat.new", GDK_EXCEPTION);
	if (*ht == TYPE_oid)
		BATseqbase(bn, 0);
	*res = bn->batCacheid;
	BBPkeepref(*res);
	return MAL_SUCCEED;
}

str
BKCattach(bat *ret, const int *tt, const char * const *heapfile)
{
	BAT *bn;

	bn = BATattach(*tt, *heapfile, TRANSIENT);
	if (bn == NULL)
		throw(MAL, "bat.attach", GDK_EXCEPTION);
	if( bn->batPersistence == PERSISTENT)
		BATmsync(bn);
	*ret = bn->batCacheid;
	BBPkeepref(*ret);
	return MAL_SUCCEED;
}

str
BKCdensebat(bat *ret, const wrd *size)
{
	BAT *bn;
	wrd sz = *size;

	if (sz < 0)
		sz = 0;
	if (sz > (wrd) BUN_MAX)
		sz = (wrd) BUN_MAX;
	bn = BATnew(TYPE_void, TYPE_void, (BUN) sz, TRANSIENT);
	if (bn == NULL)
		throw(MAL, "bat.densebat", GDK_EXCEPTION);
	BATsetcount(bn, (BUN) sz);
	BATseqbase(bn, 0);
	BATseqbase(BATmirror(bn), 0);
	*ret = bn->batCacheid;
	BBPkeepref(*ret);
	return MAL_SUCCEED;
}

str
BKCreverse(bat *ret, const bat *bid)
{
	BAT *b, *bn = NULL;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.reverse", RUNTIME_OBJECT_MISSING);
	}

	bn = BATmirror(b);			/* bn inherits ref from b */
	assert(bn != NULL);
	*ret = bn->batCacheid;
	BBPkeepref(bn->batCacheid);
	return MAL_SUCCEED;
}

str
BKCmirror(bat *ret, const bat *bid)
{
	BAT *b, *bn;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.mirror", RUNTIME_OBJECT_MISSING);
	}
	bn = VIEWcombine(b);
	if (bn != NULL) {
		if (b->batRestricted == BAT_WRITE) {
			BAT *bn1;
			bn1 = BATcopy(bn, bn->htype, bn->ttype, FALSE, TRANSIENT);
			BBPreclaim(bn);
			bn = bn1;
		}
		if (bn != NULL) {
			*ret = bn->batCacheid;
			BBPkeepref(*ret);
			BBPunfix(b->batCacheid);
			return MAL_SUCCEED;
		}
	}
	*ret = 0;
	BBPunfix(b->batCacheid);
	throw(MAL, "bat.mirror", GDK_EXCEPTION);
}

str
BKCrevert(bat *r, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.revert", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.revert", OPERATION_FAILED);
	if (BATrevert(b) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.revert", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCorder(bat *r, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.order", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.order", OPERATION_FAILED);
	if (BATorder(b) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.order", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCorder_rev(bat *r, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.order_rev", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.order_rev", OPERATION_FAILED);
	if (BATorder_rev(b) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.order_rev", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCinsert_bat(bat *r, const bat *bid, const bat *sid)
{
	BAT *b, *s;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.insert", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.insert", OPERATION_FAILED);
	if ((s = BATdescriptor(*sid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.insert", RUNTIME_OBJECT_MISSING);
	}
	if (BATins(b, s, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(s->batCacheid);
		throw(MAL, "bat.insert", GDK_EXCEPTION);
	}
	BBPunfix(s->batCacheid);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCinsert_bat_force(bat *r, const bat *bid, const bat *sid, const bit *force)
{
	BAT *b, *s;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.insert", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.insert", OPERATION_FAILED);
	if ((s = BATdescriptor(*sid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.insert", RUNTIME_OBJECT_MISSING);
	}
	if (BATins(b, s, *force) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(s->batCacheid);
		throw(MAL, "bat.insert", GDK_EXCEPTION);
	}
	BBPunfix(s->batCacheid);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

char *
BKCdelete_bun(bat *r, const bat *bid, const oid *h, const void *t)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.delete_bun", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.delete_bun", OPERATION_FAILED);
	if (b->ttype >= TYPE_str && ATOMstorage(b->ttype) >= TYPE_str) {
		if (t == 0 || *(str*)t == 0)
			t = (ptr) str_nil;
		else
			t = (ptr) *(str *)t;
	}
	if (BUNdel(b, h, t, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.delete_bun", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

char *
BKCdelete(bat *r, const bat *bid, const oid *h)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.delete", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.delete", OPERATION_FAILED);
	if (BUNdelHead(b, h, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.delete", GDK_EXCEPTION);
	}
	if( b->batPersistence == PERSISTENT)
		BATmsync(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCdelete_all(bat *r, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.delete", RUNTIME_OBJECT_MISSING);
	if (BATclear(b, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.delete_all", GDK_EXCEPTION);
	}
	if( b->batPersistence == PERSISTENT)
		BATmsync(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCdelete_bat_bun(bat *r, const bat *bid, const bat *sid)
{
	BAT *b, *s;
	gdk_return ret;

	if (*bid == *sid)
		return BKCdelete_all(r, bid);
	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.delete", RUNTIME_OBJECT_MISSING);
	if ((s = BATdescriptor(*sid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.delete", RUNTIME_OBJECT_MISSING);
	}
	ret = BATdel(b, s, FALSE);
	BBPunfix(s->batCacheid);
	if (ret != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		 throw(MAL, "bat.delete_bat_bun", GDK_EXCEPTION);
	}
	if( b->batPersistence == PERSISTENT)
		BATmsync(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

char *
BKCappend_wrap(bat *r, const bat *bid, const bat *uid)
{
	BAT *b, *u;
	gdk_return ret;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.append", OPERATION_FAILED);
	if ((u = BATdescriptor(*uid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	}
	ret = BATappend(b, u, FALSE);
	BBPunfix(u->batCacheid);
	if (ret != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", GDK_EXCEPTION);
	}
	if( b->batPersistence == PERSISTENT)
		BATmsync(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCappend_val_wrap(bat *r, const bat *bid, const void *u)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.append", OPERATION_FAILED);
	if (b->ttype >= TYPE_str && ATOMstorage(b->ttype) >= TYPE_str) {
		if (u == 0 || *(str*)u == 0)
			u = (ptr) str_nil;
		else
			u = (ptr) *(str *)u;
	}
	if (BUNappend(b, u, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCappend_reverse_val_wrap(bat *r, const bat *bid, const void *u)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.append", OPERATION_FAILED);
	if (b->htype >= TYPE_str && ATOMstorage(b->htype) >= TYPE_str) {
		if (u == 0 || *(str*)u == 0)
			u = (ptr) str_nil;
		else
			u = (ptr) *(str *)u;
	}
	b = BATmirror(b);
	if (BUNappend(b, u, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", GDK_EXCEPTION);
	}
	b = BATmirror(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

char *
BKCappend_force_wrap(bat *r, const bat *bid, const bat *uid, const bit *force)
{
	BAT *b, *u;
	gdk_return ret;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	if ((u = BATdescriptor(*uid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	}
	if (BATcount(u) == 0) {
		ret = GDK_SUCCEED;
	} else {
		if ((b = setaccess(b, BAT_WRITE)) == NULL)
			throw(MAL, "bat.append", OPERATION_FAILED);
		ret = BATappend(b, u, *force);
	}
	BBPunfix(u->batCacheid);
	if (ret != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", GDK_EXCEPTION);
	}
	if( b->batPersistence == PERSISTENT)
		BATmsync(b);
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCappend_val_force_wrap(bat *r, const bat *bid, const void *u, const bit *force)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.append", RUNTIME_OBJECT_MISSING);
	if ((b = setaccess(b, BAT_WRITE)) == NULL)
		throw(MAL, "bat.append", OPERATION_FAILED);
	if (b->ttype >= TYPE_str && ATOMstorage(b->ttype) >= TYPE_str) {
		if (u == 0 || *(str*)u == 0)
			u = (ptr) str_nil;
		else
			u = (ptr) *(str *)u;
	}
	if (BUNappend(b, u, *force) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.append", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCbun_inplace(bat *r, const bat *bid, const oid *id, const void *t)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.inplace", RUNTIME_OBJECT_MISSING);
	if (void_inplace(b, *id, t, FALSE) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.inplace", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCbun_inplace_force(bat *r, const bat *bid, const oid *id, const void *t, const bit *force)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.inplace", RUNTIME_OBJECT_MISSING);
	if (void_inplace(b, *id, t, *force) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.inplace", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	return MAL_SUCCEED;
}


str
BKCbat_inplace_force(bat *r, const bat *bid, const bat *rid, const bat *uid, const bit *force)
{
	BAT *b, *p, *u;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.inplace", RUNTIME_OBJECT_MISSING);
	if ((p = BATdescriptor(*rid)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.inplace", RUNTIME_OBJECT_MISSING);
	}
	if ((u = BATdescriptor(*uid)) == NULL) {
		BBPunfix(b->batCacheid);
		BBPunfix(p->batCacheid);
		throw(MAL, "bat.inplace", RUNTIME_OBJECT_MISSING);
	}
	if (void_replace_bat(b, p, u, *force) == BUN_NONE) {
		BBPunfix(b->batCacheid);
		BBPunfix(p->batCacheid);
		BBPunfix(u->batCacheid);
		throw(MAL, "bat.inplace", GDK_EXCEPTION);
	}
	BBPkeepref(*r = b->batCacheid);
	BBPunfix(p->batCacheid);
	BBPunfix(u->batCacheid);
	return MAL_SUCCEED;
}

str
BKCbat_inplace(bat *r, const bat *bid, const bat *rid, const bat *uid)
{
	bit F = FALSE;

	return BKCbat_inplace_force(r, bid, rid, uid, &F);
}

/*end of SQL enhancement */

str
BKCgetCapacity(lng *res, const bat *bid)
{
	*res = lng_nil;
	if (BBPcheck(*bid, "bat.getCapacity")) {
		BAT *b = BBPquickdesc(abs(*bid), 0);

		if (b != NULL)
			*res = (lng) BATcapacity(b);
	}
	return MAL_SUCCEED;
}

str
BKCgetColumnType(str *res, const bat *bid)
{
	const char *ret = str_nil;

	if (BBPcheck(*bid, "bat.getColumnType")) {
		BAT *b = BBPquickdesc(abs(*bid), 0);

		if (b) {
			ret = *bid < 0 ? ATOMname(b->htype) : ATOMname(b->ttype);
		}
	}
	*res = GDKstrdup(ret);
	return MAL_SUCCEED;
}

str
BKCgetRole(str *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.getType", RUNTIME_OBJECT_MISSING);
	}
	*res = GDKstrdup((*bid > 0) ? b->hident : b->tident);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetkey(bat *res, const bat *bid, const bit *param)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setKey", RUNTIME_OBJECT_MISSING);
	}
	BATkey(BATmirror(b), *param ? BOUND2BTRUE :FALSE);
	*res = b->batCacheid;
	BBPkeepref(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCisSorted(bit *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.isSorted", RUNTIME_OBJECT_MISSING);
	}
	*res = BATordered(BATmirror(b));
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCisSortedReverse(bit *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.isSorted", RUNTIME_OBJECT_MISSING);
	}
	*res = BATordered_rev(BATmirror(b));
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

/*
 * We must take care of the special case of a nil column (TYPE_void,seqbase=nil)
 * such nil columns never set hkey (and BUNins will never invalidate it if set) yet
 * a nil column of a BAT with <= 1 entries does not contain doubles => return TRUE.
 */

str
BKCgetKey(bit *ret, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) 
		throw(MAL, "bat.setPersistence", RUNTIME_OBJECT_MISSING);
	if (BATcount(b) <= 1) {
		*ret = TRUE;
	} else {
		if (!b->tkey) {
			BATderiveHeadProps(BATmirror(b), 1);
		}
		*ret = b->tkey ? TRUE : FALSE;
	}
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCpersists(void *r, const bat *bid, const bit *flg)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setPersistence", RUNTIME_OBJECT_MISSING);
	}
	if (BATmode(b, (*flg == TRUE) ? PERSISTENT : TRANSIENT) != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setPersistence", ILLEGAL_ARGUMENT);
	}
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetPersistent(void *r, const bat *bid)
{
	bit flag= TRUE;
	return BKCpersists(r, bid, &flag);
}

str
BKCisPersistent(bit *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setPersistence", RUNTIME_OBJECT_MISSING);
	}
	*res = (b->batPersistence == PERSISTENT) ? TRUE :FALSE;
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetTransient(void *r, const bat *bid)
{
	bit flag = FALSE;
	return BKCpersists(r, bid, &flag);
}

str
BKCisTransient(bit *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setTransient", RUNTIME_OBJECT_MISSING);
	}
	*res = b->batPersistence == TRANSIENT;
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetAccess(bat *res, const bat *bid, const char * const *param)
{
	BAT *b;
	int m;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.setAccess", RUNTIME_OBJECT_MISSING);
	switch (*param[0]) {
	case 'r':
		m = BAT_READ;
		break;
	case 'a':
		m = BAT_APPEND;
		break;
	case 'w':
		m = BAT_WRITE;
		break;
	default:
		*res = 0;
		throw(MAL, "bat.setAccess", ILLEGAL_ARGUMENT " Got %c" " expected 'r','a', or 'w'", *param[0]);
	}
	if ((b = setaccess(b, m)) == NULL)
		throw(MAL, "bat.setAccess", OPERATION_FAILED);
	BBPkeepref(*res = b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCgetAccess(str *res, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL)
		throw(MAL, "bat.getAccess", RUNTIME_OBJECT_MISSING);
	switch (BATgetaccess(b)) {
	case BAT_READ:
		*res = GDKstrdup("read");
		break;
	case BAT_APPEND:
		*res = GDKstrdup("append");
		break;
	case BAT_WRITE:
		*res = GDKstrdup("write");
		break;
	default:
		/* cannot happen, just here to help analysis tools */
		*res = GDKstrdup(str_nil);
		break;
	}
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

/*
 * Property management
 * All property operators should ensure exclusive access to the BAT
 * descriptor.
 * Where necessary use the primary view to access the properties
 */
str
BKCinfo(bat *ret1, bat *ret2, const bat *bid)
{
	BAT *bk = NULL, *bv= NULL, *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.getInfo", RUNTIME_OBJECT_MISSING);
	}
	if (CMDinfo(&bk, &bv, b) == GDK_SUCCEED) {
		*ret1 = bk->batCacheid;
		*ret2 = bv->batCacheid;
		BBPkeepref(bk->batCacheid);
		BBPkeepref(bv->batCacheid);
		BBPunfix(*bid);
		return MAL_SUCCEED;
	}
	BBPunfix(*bid);
	throw(MAL, "BKCinfo", GDK_EXCEPTION);
}

// get the actual size of all constituents, also for views
#define ROUND_UP(x,y) ((y)*(((x)+(y)-1)/(y)))

str
BKCgetSize(lng *tot, const bat *bid){
	BAT *b;
	lng size = 0;
	lng blksize = (lng) MT_pagesize();
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.getDiskSize", RUNTIME_OBJECT_MISSING);
	}

	size = sizeof (bat);
	if ( !isVIEW(b)) {
		BUN cnt = BATcapacity(b);
		size += ROUND_UP(b->H->heap.free, blksize);
		size += ROUND_UP(b->T->heap.free, blksize);
		if (b->H->vheap)
			size += ROUND_UP(b->H->vheap->free, blksize);
		if (b->T->vheap)
			size += ROUND_UP(b->T->vheap->free, blksize);
		if (b->H->hash)
			size += ROUND_UP(sizeof(BUN) * cnt, blksize);
		if (b->T->hash)
			size += ROUND_UP(sizeof(BUN) * cnt, blksize);
		size += IMPSimprintsize(b);
	} 
	*tot = size;
	BBPunfix(*bid);
	return MAL_SUCCEED;
}

/*
 * Synced BATs
 */
str
BKCisSynced(bit *ret, const bat *bid1, const bat *bid2)
{
	BAT *b1, *b2;

	if ((b1 = BATdescriptor(*bid1)) == NULL) {
		throw(MAL, "bat.isSynced", RUNTIME_OBJECT_MISSING);
	}
	if ((b2 = BATdescriptor(*bid2)) == NULL) {
		BBPunfix(b1->batCacheid);
		throw(MAL, "bat.isSynced", RUNTIME_OBJECT_MISSING);
	}
	*ret = ALIGNsynced(b1, b2) != 0;
	BBPunfix(b1->batCacheid);
	BBPunfix(b2->batCacheid);
	return MAL_SUCCEED;
}

/*
 * Role Management
 */
char *
BKCsetRole(void *r, const bat *bid, const char * const *hname, const char * const *tname)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setRole", RUNTIME_OBJECT_MISSING);
	}
	if (hname == 0 || *hname == 0 || **hname == 0){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setRole", ILLEGAL_ARGUMENT " Head name missing");
	}
	if (tname == 0 || *tname == 0 || **tname == 0){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setRole", ILLEGAL_ARGUMENT " Tail name missing");
	}
	BATroles(b, *hname, *tname);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetColumn(void *r, const bat *bid, const char * const *tname)
{
	BAT *b;
	str dummy;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setColumn", RUNTIME_OBJECT_MISSING);
	}
	if (tname == 0 || *tname == 0 || **tname == 0){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setColumn", ILLEGAL_ARGUMENT " Column name missing");
	}
	/* watch out, hident is freed first */
	dummy= GDKstrdup(b->hident);
	BATroles(b, dummy, *tname);
	GDKfree(dummy);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetColumns(void *r, const bat *bid, const char * const *hname, const char * const *tname)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setColumns", RUNTIME_OBJECT_MISSING);
	}
	if (hname == 0 || *hname == 0 || **hname == 0){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setRole", ILLEGAL_ARGUMENT " Head name missing");
	}
	if (tname == 0 || *tname == 0 || **tname == 0){
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.setRole", ILLEGAL_ARGUMENT " Tail name missing");
	}
	BATroles(b, *hname, *tname);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}


str
BKCsetName(void *r, const bat *bid, const char * const *s)
{
	BAT *b;
	bit res, *rp = &res;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setName", RUNTIME_OBJECT_MISSING);
	}
	CMDrename(rp, b, *s);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCgetBBPname(str *ret, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.getName", RUNTIME_OBJECT_MISSING);
	}
	*ret = GDKstrdup(BBPname(b->batCacheid));
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsave(bit *res, const char * const *input)
{
	CMDsave(res, *input);
	return MAL_SUCCEED;
}

str
BKCsave2(void *r, const bat *bid)
{
	BAT *b;

	(void) r;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.save", RUNTIME_OBJECT_MISSING);
	}
	if ( b->batPersistence != TRANSIENT){
		throw(MAL, "bat.save", "Only save transient columns.");
	}

	if (b && BATdirty(b))
		BBPsave(b);
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

/*
 * Accelerator Control
 */
str
BKCsetHash(bit *ret, const bat *bid)
{
	BAT *b;

	(void) ret;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setHash", RUNTIME_OBJECT_MISSING);
	}
	*ret = BAThash(b, 0) == GDK_SUCCEED;
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCsetImprints(bit *ret, const bat *bid)
{
	BAT *b;

	(void) ret;
	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setImprints", RUNTIME_OBJECT_MISSING);
	}
	*ret = BATimprints(b) == GDK_SUCCEED;
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

str
BKCgetSequenceBase(oid *r, const bat *bid)
{
	BAT *b;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.setSequenceBase", RUNTIME_OBJECT_MISSING);
	}
	*r = b->hseqbase;
	BBPunfix(b->batCacheid);
	return MAL_SUCCEED;
}

/*
 * Shrinking a void-headed BAT using a list of oids to ignore.
 */
#define shrinkloop(Type)							\
	do {											\
		Type *p = (Type*)Tloc(b, BUNfirst(b));		\
		Type *q = (Type*)Tloc(b, BUNlast(b));		\
		Type *r = (Type*)Tloc(bn, BUNfirst(bn));	\
		cnt=0;										\
		for (;p<q; oidx++, p++) {					\
			if ( o < ol && *o == oidx ){			\
				o++;								\
			} else {								\
				cnt++;								\
				*r++ = *p;							\
			}										\
		}											\
	} while (0)

str
BKCshrinkBAT(bat *ret, const bat *bid, const bat *did)
{
	BAT *b, *d, *bn, *bs;
	BUN cnt =0;
	oid oidx = 0, *o, *ol;
	gdk_return res;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.shrink", RUNTIME_OBJECT_MISSING);
	}
	if ( b->htype != TYPE_void) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrink", SEMANTIC_TYPE_MISMATCH);
	}
	if ((d = BATdescriptor(*did)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrink", RUNTIME_OBJECT_MISSING);
	}
	bn= BATnew(b->htype, b->ttype, BATcount(b) - BATcount(d) , TRANSIENT);
	if (bn == NULL) {
		BBPunfix(b->batCacheid);
		BBPunfix(d->batCacheid);
		throw(MAL, "bat.shrink", MAL_MALLOC_FAIL );
	}
	res = BATsubsort(&bs, NULL, NULL, d, NULL, NULL, 0, 0);
	BBPunfix(d->batCacheid);
	if (res != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(bn->batCacheid);
		throw(MAL, "bat.shrink", MAL_MALLOC_FAIL );
	}

	o = (oid*)Tloc(bs, BUNfirst(bs));
	ol= (oid*)Tloc(bs, BUNlast(bs));

	switch(ATOMstorage(b->ttype) ){
	case TYPE_bte: shrinkloop(bte); break;
	case TYPE_sht: shrinkloop(sht); break;
	case TYPE_int: shrinkloop(int); break;
	case TYPE_lng: shrinkloop(lng); break;
#ifdef HAVE_HGE
	case TYPE_hge: shrinkloop(hge); break;
#endif
	case TYPE_flt: shrinkloop(flt); break;
	case TYPE_dbl: shrinkloop(dbl); break;
	case TYPE_oid: shrinkloop(oid); break;
	default:
		if (ATOMvarsized(bn->ttype)) {
			BUN p = BUNfirst(b);
			BUN q = BUNlast(b);
			BATiter bi = bat_iterator(b);

			cnt=0;
			for (;p<q; oidx++, p++) {
				if ( o < ol && *o == oidx ){
					o++;
				} else {
					BUNappend(bn, BUNtail(bi, p), FALSE);
					cnt++;
				}
			}
		} else {
			switch( b->T->width){
			case 1:shrinkloop(bte); break;
			case 2:shrinkloop(sht); break;
			case 4:shrinkloop(int); break;
			case 8:shrinkloop(lng); break;
#ifdef HAVE_HGE
			case 16:shrinkloop(hge); break;
#endif
			default:
				throw(MAL, "bat.shrink", "Illegal argument type");
			}
		}
	}

	BATsetcount(bn, cnt);
	BATseqbase(bn, 0);
	bn->tsorted = 0;
	bn->trevsorted = 0;
	bn->tdense = 0;
	bn->tkey = b->tkey;
	bn->T->nonil = b->T->nonil;
	bn->T->nil = b->T->nil;

	if (!(bn->batDirty&2)) BATsetaccess(bn, BAT_READ);

	BBPunfix(b->batCacheid);
	BBPunfix(bs->batCacheid);
	BBPkeepref(*ret= bn->batCacheid);
	return MAL_SUCCEED;
}

str
BKCshrinkBATmap(bat *ret, const bat *bid, const bat *did)
{
	BAT *b, *d, *bn, *bs;
	oid lim,oidx = 0, *o, *ol;
	oid *r;
	gdk_return res;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.shrinkMap", RUNTIME_OBJECT_MISSING);
	}
	if ( b->htype != TYPE_void) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrinkMap", SEMANTIC_TYPE_MISMATCH);
	}
	if ((d = BATdescriptor(*did)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrinkMap", RUNTIME_OBJECT_MISSING);
	}
	if ( d->htype != TYPE_void) {
		BBPunfix(d->batCacheid);
		throw(MAL, "bat.shrinkMap", SEMANTIC_TYPE_MISMATCH);
	}

	bn= BATnew(TYPE_void, TYPE_oid, BATcount(b) , TRANSIENT);
	if (bn == NULL) {
		BBPunfix(b->batCacheid);
		BBPunfix(d->batCacheid);
		throw(MAL, "bat.shrinkMap", MAL_MALLOC_FAIL );
	}
	res = BATsubsort(&bs, NULL, NULL, d, NULL, NULL, 0, 0);
	BBPunfix(d->batCacheid);
	if (res != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(bn->batCacheid);
		throw(MAL, "bat.shrinkMap", MAL_MALLOC_FAIL );
	}

	o = (oid*)Tloc(bs, BUNfirst(bs));
	ol= (oid*)Tloc(bs, BUNlast(bs));
	r = (oid*)Tloc(bn, BUNfirst(bn));

	lim = BATcount(b);

	for (;oidx<lim; oidx++) {
		if ( o < ol && *o == oidx ){
			o++;
		} else {
			*r++ = oidx;
		}
	}

    BATsetcount(bn, BATcount(b)-BATcount(bs));
	BATseqbase(bn, b->hseqbase);
    bn->tsorted = 0;
    bn->trevsorted = 0;
    bn->tdense = 0;

    if (!(bn->batDirty&2)) BATsetaccess(bn, BAT_READ);

	BBPunfix(b->batCacheid);
	BBPunfix(bs->batCacheid);
	BBPkeepref(*ret= bn->batCacheid);
	return MAL_SUCCEED;
}
/*
 * Shrinking a void-headed BAT using a list of oids to ignore.
 */
#define reuseloop(Type)								\
	do {											\
		Type *p = (Type*)Tloc(b, BUNfirst(b));		\
		Type *q = (Type*)Tloc(b, BUNlast(b));		\
		Type *r = (Type*)Tloc(bn, BUNfirst(bn));	\
		for (;p<q; oidx++, p++) {					\
			if ( *o == oidx ){						\
				while ( ol>o && ol[-1] == bidx) {	\
					bidx--;							\
					q--;							\
					ol--;							\
				}									\
				*r++ = *(--q);						\
				o += (o < ol);						\
				bidx--;								\
			} else									\
				*r++ = *p;							\
		}											\
	} while (0)

str
BKCreuseBAT(bat *ret, const bat *bid, const bat *did)
{
	BAT *b, *d, *bn, *bs;
	oid oidx = 0, bidx, *o, *ol;
	gdk_return res;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.reuse", RUNTIME_OBJECT_MISSING);
	}
	if ( b->htype != TYPE_void) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.reuse", SEMANTIC_TYPE_MISMATCH);
	}
	if ((d = BATdescriptor(*did)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.reuse", RUNTIME_OBJECT_MISSING);
	}
	bn= BATnew(b->htype, b->ttype, BATcount(b) - BATcount(d), TRANSIENT);
	if (bn == NULL) {
		BBPunfix(b->batCacheid);
		BBPunfix(d->batCacheid);
		throw(MAL, "bat.reuse", MAL_MALLOC_FAIL );
	}
	res = BATsubsort(&bs, NULL, NULL, d, NULL, NULL, 0, 0);
	BBPunfix(d->batCacheid);
	if (res != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(bn->batCacheid);
		throw(MAL, "bat.reuse", MAL_MALLOC_FAIL );
	}

	oidx = b->hseqbase;
	bidx = oidx + BATcount(b)-1;
	o = (oid*)Tloc(bs, BUNfirst(bs));
	ol= (oid*)Tloc(bs, BUNlast(bs));

	switch(ATOMstorage(b->ttype) ){
	case TYPE_bte: reuseloop(bte); break;
	case TYPE_sht: reuseloop(sht); break;
	case TYPE_int: reuseloop(int); break;
	case TYPE_lng: reuseloop(lng); break;
#ifdef HAVE_HGE
	case TYPE_hge: reuseloop(hge); break;
#endif
	case TYPE_flt: reuseloop(flt); break;
	case TYPE_dbl: reuseloop(dbl); break;
	case TYPE_oid: reuseloop(oid); break;
	case TYPE_str: /* to be done based on its index width */
	default:
		if (ATOMvarsized(bn->ttype)) {
			BUN p = BUNfirst(b);
			BUN q = BUNlast(b);
			BATiter bi = bat_iterator(b);

			for (;p<q; oidx++, p++) {
				if ( *o == oidx ){
					while ( ol > o && ol[-1] == bidx) {
						bidx--;
						q--;
						ol--;
					}
					BUNappend(bn, BUNtail(bi, --q), FALSE);
					o += (o < ol);
					bidx--;
				} else {
					BUNappend(bn, BUNtail(bi, p), FALSE);
				}
			}
		} else {
			switch( b->T->width){
			case 1:reuseloop(bte); break;
			case 2:reuseloop(sht); break;
			case 4:reuseloop(int); break;
			case 8:reuseloop(lng); break;
#ifdef HAVE_HGE
			case 16:reuseloop(hge); break;
#endif
			default:
				throw(MAL, "bat.shrink", "Illegal argument type");
			}
		}
	}

    BATsetcount(bn, BATcount(b) - BATcount(bs));
	BATseqbase(bn, b->hseqbase);
    bn->tsorted = 0;
    bn->trevsorted = 0;
    bn->tdense = 0;
	bn->tkey = b->tkey;

    if (!(bn->batDirty&2)) BATsetaccess(bn, BAT_READ);

	BBPunfix(b->batCacheid);
	BBPunfix(bs->batCacheid);
	BBPkeepref(*ret= bn->batCacheid);
	return MAL_SUCCEED;
}

str
BKCreuseBATmap(bat *ret, const bat *bid, const bat *did)
{
	BAT *b, *d, *bn, *bs;
	oid bidx, oidx = 0, *o, *ol;
	oid *r;
	gdk_return res;

	if ((b = BATdescriptor(*bid)) == NULL) {
		throw(MAL, "bat.shrinkMap", RUNTIME_OBJECT_MISSING);
	}
	if ( b->htype != TYPE_void) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrinkMap", SEMANTIC_TYPE_MISMATCH);
	}
	if ((d = BATdescriptor(*did)) == NULL) {
		BBPunfix(b->batCacheid);
		throw(MAL, "bat.shrinkMap", RUNTIME_OBJECT_MISSING);
	}
	bn= BATnew(TYPE_void, TYPE_oid, BATcount(b) - BATcount(d), TRANSIENT);
	if (bn == NULL) {
		BBPunfix(b->batCacheid);
		BBPunfix(d->batCacheid);
		throw(MAL, "bat.shrinkMap", MAL_MALLOC_FAIL );
	}
	res = BATsubsort(&bs, NULL, NULL, d, NULL, NULL, 0, 0);
	BBPunfix(d->batCacheid);
	if (res != GDK_SUCCEED) {
		BBPunfix(b->batCacheid);
		BBPunfix(bn->batCacheid);
		throw(MAL, "bat.shrinkMap", MAL_MALLOC_FAIL );
	}

	oidx = b->hseqbase;
	bidx = oidx + BATcount(b)-1;
	o  = (oid*)Tloc(bs, BUNfirst(bs));
	ol = (oid*)Tloc(bs, BUNlast(bs));
	r  = (oid*)Tloc(bn, BUNfirst(bn));

	for (; oidx <= bidx; oidx++) {
		if ( *o == oidx ){
			while ( ol > o && ol[-1] == bidx) {
				bidx--;
				ol--;
			}
			*r++ = bidx;
			o += (o < ol);
			bidx--;
		} else {
			*r++ = oidx;
		}
	}

    BATsetcount(bn, BATcount(b)-BATcount(bs));
	BATseqbase(bn, b->hseqbase);
    bn->tsorted = 0;
    bn->trevsorted = 0;
    bn->tdense = 0;

    if (!(bn->batDirty&2)) BATsetaccess(bn, BAT_READ);

	BBPunfix(b->batCacheid);
	BBPunfix(bs->batCacheid);
	BBPkeepref(*ret= bn->batCacheid);
	return MAL_SUCCEED;
}

str
BKCmergecand(bat *ret, const bat *aid, const bat *bid)
{
	BAT *a, *b, *bn;

	if ((a = BATdescriptor(*aid)) == NULL) {
		throw(MAL, "bat.mergecand", RUNTIME_OBJECT_MISSING);
	}
	if ((b = BATdescriptor(*bid)) == NULL) {
		BBPunfix(a->batCacheid);
		throw(MAL, "bat.mergecand", RUNTIME_OBJECT_MISSING);
	}
	bn = BATmergecand(a, b);
	BBPunfix(a->batCacheid);
	BBPunfix(b->batCacheid);
	if (bn == NULL)
		throw(MAL, "bat.mergecand", OPERATION_FAILED);
	*ret = bn->batCacheid;
	BBPkeepref(*ret);
	return MAL_SUCCEED;
}

str
BKCintersectcand(bat *ret, const bat *aid, const bat *bid)
{
	BAT *a, *b, *bn;

	if ((a = BATdescriptor(*aid)) == NULL) {
		throw(MAL, "bat.intersectcand", RUNTIME_OBJECT_MISSING);
	}
	if ((b = BATdescriptor(*bid)) == NULL) {
		BBPunfix(a->batCacheid);
		throw(MAL, "bat.intersectcand", RUNTIME_OBJECT_MISSING);
	}
	bn = BATintersectcand(a, b);
	BBPunfix(a->batCacheid);
	BBPunfix(b->batCacheid);
	if (bn == NULL)
		throw(MAL, "bat.intersectcand", OPERATION_FAILED);
	*ret = bn->batCacheid;
	BBPkeepref(*ret);
	return MAL_SUCCEED;
}
