/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

#ifndef _GDK_SEARCH_H_
#define _GDK_SEARCH_H_
/*
 * @+ Hash indexing
 *
 * This is a highly efficient implementation of simple bucket-chained
 * hashing.
 *
 * In the past, we used integer modulo for hashing, with bucket chains
 * of mean size 4.  This was shown to be inferior to direct hashing
 * with integer anding. The new implementation reflects this.
 */
gdk_export void HASHdestroy(BAT *b);
gdk_export BUN HASHprobe(Hash *h, const void *v);
gdk_export BUN HASHlist(Hash *h, BUN i);


#define HASHnil(H)	(H)->nil

/* play around with h->Hash[i] and h->Link[j] */
#define HASHget2(h,i)		((BUN) ((BUN2type*) (h)->Hash)[i])
#define HASHput2(h,i,v)		(((BUN2type*) (h)->Hash)[i] = (BUN2type) (v))
#define HASHgetlink2(h,i)	((BUN) ((BUN2type*) (h)->Link)[i])
#define HASHputlink2(h,i,v)	(((BUN2type*) (h)->Link)[i] = (BUN2type) (v))
#define HASHget4(h,i)		((BUN) ((BUN4type*) (h)->Hash)[i])
#define HASHput4(h,i,v)		(((BUN4type*) (h)->Hash)[i] = (BUN4type) (v))
#define HASHgetlink4(h,i)	((BUN) ((BUN4type*) (h)->Link)[i])
#define HASHputlink4(h,i,v)	(((BUN4type*) (h)->Link)[i] = (BUN4type) (v))
#if SIZEOF_BUN == 8
#define HASHget8(h,i)		((BUN) ((BUN8type*) (h)->Hash)[i])
#define HASHput8(h,i,v)		(((BUN8type*) (h)->Hash)[i] = (BUN8type) (v))
#define HASHgetlink8(h,i)	((BUN) ((BUN8type*) (h)->Link)[i])
#define HASHputlink8(h,i,v)	(((BUN8type*) (h)->Link)[i] = (BUN8type) (v))
#endif

#if SIZEOF_BUN <= 4
#define HASHget(h,i)				\
	((h)->width == BUN4 ? HASHget4(h,i) : HASHget2(h,i))
#define HASHput(h,i,v)				\
	do {					\
		if ((h)->width == 2) {		\
			HASHput2(h,i,v);	\
		} else {			\
			HASHput4(h,i,v);	\
		}				\
	} while (0)
#define HASHgetlink(h,i)				\
	((h)->width == BUN4 ? HASHgetlink4(h,i) : HASHgetlink2(h,i))
#define HASHputlink(h,i,v)			\
	do {					\
		if ((h)->width == 2) {		\
			HASHputlink2(h,i,v);	\
		} else {			\
			HASHputlink4(h,i,v);	\
		}				\
	} while (0)
#define HASHputall(h, i, v)					\
	do {							\
		if ((h)->width == 2) {				\
			HASHputlink2(h, i, HASHget2(h, v));	\
			HASHput2(h, v, i);			\
		} else {					\
			HASHputlink4(h, i, HASHget4(h, v));	\
			HASHput4(h, v, i);			\
		}						\
	} while (0)
#else
#define HASHget(h,i)					\
	((h)->width == BUN8 ? HASHget8(h,i) :		\
	 (h)->width == BUN4 ? HASHget4(h,i) :		\
	 HASHget2(h,i))
#define HASHput(h,i,v)				\
	do {					\
		switch ((h)->width) {		\
		case 2:				\
			HASHput2(h,i,v);	\
			break;			\
		case 4:				\
			HASHput4(h,i,v);	\
			break;			\
		case 8:				\
			HASHput8(h,i,v);	\
			break;			\
		}				\
	} while (0)
#define HASHgetlink(h,i)				\
	((h)->width == BUN8 ? HASHgetlink8(h,i) :	\
	 (h)->width == BUN4 ? HASHgetlink4(h,i) :	\
	 HASHgetlink2(h,i))
#define HASHputlink(h,i,v)			\
	do {					\
		switch ((h)->width) {		\
		case 2:				\
			HASHputlink2(h,i,v);	\
			break;			\
		case 4:				\
			HASHputlink4(h,i,v);	\
			break;			\
		case 8:				\
			HASHputlink8(h,i,v);	\
			break;			\
		}				\
	} while (0)
#define HASHputall(h, i, v)					\
	do {							\
		switch ((h)->width) {				\
		case 2:						\
			HASHputlink2(h, i, HASHget2(h, v));	\
			HASHput2(h, v, i);			\
			break;					\
		case 4:						\
			HASHputlink4(h, i, HASHget4(h, v));	\
			HASHput4(h, v, i);			\
			break;					\
		case 8:						\
			HASHputlink8(h, i, HASHget8(h, v));	\
			HASHput8(h, v, i);			\
			break;					\
		}						\
	} while (0)
#endif

#define mix_sht(X)	(((X)>>7)^(X))
#define mix_int(X)	(((X)>>7)^((X)>>13)^((X)>>21)^(X))
#define hash_loc(H,V)	hash_any(H,V)
#define hash_var(H,V)	hash_any(H,V)
#define hash_any(H,V)	(ATOMhash((H)->type, (V)) & (H)->mask)
#define heap_hash_any(hp,H,V)	((hp) && (hp)->hashash ? ((BUN *) (V))[-1] & (H)->mask : hash_any(H,V))
#define hash_bte(H,V)	((BUN) (*(const unsigned char*) (V)) & (H)->mask)
#define hash_sht(H,V)	((BUN) mix_sht(*((const unsigned short*) (V))) & (H)->mask)
#define hash_int(H,V)	((BUN) mix_int(*((const unsigned int*) (V))) & (H)->mask)
/* XXX return size_t-sized value for 8-byte oid? */
#define hash_lng(H,V)	((BUN) mix_int((unsigned int) (*(const lng *)(V) ^ (*(const lng *)(V) >> 32))) & (H)->mask)
#ifdef HAVE_HGE
#define hash_hge(H,V)	((BUN) mix_int((unsigned int) (*(const hge *)(V) ^ (*(const hge *)(V) >> 32) ^ \
                     	                               (*(const hge *)(V) >> 64) ^ (*(const hge *)(V) >> 96))) & (H)->mask)
#endif
#if SIZEOF_OID == SIZEOF_INT
#define hash_oid(H,V)	((BUN) mix_int((unsigned int) *((const oid*) (V))) & (H)->mask)
#else
#define hash_oid(H,V)	((BUN) mix_int((unsigned int) (*(const oid *)(V) ^ (*(const oid *)(V) >> 32))) & (H)->mask)
#endif
#if SIZEOF_WRD == SIZEOF_INT
#define hash_wrd(H,V)	((BUN) mix_int((unsigned int) *((const wrd*) (V))) & (H)->mask)
#else
#define hash_wrd(H,V)	((BUN) mix_int((unsigned int) (*(const wrd *)(V) ^ (*(const wrd *)(V) >> 32))) & (H)->mask)
#endif

#define hash_flt(H,V)	hash_int(H,V)
#define hash_dbl(H,V)	hash_lng(H,V)

#define HASHfnd_str(x,y,z)						\
	do {								\
		BUN _i;							\
		(x) = BUN_NONE;						\
		if ((y).b->T->hash || BAThash((y).b, 0) == GDK_SUCCEED) { \
			HASHloop_str((y), (y).b->T->hash, _i, (z)) {	\
				(x) = _i;				\
				break;					\
			}						\
		} else							\
			goto hashfnd_failed;				\
	} while (0)
#define HASHfnd_str_hv(x,y,z)						\
	do {								\
		BUN _i;							\
		(x) = BUN_NONE;						\
		if ((y).b->T->hash || BAThash((y).b, 0) == GDK_SUCCEED) { \
			HASHloop_str_hv((y), (y).b->T->hash, _i, (z)) {	\
				(x) = _i;				\
				break;					\
			}						\
		} else							\
			goto hashfnd_failed;				\
	} while (0)
#define HASHfnd(x,y,z)							\
	do {								\
		BUN _i;							\
		(x) = BUN_NONE;						\
		if ((y).b->T->hash || BAThash((y).b, 0) == GDK_SUCCEED) { \
			HASHloop((y), (y).b->T->hash, _i, (z)) {	\
				(x) = _i;				\
				break;					\
			}						\
		} else							\
			goto hashfnd_failed;				\
	} while (0)
#define HASHfnd_TYPE(x,y,z,TYPE)					\
	do {								\
		BUN _i;							\
		(x) = BUN_NONE;						\
		if ((y).b->T->hash || BAThash((y).b, 0) == GDK_SUCCEED) { \
			HASHloop_##TYPE((y), (y).b->T->hash, _i, (z)) {	\
				(x) = _i;				\
				break;					\
			}						\
		} else							\
			goto hashfnd_failed;				\
	} while (0)
#define HASHfnd_bte(x,y,z)	HASHfnd_TYPE(x,y,z,bte)
#define HASHfnd_sht(x,y,z)	HASHfnd_TYPE(x,y,z,sht)
#define HASHfnd_int(x,y,z)	HASHfnd_TYPE(x,y,z,int)
#define HASHfnd_lng(x,y,z)	HASHfnd_TYPE(x,y,z,lng)
#ifdef HAVE_HGE
#define HASHfnd_hge(x,y,z)	HASHfnd_TYPE(x,y,z,hge)
#endif
#define HASHfnd_oid(x,y,z)	HASHfnd_TYPE(x,y,z,oid)
#define HASHfnd_wrd(x,y,z)	HASHfnd_TYPE(x,y,z,wrd)

#if SIZEOF_VOID_P == SIZEOF_INT
#define HASHfnd_ptr(x,y,z)	HASHfnd_int(x,y,z)
#else /* SIZEOF_VOID_P == SIZEOF_LNG */
#define HASHfnd_ptr(x,y,z)	HASHfnd_lng(x,y,z)
#endif
#define HASHfnd_bit(x,y,z)	HASHfnd_bte(x,y,z)
#define HASHfnd_flt(x,y,z)	HASHfnd_int(x,y,z)
#define HASHfnd_dbl(x,y,z)	HASHfnd_lng(x,y,z)
#define HASHfnd_any(x,y,z)	HASHfnd(x,y,z)
/*
 * A new entry is added with HASHins using the BAT, the BUN index, and
 * a pointer to the value to be stored. An entry is removed by HASdel.
 */
#define HASHins_TYPE(h, i, v, TYPE)		\
	do {					\
		BUN _c = hash_##TYPE(h,v);	\
		HASHputall(h,i,_c);		\
	} while (0)

#define HASHins_str(h,i,v)			\
	do {					\
		BUN _c;				\
		GDK_STRHASH(v,_c);		\
		_c &= (h)->mask;		\
		HASHputall(h,i,_c);		\
	} while (0)
#define HASHins_str_hv(h,i,v)				\
	do {						\
		BUN _c = ((BUN *) v)[-1] & (h)->mask;	\
		HASHputall(h,i,_c);		\
	} while (0)

#define HASHins_any(h,i,v)			\
	do {					\
		BUN _c = HASHprobe(h, v);	\
		HASHputall(h,i,_c);		\
	} while (0)

/* HASHins receives a BAT* param and is adaptive, killing wrongly
 * configured hash tables.
 * Use HASHins_any or HASHins_<tpe> instead if you know what you're
 * doing or want to keep the hash. */
#define HASHins(b,i,v)							\
	do {								\
		if (((i) & 1023) == 1023 && HASHgonebad((b),(v)))	\
			HASHremove(b);					\
		else							\
			HASHins_any((b)->T->hash,(i),(v));		\
	} while (0)

#if SIZEOF_VOID_P == SIZEOF_INT
#define HASHins_ptr(h,i,v)	HASHins_int(h,i,v)
#else /* SIZEOF_VOID_P == SIZEOF_LNG */
#define HASHins_ptr(h,i,v)	HASHins_lng(h,i,v)
#endif
#define HASHins_bit(h,i,v)	HASHins_bte(h,i,v)
#if SIZEOF_OID == SIZEOF_INT	/* OIDDEPEND */
#define HASHins_oid(h,i,v)	HASHins_int(h,i,v)
#else
#define HASHins_oid(h,i,v)	HASHins_lng(h,i,v)
#endif
#define HASHins_flt(h,i,v)	HASHins_int(h,i,v)
#define HASHins_dbl(h,i,v)	HASHins_lng(h,i,v)
#define HASHinsvar(h,i,v)	HASHins_any(h,i,v)
#define HASHinsloc(h,i,v)	HASHins_any(h,i,v)

#define HASHins_bte(h,i,v)	HASHins_TYPE(h,i,v,bte)
#define HASHins_sht(h,i,v)	HASHins_TYPE(h,i,v,sht)
#define HASHins_int(h,i,v)	HASHins_TYPE(h,i,v,int)
#define HASHins_lng(h,i,v)	HASHins_TYPE(h,i,v,lng)
#ifdef HAVE_HGE
#define HASHins_hge(h,i,v)	HASHins_TYPE(h,i,v,hge)
#endif

#define HASHdel(h, i, v, next)						\
	do {								\
		if (next && HASHgetlink(h, i+1) == i) {			\
			HASHputlink(h,i+1,HASHgetlink(h,i));		\
		} else {						\
			BUN _c = HASHprobe(h, v);			\
			if (HASHget(h,_c) == i) {			\
				HASHput(h,_c, HASHgetlink(h,i));	\
			} else {					\
				for(_c = HASHget(h,_c); _c != HASHnil(h); \
				    _c = HASHgetlink(h,_c)) {		\
					if (HASHgetlink(h,_c) == i) {	\
						HASHputlink(h,_c, HASHgetlink(h,i)); \
						break;			\
					}				\
				}					\
			}						\
		}							\
		HASHputlink(h,i,HASHnil(h));				\
	} while (0)

#define HASHmove(h, i, j, v, next)					\
	do {								\
		if (next && HASHgetlink(h,i+1) == i) {			\
			HASHputlink(h,i+1,j);				\
		} else {						\
			BUN _c = HASHprobe(h, v);			\
			if (HASHget(h,_c) == i) {			\
				HASHput(h,_c,j);			\
			} else {					\
				for(_c = HASHget(h,_c) ; _c != HASHnil(h); \
				    _c = HASHgetlink(h,_c)) {		\
					if (HASHgetlink(h,_c) == i) {	\
						HASHputlink(h,_c,j);	\
						break;			\
					}				\
				}					\
			}						\
		}							\
		HASHputlink(h,j, HASHgetlink(h,i));			\
	} while (0)

/* Functions to perform a binary search on a sorted BAT.
 * See gdk_search.c for details. */
gdk_export BUN SORTfnd(BAT *b, const void *v);
gdk_export BUN SORTfndfirst(BAT *b, const void *v);
gdk_export BUN SORTfndlast(BAT *b, const void *v);

#endif /* _GDK_SEARCH_H_ */
