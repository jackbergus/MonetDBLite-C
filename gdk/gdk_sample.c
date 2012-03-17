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
 * @f gdk_sample
 * @a Lefteris Sidirourgos
 * @* Low level sample facilities
 *
 */

#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_private.h"

#define DRAND ((double)rand()/(double)RAND_MAX)

/*
 * @+ Uniform Sampling.
 *
 * The implementation of the uniform sampling is based on the algorithm A as
 * described in the paper "Faster Methods for Random Sampling" by Jeffrey Scott
 * Vitter. Algorithm A is not the fastest one, but it only makes s calls in
 * function random() and it is simpler than the other more complex and CPU
 * intensive algorithms in the literature.
 *
 * Algorithm A instead of performing one random experiment for each row to
 * decide if it should be included in the sample or not, it skips S rows
 * and includes the S+1 row. The algorithm scans the input relation
 * sequentially and maintains the unique and sort properties. The sample is
 * without replacement.
 */

BAT *
BATsample(BAT *b, BUN n)
{
	BAT *bn;
	BUN cnt;

	BATcheck(b, "BATsample");
	ERRORcheck(n > BUN_MAX, "BATsample: sample size larger than BUN_MAX\n");
	ALGODEBUG THRprintf(GDKout, "#BATsample: sample " BUNFMT " elements.\n", n);

	cnt = BATcount(b);
	if (cnt <= n) {
		bn = BATcopy(b, b->htype, b->ttype, FALSE);
	} else {
		BUN top = cnt - n;
		BUN smp = n;
		BATiter iter = bat_iterator(b);
		BUN p = BUNfirst(b)-1;
		bn = BATnew(
			b->htype==TYPE_void && b->hseqbase!=oid_nil?TYPE_oid:b->htype,
			b->ttype==TYPE_void && b->tseqbase!=oid_nil?TYPE_oid:b->ttype,
			n);
		if (bn == NULL)
			return NULL;
		if (n == 0)
			return bn;
		while (smp-->1) { /* loop until all but 1 values are sampled */
			double v = DRAND;
			double quot = (double)top/(double)cnt;
			BUN jump = 0;
			while (quot > v) { /* determine how many positions to jump */
				jump++;
				top--;
				cnt--;
				quot *= (double)top/(double)cnt;
			}
			p += (jump+1);
			cnt--;
			bunfastins(bn, BUNhead(iter, p), BUNtail(iter,p));
		}
		/* 1 left */
		p += (BUN) rand() % cnt;
		bunfastins(bn, BUNhead(iter, p+1), BUNtail(iter,p+1));

		/* property management */
		bn->tsorted = BATtordered(b);
		bn->hsorted = BAThordered(b);
		bn->hdense = FALSE;
		bn->tdense = FALSE;
		BATkey(bn, BAThkey(b));
		BATkey(BATmirror(bn), BATtkey(b));
		bn->H->nonil = b->H->nonil;
		bn->T->nonil = b->T->nonil;
		BATsetcount(bn, n);
	}

	return bn;

bunins_failed:
	BBPreclaim(bn);
	return NULL;
}
