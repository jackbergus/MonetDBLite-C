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
 * Implementation for the column imprints index.
 * See paper:
 * Column Imprints: A Secondary Index Structure,
 * L.Sidirourgos and M.Kersten.
 */

#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_private.h"
#include "gdk_imprints.h"

#define IMPRINTS_VERSION	2

#define BINSIZE(B, FUNC, T) do {		\
	switch (B) {				\
		case 8: FUNC(T,8); break;	\
		case 16: FUNC(T,16); break;	\
		case 32: FUNC(T,32); break;	\
		case 64: FUNC(T,64); break;	\
		default: assert(0); break;	\
	}					\
} while (0)

/* binary search */
#define check(Z,X,W) if ((X) >= bins[W] && (X) < bins[W+1]) (Z) = W;
#define left(Z,X,W)  if ((X) < bins[W+1])
#define right(Z,X,W) if ((X) >= bins[W])

#define GETBIN64(Z,X)						\
	right(Z,X,32) {						\
		right(Z,X,48) {					\
			right(Z,X,56) {				\
				right(Z,X,60){			\
					right(Z,X,62) {		\
						Z = 62;		\
						right(Z,X,63) {	\
							Z = 63;	\
						}		\
					}			\
					check(Z,X,61)		\
					left(Z,X,60) {		\
						Z = 60;		\
					}			\
				}				\
				check(Z,X,59)			\
				left(Z,X,58) {			\
					right(Z,X,58) {		\
						Z = 58;		\
					}			\
					check(Z,X,57)		\
					left(Z,X,56) {		\
						Z = 56;		\
					}			\
				}				\
			}					\
			check(Z,X,55)				\
			left(Z,X,54) {				\
				right(Z,X,52){			\
					right(Z,X,54) {		\
						Z = 54;		\
					}			\
					check(Z,X,53)		\
					left(Z,X,52) {		\
						Z = 52;		\
					}			\
				}				\
				check(Z,X,51)			\
				left(Z,X,50) {			\
					right(Z,X,50) {		\
						Z = 50;		\
					}			\
					check(Z,X,49)		\
					left(Z,X,48) {		\
						Z = 48;		\
					}			\
				}				\
			}					\
		}						\
		check(Z,X,47)					\
		left(Z,X,46) {					\
			right(Z,X,40) {				\
				right(Z,X,44){			\
					right(Z,X,46) {		\
						Z = 46;		\
					}			\
					check(Z,X,45)		\
					left(Z,X,44) {		\
						Z = 44;		\
					}			\
				}				\
				check(Z,X,43)			\
				left(Z,X,42) {			\
					right(Z,X,42) {		\
						Z = 42;		\
					}			\
					check(Z,X,41)		\
					left(Z,X,40) {		\
						Z = 40;		\
					}			\
				}				\
			}					\
			check(Z,X,39)				\
			left(Z,X,38) {				\
				right(Z,X,36){			\
					right(Z,X,38) {		\
						Z = 38;		\
					}			\
					check(Z,X,37)		\
					left(Z,X,36) {		\
						Z = 36;		\
					}			\
				}				\
				check(Z,X,35)			\
				left(Z,X,34) {			\
					right(Z,X,34) {		\
						Z = 34;		\
					}			\
					check(Z,X,33)		\
					left(Z,X,32) {		\
						Z = 32;		\
					}			\
				}				\
			}					\
		}						\
	}							\
	check(Z,X,31)						\
	left(Z,X,30) {						\
		right(Z,X,16) {					\
			right(Z,X,24) {				\
				right(Z,X,28){			\
					right(Z,X,30) {		\
						Z = 30;		\
					}			\
					check(Z,X,29)		\
					left(Z,X,28) {		\
						Z = 28;		\
					}			\
				}				\
				check(Z,X,27)			\
				left(Z,X,26) {			\
					right(Z,X,26) {		\
						Z = 26;		\
					}			\
					check(Z,X,25)		\
					left(Z,X,24) {		\
						Z = 24;		\
					}			\
				}				\
			}					\
			check(Z,X,23)				\
			left(Z,X,22) {				\
				right(Z,X,20){			\
					right(Z,X,22) {		\
						Z = 22;		\
					}			\
					check(Z,X,21)		\
					left(Z,X,20) {		\
						Z = 20;		\
					}			\
				}				\
				check(Z,X,19)			\
				left(Z,X,18) {			\
					right(Z,X,18) {		\
						Z = 18;		\
					}			\
					check(Z,X,17)		\
					left(Z,X,16) {		\
						Z = 16;		\
					}			\
				}				\
			}					\
		}						\
		check(Z,X,15)					\
		left(Z,X,14) {					\
			right(Z,X,8) {				\
				right(Z,X,12){			\
					right(Z,X,14) {		\
						Z = 14;		\
					}			\
					check(Z,X,13)		\
					left(Z,X,12) {		\
						Z = 12;		\
					}			\
				}				\
				check(Z,X,11)			\
				left(Z,X,10) {			\
					right(Z,X,10) {		\
						Z = 10;		\
					}			\
					check(Z,X,9)		\
					left(Z,X,8) {		\
						Z = 8;		\
					}			\
				}				\
			}					\
			check(Z,X,7)				\
			left(Z,X,6) {				\
				right(Z,X,4){			\
					right(Z,X,6) {		\
						Z = 6;		\
					}			\
					check(Z,X,5)		\
					left(Z,X,4) {		\
						Z = 4;		\
					}			\
				}				\
				check(Z,X,3)			\
				left(Z,X,2) {			\
					right(Z,X,2) {		\
						Z = 2;		\
					}			\
					check(Z,X,1)		\
					left(Z,X,0) {		\
						Z = 0;		\
					}			\
				}				\
			}					\
		}						\
	}

#define GETBIN32(Z,X)					\
	right(Z,X,16) {					\
		right(Z,X,24) {				\
			right(Z,X,28){			\
				right(Z,X,30) {		\
					Z = 30;		\
					right(Z,X,31) {	\
						Z = 31;	\
					}		\
				}			\
				check(Z,X,29)		\
				left(Z,X,28) {		\
					Z = 28;		\
				}			\
			}				\
			check(Z,X,27)			\
			left(Z,X,26) {			\
				right(Z,X,26) {		\
					Z = 26;		\
				}			\
				check(Z,X,25)		\
				left(Z,X,24) {		\
					Z = 24;		\
				}			\
			}				\
		}					\
		check(Z,X,23)				\
		left(Z,X,22) {				\
			right(Z,X,20){			\
				right(Z,X,22) {		\
					Z = 22;		\
				}			\
				check(Z,X,21)		\
				left(Z,X,20) {		\
					Z = 20;		\
				}			\
			}				\
			check(Z,X,19)			\
			left(Z,X,18) {			\
				right(Z,X,18) {		\
					Z = 18;		\
				}			\
				check(Z,X,17)		\
				left(Z,X,16) {		\
					Z = 16;		\
				}			\
			}				\
		}					\
	}						\
	check(Z,X,15)					\
	left(Z,X,14) {					\
		right(Z,X,8) {				\
			right(Z,X,12){			\
				right(Z,X,14) {		\
					Z = 14;		\
				}			\
				check(Z,X,13)		\
				left(Z,X,12) {		\
					Z = 12;		\
				}			\
			}				\
			check(Z,X,11)			\
			left(Z,X,10) {			\
				right(Z,X,10) {		\
					Z = 10;		\
				}			\
				check(Z,X,9)		\
				left(Z,X,8) {		\
					Z = 8;		\
				}			\
			}				\
		}					\
		check(Z,X,7)				\
		left(Z,X,6) {				\
			right(Z,X,4){			\
				right(Z,X,6) {		\
					Z = 6;		\
				}			\
				check(Z,X,5)		\
				left(Z,X,4) {		\
					Z = 4;		\
				}			\
			}				\
			check(Z,X,3)			\
			left(Z,X,2) {			\
				right(Z,X,2) {		\
					Z = 2;		\
				}			\
				check(Z,X,1)		\
				left(Z,X,0) {		\
					Z = 0;		\
				}			\
			}				\
		}					\
	}

#define GETBIN16(Z,X)				\
	right(Z,X,8) {				\
		right(Z,X,12){			\
			right(Z,X,14) {		\
				Z = 14;		\
				right(Z,X,15) {	\
					Z = 15;	\
				}		\
			}			\
			check(Z,X,13)		\
			left(Z,X,12) {		\
				Z = 12;		\
			}			\
		}				\
		check(Z,X,11)			\
		left(Z,X,10) {			\
			right(Z,X,10) {		\
				Z = 10;		\
			}			\
			check(Z,X,9)		\
			left(Z,X,8) {		\
				Z = 8;		\
			}			\
		}				\
	}					\
	check(Z,X,7)				\
	left(Z,X,6) {				\
		right(Z,X,4){			\
			right(Z,X,6) {		\
				Z = 6;		\
			}			\
			check(Z,X,5)		\
			left(Z,X,4) {		\
				Z = 4;		\
			}			\
		}				\
		check(Z,X,3)			\
		left(Z,X,2) {			\
			right(Z,X,2) {		\
				Z = 2;		\
			}			\
			check(Z,X,1)		\
			left(Z,X,0) {		\
				Z = 0;		\
			}			\
		}				\
	}

#define GETBIN8(Z,X)				\
	right(Z,X,4){				\
		right(Z,X,6) {			\
			Z = 6;			\
			right(Z,X,7) {		\
				Z = 7;		\
			}			\
		}				\
		check(Z,X,5)			\
		left(Z,X,4) {			\
			Z = 4;			\
		}				\
	}					\
	check(Z,X,3)				\
	left(Z,X,2) {				\
		right(Z,X,2) {			\
			Z = 2;			\
		}				\
		check(Z,X,1)			\
		left(Z,X,0) {			\
			Z = 0;			\
		}				\
	}

/* end of binary search */

#define IMPS_CREATE(TYPE,B)						\
do {									\
	uint##B##_t mask, prvmask;					\
	uint##B##_t *restrict im = (uint##B##_t *) imps;		\
	const TYPE *restrict col = (TYPE *) Tloc(b, b->batFirst);	\
	const TYPE *restrict bins = (TYPE *) inbins;			\
	TYPE nil = TYPE##_nil;						\
	prvmask = mask = 0;						\
	new = (IMPS_PAGE/sizeof(TYPE))-1;				\
	for (i = 0; i < b->batCount; i++) {				\
		if (!(i&new) && i>0) {					\
			/* same mask as previous and enough count to add */ \
			if ((prvmask == mask) &&			\
			    (dict[dcnt-1].cnt < (IMPS_MAX_CNT-1))) {	\
				/* not a repeat header */		\
				if (!dict[dcnt-1].repeat) {		\
					/* if compressed */		\
					if (dict[dcnt-1].cnt > 1) {	\
						/* uncompress last */	\
						dict[dcnt-1].cnt--;	\
						dcnt++; /* new header */ \
						dict[dcnt-1].cnt = 1;	\
					}				\
					/* set repeat */		\
					dict[dcnt-1].repeat = 1;	\
				}					\
				/* increase cnt */			\
				dict[dcnt-1].cnt++;			\
			} else { /* new mask (or run out of header count) */ \
				prvmask=mask;				\
				im[icnt] = mask;			\
				icnt++;					\
				if ((dcnt > 0) && !(dict[dcnt-1].repeat) && \
				    (dict[dcnt-1].cnt < (IMPS_MAX_CNT-1))) { \
					dict[dcnt-1].cnt++;		\
				} else {				\
					dict[dcnt].cnt = 1;		\
					dict[dcnt].repeat = 0;		\
					dict[dcnt].flags = 0;		\
					dcnt++;				\
				}					\
			}						\
			/* new mask */					\
			mask = 0;					\
		}							\
		GETBIN##B(bin,col[i]);					\
		mask = IMPSsetBit(B,mask,bin);				\
		if (col[i] != nil) { /* do not count nils */		\
			if (!cnt_bins[bin]++) {				\
				min_bins[bin] = max_bins[bin] = i;	\
			} else {					\
				if (col[i] < col[min_bins[bin]])	\
					min_bins[bin] = i;		\
				if (col[i] > col[max_bins[bin]])	\
					max_bins[bin] = i;		\
			}						\
		}							\
	}								\
	/* one last left */						\
	if (prvmask == mask && dcnt > 0 &&				\
	    (dict[dcnt-1].cnt < (IMPS_MAX_CNT-1))) {			\
		if (!dict[dcnt-1].repeat) {				\
			if (dict[dcnt-1].cnt > 1) {			\
				dict[dcnt-1].cnt--;			\
				dict[dcnt].cnt = 1;			\
				dict[dcnt].flags = 0;			\
				dcnt++;					\
			}						\
			dict[dcnt-1].repeat = 1;			\
		}							\
		dict[dcnt-1].cnt ++;					\
	} else {							\
		im[icnt] = mask;					\
		icnt++;							\
		if ((dcnt > 0) && !(dict[dcnt-1].repeat) &&		\
		    (dict[dcnt-1].cnt < (IMPS_MAX_CNT-1))) {		\
			dict[dcnt-1].cnt++;				\
		} else {						\
			dict[dcnt].cnt = 1;				\
			dict[dcnt].repeat = 0;				\
			dict[dcnt].flags = 0;				\
			dcnt++;						\
		}							\
	}								\
} while (0)

static int
imprints_create(BAT *b, void *inbins, BUN *stats, bte bits,
		void *imps, BUN *impcnt, cchdc_t *dict, BUN *dictcnt)
{
	BUN i;
	BUN dcnt, icnt, new;
	BUN *restrict min_bins = stats;
	BUN *restrict max_bins = min_bins + 64;
	BUN *restrict cnt_bins = max_bins + 64;
	bte bin = 0;
	dcnt = icnt = 0;
	for (i = 0; i < 64; i++)
		cnt_bins[i] = 0;

	switch (ATOMstorage(b->T->type)) {
	case TYPE_bte:
		BINSIZE(bits, IMPS_CREATE, bte);
		break;
	case TYPE_sht:
		BINSIZE(bits, IMPS_CREATE, sht);
		break;
	case TYPE_int:
		BINSIZE(bits, IMPS_CREATE, int);
		break;
	case TYPE_lng:
		BINSIZE(bits, IMPS_CREATE, lng);
		break;
	case TYPE_flt:
		BINSIZE(bits, IMPS_CREATE, flt);
		break;
	case TYPE_dbl:
		BINSIZE(bits, IMPS_CREATE, dbl);
		break;
	default:
		/* should never reach here */
		assert(0);
	}

	*dictcnt = dcnt;
	*impcnt = icnt;

	return 1;
}

#define FILL_HISTOGRAM(TYPE)						\
do {									\
	BUN k;								\
	TYPE *restrict s = (TYPE *) Tloc(smp, smp->batFirst);		\
	TYPE *restrict h = imprints->bins;				\
	if (cnt < 64-1) {						\
		TYPE max = GDK_##TYPE##_max;				\
		for (k = 0; k < cnt; k++)				\
			h[k] = s[k];					\
		while (k < (BUN) imprints->bits)			\
			h[k++] = max;					\
	} else {							\
		double y, ystep = (double) cnt / (64 - 1);		\
		for (k = 0, y = 0; (BUN) y < cnt; y += ystep, k++)	\
			h[k] = s[(BUN) y];				\
		if (k == 64 - 1) /* there is one left */		\
			h[k] = s[cnt - 1];				\
	}								\
} while (0)

BAT *
BATimprints(BAT *b)
{
	BAT *o = NULL;
	Imprints *imprints;
	lng t0 = 0, t1 = 0;

	assert(BAThdense(b));	/* assert void head */

	/* we only create imprints for types that look like types we know */
	if (b->ttype != ATOMstorage(b->ttype) &&
	    (ATOMnilptr(b->ttype) != ATOMnilptr(ATOMstorage(b->ttype)) ||
	     BATatoms[b->ttype].atomCmp != BATatoms[ATOMstorage(b->ttype)].atomCmp))
		return NULL;	/* doesn't look enough like base type */

	switch (ATOMstorage(b->T->type)) {
	case TYPE_bte:
	case TYPE_sht:
	case TYPE_int:
	case TYPE_lng:
	case TYPE_flt:
	case TYPE_dbl:
		break;
	default:		/* type not supported */
		return NULL;	/* do nothing */
	}

	BATcheck(b, "BATimprints");

	if (VIEWtparent(b)) {
		bat p = VIEWtparent(b);
		o = b;
		b = BATmirror(BATdescriptor(p));
	}
	if (b->batFirst > 0) {
		/* no imprints if batFirst is not 0
		 * this shouldn't really happen */
		if (o)
			BBPunfix(b->batCacheid);
		return NULL;
	}

	MT_lock_set(&GDKimprintsLock(abs(b->batCacheid)), "BATimprints");
	t0= GDKusec();
	if (b->T->imprints == NULL) {
		BAT *smp, *s;
		BUN cnt;
		str nme = BBP_physical(b->batCacheid);
		size_t pages;
		int fd;

		ALGODEBUG fprintf(stderr, "#BATimprints(b=%s#" BUNFMT ") %s: "
				  "created imprints\n", BATgetId(b),
				  BATcount(b), b->T->heap.filename);

		imprints = (Imprints *) GDKzalloc(sizeof(Imprints));
		if (imprints == NULL) {
			GDKerror("#BATimprints: memory allocation error.\n");
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			return NULL;
		}
		imprints->imprints = GDKzalloc(sizeof(Heap));
		if (imprints->imprints == NULL ||
		    (imprints->imprints->filename =
		     GDKmalloc(strlen(nme) + 12)) == NULL) {
			GDKfree(imprints->imprints);
			GDKfree(imprints);
			GDKerror("#BATimprints: memory allocation error.\n");
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			return NULL;
		}
		sprintf(imprints->imprints->filename, "%s.%cimprints", nme,
			b->batCacheid > 0 ? 't' : 'h');
		pages = (((size_t) BATcount(b) * b->T->width) + IMPS_PAGE - 1) / IMPS_PAGE;
		imprints->imprints->farmid = BBPselectfarm(PERSISTENT, b->ttype,
							   imprintsheap);
		if ((fd = GDKfdlocate(imprints->imprints->farmid, nme, "rb",
				      b->batCacheid > 0 ? "timprints" : "himprints")) >= 0) {
			size_t hdata[4];
			struct stat st;
			if (read(fd, hdata, sizeof(hdata)) == sizeof(hdata) &&
			    hdata[0] & ((size_t) 1 << 16) &&
			    ((hdata[0] & 0xFF00) >> 8) == IMPRINTS_VERSION &&
			    hdata[3] == (size_t) BATcount(b) &&
			    fstat(fd, &st) == 0 &&
			    st.st_size >= (off_t) (imprints->imprints->size =
						   imprints->imprints->free =
						   64 * b->T->width +
						   64 * 2 * SIZEOF_OID +
						   64 * SIZEOF_BUN +
						   pages * ((bte) hdata[0] / 8) +
						   hdata[2] * sizeof(cchdc_t) +
						   sizeof(uint64_t) /* padding for alignment */
						   + 4 * SIZEOF_SIZE_T) &&
			    HEAPload(imprints->imprints, nme, b->batCacheid > 0 ? "timprints" : "himprints", 0) >= 0) {
				/* usable */
				imprints->bits = (bte) (hdata[0] & 0xFF);
				imprints->impcnt = (BUN) hdata[1];
				imprints->dictcnt = (BUN) hdata[2];
				imprints->bins = imprints->imprints->base + 4 * SIZEOF_SIZE_T;
				imprints->stats = (BUN *) ((char *) imprints->bins + 64 * b->T->width);
				imprints->imps = (void *) (imprints->stats + 64 * 3);
				imprints->dict = (void *) ((uintptr_t) ((char *) imprints->imps + pages * (imprints->bits / 8) + sizeof(uint64_t)) & ~(sizeof(uint64_t) - 1));
				b->T->imprints = imprints;
				close(fd);
				goto do_return;
			}
			close(fd);
			/* file exists, but can't be used: delete it */
			GDKunlink(imprints->imprints->farmid, BATDIR, nme,
				  b->batCacheid > 0 ? "timprints" : "himprints");
		}

#define SMP_SIZE 2048
		s = BATsample(b, SMP_SIZE);
		if (s == NULL) {
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			GDKfree(imprints);
			return NULL;
		}
		smp = BATsubunique(b, s);
		BBPunfix(s->batCacheid);
		if (smp == NULL) {
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			GDKfree(imprints);
			return NULL;
		}
		s = BATproject(smp, b);
		BBPunfix(smp->batCacheid);
		if (s == NULL) {
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			GDKfree(imprints);
			return NULL;
		}
		s->tkey = 1;	/* we know is unique on tail now */
		if (BATsubsort(&smp, NULL, NULL, s, NULL, NULL, 0, 0) == GDK_FAIL) {
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			BBPunfix(s->batCacheid);
			GDKfree(imprints);
			return NULL;
		}
		BBPunfix(s->batCacheid);
		/* smp now is ordered and unique on tail */
		assert(smp->tkey && smp->tsorted);
		cnt = BATcount(smp);
		imprints->bits = 64;
		if (cnt < 32)
			imprints->bits = 32;
		if (cnt < 16)
			imprints->bits = 16;
		if (cnt < 8)
			imprints->bits = 8;

		/* The heap we create here consists of four parts:
		 * bins, max 64 entries with bin boundaries, domain of b;
		 * stats, min/max/count for each bin, min/max are oid, and count BUN;
		 * imps, max one entry per "page", entry is "bits" wide;
		 * dict, max two entries per three "pages".
		 * In addition, we add some housekeeping entries at
		 * the start so that we can determine whether we can
		 * trust the imprints when encountered on startup (including
		 * a version number -- CURRENT VERSION is 2). */
		if (HEAPalloc(imprints->imprints,
			      64 * b->T->width +
			      64 * 2 * SIZEOF_OID +
			      64 * SIZEOF_BUN +
			      pages * (imprints->bits / 8) +
			      pages * sizeof(cchdc_t) +
			      sizeof(uint64_t) /* padding for alignment */
			      + 4 * SIZEOF_SIZE_T, /* extra info */
			      1) < 0) {
			GDKfree(imprints->imprints);
			GDKfree(imprints);
			GDKerror("#BATimprints: memory allocation error");
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			return NULL;
		}
		imprints->bins = imprints->imprints->base + 4 * SIZEOF_SIZE_T;
		imprints->stats = (BUN *) ((char *) imprints->bins + 64 * b->T->width);
		imprints->imps = (void *) (imprints->stats + 64 * 3);
		imprints->dict = (void *) ((uintptr_t) ((char *) imprints->imps + pages * (imprints->bits / 8) + sizeof(uint64_t)) & ~(sizeof(uint64_t) - 1));

		switch (ATOMstorage(b->T->type)) {
		case TYPE_bte:
			FILL_HISTOGRAM(bte);
			break;
		case TYPE_sht:
			FILL_HISTOGRAM(sht);
			break;
		case TYPE_int:
			FILL_HISTOGRAM(int);
			break;
		case TYPE_lng:
			FILL_HISTOGRAM(lng);
			break;
		case TYPE_flt:
			FILL_HISTOGRAM(flt);
			break;
		case TYPE_dbl:
			FILL_HISTOGRAM(dbl);
			break;
		default:
			/* should never reach here */
			assert(0);
		}

		BBPunfix(smp->batCacheid);

		if (!imprints_create(b,
				     imprints->bins,
				     imprints->stats,
				     imprints->bits,
				     imprints->imps,
				     &imprints->impcnt,
				     imprints->dict,
				     &imprints->dictcnt)) {
			GDKerror("#BATimprints: failed to create imprints");
			HEAPfree(imprints->imprints, 1);
			GDKfree(imprints->imprints);
			GDKfree(imprints);
			MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)),
				      "BATimprints");
			return NULL;
		}
		assert(imprints->impcnt <= pages);
		assert(imprints->dictcnt <= pages);
		imprints->imprints->free = (size_t) ((char *) ((cchdc_t *) imprints->dict + imprints->dictcnt) - imprints->imprints->base);
		/* add info to heap for when they become persistent */
		((size_t *) imprints->imprints->base)[0] = (size_t) (imprints->bits);
		((size_t *) imprints->imprints->base)[1] = (size_t) imprints->impcnt;
		((size_t *) imprints->imprints->base)[2] = (size_t) imprints->dictcnt;
		((size_t *) imprints->imprints->base)[3] = (size_t) BATcount(b);
		if (HEAPsave(imprints->imprints, nme, b->batCacheid > 0 ? "timprints" : "himprints") == 0 &&
		    (fd = GDKfdlocate(imprints->imprints->farmid, nme, "rb+",
				      b->batCacheid > 0 ? "timprints" : "himprints")) >= 0) {
			/* add version number */
			((size_t *) imprints->imprints->base)[0] |= (size_t) IMPRINTS_VERSION << 8;
			/* sync-on-disk checked bit */
			((size_t *) imprints->imprints->base)[0] |= (size_t) 1 << 16;
			if (write(fd, imprints->imprints->base, sizeof(size_t)) < 0)
				perror("write imprints");
#if defined(NATIVE_WIN32)
			_commit(fd);
#elif defined(HAVE_FDATASYNC)
			fdatasync(fd);
#elif defined(HAVE_FSYNC)
			fsync(fd);
#endif
			close(fd);
		}
		b->T->imprints = imprints;
	}

	t1 = GDKusec();
	ALGODEBUG fprintf(stderr, "#BATimprints: imprints construction " LLFMT " usec\n", t1 - t0);

  do_return:
	MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)), "BATimprints");

	if (o != NULL) {
		o->T->imprints = NULL;	/* views always keep null pointer and
					   need to obtain the latest imprint
					   from the parent at query time */
		BBPunfix(b->batCacheid);
		b = o;
	}
	assert(b->batCapacity >= BATcount(b));
	return b;
}

#define getbin(TYPE,B) GETBIN##B(ret, *(TYPE *)v);

int
IMPSgetbin(int tpe, bte bits, const char *restrict inbins, const void *restrict v)
{
	int ret = -1;

	switch (tpe) {
	case TYPE_bte:
	{
		const bte *restrict bins = (bte *) inbins;
		BINSIZE(bits, getbin, bte);
	}
		break;
	case TYPE_sht:
	{
		const sht *restrict bins = (sht *) inbins;
		BINSIZE(bits, getbin, sht);
	}
		break;
	case TYPE_int:
	{
		const int *restrict bins = (int *) inbins;
		BINSIZE(bits, getbin, int);
	}
		break;
	case TYPE_lng:
	{
		const lng *restrict bins = (lng *) inbins;
		BINSIZE(bits, getbin, lng);
	}
		break;
	case TYPE_flt:
	{
		const flt *restrict bins = (flt *) inbins;
		BINSIZE(bits, getbin, flt);
	}
		break;
	case TYPE_dbl:
	{
		const dbl *restrict bins = (dbl *) inbins;
		BINSIZE(bits, getbin, dbl);
	}
		break;
	default:
		assert(0);
		(void) inbins;
		break;
	}
	return ret;
}

lng
IMPSimprintsize(BAT *b)
{
	lng sz = 0;
	if (b->T->imprints) {
		sz = b->T->imprints->impcnt * b->T->imprints->bits / 8;
		sz += b->T->imprints->dictcnt * sizeof(cchdc_t);
	}
	return sz;
}

static void
IMPSremove(BAT *b)
{
	Imprints *imprints;

	assert(BAThdense(b));	/* assert void head */
	assert(b->T->imprints != NULL);
	assert(!VIEWtparent(b));

	MT_lock_set(&GDKimprintsLock(abs(b->batCacheid)), "BATimprints");
	if ((imprints = b->T->imprints) != NULL) {
		b->T->imprints = NULL;

		if (HEAPdelete(imprints->imprints, BBP_physical(b->batCacheid),
			       b->batCacheid > 0 ? "timprints" : "himprints"))
			IODEBUG fprintf(stderr, "#IMPSremove(%s): imprints heap\n", BATgetId(b));

		GDKfree(imprints->imprints);
		GDKfree(imprints);
	}

	MT_lock_unset(&GDKimprintsLock(abs(b->batCacheid)), "BATimprints");

	return;
}

void
IMPSdestroy(BAT *b)
{
	if (b) {
		if (b->T->imprints != NULL && !VIEWtparent(b)) {
			IMPSremove(b);
		}

		if (b->H->imprints != NULL && !VIEWhparent(b)) {
			IMPSremove(BATmirror(b));
		}
	}

	return;
}

#ifndef NDEBUG
/* never called, useful for debugging */

#define IMPSPRNTMASK(T, B)						\
	do {								\
		uint##B##_t *restrict im = (uint##B##_t *) imprints->imps; \
		for (j = 0; j < imprints->bits; j++)			\
			s[j] = IMPSisSet(B, im[icnt], j) ? 'x' : '.';	\
		s[j] = '\0';						\
	} while (0)

void
IMPSprint(BAT *b)
{
	Imprints *imprints;
	cchdc_t *restrict d;
	char s[65];		/* max number of bits + 1 */
	BUN icnt, dcnt, l, pages;
	BUN *restrict min_bins, *restrict max_bins;
	BUN *restrict cnt_bins;
	bte j;
	int i;

	if (!BATimprints(b))
		return;
	imprints = b->T->imprints;
	d = (cchdc_t *) imprints->dict;
	min_bins = imprints->stats;
	max_bins = min_bins + 64;
	cnt_bins = max_bins + 64;

	fprintf(stderr,
		"bits = %d, impcnt = " BUNFMT ", dictcnt = " BUNFMT "\n",
		imprints->bits, imprints->impcnt, imprints->dictcnt);
	fprintf(stderr,"MIN = ");
	for (i = 0; i < imprints->bits; i++) {
		fprintf(stderr, "[ " BUNFMT " ] ", min_bins[i]);
	}
	fprintf(stderr,"\n");
	fprintf(stderr,"MAX = ");
	for (i = 0; i < imprints->bits; i++) {
		fprintf(stderr, "[ " BUNFMT " ] ", max_bins[i]);
	}
	fprintf(stderr,"\n");
	fprintf(stderr,"COUNT = ");
	for (i = 0; i < imprints->bits; i++) {
		fprintf(stderr, "[ " BUNFMT " ] ", cnt_bins[i]);
	}
	fprintf(stderr,"\n");
	for (dcnt = 0, icnt = 0, pages = 1; dcnt < imprints->dictcnt; dcnt++) {
		if (d[dcnt].repeat) {
			BINSIZE(imprints->bits, IMPSPRNTMASK, " ");
			pages += d[dcnt].cnt;
			fprintf(stderr, "[ " BUNFMT " ]r %s\n", pages, s);
			icnt++;
		} else {
			l = icnt + d[dcnt].cnt;
			for (; icnt < l; icnt++) {
				BINSIZE(imprints->bits, IMPSPRNTMASK, " ");
				fprintf(stderr, "[ " BUNFMT " ]  %s\n",
					pages++, s);
			}
		}
	}
}
#endif
