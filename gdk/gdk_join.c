/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_private.h"
#include "gdk_calc_private.h"

/*
 * All "sub" join variants produce some sort of join on two input
 * BATs, optionally subject to up to two candidate lists.  Only values
 * in the input BATs that are mentioned in the associated candidate
 * list (if provided) are eligible.  They all return two output BATs
 * in the first two arguments.  The join operations differ in the way
 * in which tuples from the two inputs are matched.
 *
 * All inputs BATs must be dense headed, the output BATs will also be
 * dense headed.  The outputs consist of two aligned BATs (i.e. same
 * length and same seqbase in the head column (0@0)) that contain in
 * their tails the OIDs of the input BATs that match.  The candidate
 * lists, if given, contain in their tail the OIDs of the associated
 * input BAT which must be considered for matching.  The input BATs
 * must have the same tail type.
 *
 * All functions also have a parameter nil_matches which indicates
 * whether NIL must be considered an ordinary value that can match, or
 * whether NIL must be considered to never match.
 *
 * The join functions that are provided here are:
 * BATsubjoin
 *	normal equi-join
 * BATsubleftjoin
 *	normal equi-join, but the left output is sorted
 * BATsubleftfetchjoin
 *	normal equi-join, but the left output is sorted, and all
 *	values in the left input must match at least one value in the
 *	right input
 * BATsubouterjoin
 *	equi-join, but the left output is sorted, and if there is no
 *	match for a value in the left input, there is still an output
 *	with NIL in the right output
 * BATsubsemijoin
 *	equi-join, but the left output is sorted, and if there are
 *	multiple matches, only one is returned (i.e., the left output
 *	is also key)
 * BATsubthetajoin
 *	theta-join: an extra operator must be provided encoded as an
 *	integer (macros JOIN_EQ, JOIN_NE, JOIN_LT, JOIN_LE, JOIN_GT,
 *	JOIN_GE); value match if the left input has the given
 *	relationship with the right input; order of the outputs is not
 *	guaranteed
 * BATsubbandjoin
 *	band-join: two extra input values (c1, c2) must be provided as
 *	well as Booleans (li, hi) that indicate whether the value
 *	ranges are inclusive or not; values in the left and right
 *	inputs match if right - c1 <[=] left <[=] right + c2; if c1 or
 *	c2 is NIL, there are no matches
 * BATsubrangejoin
 *	range-join: the right input consists of two aligned BATs,
 *	values match if the left value is between two corresponding
 *	right values; two extra Boolean parameters, li and hi,
 *	indicate whether equal values match
 */

/* Perform a bunch of sanity checks on the inputs to a join. */
static gdk_return
joinparamcheck(BAT *l, BAT *r1, BAT *r2, BAT *sl, BAT *sr, const char *func)
{
	if (!BAThdense(l) || !BAThdense(r1) || (r2 && !BAThdense(r2))) {
		GDKerror("%s: inputs must have dense head.\n", func);
		return GDK_FAIL;
	}
	if (ATOMtype(l->ttype) != ATOMtype(r1->ttype) ||
	    (r2 && ATOMtype(l->ttype) != ATOMtype(r2->ttype))) {
		GDKerror("%s: inputs not compatible.\n", func);
		return GDK_FAIL;
	}
	if (r2 &&
	    (BATcount(r1) != BATcount(r2) || r1->hseqbase != r2->hseqbase)) {
		GDKerror("%s: right inputs not aligned.\n", func);
		return GDK_FAIL;
	}
	if ((sl && !BAThdense(sl)) || (sr && !BAThdense(sr))) {
		GDKerror("%s: candidate lists must have dense head.\n", func);
		return GDK_FAIL;
	}
	if ((sl && ATOMtype(sl->ttype) != TYPE_oid) ||
	    (sr && ATOMtype(sr->ttype) != TYPE_oid)) {
		GDKerror("%s: candidate lists must have OID tail.\n", func);
		return GDK_FAIL;
	}
	if ((sl && !BATtordered(sl)) ||
	    (sr && !BATtordered(sr))) {
		GDKerror("%s: candidate lists must be sorted.\n", func);
		return GDK_FAIL;
	}
	if ((sl && !BATtkey(sl)) ||
	    (sr && !BATtkey(sr))) {
		GDKerror("%s: candidate lists must be unique.\n", func);
		return GDK_FAIL;
	}
	return GDK_SUCCEED;
}

/* Create the result bats for a join. */
static BUN
joininitresults(BAT **r1p, BAT **r2p, BUN lcnt, BUN rcnt, int lkey, int rkey, int semi, int nil_on_miss, BUN estimate, const char *func)
{
	BAT *r1, *r2;
	BUN maxsize, size;

	lkey |= lcnt <= 1;
	rkey |= rcnt <= 1;

	if (rkey | semi) {
		/* each entry left matches at most one on right, in
		 * case nil_on_miss is also set, each entry matches
		 * exactly one */
		maxsize = lcnt;
	} else if (lkey) {
		/* each entry on right is matched at most once */
		if (nil_on_miss) {
			/* one entry left could match all right, and
			 * all other entries left match nil */
			maxsize = lcnt + rcnt - 1;
		} else {
			maxsize = rcnt;
		}
	} else {
		/* in the worst case we have a full cross product */
		if (lcnt == 0 || rcnt == 0)
			maxsize = nil_on_miss ? lcnt : 0;
		else if (BUN_MAX / lcnt >= rcnt)
			maxsize = BUN_MAX;
		else
			maxsize = lcnt * rcnt;
	}
	size = estimate == BUN_NONE ? lcnt : estimate;
	if (size > maxsize)
		size = maxsize;

	r1 = BATnew(TYPE_void, TYPE_oid, size, TRANSIENT);
	r2 = BATnew(TYPE_void, TYPE_oid, size, TRANSIENT);
	if (r1 == NULL || r2 == NULL) {
		BBPreclaim(r1);
		BBPreclaim(r2);
		*r1p = *r2p = NULL;
		GDKerror("%s: cannot create output BATs.\n", func);
		return BUN_NONE;
	}
	BATseqbase(r1, 0);
	BATseqbase(r2, 0);
	r1->T->nil = 0;
	r1->T->nonil = 1;
	r1->tkey = 1;
	r1->tsorted = 1;
	r1->trevsorted = 1;
	r1->tdense = 1;
	r2->T->nil = 0;
	r2->T->nonil = 1;
	r2->tkey = 1;
	r2->tsorted = 1;
	r2->trevsorted = 1;
	r2->tdense = 1;
	*r1p = r1;
	*r2p = r2;
	return maxsize;
}

#define VALUE(s, x)	(s##vars ? \
			 s##vars + VarHeapVal(s##vals, (x), s##width) : \
			 s##vals + ((x) * s##width))
#define FVALUE(s, x)	(s##vals + ((x) * s##width))

#define BINSEARCHFUNC(TYPE)						\
static inline BUN							\
binsearch_##TYPE(const oid *rcand, oid offset, const TYPE *rvals,	\
		 BUN lo, BUN hi, const void *vp, int ordering, int last) \
{									\
	BUN mid;							\
	TYPE v, x;							\
									\
	assert(ordering == 1 || ordering == -1);			\
	assert(lo <= hi);						\
									\
	v = *(const TYPE *) vp;		/* value we're searching for */	\
									\
	if (ordering > 0) {						\
		if (rcand) {						\
			if (last) {					\
				if ((x = rvals[rcand[lo] - offset]) > v) \
					return lo;			\
				if ((x = rvals[rcand[hi] - offset]) < v || \
				    x == v)				\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo <= v < value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[rcand[mid] - offset] > v) \
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			} else {					\
				if ((x = rvals[rcand[lo] - offset]) > v || \
				    x == v)				\
					return lo;			\
				if ((x = rvals[rcand[hi] - offset]) < v) \
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo < v <= value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[rcand[mid] - offset] >= v) \
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			}						\
		} else {						\
			if (last) {					\
				if ((x = rvals[lo]) > v)		\
					return lo;			\
				if ((x = rvals[hi]) < v || x == v)	\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo <= v < value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[mid] > v)		\
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			} else {					\
				if ((x = rvals[lo]) > v || x == v)	\
					return lo;			\
				if ((x = rvals[hi]) < v)		\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo < v <= value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[mid] >= v)		\
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			}						\
		}							\
	} else {							\
		if (rcand) {						\
			if (last) {					\
				if ((x = rvals[rcand[lo] - offset]) < v) \
					return lo;			\
				if ((x = rvals[rcand[hi] - offset]) > v || \
				    x == v)				\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo >= v > value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[rcand[mid] - offset] < v) \
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			} else {					\
				if ((x = rvals[rcand[lo] - offset]) < v || \
				    x == v)				\
					return lo;			\
				if ((x = rvals[rcand[hi] - offset]) > v) \
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo > v >= value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[rcand[mid] - offset] <= v) \
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			}						\
		} else {						\
			if (last) {					\
				if ((x = rvals[lo]) < v)		\
					return lo;			\
				if ((x = rvals[hi]) > v || x == v)	\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo >= v > value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[mid] < v)		\
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			} else {					\
				if ((x = rvals[lo]) < v || x == v)	\
					return lo;			\
				if ((x = rvals[hi]) > v)		\
					return hi + 1;			\
									\
				/* loop invariant: */			\
				/* value@lo > v >= value@hi */		\
				while (hi - lo > 1) {			\
					mid = (hi + lo) / 2;		\
					if (rvals[mid] <= v)		\
						hi = mid;		\
					else				\
						lo = mid;		\
				}					\
			}						\
		}							\
	}								\
	return hi;							\
}

BINSEARCHFUNC(bte)
BINSEARCHFUNC(sht)
BINSEARCHFUNC(int)
BINSEARCHFUNC(lng)
#ifdef HAVE_HGE
BINSEARCHFUNC(hge)
#endif
BINSEARCHFUNC(flt)
BINSEARCHFUNC(dbl)
#if SIZEOF_OID == SIZEOF_INT
#define binsearch_oid(rcand, offset, rvals, lo, hi, vp, ordering, last) binsearch_int(rcand, offset, (const int *) rvals, lo, hi, (const int *) (vp), ordering, last)
#endif
#if SIZEOF_OID == SIZEOF_LNG
#define binsearch_oid(rcand, offset, rvals, lo, hi, vp, ordering, last) binsearch_lng(rcand, offset, (const lng *) rvals, lo, hi, (const lng *) (vp), ordering, last)
#endif

/* Do a binary search for the first/last occurrence of v between lo and hi
 * (lo inclusive, hi not inclusive) in rvals/rvars.
 * If last is set, return the index of the first value > v; if last is
 * not set, return the index of the first value >= v.
 * If ordering is -1, the values are sorted in reverse order and hence
 * all comparisons are reversed.
 */
static BUN
binsearch(const oid *rcand, oid offset,
	  int type, const char *rvals, const char *rvars,
	  int rwidth, BUN lo, BUN hi, const char *v,
	  int (*cmp)(const void *, const void *), int ordering, int last)
{
	BUN mid;
	int c;

	assert(ordering == 1 || ordering == -1);
	assert(lo < hi);

	--hi;			/* now hi is inclusive */

	switch (type) {
	case TYPE_bte:
		return binsearch_bte(rcand, offset, (const bte *) rvals,
				     lo, hi, (const bte *) v, ordering, last);
	case TYPE_sht:
		return binsearch_sht(rcand, offset, (const sht *) rvals,
				     lo, hi, (const sht *) v, ordering, last);
	case TYPE_int:
#if SIZEOF_WRD == SIZEOF_INT
	case TYPE_wrd:
#endif
#if SIZEOF_OID == SIZEOF_INT
	case TYPE_oid:
#endif
		return binsearch_int(rcand, offset, (const int *) rvals,
				     lo, hi, (const int *) v, ordering, last);
	case TYPE_lng:
#if SIZEOF_WRD == SIZEOF_LNG
	case TYPE_wrd:
#endif
#if SIZEOF_OID == SIZEOF_LNG
	case TYPE_oid:
#endif
		return binsearch_lng(rcand, offset, (const lng *) rvals,
				     lo, hi, (const lng *) v, ordering, last);
#ifdef HAVE_HGE
	case TYPE_hge:
		return binsearch_hge(rcand, offset, (const hge *) rvals,
				     lo, hi, (const hge *) v, ordering, last);
#endif
	case TYPE_flt:
		return binsearch_flt(rcand, offset, (const flt *) rvals,
				     lo, hi, (const flt *) v, ordering, last);
	case TYPE_dbl:
		return binsearch_dbl(rcand, offset, (const dbl *) rvals,
				     lo, hi, (const dbl *) v, ordering, last);
	}

	if ((c = ordering * cmp(VALUE(r, rcand ? rcand[lo] - offset : lo), v)) > 0 ||
	    (!last && c == 0))
		return lo;
	if ((c = ordering * cmp(VALUE(r, rcand ? rcand[hi] - offset : hi), v)) < 0 ||
	    (last && c == 0))
		return hi + 1;

	/* loop invariant:
	 * last ? value@lo <= v < value@hi : value@lo < v <= value@hi
	 *
	 * This version does some more work in the inner loop than the
	 * type-expanded versions (ordering and rcand checks) but is
	 * slow due to the function call and the needed check for
	 * rvars (in VALUE()) already, so we're beyond caring. */
	while (hi - lo > 1) {
		mid = (hi + lo) / 2;
		if ((c = ordering * cmp(VALUE(r, rcand ? rcand[mid] - offset : mid), v)) > 0 ||
		    (!last && c == 0))
			hi = mid;
		else
			lo = mid;
	}
	return hi;
}

#define APPEND(b, o)		(((oid *) b->T->heap.base)[b->batFirst + b->batCount++] = (o))

static gdk_return
nomatch(BAT *r1, BAT *r2, BAT *l, BAT *r, BUN lstart, BUN lend,
	const oid *lcand, const oid *lcandend,
	int nil_on_miss, int must_match, const char *func, lng t0)
{
	BUN cnt;

	r1->tkey = 1;
	r1->T->nokey[0] = r1->T->nokey[1] = 0;
	r1->tsorted = 1;
	r1->T->nosorted = 0;
	r1->tdense = 0;
	r1->T->nodense = 0;
	r1->T->nil = 0;
	r1->T->nonil = 1;
	r2->tkey = 1;
	r2->T->nokey[0] = r2->T->nokey[1] = 0;
	r2->tsorted = 1;
	r2->T->nosorted = 0;
	r2->tdense = 0;
	r2->T->nodense = 0;
	r2->T->nil = 0;
	r2->T->nonil = 1;
	if (lstart == lend || (!must_match && !nil_on_miss)) {
		virtualize(r1);
		r1->trevsorted = 1;
		r1->T->norevsorted = 0;
		virtualize(r2);
		r2->trevsorted = 1;
		r2->T->norevsorted = 0;
		return GDK_SUCCEED;
	}
	if (must_match) {
		GDKerror("%s(%s,%s) does not hit always => can't use fetchjoin.\n",
			 func, BATgetId(l), BATgetId(r));
		goto bailout;
	}
	if (lcand) {
		cnt = (BUN) (lcandend - lcand);
		if (BATextend(r1, cnt) != GDK_SUCCEED)
			goto bailout;
		memcpy(Tloc(r1, BUNfirst(r1)), lcand, (lcandend - lcand) * sizeof(oid));
		BATsetcount(r1, cnt);
	} else {
		cnt = lend - lstart;
		HEAPfree(&r1->T->heap, 1);
		r1->ttype = TYPE_void;
		r1->tvarsized = 1;
		r1->T->width = 0;
		r1->T->shift = 0;
		if (BATextend(r1, cnt) != GDK_SUCCEED)
			goto bailout;
		BATsetcount(r1, cnt);
		BATseqbase(BATmirror(r1), lstart + l->hseqbase);
	}
	r1->T->norevsorted = !(r1->trevsorted = BATcount(r1) <= 1);
	HEAPfree(&r2->T->heap, 1);
	r2->ttype = TYPE_void;
	r2->tvarsized = 1;
	r2->T->width = 0;
	r2->T->shift = 0;
	if (BATextend(r2, cnt) != GDK_SUCCEED)
		goto bailout;
	BATsetcount(r2, cnt);
	BATseqbase(BATmirror(r2), oid_nil);
	ALGODEBUG fprintf(stderr,
			  "#%s(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us -- nomatch\n",
			  func,
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;

  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

static gdk_return
mergejoin_void(BAT *r1, BAT *r2, BAT *l, BAT *r, BAT *sl, BAT *sr,
	       int nil_on_miss, int must_match, lng t0)
{
	oid lo, hi;
	BUN cnt, i;
	const oid *lvals;
	oid o, seq;

	/* r has a dense tail, and if there is a candidate list, it
	 * too is dense.  This means we don't have to do any searches,
	 * we only need to compare ranges to know whether a value from
	 * l has a match in r */
	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(ATOMtype(l->ttype) == ATOMtype(r->ttype));
	assert(r->tsorted || r->trevsorted);
	assert(sl == NULL || sl->tsorted);
	assert(sr == NULL || sr->tsorted);
	assert(!nil_on_miss || !must_match); /* can't have both */
	assert(BATcount(l) > 0);
	assert(BATtdense(r));
	assert(BATcount(r) > 0);
	/* some output properties are easy: r is dense and hence key,
	 * so r1 is key; r1 is sorted; r1 does not contain nils */
	r1->tsorted = 1;
	r1->tkey = 1;
	r1->T->nil = 0;
	r1->T->nonil = 1;
	/* figure out range [lo..hi) of values in r that we need to match */
	lo = r->tseqbase;
	hi = lo + BATcount(r);
	if (sr) {
		assert(BAThdense(sr));
		assert(BATtdense(sr));
		assert(BATcount(sr) > 0);
		/* restrict [lo..hi) range further using candidate
		 * list */
		if (sr->tseqbase > r->hseqbase)
			lo += sr->tseqbase - r->hseqbase;
		if (sr->tseqbase + BATcount(sr) < r->hseqbase + BATcount(r))
			hi -= r->hseqbase + BATcount(r) - sr->tseqbase - BATcount(sr);
	}
	/* at this point, the matchable values in r are [lo..hi) */
	assert(BAThdense(l));
	if (BATtdense(l)) {
		/* if l has a dense tail, we can further restrict the
		 * [lo..hi) range to values in l that match with
		 * values in r */
		i = hi - lo;	/* remember these for nil_on_miss case below */
		o = lo;
		if (l->tseqbase > lo)
			lo = l->tseqbase;
		if (l->tseqbase + BATcount(l) < hi)
			hi = l->tseqbase + BATcount(l);
		if (sl == NULL || BATtdense(sl)) {
			/* l has a dense tail, and so does the left
			 * candidate list (if it exists); this means
			 * we don't have to actually look at any
			 * values in l: we can just do some
			 * arithmetic; it also means that r1 will be
			 * dense, and if nil_on_miss is not set, or if
			 * all values in l match, r2 will too */
			seq = l->hseqbase;
			cnt = BATcount(l);
			if (sl) {
				/* still further restrict lo and hi
				 * based on the left candidate list */
				if (sl->tseqbase > l->hseqbase + (lo - l->tseqbase))
					lo += sl->tseqbase - (l->hseqbase + (lo - l->tseqbase));
				if (sl->tseqbase + BATcount(sl) < l->hseqbase + (hi - l->tseqbase))
					hi -= l->hseqbase + (hi - l->tseqbase) - sl->tseqbase - BATcount(sl);
				if (sl->tseqbase > l->hseqbase) {
					cnt -= sl->tseqbase - l->hseqbase;
					seq = sl->tseqbase;
				}
				if (sl->tseqbase + BATcount(sl) < l->hseqbase + BATcount(l))
					cnt -= l->hseqbase + BATcount(l) - sl->tseqbase - BATcount(sl);
			}

			if (hi <= lo)
				return nomatch(r1, r2, l, r,
					       seq - l->hseqbase,
					       seq + cnt - l->hseqbase,
					       NULL, NULL, nil_on_miss,
					       must_match,
					       "mergejoin_void", t0);
			if (must_match && hi - lo < cnt) {
				GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
				goto bailout;
			}

			/* at this point, the matched values in l and
			 * r (taking candidate lists into account) are
			 * [lo..hi) which we can translate back to the
			 * respective head values that we can store in
			 * r1 and r2; note that r1 will have a dense
			 * tail since all values in l will match
			 * something (even if nil if nil_on_miss is
			 * set) */
			r1->tdense = 1;
			HEAPfree(&r1->T->heap, 1);
			r1->ttype = TYPE_void;
			r1->tvarsized = 1;
			r1->T->width = 0;
			r1->T->shift = 0;
			if (nil_on_miss && hi - lo < cnt) {
				/* we need to fill in nils in r2 for
				 * missing values */
				BATsetcount(r1, cnt);
				BATseqbase(BATmirror(r1), seq);
				if (BATextend(r2, cnt) != GDK_SUCCEED)
					goto bailout;
				for (o = seq - l->hseqbase + l->tseqbase; o < lo; o++)
					APPEND(r2, oid_nil);
				if (BATcount(r2) > 0 && hi - lo > 0)
					r2->T->norevsorted = BUNlast(r2);
				else if (hi - lo > 1)
					r2->T->norevsorted = BUNlast(r2) + 1;
				for (o = lo; o < hi; o++)
					APPEND(r2, o - r->tseqbase + r->hseqbase);
				if (BATcount(r2) > 0 && BATcount(r2) < cnt) {
					/* nils are smaller than
					 * non-nils, so so far r2 is
					 * sorted, it becomes unsorted
					 * if more nils are to
					 * follow */
					r2->T->nosorted = BUNlast(r2);
				}
				for (o = BATcount(r2); o < cnt; o++)
					APPEND(r2, oid_nil);
				BATsetcount(r2, BATcount(r2));
				r2->tsorted = r2->T->nosorted == 0;
				r2->trevsorted = r2->T->norevsorted == 0;
				r2->T->nonil = 0;
				r2->T->nil = 1;
				r2->tdense = 0;
				r2->tseqbase = oid_nil;
				/* (hi - lo) different OIDs in r2,
				 * plus one for nil */
				r2->tkey = hi - lo + 1 == cnt;
				ALGODEBUG fprintf(stderr, "#mergejoin_void(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
						  BATgetId(l), BATgetId(r),
						  BATgetId(r1), BATcount(r1),
						  r1->tsorted ? "-sorted" : "",
						  r1->trevsorted ? "-revsorted" : "",
						  r1->tkey & 1 ? "-key" : "",
						  BATgetId(r2), BATcount(r2),
						  r2->tsorted ? "-sorted" : "",
						  r2->trevsorted ? "-revsorted" : "",
						  r2->tkey & 1 ? "-key" : "",
						  GDKusec() - t0);
				return GDK_SUCCEED;
			}
			BATsetcount(r1, hi - lo);
			BATseqbase(BATmirror(r1), l->hseqbase + lo - l->tseqbase);
			r2->tdense = 1;
			HEAPfree(&r2->T->heap, 1);
			r2->ttype = TYPE_void;
			r2->tvarsized = 1;
			r2->T->width = 0;
			r2->T->shift = 0;
			BATsetcount(r2, hi - lo);
			BATseqbase(BATmirror(r2), r->hseqbase + lo - r->tseqbase);
			ALGODEBUG fprintf(stderr, "#mergejoin_void(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
					  BATgetId(l), BATgetId(r),
					  BATgetId(r1), BATcount(r1),
					  r1->tsorted ? "-sorted" : "",
					  r1->trevsorted ? "-revsorted" : "",
					  r1->tkey & 1 ? "-key" : "",
					  BATgetId(r2), BATcount(r2),
					  r2->tsorted ? "-sorted" : "",
					  r2->trevsorted ? "-revsorted" : "",
					  r2->tkey & 1 ? "-key" : "",
					  GDKusec() - t0);
			return GDK_SUCCEED;
		}
		/* l has a dense tail, but the candidate list exists
		 * and does not have a dense tail; we can, by
		 * manipulating the range [lo..hi), just look at the
		 * candidate list values */
		assert(!BATtdense(sl));
		lvals = (const oid *) Tloc(sl, BUNfirst(sl));
		/* translate lo and hi to l's head values that now
		 * need to match */
		lo = lo - l->tseqbase + l->hseqbase;
		hi = hi - l->tseqbase + l->hseqbase;
		r2->T->nil = 0;
		r2->T->nonil = 1;
		r2->tkey = 1;
		r2->tsorted = r2->trevsorted = 1;
		cnt = BATcount(sl);
		if (BATextend(r1, cnt) != GDK_SUCCEED ||
		    BATextend(r2, cnt) != GDK_SUCCEED) {
			goto bailout;
		}
		if (nil_on_miss) {
			for (i = 0; i < cnt && lvals[i] < lo; i++) {
				APPEND(r1, lvals[i]);
				APPEND(r2, oid_nil);
			}
			if (i > 0) {
				r2->T->nil = 1;
				r2->T->nonil = 0;
				r2->tkey = i > 1;
				if (!r2->tkey) {
					r2->T->nokey[0] = BUNfirst(r2);
					r2->T->nokey[1] = BUNfirst(r2) + 1;
				}
			}
		} else {
			i = binsearch_oid(NULL, 0, lvals, 0, cnt - 1, &lo, 1, 0);
			if (must_match && i > 0) {
				GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
				goto bailout;
			}
		}
		if (BATcount(r2) > 0 && i < cnt && lvals[i] < hi) {
			/* after nils we get at least one non-nil */
			r2->trevsorted = 0;
			r2->T->norevsorted = BUNlast(r2);
		} else if (i + 1 < cnt && lvals[i + 1] < hi) {
			/* otherwise at least two non-nils of which
			 * the second is larger than the first */
			r2->trevsorted = 0;
			r2->T->norevsorted = BUNlast(r2) + 1;
		}
		for (; i < cnt && lvals[i] < hi; i++) {
			APPEND(r1, lvals[i]);
			APPEND(r2, lvals[i] - l->hseqbase + l->tseqbase - r->tseqbase + r->hseqbase);
		}
		if (nil_on_miss) {
			if (i < cnt) {
				r2->tkey = r2->T->nil || (cnt - i > 1);
				r2->T->nil = 1;
				r2->T->nonil = 0;
				r2->tsorted = 0;
				r2->T->nosorted = BUNlast(r2);
			}
			for (; i < cnt; i++) {
				APPEND(r1, lvals[i]);
				APPEND(r2, oid_nil);
			}
		} else if (must_match && i < cnt) {
			GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
			goto bailout;
		}
		BATsetcount(r1, BATcount(r1));
		BATsetcount(r2, BATcount(r2));
		assert(BATcount(r1) == BATcount(r2));
		if (BATcount(r1) <= 1) {
			r1->tdense = 1;
			r1->trevsorted = 1;
			r2->tdense = 1;
		} else {
			r1->tdense = 0;
			r1->trevsorted = 0;
			r1->T->norevsorted = 1;
			r2->tdense = 0;
		}
		ALGODEBUG fprintf(stderr, "#mergejoin_void(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
				  BATgetId(l), BATgetId(r),
				  BATgetId(r1), BATcount(r1),
				  r1->tsorted ? "-sorted" : "",
				  r1->trevsorted ? "-revsorted" : "",
				  r1->tkey & 1 ? "-key" : "",
				  BATgetId(r2), BATcount(r2),
				  r2->tsorted ? "-sorted" : "",
				  r2->trevsorted ? "-revsorted" : "",
				  r2->tkey & 1 ? "-key" : "",
				  GDKusec() - t0);
		return GDK_SUCCEED;
	}
	/* l does not have a dense tail, so we need to look at the
	 * values and check whether they are in the range [lo..hi) */
	lvals = (const oid *) Tloc(l, BUNfirst(l));
	seq = l->hseqbase;
	cnt = BATcount(l);
	if (sl) {
		if (BATtdense(sl)) {
			/* candidate list exists and has a dense tail,
			 * we can try to restrict the values in l that
			 * we need to look at */
			if (sl->tseqbase > l->hseqbase) {
				/* we don't need to start at the
				 * beginning of l */
				lvals += sl->tseqbase - l->hseqbase;
				seq += sl->tseqbase - l->hseqbase;
				cnt -= sl->tseqbase - l->hseqbase;
			}
			if (sl->tseqbase + BATcount(sl) < l->hseqbase + BATcount(l)) {
				/* we don't have to continue to the
				 * end of l */
				if (cnt < l->hseqbase + BATcount(l) - sl->tseqbase - BATcount(sl))
					cnt = 0;
				else
					cnt -= l->hseqbase + BATcount(l) - sl->tseqbase - BATcount(sl);
			}
		} else {
			/* we have a non-dense candidate list, so we
			 * need to look at the values using an
			 * indirection and check whether they are in
			 * range */
			const oid *lcand = (const oid *) Tloc(sl, BUNfirst(sl));
			o = l->hseqbase;
			cnt = BATcount(sl);
			i = binsearch_oid(NULL, 0, lcand, 0, cnt - 1, &o, 1, 0);
			lcand += i;
			cnt -= i;
			o = l->hseqbase + BATcount(l);
			i = binsearch_oid(NULL, 0, lcand, 0, cnt - 1, &o, 1, 0);
			cnt -= i;

			if (BATextend(r1, cnt) != GDK_SUCCEED ||
			    BATextend(r2, cnt) != GDK_SUCCEED) {
				goto bailout;
			}
			r2->T->nil = 0;
			r2->T->nonil = 1;
			for (i = 0; i < cnt; i++) {
				oid c = lcand[i];
				if (c >= l->hseqbase && c < l->hseqbase + BATcount(l)) {
					o = lvals[c - l->hseqbase];
					if (o >= lo && o < hi) {
						APPEND(r1, c);
						APPEND(r2, o - r->tseqbase + r->hseqbase);
					} else if (must_match) {
						GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
						goto bailout;
					} else if (nil_on_miss) {
						APPEND(r1, c);
						APPEND(r2, oid_nil);
						r2->T->nil = 1;
						r2->T->nonil = 0;
					}
				}
			}
			BATsetcount(r1, BATcount(r1));
			BATsetcount(r2, BATcount(r2));
			r1->trevsorted = BATcount(r1) <= 1;
			r1->T->norevsorted = BUNfirst(r1) + 1;
			r1->tdense = 0;
			r2->tsorted = l->tsorted || BATcount(r2) <= 1;
			r2->trevsorted = l->trevsorted || BATcount(r2) <= 1;
			r2->T->nosorted = r2->T->norevsorted = 0;
			r2->tkey = (l->tkey & 1) || BATcount(r2) <= 1;
			r2->tdense = 0;
			ALGODEBUG fprintf(stderr, "#mergejoin_void(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT " us\n",
					  BATgetId(l), BATgetId(r),
					  BATgetId(r1), BATcount(r1),
					  r1->tsorted ? "-sorted" : "",
					  r1->trevsorted ? "-revsorted" : "",
					  r1->tkey & 1 ? "-key" : "",
					  BATgetId(r2), BATcount(r2),
					  r2->tsorted ? "-sorted" : "",
					  r2->trevsorted ? "-revsorted" : "",
					  r2->tkey & 1 ? "-key" : "",
					  GDKusec() - t0);
			return GDK_SUCCEED;
		}
	}
	if (BATextend(r1, cnt) != GDK_SUCCEED ||
	    BATextend(r2, cnt) != GDK_SUCCEED) {
		goto bailout;
	}
	r1->tdense = 1;
	r1->tseqbase = seq;
	r2->T->nil = 0;
	r2->T->nonil = 1;
	for (i = 0; i < cnt; i++) {
		o = lvals[i];
		if (o >= lo && o < hi) {
			APPEND(r1, i + seq);
			APPEND(r2, o - r->tseqbase + r->hseqbase);
		} else if (must_match) {
			GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
			goto bailout;
		} else if (nil_on_miss) {
			APPEND(r1, i + seq);
			APPEND(r2, oid_nil);
			r2->T->nil = 1;
			r2->T->nonil = 0;
		} else if (r1->tdense) {
			r1->tdense = 0;
			r1->tseqbase = oid_nil;
		}
	}
	BATsetcount(r1, BATcount(r1));
	BATsetcount(r2, BATcount(r2));
	if (BATcount(r1) <= 1) {
		r1->trevsorted = 1;
		r2->tdense = r2->T->nonil;
		if (BATcount(r1) == 0) {
			r1->tseqbase = 0;
			r2->tseqbase = 0;
		} else {
			r1->tseqbase = *(oid *) Tloc(r1, BUNfirst(r1));
			r2->tseqbase = *(oid *) Tloc(r2, BUNfirst(r2));
		}
		r2->tkey = 1;
		r2->tsorted = 1;
		r2->trevsorted = 1;
		r2->tdense = 1;
	} else {
		r1->trevsorted = 0;
		if (r2->T->nil) {
			r2->tkey = 0;
			r2->tsorted = 0;
			r2->trevsorted = 0;
		} else {
			r2->tkey = l->tkey & 1;
			r2->tsorted = l->tsorted;
			r2->trevsorted = l->trevsorted;
		}
		r2->tdense = 0;
		r2->tseqbase = oid_nil;
	}
	ALGODEBUG fprintf(stderr, "#mergejoin_void(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;
  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

/* Perform a "merge" join on l and r (if both are sorted) with
 * optional candidate lists, or join using binary search on r if l is
 * not sorted.  The return BATs have already been created by the
 * caller.
 *
 * If nil_matches is set, nil values are treated as ordinary values
 * that can match; otherwise nil values never match.
 *
 * If nil_on_miss is set, a nil value is returned in r2 if there is no
 * match in r for a particular value in l (left outer join).
 *
 * If semi is set, only a single set of values in r1/r2 is returned if
 * there is a match of l in r, no matter how many matches there are in
 * r; otherwise all matches are returned.
 */
static gdk_return
mergejoin(BAT *r1, BAT *r2, BAT *l, BAT *r, BAT *sl, BAT *sr,
	  int nil_matches, int nil_on_miss, int semi, int must_match,
	  BUN maxsize, lng t0, int swapped)
{
	BUN lstart, lend, lcnt;
	const oid *lcand, *lcandend;
	BUN rstart, rend, rcnt, rstartorig;
	const oid *rcand, *rcandend, *rcandorig;
	BUN lscan, rscan;
	const char *lvals, *rvals;
	const char *lvars, *rvars;
	int lwidth, rwidth;
	const void *nil = ATOMnilptr(l->ttype);
	int (*cmp)(const void *, const void *) = ATOMcompare(l->ttype);
	const char *v, *prev = NULL;
	BUN nl, nr;
	BUN total;		/* number of rows in l we scan */
	int insert_nil;
	/* equal_order is set if we can scan both BATs in the same
	 * order, so when both are sorted or both are reverse sorted
	 * -- important to know in order to skip over values; if l is
	 * not sorted, this must be set to 1 and we will always do a
	 * binary search on all of r */
	int equal_order;
	/* [lr]ordering is either 1 or -1 depending on the order of
	 * l/r: it determines the comparison function used */
	int lordering, rordering;
	oid lv;
	BUN i;
	int lskipped = 0;	/* whether we skipped values in l */
	wrd loff = 0, roff = 0;
	oid lval = oid_nil, rval = oid_nil;

	ALGODEBUG fprintf(stderr, "#mergejoin(l=%s#" BUNFMT "[%s]%s%s%s,"
			  "r=%s#" BUNFMT "[%s]%s%s%s,sl=%s#" BUNFMT "%s%s%s,"
			  "sr=%s#" BUNFMT "%s%s%s,nil_matches=%d,"
			  "nil_on_miss=%d,semi=%d,must_match=%d)%s\n",
			  BATgetId(l), BATcount(l), ATOMname(l->ttype),
			  l->tsorted ? "-sorted" : "",
			  l->trevsorted ? "-revsorted" : "",
			  l->tkey & 1 ? "-key" : "",
			  BATgetId(r), BATcount(r), ATOMname(r->ttype),
			  r->tsorted ? "-sorted" : "",
			  r->trevsorted ? "-revsorted" : "",
			  r->tkey & 1 ? "-key" : "",
			  sl ? BATgetId(sl) : "NULL", sl ? BATcount(sl) : 0,
			  sl && sl->tsorted ? "-sorted" : "",
			  sl && sl->trevsorted ? "-revsorted" : "",
			  sl && sl->tkey & 1 ? "-key" : "",
			  sr ? BATgetId(sr) : "NULL", sr ? BATcount(sr) : 0,
			  sr && sr->tsorted ? "-sorted" : "",
			  sr && sr->trevsorted ? "-revsorted" : "",
			  sr && sr->tkey & 1 ? "-key" : "",
			  nil_matches, nil_on_miss, semi, must_match,
			  swapped ? " swapped" : "");

	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(ATOMtype(l->ttype) == ATOMtype(r->ttype));
	assert(r->tsorted || r->trevsorted);
	assert(sl == NULL || sl->tsorted);
	assert(sr == NULL || sr->tsorted);
	assert(!nil_on_miss || !must_match); /* can't have both */

	CANDINIT(l, sl, lstart, lend, lcnt, lcand, lcandend);
	CANDINIT(r, sr, rstart, rend, rcnt, rcand, rcandend);
	total = lcand ? (BUN) (lcandend - lcand) : lend - lstart;
	lvals = l->ttype == TYPE_void ? NULL : (const char *) Tloc(l, BUNfirst(l));
	rvals = r->ttype == TYPE_void ? NULL : (const char *) Tloc(r, BUNfirst(r));
	if (l->tvarsized && l->ttype) {
		assert(r->tvarsized && r->ttype);
		lvars = l->T->vheap->base;
		rvars = r->T->vheap->base;
	} else {
		assert(!r->tvarsized || !r->ttype);
		lvars = rvars = NULL;
	}
	lwidth = l->T->width;
	rwidth = r->T->width;

	/* basic properties will be adjusted if necessary later on,
	 * they were initially set by joininitresults() */

	if (lstart == lend ||
	    rstart == rend ||
	    (!nil_matches &&
	     ((l->ttype == TYPE_void && l->tseqbase == oid_nil) ||
	      (r->ttype == TYPE_void && r->tseqbase == oid_nil))) ||
	    (l->ttype == TYPE_void && l->tseqbase == oid_nil &&
	     (r->T->nonil ||
	      (r->ttype == TYPE_void && r->tseqbase != oid_nil))) ||
	    (r->ttype == TYPE_void && r->tseqbase == oid_nil &&
	     (l->T->nonil ||
	      (l->ttype == TYPE_void && l->tseqbase != oid_nil)))) {
		/* there are no matches */
		return nomatch(r1, r2, l, r, lstart, lend, lcand, lcandend,
			       nil_on_miss, must_match, "mergejoin", t0);
	}

	if (l->tsorted || l->trevsorted) {
		/* determine opportunistic scan window for l */
		for (nl = lcand ? (BUN) (lcandend - lcand) : lend - lstart,
			     lscan = 4;
		     nl > 0;
		     lscan++)
			nl >>= 1;
		equal_order = (l->tsorted && r->tsorted) ||
			(l->trevsorted && r->trevsorted &&
			 l->ttype != TYPE_void && r->ttype != TYPE_void);
		lordering = l->tsorted && (r->tsorted || !equal_order) ? 1 : -1;
		rordering = equal_order ? lordering : -lordering;
	} else {
		/* if l not sorted, we will always use binary search
		 * on r */
		assert(l->ttype != TYPE_void); /* void is always sorted */
		lscan = 0;
		equal_order = 1;
		lordering = 1;
		rordering = r->tsorted ? 1 : -1;
		/* if l not sorted, we only know for sure that r2 is
		 * key if l is, and that r1 is key if r is; r1 is also
		 * key in the case of a semi-join */
		r2->tkey = l->tkey != 0;
		r1->tkey = (r->tkey != 0) | semi;
	}
	/* determine opportunistic scan window for r; if l is not
	 * sorted this is only used to find range of equal values */
	for (nl = rcand ? (BUN) (rcandend - rcand) : rend - rstart, rscan = 4;
	     nl > 0;
	     rscan++)
		nl >>= 1;

	if (l->ttype == TYPE_void) {
		if (lcand) {
			lstart = 0;
			lend = (BUN) (lcandend - lcand);
			lvals = (const char *) lcand;
			lcand = NULL;
			lwidth = SIZEOF_OID;
		}
		if (l->tseqbase == oid_nil)
			loff = wrd_nil;
		else
			loff = (wrd) l->tseqbase - (wrd) l->hseqbase;
	}
	if (r->ttype == TYPE_void) {
		if (rcand) {
			rstart = 0;
			rend = (BUN) (rcandend - rcand);
			rvals = (const char *) rcand;
			rcand = NULL;
			rwidth = SIZEOF_OID;
		}
		if (r->tseqbase == oid_nil)
			roff = wrd_nil;
		else
			roff = (wrd) r->tseqbase - (wrd) r->hseqbase;
	}
	assert(lvals != NULL || lcand == NULL);
	assert(rvals != NULL || rcand == NULL);

	rcandorig = rcand;
	rstartorig = rstart;

	if (sl)
		r1->tdense = sl->tdense;
	if (sr)
		r2->tdense = sr->tdense;
	while (lcand ? lcand < lcandend : lstart < lend) {
		if (!nil_on_miss && !must_match && lscan > 0) {
			/* If l is sorted (lscan > 0), we look at the
			 * next value in r to see whether we can jump
			 * over a large section of l using binary
			 * search.  We do this by looking ahead in l
			 * (lscan far, to be precise) and seeing if
			 * the value there is still too "small"
			 * (definition depends on sort order of l).
			 * If it is, we use binary search on l,
			 * otherwise we scan l for the next position
			 * with a value greater than or equal to the
			 * value in r.  Obviously, we can only do this
			 * if we're not inserting NILs for missing
			 * values in r (nil_on_miss set, i.e., outer
			 * join).
			 * The next value to match in r is the first
			 * if equal_order is set, the last
			 * otherwise. */
			if (rcand) {
				if (rcand == rcandend)
					break;
				v = VALUE(r, (equal_order ? rcand[0] : rcandend[-1]) - r->hseqbase);
			} else {
				if (rstart == rend)
					break;
				if (rvals) {
					v = VALUE(r, equal_order ? rstart : rend - 1);
					if (roff == wrd_nil) {
						rval = oid_nil;
						v = (const char *) &rval;
					} else if (roff != 0) {
						rval = (oid) (*(const oid *)v + roff);
						v = (const char *) &rval;
					}
				} else {
					if (roff == wrd_nil)
						rval = oid_nil;
					else if (equal_order)
						rval = rstart + r->tseqbase;
					else
						rval = rend - 1 + r->tseqbase;
					v = (const char *) &rval;
				}
			}
			/* here, v points to next value in r */
			if (lcand) {
				if (lscan < (BUN) (lcandend - lcand) &&
				    lordering * cmp(VALUE(l, lcand[lscan] - l->hseqbase),
						    v) < 0) {
					lcand += binsearch(lcand, l->hseqbase,
							   l->ttype, lvals, lvars,
							   lwidth, lscan,
							   (BUN) (lcandend - lcand), v,
							   cmp, lordering, 0);
					if (lcand == lcandend)
						break;
					lskipped = BATcount(r1) > 0;
				}
			} else if (lvals) {
				if (lscan < lend - lstart &&
				    lordering * cmp(VALUE(l, lstart + lscan),
						    v) < 0) {
					lstart = binsearch(NULL, 0,
							   l->ttype, lvals, lvars,
							   lwidth,
							   lstart + lscan,
							   lend, v,
							   cmp, lordering, 0);
					if (lstart == lend)
						break;
					lskipped = BATcount(r1) > 0;
				}
			} else if (*(const oid *)v != oid_nil) {
				if (l->tseqbase == oid_nil) {
					/* there cannot be any more
					 * matches since r's next
					 * value is not nil and hence
					 * all other values in r are
					 * also not nil, and all
					 * values in l are nil */
					lstart = lend;
					break;
				}
				if (*(const oid *)v > l->tseqbase) {
					BUN olstart = lstart;
					lstart = *(const oid *)v - l->tseqbase;
					if (lstart >= lend)
						break;
					if (lstart > olstart)
						lskipped = BATcount(r1) > 0;
				}
			}
		} else if (lscan == 0) {
			/* always search r completely */
			rcand = rcandorig;
			rstart = rstartorig;
		}
		/* Here we determine the next value in l that we are
		 * going to try to match in r.  We will also count the
		 * number of occurrences in l of that value.
		 * Afterwards, v points to the value and nl is the
		 * number of times it occurs.  Also, lstart/lcand will
		 * point to the next value to be considered (ready for
		 * the next iteration).
		 * If there are many equal values in l (more than
		 * lscan), we will use binary search to find the end
		 * of the sequence.  Obviously, we can do this only if
		 * l is actually sorted (lscan > 0). */
		nl = 1;		/* we'll match (at least) one in l */
		nr = 0;		/* maybe we won't match anything in r */
		if (lcand) {
			v = VALUE(l, lcand[0] - l->hseqbase);
			if (l->tkey) {
				/* if l is key, there is a single value */
				lcand++;
			} else if (lscan > 0 &&
				   lscan < (BUN) (lcandend - lcand) &&
				   cmp(v, VALUE(l, lcand[lscan] - l->hseqbase)) == 0) {
				/* lots of equal values: use binary
				 * search to find end */
				nl = binsearch(lcand, l->hseqbase, l->ttype, lvals, lvars, lwidth, lscan, (BUN) (lcandend - lcand), v, cmp, lordering, 1);
				lcand += nl;
			} else {
				while (++lcand < lcandend &&
				       cmp(v, VALUE(l, lcand[0] - l->hseqbase)) == 0)
					nl++;
			}
		} else if (lvals) {
			if (loff == wrd_nil) {
				/* all values are nil */
				lval = oid_nil;
				nl = lend - lstart;
				lstart = lend;
				v = (const char *) &lval;
			} else {
				/* compare values without offset */
				v = VALUE(l, lstart);
				if (l->tkey) {
					/* if l is key, there is a
					 * single value */
					lstart++;
				} else if (lscan > 0 &&
					   lscan < lend - lstart &&
					   cmp(v, VALUE(l, lstart + lscan)) == 0) {
					/* lots of equal values: use
					 * binary search to find
					 * end */
					nl = binsearch(NULL, 0, l->ttype, lvals, lvars,
						       lwidth, lstart + lscan,
						       lend, v, cmp, lordering,
						       1);
					nl -= lstart;
					lstart += nl;
				} else {
					while (++lstart < lend &&
					       cmp(v, VALUE(l, lstart)) == 0)
						nl++;
				}
				/* now fix offset */
				if (loff != 0) {
					lval = (oid) (*(const oid *)v + loff);
					v = (const char *) &lval;
				}
			}
		} else {
			if (loff == wrd_nil) {
				lval = oid_nil;
				nl = lend - lstart;
				lstart = lend;
			} else {
				lval = lstart + l->tseqbase;
				lstart++;
			}
			v = (const char *) &lval;
		}
		/* lcand/lstart points one beyond the value we're
		 * going to match: ready for the next iteration. */
		if (!nil_matches && cmp(v, nil) == 0) {
			/* v is nil and nils don't match anything */
			r1->tdense = 0;
			r2->tdense = 0;
			if (must_match) {
				GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
				goto bailout;
			}
			continue;
		}
		/* First we find the "first" value in r that is "at
		 * least as large" as v, then we find the "first"
		 * value in r that is "larger" than v.  The difference
		 * is the number of values equal to v and is stored in
		 * nr.  The definitions of "larger" and "first" depend
		 * on the orderings of l and r.  If equal_order is
		 * set, we go through r from low to high, changing
		 * rstart/rcand (this includes the case that l is not
		 * sorted); otherwise we go through r from high to
		 * low, changing rend/rcandend.
		 * In either case, we will use binary search on r to
		 * find both ends of the sequence of values that are
		 * equal to v in case the position is "too far" (more
		 * than rscan away). */
		if (equal_order) {
			if (rcand) {
				/* first find the location of the
				 * first value in r that is >= v, then
				 * find the location of the first
				 * value in r that is > v; the
				 * difference is the number of values
				 * equal v */
				/* look ahead a little (rscan) in r to
				 * see whether we're better off doing
				 * a binary search */
				if (rscan < (BUN) (rcandend - rcand) &&
				    rordering * cmp(v, VALUE(r, rcand[rscan] - r->hseqbase)) > 0) {
					/* value too far away in r:
					 * use binary search */
					rcand += binsearch(rcand, r->hseqbase,
							   r->ttype, rvals, rvars,
							   rwidth, rscan,
							   (BUN) (rcandend - rcand), v,
							   cmp, rordering, 0);
				} else {
					/* scan r for v */
					while (rcand < rcandend &&
					       rordering * cmp(v, VALUE(r, rcand[0] - r->hseqbase)) > 0)
						rcand++;
				}
				/* if r is key, there is zero or one
				 * match, otherwise look ahead a
				 * little (rscan) in r to see whether
				 * we're better off doing a binary
				 * search */
				if (r->tkey) {
					if (rcand < rcandend &&
					    cmp(v, VALUE(r, rcand[0] - r->hseqbase)) == 0) {
						nr = 1;
						rcand++;
					}
				} else if (rscan < (BUN) (rcandend - rcand) &&
					   cmp(v, VALUE(r, rcand[rscan] - r->hseqbase)) == 0) {
					/* range too large: use binary
					 * search */
					nr = binsearch(rcand, r->hseqbase,
						       r->ttype, rvals, rvars, rwidth,
						       rscan, (BUN) (rcandend - rcand),
						       v, cmp, rordering, 1);
					rcand += nr;
				} else {
					/* scan r for end of range */
					while (rcand < rcandend &&
					       cmp(v, VALUE(r, rcand[0] - r->hseqbase)) == 0) {
						nr++;
						rcand++;
					}
				}
			} else if (rvals) {
				/* first find the location of the
				 * first value in r that is >= v, then
				 * find the location of the first
				 * value in r that is > v; the
				 * difference is the number of values
				 * equal v */
				/* look ahead a little (rscan) in r to
				 * see whether we're better off doing
				 * a binary search */
				if (rscan < rend - rstart &&
				    rordering * cmp(v, VALUE(r, rstart + rscan)) > 0) {
					/* value too far away in r:
					 * use binary search */
					rstart = binsearch(NULL, 0, r->ttype, rvals,
							   rvars, rwidth,
							   rstart + rscan,
							   rend, v, cmp,
							   rordering, 0);
				} else {
					/* scan r for v */
					while (rstart < rend &&
					       rordering * cmp(v, VALUE(r, rstart)) > 0)
						rstart++;
				}
				/* if r is key, there is zero or one
				 * match, otherwise look ahead a
				 * little (rscan) in r to see whether
				 * we're better off doing a binary
				 * search */
				if (r->tkey) {
					if (rstart < rend &&
					    cmp(v, VALUE(r, rstart)) == 0) {
						nr = 1;
						rstart++;
					}
				} else if (rscan < rend - rstart &&
					   cmp(v, VALUE(r, rstart + rscan)) == 0) {
					/* range too large: use binary
					 * search */
					nr = binsearch(NULL, 0, r->ttype, rvals, rvars,
						       rwidth, rstart + rscan,
						       rend, v, cmp,
						       rordering, 1);
					nr -= rstart;
					rstart += nr;
				} else {
					/* scan r for end of range */
					while (rstart < rend &&
					       cmp(v, VALUE(r, rstart)) == 0) {
						nr++;
						rstart++;
					}
				}
			} else {
				/* r is dense or void-nil, so we don't
				 * need to search, we know there is
				 * either zero or one match, or
				 * everything matches (nil) */
				if (r->tseqbase == oid_nil) {
					if (*(const oid *)v == oid_nil) {
						/* both sides are nil:
						 * everything matches */
						nr = rend - rstart;
						rstart = rend;
					}
				} else if (*(const oid *)v != oid_nil &&
					   *(const oid *)v >= rstart + r->tseqbase) {
					if (*(const oid *)v < rend + r->tseqbase) {
						/* within range: a
						 * single match */
						nr = 1;
						rstart = *(const oid *)v - r->tseqbase + 1;
					} else {
						/* beyond the end: no match */
						rstart = rend;
					}
				}
			}
			/* rstart or rcand points to first value > v
			 * or end of r, and nr is the number of values
			 * in r that are equal to v */
		} else {
			if (rcand) {
				/* first find the location of the
				 * first value in r that is > v, then
				 * find the location of the first
				 * value in r that is >= v; the
				 * difference is the number of values
				 * equal v */
				/* look ahead a little (rscan) in r to
				 * see whether we're better off doing
				 * a binary search */
				if (rscan < (BUN) (rcandend - rcand) &&
				    rordering * cmp(v, VALUE(r, rcandend[-(ssize_t)rscan - 1] - r->hseqbase)) < 0) {
					/* value too far away in r:
					 * use binary search */
					rcandend = rcand + binsearch(rcand,
								     r->hseqbase,
								     r->ttype, rvals,
								     rvars,
								     rwidth, 0,
								     (BUN) (rcandend - rcand) - rscan,
								     v, cmp,
								     rordering,
								     1);
				} else {
					/* scan r for v */
					while (rcand < rcandend &&
					       rordering * cmp(v, VALUE(r, rcandend[-1] - r->hseqbase)) < 0)
						rcandend--;
				}
				/* if r is key, there is zero or one
				 * match, otherwise look ahead a
				 * little (rscan) in r to see whether
				 * we're better off doing a binary
				 * search */
				if (r->tkey) {
					if (rcand < rcandend &&
					    cmp(v, VALUE(r, rcandend[-1] - r->hseqbase)) == 0) {
						nr = 1;
						rcandend--;
					}
				} else if (rscan < (BUN) (rcandend - rcand) &&
					   cmp(v, VALUE(r, rcandend[-(ssize_t)rscan - 1] - r->hseqbase)) == 0) {
					nr = binsearch(rcand, r->hseqbase,
						       r->ttype, rvals, rvars, rwidth, 0,
						       (BUN) (rcandend - rcand) - rscan,
						       v, cmp, rordering, 0);
					nr = (BUN) (rcandend - rcand) - nr;
					rcandend -= nr;
				} else {
					/* scan r for start of range */
					while (rcand < rcandend &&
					       cmp(v, VALUE(r, rcandend[-1] - r->hseqbase)) == 0) {
						nr++;
						rcandend--;
					}
				}
			} else if (rvals) {
				/* first find the location of the
				 * first value in r that is > v, then
				 * find the location of the first
				 * value in r that is >= v; the
				 * difference is the number of values
				 * equal v */
				/* look ahead a little (rscan) in r to
				 * see whether we're better off doing
				 * a binary search */
				if (rscan < rend - rstart &&
				    rordering * cmp(v, VALUE(r, rend - rscan - 1)) < 0) {
					/* value too far away in r:
					 * use binary search */
					rend = binsearch(NULL, 0, r->ttype, rvals, rvars,
							 rwidth, rstart,
							 rend - rscan, v, cmp,
							 rordering, 1);
				} else {
					/* scan r for v */
					while (rstart < rend &&
					       rordering * cmp(v, VALUE(r, rend - 1)) < 0)
						rend--;
				}
				/* if r is key, there is zero or one
				 * match, otherwise look ahead a
				 * little (rscan) in r to see whether
				 * we're better off doing a binary
				 * search */
				if (r->tkey) {
					if (rstart < rend &&
					    cmp(v, VALUE(r, rend - 1)) == 0) {
						nr = 1;
						rend--;
					}
				} else if (rscan < rend - rstart &&
					   cmp(v, VALUE(r, rend - rscan - 1)) == 0) {
					nr = binsearch(NULL, 0, r->ttype, rvals, rvars, rwidth, rstart, rend - rscan, v, cmp, rordering, 0);
					nr = rend - nr;
					rend -= nr;
				} else {
					/* scan r for start of range */
					while (rstart < rend &&
					       cmp(v, VALUE(r, rend - 1)) == 0) {
						nr++;
						rend--;
					}
				}
			} else {
				/* r is dense or void-nil, so we don't
				 * need to search, we know there is
				 * either zero or one match, or
				 * everything matches (nil) */
				if (r->tseqbase == oid_nil) {
					if (*(const oid *)v == oid_nil) {
						/* both sides are nil:
						 * everything matches */
						nr = rend - rstart;
						rend = rstart;
					}
				} else if (*(const oid *)v != oid_nil &&
					   *(const oid *)v < rend + r->tseqbase) {
					if (*(const oid *)v >= rstart + r->tseqbase) {
						/* within range: a
						 * single match */
						nr = 1;
						rend = *(const oid *)v - r->tseqbase;
					} else {
						/* before the start:
						 * no match */
						rend = rstart;
					}
				}
			}
			/* rend/rcandend now points to first value >= v
			 * or start of r */
		}
		if (nr == 0) {
			/* no entries in r found */
			if (must_match) {
				GDKerror("mergejoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
				goto bailout;
			}
			if (!nil_on_miss) {
				if (lscan > 0 &&
				    (rcand ? rcand == rcandend : rstart == rend)) {
					/* nothing more left to match
					 * in r */
					break;
				}
				lskipped = BATcount(r1) > 0;
				continue;
			}
			/* insert a nil to indicate a non-match */
			insert_nil = 1;
			nr = 1;
			r2->T->nil = 1;
			r2->T->nonil = 0;
			r2->tsorted = 0;
			r2->trevsorted = 0;
			r2->tdense = 0;
		} else {
			insert_nil = 0;
			if (semi) {
				/* for semi-join, only insert single
				 * value */
				nr = 1;
			}
			if (lcand &&
			    nl > 1 &&
			    lcand[-1] != lcand[-1 - (ssize_t) nl] + nl) {
				/* not all values in the range are
				 * candidates */
				lskipped = 1;
			}
		}
		/* make space: nl values in l match nr values in r, so
		 * we need to add nl * nr values in the results */
		if (BATcount(r1) + nl * nr > BATcapacity(r1)) {
			/* make some extra space by extrapolating how
			 * much more we need (fraction of l we've seen
			 * so far is used as the fraction of the
			 * expected result size we've produced so
			 * far) */
			BUN newcap = (BUN) ((double) total / (total - (lcand ? (BUN) (lcandend - lcand) : (lend - lstart))) * (BATcount(r1) + nl * nr) * 1.1);
			if (newcap < nl * nr + BATcount(r1))
				newcap = nl * nr + BATcount(r1) + 1024;
			if (newcap > maxsize)
				newcap = maxsize;
			/* make sure heap.free is set properly before
			 * extending */
			BATsetcount(r1, BATcount(r1));
			BATsetcount(r2, BATcount(r2));
			if (BATextend(r1, newcap) != GDK_SUCCEED ||
			    BATextend(r2, newcap) != GDK_SUCCEED) {
				goto bailout;
			}
			assert(BATcapacity(r1) == BATcapacity(r2));
		}

		/* maintain properties */
		if (nl > 1) {
			/* value occurs multiple times in l, so entry
			 * in r will be repeated multiple times: hence
			 * r2 is not key and not dense */
			r2->tkey = 0;
			r2->tdense = 0;
			/* multiple different values will be inserted
			 * in r1 (always in order), so not reverse
			 * ordered anymore */
			r1->trevsorted = 0;
		}
		if (nr > 1) {
			/* value occurs multiple times in r, so entry
			 * in l will be repeated multiple times: hence
			 * r1 is not key and not dense */
			r1->tkey = 0;
			r1->tdense = 0;
			/* multiple different values will be inserted
			 * in r2 (in order), so not reverse ordered
			 * anymore */
			r2->trevsorted = 0;
			if (nl > 1) {
				/* multiple values in l match multiple
				 * values in r, so an ordered sequence
				 * will be inserted multiple times in
				 * r2, so r2 is not ordered anymore */
				r2->tsorted = 0;
			}
		}
		if (lscan == 0) {
			/* deduce relative positions of r matches for
			 * this and previous value in v */
			if (prev) {
				if (rordering * cmp(prev, v) < 0) {
					/* previous value in l was
					 * less than current */
					r2->trevsorted = 0;
				} else {
					r2->tsorted = 0;
				}
			}
			prev = v;
		}
		if (BATcount(r1) > 0) {
			/* a new, higher value will be inserted into
			 * r1, so r1 is not reverse ordered anymore */
			r1->trevsorted = 0;
			/* depending on whether l and r are ordered
			 * the same or not, a new higher or lower
			 * value will be added to r2 */
			if (equal_order)
				r2->trevsorted = 0;
			else {
				r2->tsorted = 0;
				r2->tdense = 0;
			}
			if (r1->tdense && lskipped)
				r1->tdense = 0;
		}

		/* insert values: various different ways of doing it */
		if (insert_nil) {
			do {
				lv = lcand ? lcand[-(ssize_t)nl] : lstart + l->hseqbase - nl;

				for (i = 0; i < nr; i++) {
					APPEND(r1, lv);
					APPEND(r2, oid_nil);
				}
			} while (--nl > 0);
		} else if (rcand && equal_order) {
			if (r2->batCount > 0 &&
			    r2->tdense &&
			    ((oid *) r2->T->heap.base)[r2->batFirst + r2->batCount - 1] + 1 != rcand[-(ssize_t)nr])
				r2->tdense = 0;
			do {
				lv = lcand ? lcand[-(ssize_t)nl] : lstart + l->hseqbase - nl;

				for (i = nr; i > 0; i--) {
					APPEND(r1, lv);
					APPEND(r2, rcand[-(ssize_t)i]);
				}
			} while (--nl > 0);
		} else if (rcand) {
			if (r2->batCount > 0 &&
			    r2->tdense &&
			    ((oid *) r2->T->heap.base)[r2->batFirst + r2->batCount - 1] + 1 != rcandend[0])
				r2->tdense = 0;
			do {
				lv = lcand ? lcand[-(ssize_t)nl] : lstart + l->hseqbase - nl;

				for (i = 0; i < nr; i++) {
					APPEND(r1, lv);
					APPEND(r2, rcandend[i]);
				}
			} while (--nl > 0);
		} else if (equal_order) {
			if (r2->batCount > 0 &&
			    r2->tdense &&
			    ((oid *) r2->T->heap.base)[r2->batFirst + r2->batCount - 1] + 1 != rstart + r->hseqbase - nr)
				r2->tdense = 0;
			do {
				lv = lcand ? lcand[-(ssize_t)nl] : lstart + l->hseqbase - nl;

				for (i = nr; i > 0; i--) {
					APPEND(r1, lv);
					APPEND(r2, rstart + r->hseqbase - i);
				}
			} while (--nl > 0);
		} else {
			if (r2->batCount > 0 &&
			    r2->tdense &&
			    ((oid *) r2->T->heap.base)[r2->batFirst + r2->batCount - 1] + 1 != rend + r->hseqbase)
				r2->tdense = 0;
			do {
				lv = lcand ? lcand[-(ssize_t)nl] : lstart + l->hseqbase - nl;

				for (i = 0; i < nr; i++) {
					APPEND(r1, lv);
					APPEND(r2, rend + r->hseqbase + i);
				}
			} while (--nl > 0);
		}
	}
	assert(BATcount(r1) == BATcount(r2));
	/* also set other bits of heap to correct value to indicate size */
	BATsetcount(r1, BATcount(r1));
	BATsetcount(r2, BATcount(r2));
	if (BATcount(r1) > 0) {
		if (r1->tdense)
			r1->tseqbase = ((oid *) r1->T->heap.base)[r1->batFirst];
		if (r2->tdense)
			r2->tseqbase = ((oid *) r2->T->heap.base)[r2->batFirst];
	}
	ALGODEBUG fprintf(stderr, "#mergejoin(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;

  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

/* binary search in a candidate list, return 1 if found, 0 if not */
static inline int
binsearchcand(const oid *cand, BUN lo, BUN hi, oid v)
{
	BUN mid;

	--hi;			/* now hi is inclusive */
	if (v < cand[lo] || v > cand[hi])
		return 0;
	while (hi > lo) {
		mid = (lo + hi) / 2;
		if (cand[mid] == v)
			return 1;
		if (cand[mid] < v)
			lo = mid + 1;
		else
			hi = mid - 1;
	}
	return cand[lo] == v;
}

#define HASHLOOPBODY()							\
	do {								\
		if (BUNlast(r1) == BATcapacity(r1)) {			\
			newcap = BATgrows(r1);				\
			if (newcap > maxsize)				\
				newcap = maxsize;			\
			BATsetcount(r1, BATcount(r1));			\
			BATsetcount(r2, BATcount(r2));			\
			if (BATextend(r1, newcap) != GDK_SUCCEED ||	\
			    BATextend(r2, newcap) != GDK_SUCCEED)	\
				goto bailout;				\
			assert(BATcapacity(r1) == BATcapacity(r2));	\
		}							\
		APPEND(r1, lo);						\
		APPEND(r2, ro);						\
		nr++;							\
	} while (0)

#define HASHloop_bound(bi, h, hb, v, lo, hi)		\
	for (hb = HASHget(h, HASHprobe((h), v));	\
	     hb != HASHnil(h);				\
	     hb = HASHgetlink(h,hb))			\
		if (hb >= (lo) && hb < (hi) &&		\
		    (cmp == NULL ||			\
		     (*cmp)(v, BUNtail(bi, hb)) == 0))

#define HASHloop_bound_TYPE(bi, h, hb, v, lo, hi, TYPE)		\
	for (hb = HASHget(h, hash_##TYPE(h, v));		\
	     hb != HASHnil(h);					\
	     hb = HASHgetlink(h,hb))				\
		if (hb >= (lo) && hb < (hi) &&			\
		    simple_EQ(v, BUNtloc(bi, hb), TYPE))

static gdk_return
hashjoin(BAT *r1, BAT *r2, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches,
	 int nil_on_miss, int semi, int must_match, BUN maxsize, lng t0,
	 int swapped, const char *reason)
{
	BUN lstart, lend, lcnt;
	const oid *lcand = NULL, *lcandend = NULL;
	BUN rstart, rend, rcnt;
	const oid *rcand = NULL, *rcandend = NULL;
	oid lo, ro;
	BATiter ri;
	BUN rb;
	BUN rl, rh;
	oid rseq;
	BUN nr, nrcand, newcap;
	const char *lvals;
	const char *lvars;
	int lwidth;
	const void *nil = ATOMnilptr(l->ttype);
	int (*cmp)(const void *, const void *) = ATOMcompare(l->ttype);
	oid lval = oid_nil;	/* hold value if l has dense tail */
	const char *v = (const char *) &lval;
	int lskipped = 0;	/* whether we skipped values in l */

	ALGODEBUG fprintf(stderr, "#hashjoin(l=%s#" BUNFMT "[%s]%s%s%s,"
			  "r=%s#" BUNFMT "[%s]%s%s%s,sl=%s#" BUNFMT "%s%s%s,"
			  "sr=%s#" BUNFMT "%s%s%s,nil_matches=%d,"
			  "nil_on_miss=%d,semi=%d,must_match=%d)%s%s%s\n",
			  BATgetId(l), BATcount(l), ATOMname(l->ttype),
			  l->tsorted ? "-sorted" : "",
			  l->trevsorted ? "-revsorted" : "",
			  l->tkey & 1 ? "-key" : "",
			  BATgetId(r), BATcount(r), ATOMname(r->ttype),
			  r->tsorted ? "-sorted" : "",
			  r->trevsorted ? "-revsorted" : "",
			  r->tkey & 1 ? "-key" : "",
			  sl ? BATgetId(sl) : "NULL", sl ? BATcount(sl) : 0,
			  sl && sl->tsorted ? "-sorted" : "",
			  sl && sl->trevsorted ? "-revsorted" : "",
			  sl && sl->tkey & 1 ? "-key" : "",
			  sr ? BATgetId(sr) : "NULL", sr ? BATcount(sr) : 0,
			  sr && sr->tsorted ? "-sorted" : "",
			  sr && sr->trevsorted ? "-revsorted" : "",
			  sr && sr->tkey & 1 ? "-key" : "",
			  nil_matches, nil_on_miss, semi, must_match,
			  swapped ? " swapped" : "",
			  *reason ? " " : "", reason);

	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(r->ttype != TYPE_void);
	assert(ATOMtype(l->ttype) == ATOMtype(r->ttype));
	assert(sl == NULL || sl->tsorted);
	assert(sr == NULL || sr->tsorted);
	assert(!nil_on_miss || !must_match); /* can't have both */

	CANDINIT(l, sl, lstart, lend, lcnt, lcand, lcandend);
	CANDINIT(r, sr, rstart, rend, rcnt, rcand, rcandend);
	lwidth = l->T->width;
	lvals = (const char *) Tloc(l, BUNfirst(l));
	if (l->tvarsized && l->ttype) {
		assert(r->tvarsized && r->ttype);
		lvars = l->T->vheap->base;
	} else {
		assert(!r->tvarsized || !r->ttype);
		lvars = NULL;
	}
	/* offset to convert BUN for value in right tail column to OID
	 * in right head column */
	rseq = r->hseqbase;

	/* basic properties will be adjusted if necessary later on,
	 * they were initially set by joininitresults() */

	/* if an input columns is key, the opposite output column will
	 * be key */
	r1->tkey = r->tkey != 0;
	r2->tkey = l->tkey != 0;
	/* r2 is not likely to be sorted (although it is certainly
	 * possible) */
	r2->tsorted = 0;
	r2->trevsorted = 0;
	r2->tdense = 0;

	if (sl) 
		r1->tdense = sl->tdense;

	if (lstart == lend || rstart == rend)
		return nomatch(r1, r2, l, r, lstart, lend, lcand, lcandend,
			       nil_on_miss, must_match, "hashjoin", t0);

	rl = BUNfirst(r);
#ifndef DISABLE_PARENT_HASH
	if (VIEWtparent(r)) {
		BAT *b = BBPdescriptor(-VIEWtparent(r));
		if (b->batPersistence == PERSISTENT || BATcheckhash(b)) {
			/* only use parent's hash if it is persistent
			 * or already has a hash */
			ALGODEBUG
				fprintf(stderr, "#hashjoin(%s#"BUNFMT"): "
					"using parent(%s#"BUNFMT") for hash\n",
					BATgetId(r), BATcount(r),
					BATgetId(b), BATcount(b));
			rl = (BUN) ((r->T->heap.base - b->T->heap.base) >> r->T->shift) + BUNfirst(r);
			r = b;
		} else {
			ALGODEBUG
				fprintf(stderr, "#hashjoin(%s#"BUNFMT"): not "
					"using parent(%s#"BUNFMT") for hash\n",
					BATgetId(r), BATcount(r),
					BATgetId(b), BATcount(b));
		}
	}
#endif
	rh = rl + rend;
	rl += rstart;
	rseq += rstart;

	if (BAThash(r, 0) != GDK_SUCCEED)
		goto bailout;
	ri = bat_iterator(r);
	nrcand = (BUN) (rcandend - rcand);

	if (lcand) {
		while (lcand < lcandend) {
			lo = *lcand++;
			if (l->ttype == TYPE_void) {
				if (l->tseqbase != oid_nil)
					lval = lo - l->hseqbase + l->tseqbase;
			} else {
				v = VALUE(l, lo - l->hseqbase);
			}
			if (!nil_matches && cmp(v, nil) == 0) {
				lskipped = BATcount(r1) > 0;
				continue;
			}
			nr = 0;
			if (rcand) {
				HASHloop_bound(ri, r->T->hash, rb, v, rl, rh) {
					ro = (oid) (rb - rl + rseq);
					if (!binsearchcand(rcand, 0, nrcand, ro))
						continue;
					HASHLOOPBODY();
					if (semi)
						break;
				}
			} else {
				HASHloop_bound(ri, r->T->hash, rb, v, rl, rh) {
					ro = (oid) (rb - rl + rseq);
					HASHLOOPBODY();
					if (semi)
						break;
				}
			}
			if (nr == 0) {
				if (nil_on_miss) {
					nr = 1;
					r2->T->nil = 1;
					r2->T->nonil = 0;
					r2->tkey = 0;
					if (BUNlast(r1) == BATcapacity(r1)) {
						newcap = BATgrows(r1);
						if (newcap > maxsize)
							newcap = maxsize;
						BATsetcount(r1, BATcount(r1));
						BATsetcount(r2, BATcount(r2));
						if (BATextend(r1, newcap) != GDK_SUCCEED ||
						    BATextend(r2, newcap) != GDK_SUCCEED)
							goto bailout;
						assert(BATcapacity(r1) == BATcapacity(r2));
					}
					APPEND(r1, lo);
					APPEND(r2, oid_nil);
				} else if (must_match) {
					GDKerror("hashjoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
					goto bailout;
				} else {
					lskipped = BATcount(r1) > 0;
				}
			} else {
				if (lskipped) {
					/* note, we only get here in
					 * an iteration *after*
					 * lskipped was first set to
					 * 1, i.e. we did indeed skip
					 * values in l */
					r1->tdense = 0;
				}
				if (nr > 1) {
					r1->tkey = 0;
					r1->tdense = 0;
				}
			}
			if (nr > 0 && BATcount(r1) > nr)
				r1->trevsorted = 0;
		}
	} else {
		int t = ATOMbasetype(r->ttype);

		for (lo = lstart - BUNfirst(l) + l->hseqbase; lstart < lend; lo++) {
			if (l->ttype == TYPE_void) {
				if (l->tseqbase != oid_nil)
					lval = lo - l->hseqbase + l->tseqbase;
			} else {
				v = VALUE(l, lstart);
			}
			lstart++;
			nr = 0;
			if (rcand) {
				if (!nil_matches && cmp(v, nil) == 0) {
					lskipped = BATcount(r1) > 0;
					continue;
				}
				HASHloop_bound(ri, r->T->hash, rb, v, rl, rh) {
					ro = (oid) (rb - rl + rseq);
					if (!binsearchcand(rcand, 0, nrcand, ro))
						continue;
					HASHLOOPBODY();
					if (semi)
						break;
				}
			} else {
				switch (t) {
				case TYPE_int:
					if (!nil_matches && *(const int*)v == int_nil) {
						lskipped = BATcount(r1) > 0;
						continue;
					}
					HASHloop_bound_TYPE(ri, r->T->hash, rb, v, rl, rh, int) {
						ro = (oid) (rb - rl + rseq);
						HASHLOOPBODY();
						if (semi)
							break;
					}
					break;
				case TYPE_lng:
					if (!nil_matches && *(const lng*)v == lng_nil) {
						lskipped = BATcount(r1) > 0;
						continue;
					}
					HASHloop_bound_TYPE(ri, r->T->hash, rb, v, rl, rh, lng) {
						ro = (oid) (rb - rl + rseq);
						HASHLOOPBODY();
						if (semi)
							break;
					}
					break;
#ifdef HAVE_HGE
				case TYPE_hge:
					if (!nil_matches && *(const hge*)v == hge_nil) {
						lskipped = BATcount(r1) > 0;
						continue;
					}
					HASHloop_bound_TYPE(ri, r->T->hash, rb, v, rl, rh, hge) {
						ro = (oid) (rb - rl + rseq);
						HASHLOOPBODY();
						if (semi)
							break;
					}
					break;
#endif
				default:
					if (!nil_matches && cmp(v, nil) == 0) {
						lskipped = BATcount(r1) > 0;
						continue;
					}
					HASHloop_bound(ri, r->T->hash, rb, v, rl, rh) {
						ro = (oid) (rb - rl + rseq);
						HASHLOOPBODY();
						if (semi)
							break;
					}
					break;
				}
			}
			if (nr == 0) {
				if (nil_on_miss) {
					nr = 1;
					r2->T->nil = 1;
					r2->T->nonil = 0;
					if (BUNlast(r1) == BATcapacity(r1)) {
						newcap = BATgrows(r1);
						BATsetcount(r1, BATcount(r1));
						BATsetcount(r2, BATcount(r2));
						if (BATextend(r1, newcap) != GDK_SUCCEED ||
						    BATextend(r2, newcap) != GDK_SUCCEED)
							goto bailout;
						assert(BATcapacity(r1) == BATcapacity(r2));
					}
					APPEND(r1, lo);
					APPEND(r2, oid_nil);
				} else if (must_match) {
					GDKerror("hashjoin(%s,%s) does not hit always => can't use fetchjoin.\n", BATgetId(l), BATgetId(r));
					goto bailout;
				} else {
					lskipped = BATcount(r1) > 0;
				}
			} else {
				if (lskipped) {
					/* note, we only get here in
					 * an iteration *after*
					 * lskipped was first set to
					 * 1, i.e. we did indeed skip
					 * values in l */
					r1->tdense = 0;
				}
				if (nr > 1) {
					r1->tkey = 0;
					r1->tdense = 0;
				}
			}
			if (nr > 0 && BATcount(r1) > nr)
				r1->trevsorted = 0;
		}
	}
	assert(BATcount(r1) == BATcount(r2));
	/* also set other bits of heap to correct value to indicate size */
	BATsetcount(r1, BATcount(r1));
	BATsetcount(r2, BATcount(r2));
	if (BATcount(r1) <= 1) {
		r1->tsorted = 1;
		r1->trevsorted = 1;
		r1->tkey = 1;
		r1->tdense = 1;
		r2->tsorted = 1;
		r2->trevsorted = 1;
		r2->tkey = 1;
		r2->tdense = 1;
	}
	if (BATcount(r1) > 0) {
		if (r1->tdense)
			r1->tseqbase = ((oid *) r1->T->heap.base)[r1->batFirst];
		if (r2->tdense)
			r2->tseqbase = ((oid *) r2->T->heap.base)[r2->batFirst];
	}
	ALGODEBUG fprintf(stderr, "#hashjoin(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;

  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

#define MASK_EQ		1
#define MASK_LT		2
#define MASK_GT		4
#define MASK_LE		(MASK_EQ | MASK_LT)
#define MASK_GE		(MASK_EQ | MASK_GT)
#define MASK_NE		(MASK_LT | MASK_GT)

static gdk_return
thetajoin(BAT *r1, BAT *r2, BAT *l, BAT *r, BAT *sl, BAT *sr, int opcode, BUN maxsize, lng t0)
{
	BUN lstart, lend, lcnt;
	const oid *lcand = NULL, *lcandend = NULL;
	BUN rstart, rend, rcnt;
	const oid *rcand = NULL, *rcandend = NULL;
	const char *lvals, *rvals;
	const char *lvars, *rvars;
	int lwidth, rwidth;
	const void *nil = ATOMnilptr(l->ttype);
	int (*cmp)(const void *, const void *) = ATOMcompare(l->ttype);
	const char *vl, *vr;
	const oid *p;
	oid lastr = 0;		/* last value inserted into r2 */
	BUN n, nr;
	BUN newcap;
	oid lo, ro;
	int c;
	int lskipped = 0;	/* whether we skipped values in l */
	wrd loff = 0, roff = 0;
	oid lval = oid_nil, rval = oid_nil;

	ALGODEBUG fprintf(stderr, "#thetajoin(l=%s#" BUNFMT "[%s]%s%s%s,"
			  "r=%s#" BUNFMT "[%s]%s%s%s,sl=%s#" BUNFMT "%s%s%s,"
			  "sr=%s#" BUNFMT "%s%s%s,op=%s%s%s)\n",
			  BATgetId(l), BATcount(l), ATOMname(l->ttype),
			  l->tsorted ? "-sorted" : "",
			  l->trevsorted ? "-revsorted" : "",
			  l->tkey & 1 ? "-key" : "",
			  BATgetId(r), BATcount(r), ATOMname(r->ttype),
			  r->tsorted ? "-sorted" : "",
			  r->trevsorted ? "-revsorted" : "",
			  r->tkey & 1 ? "-key" : "",
			  sl ? BATgetId(sl) : "NULL", sl ? BATcount(sl) : 0,
			  sl && sl->tsorted ? "-sorted" : "",
			  sl && sl->trevsorted ? "-revsorted" : "",
			  sl && sl->tkey & 1 ? "-key" : "",
			  sr ? BATgetId(sr) : "NULL", sr ? BATcount(sr) : 0,
			  sr && sr->tsorted ? "-sorted" : "",
			  sr && sr->trevsorted ? "-revsorted" : "",
			  sr && sr->tkey & 1 ? "-key" : "",
			  opcode & MASK_LT ? "<" : "",
			  opcode & MASK_GT ? ">" : "",
			  opcode & MASK_EQ ? "=" : "");

	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(ATOMtype(l->ttype) == ATOMtype(r->ttype));
	assert(sl == NULL || sl->tsorted);
	assert(sr == NULL || sr->tsorted);
	assert((opcode & (MASK_EQ | MASK_LT | MASK_GT)) != 0);

	CANDINIT(l, sl, lstart, lend, lcnt, lcand, lcandend);
	CANDINIT(r, sr, rstart, rend, rcnt, rcand, rcandend);

	lvals = l->ttype == TYPE_void ? NULL : (const char *) Tloc(l, BUNfirst(l));
	rvals = r->ttype == TYPE_void ? NULL : (const char *) Tloc(r, BUNfirst(r));
	if (l->tvarsized && l->ttype) {
		assert(r->tvarsized && r->ttype);
		lvars = l->T->vheap->base;
		rvars = r->T->vheap->base;
	} else {
		assert(!r->tvarsized || !r->ttype);
		lvars = rvars = NULL;
	}
	lwidth = l->T->width;
	rwidth = r->T->width;

	if (l->ttype == TYPE_void) {
		if (l->tseqbase == oid_nil) {
			/* trivial: nils don't match anything */
			return GDK_SUCCEED;
		}
		if (lcand) {
			lstart = 0;
			lend = (BUN) (lcandend - lcand);
			lvals = (const char *) lcand;
			lcand = NULL;
			lwidth = SIZEOF_OID;
		}
		loff = (wrd) l->tseqbase - (wrd) l->hseqbase;
	}
	if (r->ttype == TYPE_void) {
		if (r->tseqbase == oid_nil) {
			/* trivial: nils don't match anything */
			return GDK_SUCCEED;
		}
		if (rcand) {
			rstart = 0;
			rend = (BUN) (rcandend - rcand);
			rvals = (const char *) rcand;
			rcand = NULL;
			rwidth = SIZEOF_OID;
		}
		roff = (wrd) r->tseqbase - (wrd) r->hseqbase;
	}
	assert(lvals != NULL || lcand == NULL);
	assert(rvals != NULL || rcand == NULL);

	r1->tkey = 1;
	r1->tsorted = 1;
	r1->trevsorted = 1;
	r2->tkey = 1;
	r2->tsorted = 1;
	r2->trevsorted = 1;

	/* nested loop implementation for theta join */
	for (;;) {
		if (lcand) {
			if (lcand == lcandend)
				break;
			lo = *lcand++;
			vl = VALUE(l, lo - l->hseqbase);
		} else {
			if (lstart == lend)
				break;
			if (lvals) {
				vl = VALUE(l, lstart);
				if (loff != 0) {
					lval = (oid) (*(const oid *)vl + loff);
					vl = (const char *) &lval;
				}
			} else {
				lval = lstart + l->tseqbase;
				vl = (const char *) &lval;
			}
			lo = lstart++ + l->hseqbase;
		}
		if (cmp(vl, nil) == 0)
			continue;
		nr = 0;
		p = rcand;
		n = rstart;
		for (;;) {
			if (rcand) {
				if (p == rcandend)
					break;
				ro = *p++;
				vr = VALUE(r, ro - r->hseqbase);
			} else {
				if (n == rend)
					break;
				if (rvals) {
					vr = VALUE(r, n);
					if (roff != 0) {
						rval = (oid) (*(const oid *)vr + roff);
						vr = (const char *) &rval;
					}
				} else {
					rval = n + r->tseqbase;
					vr = (const char *) &rval;
				}
				ro = n++ + r->hseqbase;
			}
			if (cmp(vr, nil) == 0)
				continue;
			c = cmp(vl, vr);
			if (!((opcode & MASK_LT && c < 0) ||
			      (opcode & MASK_GT && c > 0) ||
			      (opcode & MASK_EQ && c == 0)))
				continue;
			if (BUNlast(r1) == BATcapacity(r1)) {
				newcap = BATgrows(r1);
				if (newcap > maxsize)
					newcap = maxsize;
				BATsetcount(r1, BATcount(r1));
				BATsetcount(r2, BATcount(r2));
				if (BATextend(r1, newcap) != GDK_SUCCEED ||
				    BATextend(r2, newcap) != GDK_SUCCEED)
					goto bailout;
				assert(BATcapacity(r1) == BATcapacity(r2));
			}
			if (BATcount(r2) > 0) {
				if (lastr + 1 != ro)
					r2->tdense = 0;
				if (nr == 0) {
					r1->trevsorted = 0;
					if (lastr > ro) {
						r2->tsorted = 0;
						r2->tkey = 0;
					} else if (lastr < ro) {
						r2->trevsorted = 0;
					} else {
						r2->tkey = 0;
					}
				}
			}
			APPEND(r1, lo);
			APPEND(r2, ro);
			lastr = ro;
			nr++;
		}
		if (nr > 1) {
			r1->tkey = 0;
			r1->tdense = 0;
			r2->trevsorted = 0;
		} else if (nr == 0) {
			lskipped = BATcount(r1) > 0;
		} else if (lskipped) {
			r1->tdense = 0;
		}
	}
	assert(BATcount(r1) == BATcount(r2));
	/* also set other bits of heap to correct value to indicate size */
	BATsetcount(r1, BATcount(r1));
	BATsetcount(r2, BATcount(r2));
	if (BATcount(r1) > 0) {
		if (r1->tdense)
			r1->tseqbase = ((oid *) r1->T->heap.base)[r1->batFirst];
		if (r2->tdense)
			r2->tseqbase = ((oid *) r2->T->heap.base)[r2->batFirst];
	}
	ALGODEBUG fprintf(stderr, "#thetajoin(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;

  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

static gdk_return
bandjoin(BAT *r1, BAT *r2, BAT *l, BAT *r, BAT *sl, BAT *sr,
	 const void *c1, const void *c2, int li, int hi, BUN maxsize, lng t0)
{
	BUN lstart, lend, lcnt;
	const oid *lcand = NULL, *lcandend = NULL;
	BUN rstart, rend, rcnt;
	const oid *rcand = NULL, *rcandend = NULL;
	const char *lvals, *rvals;
	int lwidth, rwidth;
	int t;
	const void *nil = ATOMnilptr(l->ttype);
	int (*cmp)(const void *, const void *) = ATOMcompare(l->ttype);
	const char *vl, *vr;
	const oid *p;
	oid lastr = 0;		/* last value inserted into r2 */
	BUN n, nr;
	BUN newcap;
	oid lo, ro;
	int lskipped = 0;	/* whether we skipped values in l */
	BUN nils = 0;		/* needed for XXX_WITH_CHECK macros */

	ALGODEBUG fprintf(stderr, "#bandjoin(l=%s#" BUNFMT "[%s]%s%s%s,"
			  "r=%s#" BUNFMT "[%s]%s%s%s,sl=%s#" BUNFMT "%s%s%s,"
			  "sr=%s#" BUNFMT "%s%s%s)\n",
			  BATgetId(l), BATcount(l), ATOMname(l->ttype),
			  l->tsorted ? "-sorted" : "",
			  l->trevsorted ? "-revsorted" : "",
			  l->tkey & 1 ? "-key" : "",
			  BATgetId(r), BATcount(r), ATOMname(r->ttype),
			  r->tsorted ? "-sorted" : "",
			  r->trevsorted ? "-revsorted" : "",
			  r->tkey & 1 ? "-key" : "",
			  sl ? BATgetId(sl) : "NULL", sl ? BATcount(sl) : 0,
			  sl && sl->tsorted ? "-sorted" : "",
			  sl && sl->trevsorted ? "-revsorted" : "",
			  sl && sl->tkey & 1 ? "-key" : "",
			  sr ? BATgetId(sr) : "NULL", sr ? BATcount(sr) : 0,
			  sr && sr->tsorted ? "-sorted" : "",
			  sr && sr->trevsorted ? "-revsorted" : "",
			  sr && sr->tkey & 1 ? "-key" : "");

	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(ATOMtype(l->ttype) == ATOMtype(r->ttype));
	assert(sl == NULL || sl->tsorted);
	assert(sr == NULL || sr->tsorted);

	t = ATOMtype(l->ttype);
	t = ATOMbasetype(t);

	switch (t) {
	case TYPE_bte:
		if (*(const bte *)c1 == bte_nil ||
		    *(const bte *)c2 == bte_nil ||
		    -*(const bte *)c1 > *(const bte *)c2 ||
		    ((!hi || !li) && -*(const bte *)c1 == *(const bte *)c2))
			return GDK_SUCCEED;
		break;
	case TYPE_sht:
		if (*(const sht *)c1 == sht_nil ||
		    *(const sht *)c2 == sht_nil ||
		    -*(const sht *)c1 > *(const sht *)c2 ||
		    ((!hi || !li) && -*(const sht *)c1 == *(const sht *)c2))
			return GDK_SUCCEED;
		break;
	case TYPE_int:
		if (*(const int *)c1 == int_nil ||
		    *(const int *)c2 == int_nil ||
		    -*(const int *)c1 > *(const int *)c2 ||
		    ((!hi || !li) && -*(const int *)c1 == *(const int *)c2))
			return GDK_SUCCEED;
		break;
	case TYPE_lng:
		if (*(const lng *)c1 == lng_nil ||
		    *(const lng *)c2 == lng_nil ||
		    -*(const lng *)c1 > *(const lng *)c2 ||
		    ((!hi || !li) && -*(const lng *)c1 == *(const lng *)c2))
			return GDK_SUCCEED;
		break;
#ifdef HAVE_HGE
	case TYPE_hge:
		if (*(const hge *)c1 == hge_nil ||
		    *(const hge *)c2 == hge_nil ||
		    -*(const hge *)c1 > *(const hge *)c2 ||
		    ((!hi || !li) && -*(const hge *)c1 == *(const hge *)c2))
			return GDK_SUCCEED;
		break;
#endif
	case TYPE_flt:
		if (*(const flt *)c1 == flt_nil ||
		    *(const flt *)c2 == flt_nil ||
		    -*(const flt *)c1 > *(const flt *)c2 ||
		    ((!hi || !li) && -*(const flt *)c1 == *(const flt *)c2))
			return GDK_SUCCEED;
		break;
	case TYPE_dbl:
		if (*(const dbl *)c1 == dbl_nil ||
		    *(const dbl *)c2 == dbl_nil ||
		    -*(const dbl *)c1 > *(const dbl *)c2 ||
		    ((!hi || !li) && -*(const dbl *)c1 == *(const dbl *)c2))
			return GDK_SUCCEED;
		break;
	default:
		goto bailout;
	}

	CANDINIT(l, sl, lstart, lend, lcnt, lcand, lcandend);
	CANDINIT(r, sr, rstart, rend, rcnt, rcand, rcandend);

	lvals = (const char *) Tloc(l, BUNfirst(l));
	rvals = (const char *) Tloc(r, BUNfirst(r));
	assert(!r->tvarsized);
	lwidth = l->T->width;
	rwidth = r->T->width;

	assert(lvals != NULL);
	assert(rvals != NULL);

	r1->tkey = 1;
	r1->tsorted = 1;
	r1->trevsorted = 1;
	r2->tkey = 1;
	r2->tsorted = 1;
	r2->trevsorted = 1;

	/* nested loop implementation for band join */
	for (;;) {
		if (lcand) {
			if (lcand == lcandend)
				break;
			lo = *lcand++;
			vl = FVALUE(l, lo - l->hseqbase);
		} else {
			if (lstart == lend)
				break;
			vl = FVALUE(l, lstart);
			lo = lstart++ + l->hseqbase;
		}
		if (cmp(vl, nil) == 0)
			continue;
		nr = 0;
		p = rcand;
		n = rstart;
		for (;;) {
			if (rcand) {
				if (p == rcandend)
					break;
				ro = *p++;
				vr = FVALUE(r, ro - r->hseqbase);
			} else {
				if (n == rend)
					break;
				vr = FVALUE(r, n);
				ro = n++ + r->hseqbase;
			}
			switch (ATOMtype(l->ttype)) {
			case TYPE_bte: {
				sht v1 = (sht) *(const bte *) vr, v2;

				if (v1 == bte_nil)
					continue;
				v2 = v1;
				v1 -= *(const bte *)c1;
				if (*(const bte *)vl <= v1 &&
				    (!li || *(const bte *)vl != v1))
					continue;
				v2 += *(const bte *)c2;
				if (*(const bte *)vl >= v2 &&
				    (!hi || *(const bte *)vl != v2))
					continue;
				break;
			}
			case TYPE_sht: {
				int v1 = (int) *(const sht *) vr, v2;

				if (v1 == sht_nil)
					continue;
				v2 = v1;
				v1 -= *(const sht *)c1;
				if (*(const sht *)vl <= v1 &&
				    (!li || *(const sht *)vl != v1))
					continue;
				v2 += *(const sht *)c2;
				if (*(const sht *)vl >= v2 &&
				    (!hi || *(const sht *)vl != v2))
					continue;
				break;
			}
			case TYPE_int: {
				lng v1 = (lng) *(const int *) vr, v2;

				if (v1 == int_nil)
					continue;
				v2 = v1;
				v1 -= *(const int *)c1;
				if (*(const int *)vl <= v1 &&
				    (!li || *(const int *)vl != v1))
					continue;
				v2 += *(const int *)c2;
				if (*(const int *)vl >= v2 &&
				    (!hi || *(const int *)vl != v2))
					continue;
				break;
			}
#ifdef HAVE_HGE
			case TYPE_lng: {
				hge v1 = (hge) *(const lng *) vr, v2;

				if (v1 == lng_nil)
					continue;
				v2 = v1;
				v1 -= *(const lng *)c1;
				if (*(const lng *)vl <= v1 &&
				    (!li || *(const lng *)vl != v1))
					continue;
				v2 += *(const lng *)c2;
				if (*(const lng *)vl >= v2 &&
				    (!hi || *(const lng *)vl != v2))
					continue;
				break;
			}
#else
#ifdef HAVE___INT128
			case TYPE_lng: {
				__int128 v1 = (__int128) *(const lng *) vr, v2;

				if (v1 == lng_nil)
					continue;
				v2 = v1;
				v1 -= *(const lng *)c1;
				if (*(const lng *)vl <= v1 &&
				    (!li || *(const lng *)vl != v1))
					continue;
				v2 += *(const lng *)c2;
				if (*(const lng *)vl >= v2 &&
				    (!hi || *(const lng *)vl != v2))
					continue;
				break;
			}
#else
			case TYPE_lng: {
				lng v1, v2;
				int abort_on_error = 1;

				if (*(const lng *)vr == lng_nil)
					continue;
				SUB_WITH_CHECK(lng, *(const lng *)vr,
					       lng, *(const lng *)c1,
					       lng, v1,
					       do{if(*(const lng*)c1<0)goto nolmatch;else goto lmatch1;}while(0));
				if (*(const lng *)vl <= v1 &&
				    (!li || *(const lng *)vl != v1))
					continue;
			  lmatch1:
				ADD_WITH_CHECK(lng, *(const lng *)vr,
					       lng, *(const lng *)c2,
					       lng, v2,
					       do{if(*(const lng*)c2>0)goto nolmatch;else goto lmatch2;}while(0));
				if (*(const lng *)vl >= v2 &&
				    (!hi || *(const lng *)vl != v2))
					continue;
			  lmatch2:
				break;
			  nolmatch:
				continue;
			}
#endif
#endif
#ifdef HAVE_HGE
			case TYPE_hge: {
				hge v1, v2;
				int abort_on_error = 1;

				if (*(const hge *)vr == hge_nil)
					continue;
				SUB_WITH_CHECK(hge, *(const hge *)vr,
					       hge, *(const hge *)c1,
					       hge, v1,
					       do{if(*(const hge*)c1<0)goto nohmatch;else goto hmatch1;}while(0));
				if (*(const hge *)vl <= v1 &&
				    (!li || *(const hge *)vl != v1))
					continue;
			  hmatch1:
				ADD_WITH_CHECK(hge, *(const hge *)vr,
					       hge, *(const hge *)c2,
					       hge, v2,
					       do{if(*(const hge*)c2>0)goto nohmatch;else goto hmatch2;}while(0));
				if (*(const hge *)vl >= v2 &&
				    (!hi || *(const hge *)vl != v2))
					continue;
			  hmatch2:
				break;
			  nohmatch:
				continue;
			}
#endif
			case TYPE_flt: {
				dbl v1 = (dbl) *(const flt *) vr, v2;

				if (v1 == flt_nil)
					continue;
				v2 = v1;
				v1 -= *(const flt *)c1;
				if (*(const flt *)vl <= v1 &&
				    (!li || *(const flt *)vl != v1))
					continue;
				v2 += *(const flt *)c2;
				if (*(const flt *)vl >= v2 &&
				    (!hi || *(const flt *)vl != v2))
					continue;
				break;
			}
			case TYPE_dbl: {
				dbl v1, v2;
				int abort_on_error = 1;

				if (*(const dbl *)vr == dbl_nil)
					continue;
				SUB_WITH_CHECK(dbl, *(const dbl *)vr,
					       dbl, *(const dbl *)c1,
					       dbl, v1,
					       do{if(*(const dbl*)c1<0)goto nodmatch;else goto dmatch1;}while(0));
				if (*(const dbl *)vl <= v1 &&
				    (!li || *(const dbl *)vl != v1))
					continue;
			  dmatch1:
				ADD_WITH_CHECK(dbl, *(const dbl *)vr,
					       dbl, *(const dbl *)c2,
					       dbl, v2,
					       do{if(*(const dbl*)c2>0)goto nodmatch;else goto dmatch2;}while(0));
				if (*(const dbl *)vl >= v2 &&
				    (!hi || *(const dbl *)vl != v2))
					continue;
			  dmatch2:
				break;
			  nodmatch:
				continue;
			}
			}
			if (BUNlast(r1) == BATcapacity(r1)) {
				newcap = BATgrows(r1);
				if (newcap > maxsize)
					newcap = maxsize;
				BATsetcount(r1, BATcount(r1));
				BATsetcount(r2, BATcount(r2));
				if (BATextend(r1, newcap) != GDK_SUCCEED ||
				    BATextend(r2, newcap) != GDK_SUCCEED)
					goto bailout;
				assert(BATcapacity(r1) == BATcapacity(r2));
			}
			if (BATcount(r2) > 0) {
				if (lastr + 1 != ro)
					r2->tdense = 0;
				if (nr == 0) {
					r1->trevsorted = 0;
					if (lastr > ro) {
						r2->tsorted = 0;
						r2->tkey = 0;
					} else if (lastr < ro) {
						r2->trevsorted = 0;
					} else {
						r2->tkey = 0;
					}
				}
			}
			APPEND(r1, lo);
			APPEND(r2, ro);
			lastr = ro;
			nr++;
		}
		if (nr > 1) {
			r1->tkey = 0;
			r1->tdense = 0;
			r2->trevsorted = 0;
		} else if (nr == 0) {
			lskipped = BATcount(r1) > 0;
		} else if (lskipped) {
			r1->tdense = 0;
		}
	}
	assert(BATcount(r1) == BATcount(r2));
	/* also set other bits of heap to correct value to indicate size */
	BATsetcount(r1, BATcount(r1));
	BATsetcount(r2, BATcount(r2));
	if (BATcount(r1) > 0) {
		if (r1->tdense)
			r1->tseqbase = ((oid *) r1->T->heap.base)[r1->batFirst];
		if (r2->tdense)
			r2->tseqbase = ((oid *) r2->T->heap.base)[r2->batFirst];
	}
	ALGODEBUG fprintf(stderr, "#bandjoin(l=%s,r=%s)=(%s#"BUNFMT"%s%s%s,%s#"BUNFMT"%s%s%s) " LLFMT "us\n",
			  BATgetId(l), BATgetId(r),
			  BATgetId(r1), BATcount(r1),
			  r1->tsorted ? "-sorted" : "",
			  r1->trevsorted ? "-revsorted" : "",
			  r1->tkey & 1 ? "-key" : "",
			  BATgetId(r2), BATcount(r2),
			  r2->tsorted ? "-sorted" : "",
			  r2->trevsorted ? "-revsorted" : "",
			  r2->tkey & 1 ? "-key" : "",
			  GDKusec() - t0);
	return GDK_SUCCEED;

  bailout:
	BBPreclaim(r1);
	BBPreclaim(r2);
	return GDK_FAIL;
}

/* Make the implementation choices for various left joins. */
static gdk_return
subleftjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate, int nil_on_miss, int semi, int must_match, const char *name, lng t0)
{
	BAT *r1, *r2;
	BUN lcount, rcount, maxsize;

	*r1p = NULL;
	*r2p = NULL;
	if (joinparamcheck(l, r, NULL, sl, sr, name) != GDK_SUCCEED)
		return GDK_FAIL;

	lcount = BATcount(l);
	if (sl)
		lcount = MIN(lcount, BATcount(sl));
	rcount = BATcount(r);
	if (sr)
		rcount = MIN(rcount, BATcount(sr));

	if ((maxsize = joininitresults(&r1, &r2, lcount, rcount, l->tkey, r->tkey, semi, nil_on_miss, estimate, name)) == BUN_NONE)
		return GDK_FAIL;
	*r1p = r1;
	*r2p = r2;
	if (BATtdense(r) && (sr == NULL || BATtdense(sr)) && lcount > 0 && rcount > 0) {
		/* use special implementation for dense right-hand side */
		return mergejoin_void(r1, r2, l, r, sl, sr,
				      nil_on_miss, must_match, t0);
	} else if ((BATordered(BATmirror(r)) ||
		    BATordered_rev(BATmirror(r))) &&
		   (BATtdense(r) ||
		    lcount < 1024 ||
		    BATcount(r) * (Tsize(r) + (r->T->vheap ? r->T->vheap->size : 0) + 2 * sizeof(BUN)) > GDK_mem_maxsize / (GDKnr_threads ? GDKnr_threads : 1)))
		return mergejoin(r1, r2, l, r, sl, sr, nil_matches,
				 nil_on_miss, semi, must_match, maxsize, t0, 0);
	return hashjoin(r1, r2, l, r, sl, sr, nil_matches,
			nil_on_miss, semi, must_match, maxsize, t0, 0, "leftjoin");
}

/* Perform an equi-join over l and r.  Returns two new, aligned,
 * dense-headed bats with in the tail the oids (head column values) of
 * matching tuples.  The result is in the same order as l (i.e. r1 is
 * sorted). */
gdk_return
BATsubleftjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate)
{
	return subleftjoin(r1p, r2p, l, r, sl, sr, nil_matches, estimate,
			   0, 0, 0, "BATsubleftjoin", GDKusec());
}

/* Perform an equi-join over l and r.  Returns two new, aligned,
 * dense-headed bats with in the tail the oids (head column values) of
 * matching tuples.  The result is in the same order as l (i.e. r1 is
 * sorted).  All values in l must match at least one value in r. */
gdk_return
BATsubleftfetchjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate)
{
	return subleftjoin(r1p, r2p, l, r, sl, sr, nil_matches, estimate,
			   0, 0, 1, "BATsubleftfetchjoin", GDKusec());
}

/* Performs a left outer join over l and r.  Returns two new, aligned,
 * dense-headed bats with in the tail the oids (head column values) of
 * matching tuples, or the oid in the first output bat and nil in the
 * second output bat if the value in l does not occur in r.  The
 * result is in the same order as l (i.e. r1 is sorted). */
gdk_return
BATsubouterjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate)
{
	return subleftjoin(r1p, r2p, l, r, sl, sr, nil_matches, estimate,
			   1, 0, 0, "BATsubouterjoin", GDKusec());
}

/* Perform a semi-join over l and r.  Returns two new, aligned,
 * dense-headed bats with in the tail the oids (head column values) of
 * matching tuples.  The result is in the same order as l (i.e. r1 is
 * sorted). */
gdk_return
BATsubsemijoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate)
{
	return subleftjoin(r1p, r2p, l, r, sl, sr, nil_matches, estimate,
			   0, 1, 0, "BATsubsemijoin", GDKusec());
}

gdk_return
BATsubthetajoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int op, int nil_matches, BUN estimate)
{
	BAT *r1, *r2;
	BUN maxsize;
	int opcode = 0;
	lng t0;

	/* encode operator as a bit mask into opcode */
	switch (op) {
	case JOIN_EQ:
		return BATsubjoin(r1p, r2p, l, r, sl, sr, nil_matches, estimate);
	case JOIN_NE:
		opcode = MASK_NE;
		break;
	case JOIN_LT:
		opcode = MASK_LT;
		break;
	case JOIN_LE:
		opcode = MASK_LE;
		break;
	case JOIN_GT:
		opcode = MASK_GT;
		break;
	case JOIN_GE:
		opcode = MASK_GE;
		break;
	default:
		GDKerror("BATsubthetajoin: unknown operator %d.\n", op);
		return GDK_FAIL;
	}

	t0 = GDKusec();
	*r1p = NULL;
	*r2p = NULL;
	if (joinparamcheck(l, r, NULL, sl, sr, "BATsubthetajoin") != GDK_SUCCEED)
		return GDK_FAIL;
	if ((maxsize = joininitresults(&r1, &r2, sl ? BATcount(sl) : BATcount(l), sr ? BATcount(sr) : BATcount(r), 0, 0, 0, 0, estimate, "BATsubthetajoin")) == BUN_NONE)
		return GDK_FAIL;
	*r1p = r1;
	*r2p = r2;

	return thetajoin(r1, r2, l, r, sl, sr, opcode, maxsize, t0);
}

gdk_return
BATsubjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr, int nil_matches, BUN estimate)
{
	BAT *r1, *r2;
	BUN lcount, rcount, lpcount, rpcount;
	BUN lsize, rsize;
	BUN maxsize;
	int lhash, rhash;
#ifndef DISABLE_PARENT_HASH
	bat lparent, rparent;
#endif
	int swap;
	size_t mem_size;
	lng t0 = GDKusec();
	const char *reason = "";

	*r1p = NULL;
	*r2p = NULL;
	if (joinparamcheck(l, r, NULL, sl, sr, "BATsubjoin") != GDK_SUCCEED)
		return GDK_FAIL;
	lcount = BATcount(l);
	if (sl)
		lcount = MIN(lcount, BATcount(sl));
	rcount = BATcount(r);
	if (sr)
		rcount = MIN(rcount, BATcount(sr));
	if (lcount == 0 || rcount == 0) {
		r1 = BATnew(TYPE_void, TYPE_void, 0, TRANSIENT);
		r2 = BATnew(TYPE_void, TYPE_void, 0, TRANSIENT);
		if (r1 == NULL || r2 == NULL) {
			BBPreclaim(r1);
			BBPreclaim(r2);
			return GDK_FAIL;
		}
		BATseqbase(r1, 0);
		BATseqbase(BATmirror(r1), 0);
		BATseqbase(r2, 0);
		BATseqbase(BATmirror(r2), 0);
		*r1p = r1;
		*r2p = r2;
		return GDK_SUCCEED;
	}
	if ((maxsize = joininitresults(&r1, &r2, lcount, rcount, l->tkey, r->tkey, 0, 0, estimate, "BATsubjoin")) == BUN_NONE)
		return GDK_FAIL;
	*r1p = r1;
	*r2p = r2;
	swap = 0;

	/* some statistics to help us decide */
	lsize = (BUN) (BATcount(l) * (Tsize(l)) + (l->T->vheap ? l->T->vheap->size : 0) + 2 * sizeof(BUN));
	rsize = (BUN) (BATcount(r) * (Tsize(r)) + (r->T->vheap ? r->T->vheap->size : 0) + 2 * sizeof(BUN));
	mem_size = GDK_mem_maxsize / (GDKnr_threads ? GDKnr_threads : 1);

#ifndef DISABLE_PARENT_HASH
	lparent = VIEWtparent(l);
	if (lparent) {
		lpcount = BATcount(BBPdescriptor(lparent));
		lhash = BATcheckhash(l) || BATcheckhash(BBPdescriptor(-lparent));
	} else
#endif
	{
		lpcount = BATcount(l);
		lhash = BATcheckhash(l);
	}
#ifndef DISABLE_PARENT_HASH
	rparent = VIEWtparent(r);
	if (rparent) {
		rpcount = BATcount(BBPdescriptor(rparent));
		rhash = BATcheckhash(r) || BATcheckhash(BBPdescriptor(-rparent));
	} else
#endif
	{
		rpcount = BATcount(r);
		rhash = BATcheckhash(r);
	}
	if (BATtdense(r) && (sr == NULL || BATtdense(sr))) {
		/* use special implementation for dense right-hand side */
		return mergejoin_void(r1, r2, l, r, sl, sr, 0, 0, t0);
	} else if (BATtdense(l) && (sl == NULL || BATtdense(sl))) {
		/* use special implementation for dense right-hand side */
		return mergejoin_void(r2, r1, r, l, sr, sl, 0, 0, t0);
	} else if ((BATordered(BATmirror(l)) || BATordered_rev(BATmirror(l))) &&
		   (BATordered(BATmirror(r)) || BATordered_rev(BATmirror(r)))) {
		/* both sorted, smallest on left */
		if (BATcount(l) <= BATcount(r))
			return mergejoin(r1, r2, l, r, sl, sr, nil_matches, 0, 0, 0, maxsize, t0, 0);
		else
			return mergejoin(r2, r1, r, l, sr, sl, nil_matches, 0, 0, 0, maxsize, t0, 1);
	} else if (lhash && rhash) {
		/* both have hash, smallest on right */
		swap = lcount < rcount;
		reason = "both have hash";
	} else if (lhash) {
		/* only left has hash, swap */
		swap = 1;
		reason = "left has hash";
	} else if (rhash) {
		/* only right has hash, don't swap */
		swap = 0;
		reason = "right has hash";
	} else if ((BATordered(BATmirror(l)) || BATordered_rev(BATmirror(l))) &&
		   (l->ttype == TYPE_void || rcount < 1024 || MIN(lsize, rsize) > mem_size)) {
		/* only left is sorted, swap; but only if right is
		 * "large" and the smaller of the two isn't too large
		 * (i.e. prefer hash over binary search, but only if
		 * the hash table doesn't cause thrashing) */
		return mergejoin(r2, r1, r, l, sr, sl, nil_matches, 0, 0, 0, maxsize, t0, 1);
	} else if ((BATordered(BATmirror(r)) || BATordered_rev(BATmirror(r))) &&
		   (r->ttype == TYPE_void || lcount < 1024 || MIN(lsize, rsize) > mem_size)) {
		/* only right is sorted, don't swap; but only if left
		 * is "large" and the smaller of the two isn't too
		 * large (i.e. prefer hash over binary search, but
		 * only if the hash table doesn't cause thrashing) */
		return mergejoin(r1, r2, l, r, sl, sr, nil_matches, 0, 0, 0, maxsize, t0, 0);
	} else if ((l->batPersistence == PERSISTENT
#ifndef DISABLE_PARENT_HASH
		     || (lparent != 0 &&
			 BBPquickdesc(abs(lparent), 0)->batPersistence == PERSISTENT)
#endif
			   ) &&
		   !(r->batPersistence == PERSISTENT
#ifndef DISABLE_PARENT_HASH
		     || (rparent != 0 &&
			 BBPquickdesc(abs(rparent), 0)->batPersistence == PERSISTENT)
#endif
			   )) {
		/* l (or its parent) is persistent and r is not,
		 * create hash on l since it may be reused */
		swap = 1;
		reason = "left is persistent";
	} else if (!(l->batPersistence == PERSISTENT
#ifndef DISABLE_PARENT_HASH
		     || (lparent != 0 &&
			 BBPquickdesc(abs(lparent), 0)->batPersistence == PERSISTENT)
#endif
			   ) &&
		   (r->batPersistence == PERSISTENT
#ifndef DISABLE_PARENT_HASH
		    || (rparent != 0 &&
			BBPquickdesc(abs(rparent), 0)->batPersistence == PERSISTENT)
#endif
			   )) {
		/* l (and its parent) is not persistent but r (or its
		 * parent) is, create hash on r since it may be
		 * reused */
		/* nothing */;
		reason = "right is persistent";
	} else if (lpcount < rpcount) {
		/* no hashes, not sorted, create hash on smallest BAT */
		swap = 1;
		reason = "left is smaller";
	}
	if (swap) {
		return hashjoin(r2, r1, r, l, sr, sl, nil_matches, 0, 0, 0, maxsize, t0, 1, reason);
	} else {
		return hashjoin(r1, r2, l, r, sl, sr, nil_matches, 0, 0, 0, maxsize, t0, 0, reason);
	}
}

gdk_return
BATsubbandjoin(BAT **r1p, BAT **r2p, BAT *l, BAT *r, BAT *sl, BAT *sr,
	       const void *c1, const void *c2, int li, int hi, BUN estimate)
{
	BAT *r1, *r2;
	BUN maxsize;
	lng t0 = GDKusec();

	*r1p = NULL;
	*r2p = NULL;
	if (joinparamcheck(l, r, NULL, sl, sr, "BATsubbandjoin") != GDK_SUCCEED)
		return GDK_FAIL;
	if ((maxsize = joininitresults(&r1, &r2, sl ? BATcount(sl) : BATcount(l), sr ? BATcount(sr) : BATcount(r), 0, 0, 0, 0, estimate, "BATsubbandjoin")) == BUN_NONE)
		return GDK_FAIL;
	*r1p = r1;
	*r2p = r2;

	return bandjoin(r1, r2, l, r, sl, sr, c1, c2, li, hi, maxsize, t0);
}

gdk_return
BATsubrangejoin(BAT **r1p, BAT **r2p, BAT *l, BAT *rl, BAT *rh,
		BAT *sl, BAT *sr, int li, int hi, BUN estimate)
{
	BAT *r1, *r2;
	BUN maxsize;

	*r1p = NULL;
	*r2p = NULL;
	if (joinparamcheck(l, rl, rh, sl, sr, "BATsubrangejoin") != GDK_SUCCEED)
		return GDK_FAIL;
	if ((maxsize = joininitresults(&r1, &r2, sl ? BATcount(sl) : BATcount(l), sr ? BATcount(sr) : BATcount(rl), 0, 0, 0, 0, estimate, "BATsubrangejoin")) == BUN_NONE)
		return GDK_FAIL;
	*r1p = r1;
	*r2p = r2;

	/* note, the rangejoin implementation is in gdk_select.c since
	 * it uses the imprints code there */
	return rangejoin(r1, r2, l, rl, rh, sl, sr, li, hi, maxsize);
}

#define project_loop(TYPE)						\
static gdk_return							\
project_##TYPE(BAT *bn, BAT *l, BAT *r, int nilcheck)			\
{									\
	oid lo, hi;							\
	const TYPE *restrict rt;					\
	TYPE *restrict bt;						\
	TYPE v;								\
	const oid *restrict o;						\
	oid rseq, rend;							\
									\
	o = (const oid *) Tloc(l, BUNfirst(l));				\
	rt = (const TYPE *) Tloc(r, BUNfirst(r));			\
	bt = (TYPE *) Tloc(bn, BUNfirst(bn));				\
	rseq = r->hseqbase;						\
	rend = rseq + BATcount(r);					\
	lo = 0;								\
	hi = lo + BATcount(l);						\
	if (nilcheck) {							\
		for (; lo < hi; lo++) {					\
			if (o[lo] < rseq || o[lo] >= rend) {		\
				if (o[lo] == oid_nil) {			\
					bt[lo] = TYPE##_nil;		\
					bn->T->nonil = 0;		\
					bn->T->nil = 1;			\
					bn->tsorted = 0;		\
					bn->trevsorted = 0;		\
					bn->tkey = 0;			\
					lo++;				\
					break;				\
				} else {				\
					GDKerror("BATproject: does not match always\n"); \
					return GDK_FAIL;		\
				}					\
			} else {					\
				v = rt[o[lo] - rseq];			\
				bt[lo] = v;				\
				if (v == TYPE##_nil && bn->T->nonil) {	\
					bn->T->nonil = 0;		\
					bn->T->nil = 1;			\
					lo++;				\
					break;				\
				}					\
			}						\
		}							\
	}								\
	for (; lo < hi; lo++) {						\
		if (o[lo] < rseq || o[lo] >= rend) {			\
			if (o[lo] == oid_nil) {				\
				bt[lo] = TYPE##_nil;			\
				bn->T->nonil = 0;			\
				bn->T->nil = 1;				\
				bn->tsorted = 0;			\
				bn->trevsorted = 0;			\
				bn->tkey = 0;				\
			} else {					\
				GDKerror("BATproject: does not match always\n"); \
				return GDK_FAIL;			\
			}						\
		} else {						\
			v = rt[o[lo] - rseq];				\
			bt[lo] = v;					\
		}							\
	}								\
	assert((BUN) lo == BATcount(l));				\
	BATsetcount(bn, (BUN) lo);					\
	return GDK_SUCCEED;						\
}


/* project type switch */
project_loop(bte)
project_loop(sht)
project_loop(int)
project_loop(flt)
project_loop(dbl)
project_loop(lng)
#ifdef HAVE_HGE
project_loop(hge)
#endif

static gdk_return
project_void(BAT *bn, BAT *l, BAT *r)
{
	oid lo, hi;
	oid *restrict bt;
	const oid *o;
	oid rseq, rend;

	assert(r->tseqbase != oid_nil);
	o = (const oid *) Tloc(l, BUNfirst(l));
	bt = (oid *) Tloc(bn, BUNfirst(bn));
	bn->tsorted = l->tsorted;
	bn->trevsorted = l->trevsorted;
	bn->tkey = l->tkey & 1;
	bn->T->nonil = 1;
	bn->T->nil = 0;
	rseq = r->hseqbase;
	rend = rseq + BATcount(r);
	for (lo = 0, hi = lo + BATcount(l); lo < hi; lo++) {
		if (o[lo] < rseq || o[lo] >= rend) {
			if (o[lo] == oid_nil) {
				bt[lo] = oid_nil;
				bn->T->nonil = 0;
				bn->T->nil = 1;
				bn->tsorted = 0;
				bn->trevsorted = 0;
				bn->tkey = 0;
			} else {
				GDKerror("BATproject: does not match always\n");
				return GDK_FAIL;
			}
		} else {
			bt[lo] = o[lo] - rseq + r->tseqbase;
		}
	}
	assert((BUN) lo == BATcount(l));
	BATsetcount(bn, (BUN) lo);
	return GDK_SUCCEED;
}

static gdk_return
project_any(BAT *bn, BAT *l, BAT *r, int nilcheck)
{
	BUN n;
	oid lo, hi;
	BATiter ri;
	int (*cmp)(const void *, const void *) = ATOMcompare(r->ttype);
	const void *nil = ATOMnilptr(r->ttype);
	const void *v;
	const oid *o;
	oid rseq, rend;

	o = (const oid *) Tloc(l, BUNfirst(l));
	n = BUNfirst(bn);
	ri = bat_iterator(r);
	rseq = r->hseqbase;
	rend = rseq + BATcount(r);
	for (lo = 0, hi = lo + BATcount(l); lo < hi; lo++, n++) {
		if (o[lo] < rseq || o[lo] >= rend) {
			if (o[lo] == oid_nil) {
				tfastins_nocheck(bn, n, nil, Tsize(bn));
				bn->T->nonil = 0;
				bn->T->nil = 1;
				bn->tsorted = 0;
				bn->trevsorted = 0;
				bn->tkey = 0;
			} else {
				GDKerror("BATproject: does not match always\n");
				goto bunins_failed;
			}
		} else {
			v = BUNtail(ri, o[lo] - rseq + BUNfirst(r));
			tfastins_nocheck(bn, n, v, Tsize(bn));
			if (nilcheck && bn->T->nonil && cmp(v, nil) == 0) {
				bn->T->nonil = 0;
				bn->T->nil = 1;
			}
		}
	}
	assert(n == BATcount(l));
	BATsetcount(bn, n);
	return GDK_SUCCEED;
bunins_failed:
	return GDK_FAIL;
}

BAT *
BATproject(BAT *l, BAT *r)
{
	BAT *bn;
	oid lo, hi;
	gdk_return res;
	int tpe = ATOMtype(r->ttype), nilcheck = 1, stringtrick = 0;
	BUN lcount = BATcount(l), rcount = BATcount(r);
	lng t0 = GDKusec();

	ALGODEBUG fprintf(stderr, "#BATproject(l=%s#" BUNFMT "%s%s%s,"
			  "r=%s#" BUNFMT "[%s]%s%s%s)\n",
			  BATgetId(l), BATcount(l),
			  l->tsorted ? "-sorted" : "",
			  l->trevsorted ? "-revsorted" : "",
			  l->tkey & 1 ? "-key" : "",
			  BATgetId(r), BATcount(r), ATOMname(r->ttype),
			  r->tsorted ? "-sorted" : "",
			  r->trevsorted ? "-revsorted" : "",
			  r->tkey & 1 ? "-key" : "");

	assert(BAThdense(l));
	assert(BAThdense(r));
	assert(ATOMtype(l->ttype) == TYPE_oid);

	if (BATtdense(l) && BATcount(l) > 0) {
		lo = l->tseqbase;
		hi = l->tseqbase + BATcount(l);
		if (lo < r->hseqbase || hi > r->hseqbase + BATcount(r)) {
			GDKerror("BATproject: does not match always\n");
			return NULL;
		}
		bn = BATslice(r, lo - r->hseqbase, hi - r->hseqbase);
		if (bn == NULL)
			return NULL;
		BATseqbase(bn, l->hseqbase + (lo - l->tseqbase));
		ALGODEBUG fprintf(stderr, "#BATproject(l=%s,r=%s)=%s#"BUNFMT"%s%s%s\n",
				  BATgetId(l), BATgetId(r), BATgetId(bn), BATcount(bn),
				  bn->tsorted ? "-sorted" : "",
				  bn->trevsorted ? "-revsorted" : "",
				  bn->tkey & 1 ? "-key" : "");
		assert(bn->htype == TYPE_void);
		return bn;
	}
	if (l->ttype == TYPE_void || BATcount(l) == 0 ||
	    (r->ttype == TYPE_void && r->tseqbase == oid_nil)) {
		/* trivial: all values are nil */
		const void *nil = ATOMnilptr(r->ttype);

		bn = BATconstant(r->ttype == TYPE_oid ? TYPE_void : r->ttype,
				 nil, BATcount(l), TRANSIENT);
		if (bn == NULL)
			return NULL;
		BATseqbase(bn, l->hseqbase);
		if (ATOMtype(bn->ttype) == TYPE_oid &&
		    BATcount(bn) == 0) {
			bn->tdense = 1;
			BATseqbase(BATmirror(bn), 0);
		}
		ALGODEBUG fprintf(stderr, "#BATproject(l=%s,r=%s)=%s#"BUNFMT"%s%s%s\n",
				  BATgetId(l), BATgetId(r),
				  BATgetId(bn), BATcount(bn),
				  bn->tsorted ? "-sorted" : "",
				  bn->trevsorted ? "-revsorted" : "",
				  bn->tkey & 1 ? "-key" : "");
		return bn;
	}
	assert(l->ttype == TYPE_oid);

	if (ATOMstorage(tpe) == TYPE_str &&
	    l->T->nonil &&
	    (rcount == 0 ||
	     lcount > (rcount >> 3) ||
	     r->batRestricted == BAT_READ)) {
		/* insert strings as ints, we need to copy the string
		 * heap whole sale; we can not do this if there are
		 * nils in the left column, and we will not do it if
		 * the left is much smaller than the right and the
		 * right is writable (meaning we have to actually copy
		 * the right string heap) */
		tpe = r->T->width == 1 ? TYPE_bte : (r->T->width == 2 ? TYPE_sht : (r->T->width == 4 ? TYPE_int : TYPE_lng));
		/* int's nil representation is a valid offset, so
		 * don't check for nils */
		nilcheck = 0;
		stringtrick = 1;
	}
	bn = BATnew(TYPE_void, tpe, BATcount(l), TRANSIENT);
	if (bn == NULL)
		return NULL;
	if (stringtrick) {
		/* "string type" */
		bn->tsorted = 0;
		bn->trevsorted = 0;
		bn->tkey = 0;
		bn->T->nonil = 0;
	} else {
		/* be optimistic, we'll clear these if necessary later */
		bn->T->nonil = 1;
		bn->tsorted = 1;
		bn->trevsorted = 1;
		bn->tkey = 1;
		if (l->T->nonil && r->T->nonil)
			nilcheck = 0; /* don't bother checking: no nils */
		if (tpe != TYPE_oid &&
		    tpe != ATOMstorage(tpe) &&
		    !ATOMvarsized(tpe) &&
		    ATOMcompare(tpe) == ATOMcompare(ATOMstorage(tpe)) &&
		    (!nilcheck ||
		     ATOMnilptr(tpe) == ATOMnilptr(ATOMstorage(tpe)))) {
			/* use base type if we can:
			 * only fixed sized (no advantage for variable sized),
			 * compare function identical (for sorted check),
			 * either no nils, or nil representation identical,
			 * not oid (separate case for those) */
			tpe = ATOMstorage(tpe);
		}
	}
	bn->T->nil = 0;

	switch (tpe) {
	case TYPE_bte:
		res = project_bte(bn, l, r, nilcheck);
		break;
	case TYPE_sht:
		res = project_sht(bn, l, r, nilcheck);
		break;
	case TYPE_int:
		res = project_int(bn, l, r, nilcheck);
		break;
	case TYPE_flt:
		res = project_flt(bn, l, r, nilcheck);
		break;
	case TYPE_dbl:
		res = project_dbl(bn, l, r, nilcheck);
		break;
	case TYPE_lng:
		res = project_lng(bn, l, r, nilcheck);
		break;
#ifdef HAVE_HGE
	case TYPE_hge:
		res = project_hge(bn, l, r, nilcheck);
		break;
#endif
	case TYPE_oid:
		if (r->ttype == TYPE_void) {
			res = project_void(bn, l, r);
		} else {
#if SIZEOF_OID == SIZEOF_INT
			res = project_int(bn, l, r, nilcheck);
#else
			res = project_lng(bn, l, r, nilcheck);
#endif
		}
		break;
	default:
		res = project_any(bn, l, r, nilcheck);
		break;
	}

	if (res != GDK_SUCCEED)
		goto bailout;

	/* handle string trick */
	if (stringtrick) {
		if (r->batRestricted == BAT_READ) {
			/* really share string heap */
			assert(r->T->vheap->parentid > 0);
			BBPshare(r->T->vheap->parentid);
			bn->T->vheap = r->T->vheap;
		} else {
			/* make copy of string heap */
			bn->T->vheap = (Heap *) GDKzalloc(sizeof(Heap));
			if (bn->T->vheap == NULL)
				goto bailout;
			bn->T->vheap->parentid = bn->batCacheid;
			bn->T->vheap->farmid = BBPselectfarm(bn->batRole, TYPE_str, varheap);
			if (r->T->vheap->filename) {
				char *nme = BBP_physical(bn->batCacheid);
				bn->T->vheap->filename = GDKfilepath(NOFARM, NULL, nme, "theap");
				if (bn->T->vheap->filename == NULL)
					goto bailout;
			}
			if (HEAPcopy(bn->T->vheap, r->T->vheap) != GDK_SUCCEED)
				goto bailout;
		}
		bn->ttype = r->ttype;
		bn->tvarsized = 1;
		bn->T->width = r->T->width;
		bn->T->shift = r->T->shift;

		bn->T->nil = 0; /* we don't know */
	}
	/* some properties follow from certain combinations of input
	 * properties */
	if (BATcount(bn) <= 1) {
		bn->tkey = 1;
		bn->tsorted = 1;
		bn->trevsorted = 1;
	} else {
		bn->tkey = l->tkey && r->tkey;
		bn->tsorted = (l->tsorted & r->tsorted) | (l->trevsorted & r->trevsorted);
		bn->trevsorted = (l->tsorted & r->trevsorted) | (l->trevsorted & r->tsorted);
	}
	bn->T->nonil |= l->T->nonil & r->T->nonil;

	BATseqbase(bn, l->hseqbase);
	if (!BATtdense(r))
		BATseqbase(BATmirror(bn), oid_nil);
	ALGODEBUG fprintf(stderr, "#BATproject(l=%s,r=%s)=%s#"BUNFMT"%s%s%s%s " LLFMT "us\n",
			  BATgetId(l), BATgetId(r), BATgetId(bn), BATcount(bn),
			  bn->tsorted ? "-sorted" : "",
			  bn->trevsorted ? "-revsorted" : "",
			  bn->tkey & 1 ? "-key" : "",
			  bn->ttype == TYPE_str && bn->T->vheap == r->T->vheap ? " shared string heap" : "",
			  GDKusec() - t0);
	return bn;

  bailout:
	BBPreclaim(bn);
	return NULL;
}
