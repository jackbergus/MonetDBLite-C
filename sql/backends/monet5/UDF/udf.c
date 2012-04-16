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

#include "monetdb_config.h"
#include "udf.h"

/* Reverse a string */

/* actual implementation */
static str
UDFreverse_(str *ret, str src)
{
	size_t len = 0;
	str dst = NULL;

	/* assert calling sanity */
	assert(ret != NULL);

	/* handle NULL pointer and NULL value */
	if (src == NULL || strcmp(src, str_nil) == 0) {
		*ret = GDKstrdup(str_nil);
		if (*ret == NULL)
			throw(MAL, "udf.reverse",
			      "failed to create copy of str_nil");

		return MAL_SUCCEED;
	}

	/* allocate result string */
	len = strlen(src);
	*ret = dst = GDKmalloc(len + 1);
	if (dst == NULL)
		throw(MAL, "udf.reverse",
		      "failed to allocate string of length " SZFMT, len + 1);

	/* copy characters from src to dst in reverse order */
	dst[len] = 0;
	while (len > 0)
		*dst++ = src[--len];

	return MAL_SUCCEED;
}

/* MAL wrapper */
str
UDFreverse(str *ret, str *arg)
{
	/* assert calling sanity */
	assert(ret != NULL && arg != NULL);

	return UDFreverse_ ( ret, *arg );
}


/* Reverse a BAT of strings */
/*
 * Generic "type-oblivious" version,
 * using generic "type-oblivious" BAT access interface.
 */

/* actual implementation */
static str
UDFBATreverse_(BAT **ret, BAT *left)
{
	BATiter li;
	BAT *bn = NULL;
	BUN p = 0, q = 0;

	/* assert calling sanity */
	assert(ret != NULL);

	/* handle NULL pointer */
	if (left == NULL)
		throw(MAL, "batudf.reverse", RUNTIME_OBJECT_MISSING);

	/* check tail type */
	if (left->ttype != TYPE_str) {
		throw(MAL, "batudf.reverse",
		      "tail-type of input BAT must be TYPE_str");
	}

	/* allocate result BAT */
	bn = BATnew(left->htype, TYPE_str, BATcount(left));
	if (bn == NULL) {
		throw(MAL, "batudf.reverse", MAL_MALLOC_FAIL);
	}
	BATseqbase(bn, left->hseqbase);

	/* create BAT iterator */
	li = bat_iterator(left);

	/* advice on sequential scan */
	BATaccessBegin(left, USE_HEAD | USE_TAIL, MMAP_SEQUENTIAL);

	/* the core of the algorithm, expensive due to malloc/frees */
	BATloop(left, p, q) {
		str tr = NULL, err = NULL;

		/* get original head & tail value */
		ptr h = BUNhead(li, p);
		str t = (str) BUNtail(li, p);

		/* revert tail value */
		err = UDFreverse_(&tr, t);
		if (err != MAL_SUCCEED) {
			/* error -> bail out */
			BATaccessEnd(left, USE_HEAD | USE_TAIL,
				     MMAP_SEQUENTIAL);
			BBPreleaseref(bn->batCacheid);
			return err;
		}

		/* assert logical sanity */
		assert(tr != NULL);

		/* insert original head and reversed tail in result BAT */
		/* BUNins() takes care of all necessary administration */
		BUNins(bn, h, tr, FALSE);

		/* free memory allocated in UDFreverse_() */
		GDKfree(tr);
	}

	BATaccessEnd(left, USE_HEAD | USE_TAIL, MMAP_SEQUENTIAL);

	*ret = bn;

	return MAL_SUCCEED;
}

/* MAL wrapper */           
str
UDFBATreverse(bat *ret, bat *bid)
{
	BAT *res = NULL, *left = NULL;
	str msg = NULL;

	/* assert calling sanity */
	assert(ret != NULL && bid != NULL);

	/* bat-id -> BAT-descriptor */
	if ((left = BATdescriptor(*bid)) == NULL)
		throw(MAL, "batudf.reverse", RUNTIME_OBJECT_MISSING);

	/* do the work */
	msg = UDFBATreverse_ ( &res, left );

	/* release input BAT-descriptor */
	BBPreleaseref(left->batCacheid);

	if (msg == MAL_SUCCEED) {
		/* register result BAT in buffer pool */
		BBPkeepref((*ret = res->batCacheid));
	}

	return msg;
}



/* scalar fuse */

#define UDFfuse_scalar_impl(in,uin,out,shift)				\
/* fuse two (shift-byte) in values into one (2*shift-byte) out value */	\
/* actual implementation */						\
static str UDFfuse_##in##_##out##_ ( out *ret , in one , in two )	\
{									\
	/* assert calling sanity */					\
	assert(ret != NULL);						\
									\
	if (one == in##_nil || two == in##_nil)				\
		/* NULL/nil in => NULL/nil out */			\
		*ret = out##_nil;					\
	else								\
		/* do the work; watch out for sign bits */		\
		*ret = ( ((out)((uin)one)) << shift ) | ((uin)two);	\
									\
	return MAL_SUCCEED;						\
}									\
/* MAL wrapper */							\
str UDFfuse_##in##_##out ( out *ret , in *one , in *two )		\
{									\
	/* assert calling sanity */					\
	assert(ret != NULL && one != NULL && two != NULL);		\
									\
	return UDFfuse_##in##_##out##_ ( ret, *one, *two );		\
}

UDFfuse_scalar_impl(bte, unsigned char,  sht,  8)
UDFfuse_scalar_impl(sht, unsigned short, int, 16)
UDFfuse_scalar_impl(int, unsigned int,   lng, 32)


/* BAT fuse */
/*
 * Type-expanded optimized version,
 * accessing value arrays directly.
 */

/* actual implementation */
static str
UDFBATfuse_(BAT **ret, BAT *bone, BAT *btwo)
{
	BAT *bres = NULL;
	bit two_tail_sorted_unsigned = FALSE;
	bit two_tail_revsorted_unsigned = FALSE;

	/* assert calling sanity */
	assert(ret != NULL);

	/* handle NULL pointer */
	if (bone == NULL || btwo == NULL)
		throw(MAL, "batudf.fuse", RUNTIME_OBJECT_MISSING);

	/* check for dense & aligned heads */
	if (!BAThdense(bone) ||
	    !BAThdense(btwo) ||
	    BATcount(bone) != BATcount(btwo) ||
	    bone->hseqbase != btwo->hseqbase) {
		throw(MAL, "batudf.fuse",
		      "heads of input BATs must be aligned");
	}

	/* check tail types */
	if (bone->ttype != btwo->ttype) {
		throw(MAL, "batudf.fuse",
		      "tails of input BATs must be identical");
	}

	/* advice on sequential scan */
	BATaccessBegin(bone, USE_TAIL, MMAP_SEQUENTIAL);
	BATaccessBegin(btwo, USE_TAIL, MMAP_SEQUENTIAL);

#define UDFBATfuse_TYPE(in,uin,out,shift)				\
do {	/* type-specific core algorithm */				\
	in *one = NULL, *two = NULL;					\
	out *res = NULL;						\
	BUN i, n = BATcount(bone);					\
									\
	/* allocate result BAT */					\
	bres = BATnew(TYPE_void, TYPE_##out, n);			\
	if (bres == NULL) {						\
		BBPreleaseref(bone->batCacheid);			\
		BBPreleaseref(btwo->batCacheid);			\
		throw(MAL, "batudf.fuse", MAL_MALLOC_FAIL);		\
	}								\
									\
	/* get direct access to the tail arrays	*/			\
	one = (in *) Tloc(bone, BUNfirst(bone));			\
	two = (in *) Tloc(btwo, BUNfirst(btwo));			\
	res = (out*) Tloc(bres, BUNfirst(bres));			\
									\
	/* is tail of right/second BAT sorted,				\
	 * also when cast to unsigned type,				\
	 * i.e., are the values either all >= 0 or all < 0? */		\
	two_tail_sorted_unsigned = BATtordered(btwo) &&			\
		(two[0] >= 0 || two[n - 1] < 0);			\
	two_tail_revsorted_unsigned = BATtrevordered(btwo) &&		\
		(two[0] < 0 || two[n - 1] >= 0);			\
									\
	/* iterate over all values/tuples and do the work */		\
	for (i = 0; i < n; i++)						\
		if (one[i] == in##_nil || two[i] == in##_nil)		\
			/* NULL/nil in => NULL/nil out */		\
			res[i] = out##_nil;				\
		else							\
			/* do the work; watch out for sign bits */	\
			res[i] = ((out) (uin) one[i] << shift) | (uin) two[i]; \
									\
	/* set number of tuples in result BAT */			\
	BATsetcount(bres, n);						\
} while (0)

	/* type expansion for core algorithm */
	switch (bone->ttype) {
	case TYPE_bte:
		UDFBATfuse_TYPE(bte, unsigned char, sht, 8);
		break;

	case TYPE_sht:
		UDFBATfuse_TYPE(sht, unsigned short, int, 16);
		break;

	case TYPE_int:
		UDFBATfuse_TYPE(int, unsigned int, lng, 32);
		break;

	default:
		throw(MAL, "batudf.fuse",
		      "tails of input BATs must be one of {bte, sht, int}");
	}

	BATaccessEnd(bone, USE_TAIL, MMAP_SEQUENTIAL);
	BATaccessEnd(btwo, USE_TAIL, MMAP_SEQUENTIAL);

	/* set result properties */
	bres->hdense = TRUE;              /* result head is dense */
	BATseqbase(bres, bone->hseqbase); /* result head has same seqbase as input */
	bres->hsorted = 1;                /* result head is sorted */
	bres->hrevsorted = (BATcount(bres) <= 1);
	BATkey(bres, TRUE);               /* result head is key (unique) */

	/* Result tail is sorted, if the left/first input tail is
	 * sorted and key (unique), or if the left/first input tail is
	 * sorted and the second/right input tail is sorted and the
	 * second/right tail values are either all >= 0 or all < 0;
	 * otherwise, we cannot tell.
	 */
	if (BATtordered(bone)
	    && (BATtkey(bone) || two_tail_sorted_unsigned))
		bres->tsorted = 1;
	else
		bres->tsorted = (BATcount(bres) <= 1);
	if (BATtrevordered(bone)
	    && (BATtkey(bone) || two_tail_revsorted_unsigned))
		bres->trevsorted = 1;
	else
		bres->trevsorted = (BATcount(bres) <= 1);
	/* result tail is key (unique), iff both input tails are */
	BATkey(BATmirror(bres), BATtkey(bone) || BATtkey(btwo));

	*ret = bres;

	return MAL_SUCCEED;
}

/* MAL wrapper */
str
UDFBATfuse(bat *ires, bat *ione, bat *itwo)
{
	BAT *bres = NULL, *bone = NULL, *btwo = NULL;
	str msg = NULL;

	/* assert calling sanity */
	assert(ires != NULL && ione != NULL && itwo != NULL);

	/* bat-id -> BAT-descriptor */
	if ((bone = BATdescriptor(*ione)) == NULL)
		throw(MAL, "batudf.fuse", RUNTIME_OBJECT_MISSING);

	/* bat-id -> BAT-descriptor */
	if ((btwo = BATdescriptor(*itwo)) == NULL) {
		BBPreleaseref(bone->batCacheid);
		throw(MAL, "batudf.fuse", RUNTIME_OBJECT_MISSING);
	}

	/* do the work */
	msg = UDFBATfuse_ ( &bres, bone, btwo );

	/* release input BAT-descriptors */
	BBPreleaseref(bone->batCacheid);
	BBPreleaseref(btwo->batCacheid);

	if (msg == MAL_SUCCEED) {
		/* register result BAT in buffer pool */
		BBPkeepref((*ires = bres->batCacheid));
	}

	return msg;
}
