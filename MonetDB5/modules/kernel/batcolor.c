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
 * Copyright August 2008-2015 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * M.L. Kersten
 * Color multiplexes
 * [TODO: property propagations and general testing]
 * The collection of routines provided here are map operations
 * for the color string primitives.
 *
 * In line with the batcalc module, we assume that
 * if two bat operands are provided that they are already
 * aligned on the head. Moreover, the head of the BATs
 * are limited to :oid, which can be cheaply realized using
 * the GRPsplit operation.
 */

#include "monetdb_config.h"
#include "batcolor.h"

#define BATwalk(NAME,FUNC,TYPE1,TYPE2)									\
str CLRbat##NAME(bat *ret, const bat *l)								\
{																		\
	BATiter bi;															\
	BAT *bn, *b;														\
	BUN p,q;															\
	TYPE1 *x;															\
	TYPE2 y, *yp = &y;													\
																		\
	if( (b= BATdescriptor(*l)) == NULL )								\
		throw(MAL, "batcolor." #NAME, RUNTIME_OBJECT_MISSING);			\
	bn= BATnew(b->htype,getTypeIndex(#TYPE2,-1,TYPE_int),BATcount(b), TRANSIENT); \
	if( bn == NULL){													\
		BBPreleaseref(b->batCacheid);									\
		throw(MAL, "batcolor." #NAME, MAL_MALLOC_FAIL);					\
	}																	\
	if( b->htype== TYPE_void)											\
		BATseqbase(bn, b->hseqbase);									\
	bn->hsorted=b->hsorted;												\
	bn->hrevsorted=b->hrevsorted;										\
	bn->tsorted=0;														\
	bn->trevsorted=0;													\
	bn->T->nil = 0;														\
	bn->T->nonil = 1;													\
																		\
	bi = bat_iterator(b);												\
																		\
	BATloop(b, p, q) {													\
		ptr h = BUNhead(bi,p);											\
		x= (TYPE1 *) BUNtail(bi,p);										\
		if (x== 0 || *x == TYPE1##_nil) {								\
			y = (TYPE2) TYPE2##_nil;									\
			bn->T->nonil = 0;											\
			bn->T->nil = 1;												\
		} else															\
			FUNC(yp,x);													\
		bunfastins(bn, h, yp);											\
	}																	\
	bn->H->nonil = b->H->nonil;											\
	bn->H->nil = b->H->nil;												\
	if (!(bn->batDirty & 2))											\
		bn = BATsetaccess(bn, BAT_READ);								\
	*ret = bn->batCacheid;												\
	BBPkeepref(*ret);													\
	BBPreleaseref(b->batCacheid);										\
	return MAL_SUCCEED;													\
bunins_failed:															\
	BBPreleaseref(b->batCacheid);										\
	BBPreleaseref(bn->batCacheid);										\
	throw(MAL, "batcolor." #NAME, OPERATION_FAILED " During bulk operation"); \
}

BATwalk(Color,CLRcolor,str,color)
BATwalk(Str,CLRstr,color,str)

BATwalk(Red,CLRred,color,int)
BATwalk(Green,CLRgreen,color,int)
BATwalk(Blue,CLRblue,color,int)

BATwalk(Hue,CLRhue,color,flt)
BATwalk(Saturation,CLRsaturation,color,flt)
BATwalk(Value,CLRvalue,color,flt)

BATwalk(HueInt,CLRhueInt,color,int)
BATwalk(SaturationInt,CLRsaturationInt,color,int)
BATwalk(ValueInt,CLRvalueInt,color,int)

BATwalk(Luminance,CLRluminance,color,int)
BATwalk(Cr,CLRcr,color,int)
BATwalk(Cb,CLRcb,color,int)

#define BATwalk3(NAME,FUNC,TYPE)										\
str CLRbat##NAME(bat *ret, const bat *l, const bat *bid2, const bat *bid3) \
{																		\
	BATiter bi, b2i, b3i;												\
	BAT *bn, *b2,*b3, *b;												\
	BUN p,q,p2,p3;														\
	TYPE *x, *x2, *x3;													\
	color y, *yp = &y;													\
																		\
	b= BATdescriptor(*l);												\
	b2= BATdescriptor(*bid2);											\
	b3= BATdescriptor(*bid3);											\
	if (b == NULL || b2 == NULL || b3 == NULL) {						\
		if (b)															\
			BBPreleaseref(b->batCacheid);								\
		if (b2)															\
			BBPreleaseref(b2->batCacheid);								\
		if (b3)															\
			BBPreleaseref(b3->batCacheid);								\
		throw(MAL, "batcolor." #NAME, RUNTIME_OBJECT_MISSING);			\
	}																	\
	bn= BATnew(b->htype,getTypeIndex("color",5,TYPE_int),BATcount(b), TRANSIENT); \
	if( bn == NULL){													\
		BBPreleaseref(b->batCacheid);									\
		BBPreleaseref(b2->batCacheid);									\
		BBPreleaseref(b3->batCacheid);									\
		throw(MAL, "batcolor." #NAME, MAL_MALLOC_FAIL);					\
	}																	\
	if( b->htype== TYPE_void)											\
		BATseqbase(bn, b->hseqbase);									\
	bn->hsorted=b->hsorted;												\
	bn->hrevsorted=b->hrevsorted;										\
	bn->tsorted=0;														\
	bn->trevsorted=0;													\
	bn->T->nil = 0;														\
	bn->T->nonil = 1;													\
																		\
	bi = bat_iterator(b);												\
	b2i = bat_iterator(b2);												\
	b3i = bat_iterator(b3);												\
																		\
	p2= BUNfirst(b2);													\
	p3= BUNfirst(b3);													\
	BATloop(b, p, q) {													\
		ptr h = BUNhead(bi,p);											\
		x= (TYPE *) BUNtail(bi,p);										\
		x2= (TYPE *) BUNtail(b2i,p);									\
		x3= (TYPE *) BUNtail(b3i,p);									\
		if (x== 0 || *x == TYPE##_nil ||								\
			x2== 0 || *x2 == TYPE##_nil ||								\
			x3== 0 || *x3 == TYPE##_nil) {								\
			y = color_nil;												\
			bn->T->nonil = 0;											\
			bn->T->nil = 1;												\
		} else															\
			FUNC(yp,x,x2,x3);											\
		bunfastins(bn, h, yp);											\
		p2++;															\
		p3++;															\
	}																	\
	bn->H->nonil = b->H->nonil;											\
	bn->H->nil = b->H->nil;												\
	if (!(bn->batDirty & 2))											\
		bn = BATsetaccess(bn, BAT_READ);								\
	*ret = bn->batCacheid;												\
	BBPkeepref(*ret);													\
	BBPreleaseref(b->batCacheid);										\
	BBPreleaseref(b2->batCacheid);										\
	BBPreleaseref(b3->batCacheid);										\
	return MAL_SUCCEED;													\
bunins_failed:															\
	BBPreleaseref(b->batCacheid);										\
	BBPreleaseref(b2->batCacheid);										\
	BBPreleaseref(b3->batCacheid);										\
	BBPreleaseref(bn->batCacheid);										\
	throw(MAL, "batcolor." #NAME, OPERATION_FAILED " During bulk operation"); \
}

BATwalk3(Hsv,CLRhsv,flt)
BATwalk3(Rgb,CLRrgb,int)
BATwalk3(ycc,CLRycc,int)
