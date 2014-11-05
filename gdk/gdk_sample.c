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
 * Copyright August 2008-2014 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * @a Lefteris Sidirourgos, Hannes Muehleisen
 * @* Low level sample facilities
 *
 * This sampling implementation generates a sorted set of OIDs by calling the
 * random number generator, and uses a binary tree to eliminate duplicates.
 * The elements of the tree are then used to create a sorted sample BAT.
 * This implementation has a logarithmic complexity that only depends on the
 * sample size.
 *
 * There is a pathological case when the sample size is almost the size of the BAT.
 * Then, many collisions occur and performance degrades. To catch this, we 
 * switch to antiset semantics when the sample size is larger than half the BAT
 * size. Then, we generate the values that should be omitted from the sample.
 *
 */

#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_private.h"

#undef BATsample

#ifdef STATIC_CODE_ANALYSIS
#define DRAND (0.5)
#else
/* the range of rand() is [0..RAND_MAX], i.e. inclusive;
 * cast first, add later: on Linux RAND_MAX == INT_MAX, so adding 1
 * will overflow, but INT_MAX does fit in a double */
#if RAND_MAX < 46340	    /* 46340*46340 = 2147395600 < INT_MAX */
/* random range is too small, double it */
#define DRAND ((double)(rand() * (RAND_MAX + 1) + rand()) / ((double) ((RAND_MAX + 1) * (RAND_MAX + 1))))
#else
#define DRAND ((double)rand() / ((double)RAND_MAX + 1))
#endif
#endif


/* this is a straightforward implementation of a binary tree */
struct oidtreenode {
	BUN oid;
	struct oidtreenode* left;
	struct oidtreenode* right;
};


static struct oidtreenode* OIDTreeNew(BUN oid) {
	struct oidtreenode *node = GDKmalloc(sizeof(struct oidtreenode));
	if (node == NULL) {
		GDKerror("#BATsample: memory allocation error");
		return NULL ;
	}
	node->oid = oid;
	node->left = NULL;
	node->right = NULL;
	return (node);
}

static int
OIDTreeMaybeInsert(struct oidtreenode** nodep, BUN oid)
{
	while (*nodep) {
		if (oid == (*nodep)->oid)
			return 0;
		if (oid < (*nodep)->oid)
			nodep = &(*nodep)->left;
		else
			nodep = &(*nodep)->right;
	}
	if ((*nodep = OIDTreeNew(oid)) == NULL)
		return -1;
	return 1;
}

/* inorder traversal, gives us a sorted BAT */
static void OIDTreeToBAT(struct oidtreenode* node, BAT *bat) {
	if (node->left != NULL)
		OIDTreeToBAT(node->left, bat);
	((oid *) bat->T->heap.base)[bat->batFirst + bat->batCount++] = node->oid;
	if (node->right != NULL )
		OIDTreeToBAT(node->right, bat);
}

/* Antiset traversal, give us all values but the ones in the tree */
static void OIDTreeToBATAntiset(struct oidtreenode* node, BAT *bat, BUN start, BUN stop) {
	BUN noid;
	if (node->left != NULL)
        	OIDTreeToBATAntiset(node->left, bat, start, node->oid);
	else 
		for (noid = start+1; noid < node->oid; noid++)
			((oid *) bat->T->heap.base)[bat->batFirst + bat->batCount++] = noid;			
	
        if (node->right != NULL)
 		OIDTreeToBATAntiset(node->right, bat, node->oid, stop);
	else
		for (noid = node->oid+1; noid < stop; noid++)
                        ((oid *) bat->T->heap.base)[bat->batFirst + bat->batCount++] = noid;
}

static void OIDTreeDestroy(struct oidtreenode* node) {
	if (node == NULL) {
		return;
	}
	if (node->left != NULL) {
		OIDTreeDestroy(node->left);
	}
	if (node->right != NULL) {
		OIDTreeDestroy(node->right);
	}
	GDKfree(node);
}


/* BATsample implements sampling for void headed BATs */
BAT *
BATsample(BAT *b, BUN n) {
	BAT *bn;
	BUN cnt, slen;
	BUN rescnt = 0;
	struct oidtreenode* tree = NULL;

	BATcheck(b, "BATsample");
	assert(BAThdense(b));
	ERRORcheck(n > BUN_MAX, "BATsample: sample size larger than BUN_MAX\n");
	ALGODEBUG
		fprintf(stderr, "#BATsample: sample " BUNFMT " elements.\n", n);

	cnt = BATcount(b);
	/* empty sample size */
	if (n == 0) {
		bn = BATnew(TYPE_void, TYPE_void, 0, TRANSIENT);
		if (bn == NULL) {
			GDKerror("BATsample: memory allocation error");
			return NULL;
		}
		BATsetcount(bn, 0);
		BATseqbase(bn, 0);
		BATseqbase(BATmirror(bn), 0);
	/* sample size is larger than the input BAT, return all oids */
	} else if (cnt <= n) {
		bn = BATnew(TYPE_void, TYPE_void, cnt, TRANSIENT);
		if (bn == NULL) {
			GDKerror("BATsample: memory allocation error");
			return NULL;
		}
		BATsetcount(bn, cnt);
		BATseqbase(bn, 0);
		BATseqbase(BATmirror(bn), b->H->seq);
	} else {
		BUN minoid = b->hseqbase;
		BUN maxoid = b->hseqbase + cnt;
		/* if someone samples more than half of our tree, we do the antiset */
		bit antiset = n > cnt/2;
		slen = n;
		if (antiset) 
			n = cnt - n;
		
		bn = BATnew(TYPE_void, TYPE_oid, slen, TRANSIENT);
		if (bn == NULL ) {
			GDKerror("#BATsample: memory allocation error");
			return NULL;
		}
		/* while we do not have enough sample OIDs yet */
		while (rescnt < n) {
			BUN candoid;
			int rc;
			do {
				/* generate a new random OID */
				/* coverity[dont_call] */
				candoid = (BUN) (minoid + DRAND * (maxoid - minoid));
				/* if that candidate OID was already generated, try again */
			} while ((rc = OIDTreeMaybeInsert(&tree, candoid)) == 0);
			if (rc < 0) {
				GDKerror("#BATsample: memory allocation error");
				/* if malloc fails, we still need to clean up the tree */
				OIDTreeDestroy(tree);
				return NULL;
			}
			rescnt++;
		}
		if (!antiset) {
			OIDTreeToBAT(tree, bn);
		} else {
			OIDTreeToBATAntiset(tree, bn, minoid-1, maxoid+1);
		}
		OIDTreeDestroy(tree);

		BATsetcount(bn, slen);
		bn->trevsorted = bn->batCount <= 1;
		bn->tsorted = 1;
		bn->tkey = 1;
		bn->tdense = bn->batCount <= 1;
		if (bn->batCount == 1)
			bn->tseqbase = *(oid *) Tloc(bn, BUNfirst(bn));
		bn->hdense = 1;
		bn->hseqbase = 0;
		bn->hkey = 1;
		bn->hrevsorted = bn->batCount <= 1;
		bn->hsorted = 1;
	}
	return bn;
}

