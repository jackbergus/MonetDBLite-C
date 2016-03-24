/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

/*
 * (author) N. J. Nes
 *
 * In the philosophy of MonetDB, transaction management overhead
 * should only be paid when necessary. Transaction management is for
 * this purpose implemented as a separate module and applications are
 * required to obey the transaction policy, e.g. obtaining/releasing
 * locks.
 *
 * This module is designed to support efficient logging of the SQL
 * database.  Once loaded, the SQL compiler will insert the proper
 * calls at transaction commit to include the changes in the log file.
 *
 * The logger uses a directory to store its log files. One master log
 * file stores information about the version of the logger and the
 * transaction log files. This file is a simple ascii file with the
 * following format:
 *  {6DIGIT-VERSION\n[log file number \n]*]*}
 * The transaction log files have a binary format, which stores fixed
 * size logformat headers (flag,nr,bid), where the flag is the type of
 * update logged.  The nr field indicates how many changes there were
 * (in case of inserts/deletes).  The bid stores the bid identifier.
 *
 * The key decision to be made by the user is the location of the log
 * file.  Ideally, it should be stored in fail-safe environment, or at
 * least the log and databases should be on separate disk columns.
 *
 * This file system may reside on the same hardware as the database
 * server and therefore the writes are done to the same disk, but
 * could also reside on another system and then the changes are
 * flushed through the network.  The logger works under the assumption
 * that it is called to safeguard updates on the database when it has
 * an exclusive lock on the latest version. This lock should be
 * guaranteed by the calling transaction manager first.
 *
 * Finding the updates applied to a BAT is relatively easy, because
 * each BAT contains a delta structure. On commit these changes are
 * written to the log file and the delta management is reset. Since
 * each commit is written to the same log file, the beginning and end
 * are marked by a log identifier.
 *
 * A server restart should only (re)process blocks which are
 * completely written to disk. A log replay therefore ends in a commit
 * or abort on the changed bats. Once all logs have been read, the
 * changes to the bats are made persistent, i.e. a bbp sub-commit is
 * done.
 */
#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_private.h"
#include "gdk_logger.h"
#include <string.h>

/*
 * The log record encoding is geared at reduced storage space, but at
 * the expense of readability. A user can not easily inspect the log a
 * posteriori to check what has happened.
 *
 */
#define LOG_START	1
#define LOG_END		2
#define LOG_INSERT	3
#define LOG_DELETE	4
#define LOG_UPDATE	5
#define LOG_CREATE	6
#define LOG_DESTROY	7
#define LOG_USE		8
#define LOG_CLEAR	9
#define LOG_SEQ		10

static char *log_commands[] = {
	NULL,
	"LOG_START",
	"LOG_END",
	"LOG_INSERT",
	"LOG_DELETE",
	"LOG_UPDATE",
	"LOG_CREATE",
	"LOG_DESTROY",
	"LOG_USE",
	"LOG_CLEAR",
	"LOG_SEQ",
};

typedef struct logformat_t {
	char flag;
	int tid;
	lng nr;
} logformat;

#define LOGFILE "log"

static int bm_commit(logger *lg);
static int tr_grow(trans *tr);

static BUN
log_find(BAT *b, BAT *d, int val)
{
	BATiter cni = bat_iterator(b);
	BUN p;

	assert(b->ttype == TYPE_int);
	assert(d->ttype == TYPE_oid);
	if (BAThash(b, 0) == GDK_SUCCEED) {
		HASHloop_int(cni, cni.b->T->hash, p, &val) {
			oid pos = p;
			if (BUNfnd(d, &pos) == BUN_NONE)
				return p;
		}
	} else {		/* unlikely: BAThash failed */
		BUN q;
		int *t = (int *) Tloc(b, 0);

		for (p = BUNfirst(b), q = BUNlast(b); p < q; p++) {
			if (t[p] == val) {
				oid pos = p;
				if (BUNfnd(d, &pos) == BUN_NONE)
					return p;
			}
		}
	}
	return BUN_NONE;
}

static void
logbat_destroy(BAT *b)
{
	if (b)
		BBPunfix(b->batCacheid);
}

static BAT *
logbat_new(int tt, BUN size, int role)
{
	BAT *nb = BATnew(TYPE_void, tt, size, role);

	if (nb) {
		BATseqbase(nb, 0);
		if (role == PERSISTENT)
			BATmode(nb, PERSISTENT);
	} else {
		fprintf(stderr, "!ERROR: logbat_new: creating new BAT[void:%s]#" BUNFMT " failed\n", ATOMname(tt), size);
	}
	return nb;
}

static int
log_read_format(logger *l, logformat *data)
{
	return mnstr_read(l->log, &data->flag, 1, 1) == 1 &&
		mnstr_readLng(l->log, &data->nr) == 1 &&
		mnstr_readInt(l->log, &data->tid) == 1;
}

static int
log_write_format(logger *l, logformat *data)
{
	if (mnstr_write(l->log, &data->flag, 1, 1) == 1 &&
	    mnstr_writeLng(l->log, data->nr) &&
	    mnstr_writeInt(l->log, data->tid))
		return LOG_OK;
	fprintf(stderr, "!ERROR: log_write_format: write failed\n");
	return LOG_ERR;
}

static char *
log_read_string(logger *l)
{
	int len;
	ssize_t nr;
	char *buf;

	if (mnstr_readInt(l->log, &len) != 1) {
		fprintf(stderr, "!ERROR: log_read_string: read failed\n");
//MK This leads to non-repeatable log structure?
		return NULL;
	}
	if (len == 0)
		return NULL;
	buf = GDKmalloc(len);
	if (buf == NULL) {
		fprintf(stderr, "!ERROR: log_read_string: malloc failed\n");
		return NULL;
	}

	if ((nr = mnstr_read(l->log, buf, 1, len)) != (ssize_t) len) {
		buf[len - 1] = 0;
		fprintf(stderr, "!ERROR: log_read_string: couldn't read name (%s) " SSZFMT "\n", buf, nr);
		GDKfree(buf);
		return NULL;
	}
	buf[len - 1] = 0;
	return buf;
}

static int
log_write_string(logger *l, const char *n)
{
	size_t len = strlen(n) + 1;	/* log including EOS */

	assert(len > 1);
	assert(len <= INT_MAX);
	if (!mnstr_writeInt(l->log, (int) len) ||
	    mnstr_write(l->log, n, 1, len) != (ssize_t) len) {
		fprintf(stderr, "!ERROR: log_write_string: write failed\n");
		return LOG_ERR;
	}
	return LOG_OK;
}

static void
log_read_clear(logger *lg, trans *tr, char *name)
{
	if (lg->debug & 1)
		fprintf(stderr, "#logger found log_read_clear %s\n", name);

	if (tr_grow(tr)) {
		tr->changes[tr->nr].type = LOG_CLEAR;
		tr->changes[tr->nr].name = GDKstrdup(name);
		tr->nr++;
	}
}

static int
avoid_snapshot( logger *lg, log_bid bid ) 
{
	if (BATcount(lg->snapshots_bid)-BATcount(lg->dsnapshots)) {
		BUN p = log_find(lg->snapshots_bid, lg->dsnapshots, bid);

		if (p != BUN_NONE) {
			int tid = *(int *) Tloc(lg->snapshots_tid, p);

			if (lg->tid <= tid)
				return 1;
		}
	}
	return 0;
}

static void
la_bat_clear(logger *lg, logaction *la)
{
	log_bid bid = logger_find_bat(lg, la->name);
	BAT *b;

	if (lg->debug & 1)
		fprintf(stderr, "#la_bat_clear %s\n", la->name);

	/* do we need to skip these old updates */
	if (avoid_snapshot(lg, bid)) 
		return;

	b = BATdescriptor(bid);
	if (b) {
		int access = b->batRestricted;
		b->batRestricted = BAT_WRITE;
		BATclear(b, TRUE);
		b->batRestricted = access;
		logbat_destroy(b);
	}
}

static int
log_read_seq(logger *lg, logformat *l)
{
	int seq = (int) l->nr;
	lng val;
	BUN p;

	assert(l->nr <= (lng) INT_MAX);
	if (mnstr_readLng(lg->log, &val) != 1) {
		fprintf(stderr, "!ERROR: log_read_seq: read failed\n");
		return LOG_ERR;
	}

	if ((p = log_find(lg->seqs_id, lg->dseqs, seq)) != BUN_NONE &&
	    p >= lg->seqs_id->batInserted) {
		BUNinplace(lg->seqs_val, p, NULL, &val, FALSE);
	} else {
		if (p != BUN_NONE) {
			oid pos = p;
			BUNappend(lg->dseqs, &pos, FALSE);
		}
		BUNappend(lg->seqs_id, &seq, FALSE);
		BUNappend(lg->seqs_val, &val, FALSE);
	}
	return LOG_OK;
}

static int
log_read_updates(logger *lg, trans *tr, logformat *l, char *name)
{
	log_bid bid = logger_find_bat(lg, name);
	BAT *b = BATdescriptor(bid);
	int res = LOG_OK;
	int ht = -1, tt = -1, hseq = 0, tseq = 0;

	if (lg->debug & 1)
		fprintf(stderr, "#logger found log_read_updates %s %s " LLFMT "\n", name, l->flag == LOG_INSERT ? "insert" : l->flag == LOG_DELETE ? "delete" : "update", l->nr);

	if (b) {
		ht = b->htype;
		if (ht == TYPE_void && b->hseqbase != oid_nil)
			hseq = 1;
		tt = b->ttype;
		if (tt == TYPE_void && b->tseqbase != oid_nil)
			tseq = 1;
	} else {		/* search trans action for create statement */
		int i;

		for (i = 0; i < tr->nr; i++) {
			if (tr->changes[i].type == LOG_CREATE && strcmp(tr->changes[i].name, name) == 0) {
				ht = tr->changes[i].ht;
				if (ht < 0) {
					hseq = 1;
					ht = TYPE_void;
				}
				tt = tr->changes[i].tt;
				if (tt < 0) {
					tseq = 1;
					tt = TYPE_void;
				}
				break;
			}
		}
	}
	assert( (ht == TYPE_void && l->flag == LOG_INSERT) ||
		(ht == TYPE_void && l->flag == LOG_DELETE) || 
		((ht == TYPE_oid || !ht) && l->flag == LOG_UPDATE) );
	if (ht >= 0 && tt >= 0) {
		BAT *uid = NULL;
		BAT *r;
		void *(*rt) (ptr, stream *, size_t) = BATatoms[tt].atomRead;
		void *tv = NULL;

		if (tt < TYPE_str)
			tv = lg->buf;
		else if (tt > TYPE_str)
			tv = ATOMnil(tt);
#if SIZEOF_OID == 8
		if (tt == TYPE_oid && lg->read32bitoid)
			rt = BATatoms[TYPE_int].atomRead;
#endif
		assert(l->nr <= (lng) BUN_MAX);
		if (l->flag == LOG_UPDATE) {
			uid = BATnew(TYPE_void, ht, (BUN) l->nr, PERSISTENT);
			r = BATnew(TYPE_void, tt, (BUN) l->nr, PERSISTENT);
		} else {
			assert(ht == TYPE_void);
			r = BATnew(TYPE_void, tt, (BUN) l->nr, PERSISTENT);
		}

		if (hseq)
			BATseqbase(r, 0);
		if (tseq)
			BATseqbase(BATmirror(r), 0);

		if (ht == TYPE_void && l->flag == LOG_INSERT) {
			for (; l->nr > 0; l->nr--) {
				void *t = rt(tv, lg->log, 1);

				if (!t) {
					res = LOG_ERR;
					break;
				}
#if SIZEOF_OID == 8
				if (tt == TYPE_oid && lg->read32bitoid) {
					int vi = * (int *) t;
					if (vi == int_nil)
						* (oid *) t = oid_nil;
					else
						* (oid *) t = vi;
				}
#endif
				BUNappend(r, t, TRUE);
				if (t != tv)
					GDKfree(t);
			}
		} else if (ht == TYPE_void && l->flag == LOG_DELETE) {
			for (; l->nr > 0; l->nr--) {
				void *t = rt(tv, lg->log, 1);

				if (!t) {
					res = LOG_ERR;
					break;
				}
#if SIZEOF_OID == 8
				if (tt == TYPE_oid && lg->read32bitoid) {
					int vi = * (int *) t;
					if (vi == int_nil)
						* (oid *) t = oid_nil;
					else
						* (oid *) t = vi;
				}
#endif
				BUNappend(r, t, TRUE);
				if (t != tv)
					GDKfree(t);
			}
		} else {
			void *(*rh) (ptr, stream *, size_t) = ht == TYPE_void ? BATatoms[TYPE_oid].atomRead : BATatoms[ht].atomRead;
			void *hv = ATOMnil(ht);

#if SIZEOF_OID == 8
			if ((ht == TYPE_oid || ht == TYPE_void) &&
			    lg->read32bitoid)
				rh = BATatoms[TYPE_int].atomRead;
#endif
			for (; l->nr > 0; l->nr--) {
				void *h = rh(hv, lg->log, 1);
				void *t = rt(tv, lg->log, 1);

				if (!h || !t) {
					res = LOG_ERR;
					break;
				}
#if SIZEOF_OID == 8
				if (lg->read32bitoid) {
					if (ht == TYPE_void || ht == TYPE_oid) {
						int vi = * (int *) h;
						if (vi == int_nil)
							* (oid *) h = oid_nil;
						else
							* (oid *) h = vi;
					}
					if (tt == TYPE_oid) {
						int vi = * (int *) t;
						if (vi == int_nil)
							* (oid *) t = oid_nil;
						else
							* (oid *) t = vi;
					}
				}
#endif
				BUNappend(uid, h, TRUE);
				BUNappend(r, t, TRUE);
				if (t != tv)
					GDKfree(t);
			}
			GDKfree(hv);
		}
		if (tv != lg->buf) 
			GDKfree(tv);
		logbat_destroy(b);

		if (tr_grow(tr)) {
			tr->changes[tr->nr].type = l->flag;
			tr->changes[tr->nr].nr = l->nr;
			tr->changes[tr->nr].ht = ht;
			tr->changes[tr->nr].tt = tt;
			tr->changes[tr->nr].name = GDKstrdup(name);
			tr->changes[tr->nr].b = r;
			tr->changes[tr->nr].uid = uid;
			tr->nr++;
		}
	} else {
		/* bat missing ERROR or ignore ? currently error. */
		res = LOG_ERR;
	}
	return res;
}

static void
la_bat_updates(logger *lg, logaction *la)
{
	log_bid bid = logger_find_bat(lg, la->name);
	BAT *b;

	if (bid == 0)
		return;		/* ignore bats no longer in the catalog */

	/* do we need to skip these old updates */
	if (avoid_snapshot(lg, bid)) 
		return;

	b = BATdescriptor(bid);
	assert(b);
	if (b) {
		if (b->htype == TYPE_void && la->type == LOG_INSERT) {
			BATappend(b, la->b, TRUE);
		} else {
			if (la->type == LOG_INSERT)
				BATins(b, la->b, TRUE);
			else if (la->type == LOG_DELETE)
				BATdel(b, la->b, TRUE);
			else if (la->type == LOG_UPDATE) {
				BATiter vi = bat_iterator(la->b);
				BATiter ii = bat_iterator(la->uid);
				BUN p, q;

				BATloop(la->b, p, q) {
					const void *h = BUNtail(ii, p);
					const void *t = BUNtail(vi, p);

					assert(b->htype == TYPE_void);
					if (BUNfnd(BATmirror(b), h) == BUN_NONE) {
						/* if value doesn't
						 * exist, insert it if
						 * b void headed,
						 * maintain that by
						 * inserting nils */
						if (b->batCount == 0 && *(const oid *) h != oid_nil)
							b->hseqbase = *(const oid *) h;
						if (b->hseqbase != oid_nil && *(const oid *) h != oid_nil) {
							const void *tv = ATOMnilptr(b->ttype);

							while (b->hseqbase + b->batCount < *(const oid *) h)
								BUNappend(b, tv, TRUE);
						}
						BUNappend(b, t, TRUE);
					} else {
						BUNreplace(b, h, t, TRUE);
					}
				}
			}
		}
		logbat_destroy(b);
	}
}

static void
log_read_destroy(logger *lg, trans *tr, char *name)
{
	(void) lg;
	if (tr_grow(tr)) {
		tr->changes[tr->nr].type = LOG_DESTROY;
		tr->changes[tr->nr].name = GDKstrdup(name);
		tr->nr++;
	}
}

static void
la_bat_destroy(logger *lg, logaction *la)
{
	log_bid bid = logger_find_bat(lg, la->name);

	if (bid) {
		BUN p;

		logger_del_bat(lg, bid);

		if ((p = log_find(lg->snapshots_bid, lg->dsnapshots, bid)) != BUN_NONE) {
#ifndef NDEBUG
			assert(BBP_desc(bid)->S.role == PERSISTENT);
			assert(0 <= BBP_desc(bid)->H.heap.farmid && BBP_desc(bid)->H.heap.farmid < MAXFARMS);
			assert(BBPfarms[BBP_desc(bid)->H.heap.farmid].roles & (1 << PERSISTENT));
			if (BBP_desc(bid)->H.vheap) {
				assert(0 <= BBP_desc(bid)->H.vheap->farmid && BBP_desc(bid)->H.vheap->farmid < MAXFARMS);
				assert(BBPfarms[BBP_desc(bid)->H.vheap->farmid].roles & (1 << PERSISTENT));
			}
			assert(0 <= BBP_desc(bid)->T.heap.farmid && BBP_desc(bid)->T.heap.farmid < MAXFARMS);
			assert(BBPfarms[BBP_desc(bid)->T.heap.farmid].roles & (1 << PERSISTENT));
			if (BBP_desc(bid)->T.vheap) {
				assert(0 <= BBP_desc(bid)->T.vheap->farmid && BBP_desc(bid)->T.vheap->farmid < MAXFARMS);
				assert(BBPfarms[BBP_desc(bid)->T.vheap->farmid].roles & (1 << PERSISTENT));
			}
#endif
			BUNappend(lg->dsnapshots, &p, FALSE);
		}
	}
}

static int
log_read_create(logger *lg, trans *tr, char *name)
{
	char *buf = log_read_string(lg);

	if (lg->debug & 1)
		fprintf(stderr, "#log_read_create %s\n", name);

	if (!buf) {
		return LOG_ERR;
	} else {
		int ht, tt;
		char *ha = buf, *ta = strchr(buf, ',');

		if (!ta) {
			fprintf(stderr, "!ERROR: log_read_create: inconsistent data read\n");
			return LOG_ERR;
		}
		*ta = 0;
		ta++;		/* skip over , */
		if (strcmp(ha, "vid") == 0) {
			ht = -1;
		} else {
			ht = ATOMindex(ha);
		}
		if (strcmp(ta, "vid") == 0) {
			tt = -1;
		} else {
			tt = ATOMindex(ta);
		}
		if (tr_grow(tr)) {
			tr->changes[tr->nr].type = LOG_CREATE;
			tr->changes[tr->nr].ht = ht;
			tr->changes[tr->nr].tt = tt;
			tr->changes[tr->nr].name = GDKstrdup(name);
			tr->changes[tr->nr].b = NULL;
			tr->nr++;
		}
	}
	if (buf)
		GDKfree(buf);
	return LOG_OK;
}

static void
la_bat_create(logger *lg, logaction *la)
{
	int ht = (la->ht < 0) ? TYPE_void : la->ht;
	int tt = (la->tt < 0) ? TYPE_void : la->tt;
	BAT *b = BATnew(ht, tt, BATSIZE, PERSISTENT);

	if (b != NULL) {
		if (la->ht < 0)
			BATseqbase(b, 0);
		if (la->tt < 0)
			BATseqbase(BATmirror(b), 0);

		BATsetaccess(b, BAT_READ);
		logger_add_bat(lg, b, la->name);
		logbat_destroy(b);
	}
}

static void
log_read_use(logger *lg, trans *tr, logformat *l, char *name)
{
	(void) lg;
	if (tr_grow(tr)) {
		tr->changes[tr->nr].type = LOG_USE;
		tr->changes[tr->nr].nr = l->nr;
		tr->changes[tr->nr].name = GDKstrdup(name);
		tr->changes[tr->nr].b = NULL;
		tr->nr++;
	}
}

static void
la_bat_use(logger *lg, logaction *la)
{
	log_bid bid = (log_bid) la->nr;
	BAT *b = BATdescriptor(bid);
	BUN p;

	assert(la->nr <= (lng) INT_MAX);
	if (!b) {
		GDKerror("logger: could not use bat (%d) for %s\n", (int) bid, la->name);
		return;
	}
	logger_add_bat(lg, b, la->name);
#ifndef NDEBUG
	assert(b->batRole == PERSISTENT);
	assert(0 <= b->H->heap.farmid && b->H->heap.farmid < MAXFARMS);
	assert(BBPfarms[b->H->heap.farmid].roles & (1 << PERSISTENT));
	if (b->H->vheap) {
		assert(0 <= b->H->vheap->farmid && b->H->vheap->farmid < MAXFARMS);
		assert(BBPfarms[b->H->vheap->farmid].roles & (1 << PERSISTENT));
	}
	assert(0 <= b->T->heap.farmid && b->T->heap.farmid < MAXFARMS);
	assert(BBPfarms[b->T->heap.farmid].roles & (1 << PERSISTENT));
	if (b->T->vheap) {
		assert(0 <= b->T->vheap->farmid && b->T->vheap->farmid < MAXFARMS);
		assert(BBPfarms[b->T->vheap->farmid].roles & (1 << PERSISTENT));
	}
#endif
	if ((p = log_find(lg->snapshots_bid, lg->dsnapshots, b->batCacheid)) != BUN_NONE &&
	    p >= lg->snapshots_bid->batInserted) {
		BUNinplace(lg->snapshots_tid, p, NULL, &lg->tid, FALSE);
	} else {
		if (p != BUN_NONE) {
			oid pos = p;
			BUNappend(lg->dsnapshots, &pos, FALSE);
		}
		/* move to the dirty new part of the snapshots list,
		 * new snapshots will get flushed to disk */
		BUNappend(lg->snapshots_bid, &b->batCacheid, FALSE);
		BUNappend(lg->snapshots_tid, &lg->tid, FALSE);
	}
	logbat_destroy(b);
}


#define TR_SIZE		1024

static trans *
tr_create(trans *tr, int tid)
{
	trans *ntr = GDKmalloc(sizeof(trans));

	if (ntr == NULL)
		return NULL;
	ntr->tid = tid;
	ntr->sz = TR_SIZE;
	ntr->nr = 0;
	ntr->changes = GDKmalloc(sizeof(logaction) * TR_SIZE);
	if (ntr->changes == NULL) {
		GDKfree(ntr);
		return NULL;
	}
	ntr->tr = tr;
	return ntr;
}

static trans *
tr_find(trans *tr, int tid)
/* finds the tid and reorders the chain list, puts trans with tid first */
{
	trans *t = tr, *p = NULL;

	while (t && t->tid != tid) {
		p = t;
		t = t->tr;
	}
	if (!t)
		return NULL;	/* BAD missing transaction */
	if (t == tr)
		return tr;
	if (t->tr)		/* get this tid out of the list */
		p->tr = t->tr;
	t->tr = tr;		/* and move it to the front */
	return t;
}

static void
la_apply(logger *lg, logaction *c)
{
	switch (c->type) {
	case LOG_INSERT:
	case LOG_DELETE:
	case LOG_UPDATE:
		la_bat_updates(lg, c);
		break;
	case LOG_CREATE:
		la_bat_create(lg, c);
		break;
	case LOG_USE:
		la_bat_use(lg, c);
		break;
	case LOG_DESTROY:
		la_bat_destroy(lg, c);
		break;
	case LOG_CLEAR:
		la_bat_clear(lg, c);
		break;
	}
	lg->changes++;
}

static void
la_destroy(logaction *c)
{
	if (c->name)
		GDKfree(c->name);
	if (c->b)
		logbat_destroy(c->b);
}

static int
tr_grow(trans *tr)
{
	if (tr->nr == tr->sz) {
		tr->sz <<= 1;
		tr->changes = (logaction *) GDKrealloc(tr->changes, tr->sz * sizeof(logaction));
		if (tr->changes == NULL)
			return 0;
	}
	/* cleanup the next */
	tr->changes[tr->nr].name = NULL;
	tr->changes[tr->nr].b = NULL;
	return 1;
}

static trans *
tr_destroy(trans *tr)
{
	trans *r = tr->tr;

	GDKfree(tr->changes);
	GDKfree(tr);
	return r;
}

static trans *
tr_commit(logger *lg, trans *tr)
{
	int i;

	if (lg->debug & 1)
		fprintf(stderr, "#tr_commit\n");

	for (i = 0; i < tr->nr; i++) {
		la_apply(lg, &tr->changes[i]);
		la_destroy(&tr->changes[i]);
	}
	return tr_destroy(tr);
}

static trans *
tr_abort(logger *lg, trans *tr)
{
	int i;

	if (lg->debug & 1)
		fprintf(stderr, "#tr_abort\n");

	for (i = 0; i < tr->nr; i++)
		la_destroy(&tr->changes[i]);
	return tr_destroy(tr);
}

static int log_sequence_nrs(logger *lg);

static int
logger_open(logger *lg)
{
	char filename[BUFSIZ];
	bat bid;

	snprintf(filename, sizeof(filename), "%s%s." LLFMT, lg->dir, LOGFILE, lg->id);

	lg->log = open_wstream(filename);
	lg->end = 0;

	if (lg->log == NULL || mnstr_errnr(lg->log) || log_sequence_nrs(lg) != LOG_OK) { 
		fprintf(stderr, "!ERROR: logger_open: creating %s failed\n", filename);
		return LOG_ERR;
	}
	if ((bid = logger_find_bat(lg, "seqs_id")) != 0) {
		int dbg = GDKdebug;
		BAT *b;
		GDKdebug &= ~CHECKMASK;
		b = BATdescriptor(bid);
		BATmode(b, TRANSIENT);
		logger_del_bat(lg, bid);
		logbat_destroy(b);
		bid = logger_find_bat(lg, "seqs_val");
		b = BATdescriptor(bid);
		BATmode(b, TRANSIENT);
		logger_del_bat(lg, bid);
		logbat_destroy(b);
		GDKdebug = dbg;
		if (bm_commit(lg) != LOG_OK)
			return LOG_ERR;
	}
	return LOG_OK;
}

static void
logger_close(logger *lg)
{
	stream *log = lg->log;

	if (log) {
		close_stream(log);
	}
	lg->log = NULL;
}

static int
logger_readlog(logger *lg, char *filename)
{
	trans *tr = NULL;
	logformat l;
	int err = 0;
	time_t t0, t1;
	struct stat sb;
	lng fpos;

	lg->log = open_rstream(filename);

	/* if the file doesn't exist, there is nothing to be read back */
	if (!lg->log || mnstr_errnr(lg->log)) {
		if (lg->log)
			mnstr_destroy(lg->log);
		lg->log = NULL;
		return 0;
	}
	if (fstat(fileno(getFile(lg->log)), &sb) < 0) {
		fprintf(stderr, "!ERROR: logger_readlog: fstat on opened file %s failed\n", filename);
		mnstr_destroy(lg->log);
		lg->log = NULL;
		return 0;
	}
	t0 = time(NULL);
	printf("# Start reading the write-ahead log '%s'\n", filename);
	fflush(stdout);
	while (!err && log_read_format(lg, &l)) {
		char *name = NULL;

		t1 = time(NULL);
		if (t1 - t0 > 10) {
			t0 = t1;
			/* not more than once every 10 seconds */
			if (mnstr_fgetpos(lg->log, &fpos) == 0) {
				printf("# still reading write-ahead log \"%s\" (%d%% done)\n", filename, (int) ((fpos * 100 + 50) / sb.st_size));
				fflush(stdout);
			}
		}
		if (l.flag != LOG_START && l.flag != LOG_END && l.flag != LOG_SEQ) {
			name = log_read_string(lg);

			if (!name) {
				err = -1;
				break;
			}
		}
		if (lg->debug & 1) {
			fprintf(stderr, "#logger_readlog: ");
			if (l.flag > 0 &&
			    l.flag < (char) (sizeof(log_commands) / sizeof(log_commands[0])))
				fprintf(stderr, "%s", log_commands[(int) l.flag]);
			else
				fprintf(stderr, "%d", l.flag);
			fprintf(stderr, " %d " LLFMT, l.tid, l.nr);
			if (name)
				fprintf(stderr, " %s", name);
			fprintf(stderr, "\n");
		}
		/* find proper transaction record */
		if (l.flag != LOG_START)
			tr = tr_find(tr, l.tid);
		switch (l.flag) {
		case LOG_START:
			assert(l.nr <= (lng) INT_MAX);
			if (l.nr > lg->tid)
				lg->tid = (int)l.nr;
			tr = tr_create(tr, (int)l.nr);
			if (lg->debug & 1)
				fprintf(stderr, "#logger tstart %d\n", tr->tid);
			break;
		case LOG_END:
			if (tr == NULL)
				err = 1;
			else if (l.tid != l.nr)	/* abort record */
				tr = tr_abort(lg, tr);
			else
				tr = tr_commit(lg, tr);
			break;
		case LOG_SEQ:
			err = (log_read_seq(lg, &l) != LOG_OK);
			break;
		case LOG_INSERT:
		case LOG_DELETE:
		case LOG_UPDATE:
			if (name == NULL || tr == NULL)
				err = 1;
			else
				err = (log_read_updates(lg, tr, &l, name) != LOG_OK);
			break;
		case LOG_CREATE:
			if (name == NULL || tr == NULL)
				err = 1;
			else
				err = (log_read_create(lg, tr, name) != LOG_OK);
			break;
		case LOG_USE:
			if (name == NULL || tr == NULL)
				err = 1;
			else
				log_read_use(lg, tr, &l, name);
			break;
		case LOG_DESTROY:
			if (name == NULL || tr == NULL)
				err = 1;
			else
				log_read_destroy(lg, tr, name);
			break;
		case LOG_CLEAR:
			if (name == NULL || tr == NULL)
				err = 1;
			else
				log_read_clear(lg, tr, name);
			break;
		default:
			err = -2;
		}
		if (name)
			GDKfree(name);
	}
	logger_close(lg);

	/* remaining transactions are not committed, ie abort */
	while (tr)
		tr = tr_abort(lg, tr);
	t0 = time(NULL);
	printf("# Finished reading the write-ahead log '%s'\n", filename);
	fflush(stdout);
	return 0;
}

/*
 * The log files are incrementally numbered. They are processed in the
 * same sequence.
 */
static int
logger_readlogs(logger *lg, FILE *fp, char *filename)
{
	int res = 0;
	char id[BUFSIZ];

	if (lg->debug & 1)
		fprintf(stderr, "#logger_readlogs %s\n", filename);

	while (fgets(id, sizeof(id), fp) != NULL) {
		char buf[BUFSIZ];
		lng lid = strtoll(id, NULL, 10);

		if (lid >= lg->id) {
			lg->id = lid;
			snprintf(buf, sizeof(buf), "%s." LLFMT, filename, lg->id);

			if ((res = logger_readlog(lg, buf)) != 0) {
				/* we cannot distinguish errors from
				 * incomplete transactions (even if we
				 * would log aborts in the logs). So
				 * we simply abort and move to the
				 * next log file */
				(void) res;
			}
		}
	}
	return res;
}

static int
logger_commit(logger *lg)
{
	int id = LOG_SID;
	BUN p;

	if (lg->debug & 1)
		fprintf(stderr, "#logger_commit\n");

	p = log_find(lg->seqs_id, lg->dseqs, id);
	if (p >= lg->seqs_val->batInserted) {
		BUNinplace(lg->seqs_val, p, NULL, &lg->id, FALSE);
	} else {
		oid pos = p;
		BUNappend(lg->dseqs, &pos, FALSE);
		BUNappend(lg->seqs_id, &id, FALSE);
		BUNappend(lg->seqs_val, &lg->id, FALSE);
	}

	/* cleanup old snapshots */
	if (BATcount(lg->snapshots_bid)) {
		BATclear(lg->snapshots_bid, TRUE);
		BATclear(lg->snapshots_tid, TRUE);
		BATclear(lg->dsnapshots, TRUE);
		BATcommit(lg->snapshots_bid);
		BATcommit(lg->snapshots_tid);
		BATcommit(lg->dsnapshots);
	}
	return bm_commit(lg);
}

static gdk_return
check_version(logger *lg, FILE *fp)
{
	int version = 0;

	if (fscanf(fp, "%6d", &version) != 1) {
		GDKerror("Could not read the version number from the file '%s/log'.\n",
			 lg->dir);

		return GDK_FAIL;
	}
	if (version != lg->version) {
		if (lg->prefuncp == NULL ||
		    (*lg->prefuncp)(version, lg->version) != 0) {
			GDKfatal("Incompatible database version %06d, "
				 "this server supports version %06d.\n%s",
				 version, lg->version,
				 version < lg->version ? "Maybe you need to upgrade to an intermediate release first.\n" : "");

			return GDK_FAIL;
		}
	} else
		lg->postfuncp = NULL;	 /* don't call */
	if (fgetc(fp) != '\n' ||	 /* skip \n */
	    fgetc(fp) != '\n')		 /* skip \n */
		return GDK_FAIL;
	return GDK_SUCCEED;
}

static BAT *
bm_tids(BAT *b, BAT *d) 
{
	BUN sz = BATcount(b);
	BAT *tids = BATnew(TYPE_void, TYPE_void, 0, TRANSIENT);

	tids->H->seq = 0;
	tids->T->seq = 0;
	BATsetcount(tids, sz);
	tids->H->revsorted = 0;
	tids->T->revsorted = 0;

	tids->T->key = 1;
	tids->T->dense = 1;
	tids->H->key = 1;
	tids->H->dense = 1;

	if (BATcount(d)) {
		BAT *diff = BATkdiff(tids, BATmirror(d));

		logbat_destroy(tids);
		tids = BATmirror(BATmark(diff, 0));
		logbat_destroy(diff);
	}
	return tids;
}

static void
logger_fatal(const char *format, const char *arg1, const char *arg2, const char *arg3)
{
	char *buf;

	GDKfatal(format, arg1, arg2, arg3);
	GDKlog(format, arg1, arg2, arg3);
	if ((buf = GDKerrbuf) != NULL) {
		fprintf(stderr, "%s", buf);
		fflush(stderr);
	}
	GDKexit(1);
}

static void
logger_switch_bat( BAT *old, BAT *new, const char *fn, const char *name)
{
	char bak[BUFSIZ];

	if (BATmode(old, TRANSIENT) != GDK_SUCCEED)
		logger_fatal("Logger_new: cannot convert old %s to transient", name, 0, 0);
	snprintf(bak, sizeof(bak), "tmp_%o", old->batCacheid);
	if (BBPrename(old->batCacheid, bak) != 0)
		logger_fatal("Logger_new: cannot rename old %s", name, 0, 0);
	snprintf(bak, sizeof(bak), "%s_%s", fn, name);
	if (BBPrename(new->batCacheid, bak) != 0)
		logger_fatal("Logger_new: cannot rename new %s", name, 0, 0);
}

static gdk_return
bm_subcommit(logger *lg, BAT *list_bid, BAT *list_nme, BAT *catalog_bid, BAT *catalog_nme, BAT *dcatalog, BAT *extra, int debug)
{
	BUN p, q;
	BUN nn = 6 + BATcount(list_bid) + (extra ? BATcount(extra) : 0);
	bat *n = GDKmalloc(sizeof(bat) * nn);
	int i = 0;
	BATiter iter = (list_nme)?bat_iterator(list_nme):bat_iterator(list_bid);
	gdk_return res;

	n[i++] = 0;		/* n[0] is not used */
	BATloop(list_bid, p, q) {
		bat col = *(log_bid *) Tloc(list_bid, p);
		oid pos = p;

		if (list_bid == catalog_bid && BUNfnd(dcatalog, &pos) != BUN_NONE)
			continue;
		if (debug & 1)
			fprintf(stderr, "#commit new %s (%d) %s\n",
				BBPname(col), col,
				(list_bid == catalog_bid) ? BUNtail(iter, p) : "snapshot");
		assert(col);
		n[i++] = abs(col);
	}
	if (extra) {
		iter = bat_iterator(extra);
		BATloop(extra, p, q) {
			str name = (str) BUNtvar(iter, p);

			if (debug & 1)
				fprintf(stderr, "#commit extra %s %s\n",
					name,
					(list_bid == catalog_bid) ? BUNtvar(iter, p) : "snapshot");
			assert(BBPindex(name));
			n[i++] = abs(BBPindex(name));
		}
	}
	/* now commit catalog, so it's also up to date on disk */
	n[i++] = abs(catalog_bid->batCacheid);
	n[i++] = abs(catalog_nme->batCacheid);
	n[i++] = abs(dcatalog->batCacheid);
	assert((BUN) i <= nn);
	if (BATcount(dcatalog) > (BATcount(catalog_nme)/2) && catalog_bid == list_bid && catalog_nme == list_nme && lg->catalog_bid == catalog_bid) {
		BAT *bids, *nmes, *tids = bm_tids(catalog_bid, dcatalog), *b;

		bids = logbat_new(TYPE_int, BATSIZE, PERSISTENT);
		nmes = logbat_new(TYPE_str, BATSIZE, PERSISTENT);
		b = BATproject(tids, catalog_bid);
		BATappend(bids, b, TRUE);
		logbat_destroy(b);
		b = BATproject(tids, catalog_nme);
		BATappend(nmes, b, TRUE);
		logbat_destroy(b);
		logbat_destroy(tids);
		BATclear(dcatalog, TRUE);

		logger_switch_bat(catalog_bid, bids, lg->fn, "catalog_bid");
		logger_switch_bat(catalog_nme, nmes, lg->fn, "catalog_nme");
		n[i++] = bids->batCacheid;
		n[i++] = nmes->batCacheid;

		logbat_destroy(lg->catalog_bid);
		logbat_destroy(lg->catalog_nme);

		lg->catalog_bid = catalog_bid = bids;
		lg->catalog_nme = catalog_nme = nmes;
	}
	BATcommit(catalog_bid);
	BATcommit(catalog_nme);
	BATcommit(dcatalog);
	res = TMsubcommit_list(n, i);
	GDKfree(n);
	if (res != GDK_SUCCEED)
		fprintf(stderr, "!ERROR: bm_subcommit: commit failed\n");
	return res;
}

static logger *
logger_new(int debug, const char *fn, const char *logdir, int version, preversionfix_fptr prefuncp, postversionfix_fptr postfuncp)
{
	int id = LOG_SID;
	logger *lg;
	FILE *fp;
	char filename[BUFSIZ];
	char bak[BUFSIZ];
	log_bid snapshots_bid = 0;
	bat catalog_bid, catalog_nme, dcatalog, bid;

	/* if the path is absolute, it means someone is still calling
	 * logger_create/logger_new "manually" */
	assert(!MT_path_absolute(logdir));

	lg = GDKmalloc(sizeof(struct logger));
	if (lg == NULL) {
		fprintf(stderr, "!ERROR: logger_new: allocating logger "
			"structure failed\n");
		return NULL;
	}

	lg->debug = debug;

	lg->changes = 0;
	lg->version = version;
	lg->id = 1;

	lg->tid = 0;
#if SIZEOF_OID == 8
	lg->read32bitoid = 0;
#endif

	snprintf(filename, sizeof(filename), "%s%c%s%c", logdir, DIR_SEP, fn, DIR_SEP);
	lg->fn = GDKstrdup(fn);
	lg->dir = GDKstrdup(filename);
	lg->bufsize = 64*1024;
	lg->buf = GDKmalloc(lg->bufsize);
	if (lg->fn == NULL || lg->dir == NULL || lg->buf == NULL) {
		fprintf(stderr, "!ERROR: logger_new: strdup failed\n");
		GDKfree(lg->fn);
		GDKfree(lg->dir);
		GDKfree(lg->buf);
		GDKfree(lg);
		return NULL;
	}
	lg->prefuncp = prefuncp;
	lg->postfuncp = postfuncp;
	lg->log = NULL;
	lg->end = 0;
	lg->catalog_bid = NULL;
	lg->catalog_nme = NULL;
	lg->dcatalog = NULL;
	lg->snapshots_bid = NULL;
	lg->snapshots_tid = NULL;
	lg->dsnapshots = NULL;
	lg->seqs_id = NULL;
	lg->seqs_val = NULL;
	lg->dseqs = NULL;

	snprintf(filename, sizeof(filename), "%s%s", lg->dir, LOGFILE);
	snprintf(bak, sizeof(bak), "%s.bak", filename);

	/* try to open logfile backup, or failing that, the file
	 * itself. we need to know whether this file exists when
	 * checking the database consistency later on */
	if ((fp = fopen(bak, "r")) != NULL) {
		fclose(fp);
		(void) GDKunlink(0, lg->dir, LOGFILE, NULL);
		if (GDKmove(0, lg->dir, LOGFILE, "bak", lg->dir, LOGFILE, NULL) != GDK_SUCCEED)
			logger_fatal("logger_new: cannot move log.bak "
				     "file back.\n", 0, 0, 0);
	}
	fp = fopen(filename, "r");

	snprintf(bak, sizeof(bak), "%s_catalog", fn);
	bid = BBPindex(bak);

	snprintf(bak, sizeof(bak), "%s_catalog_bid", fn);
	catalog_bid = BBPindex(bak);

	if (bid != 0 && catalog_bid == 0)
		logger_fatal("Logger_new: ancient database, please upgrade "
			     "first to Jan2014 (11.17.X) release", 0, 0, 0);

	if (catalog_bid == 0) {
		log_bid bid = 0;

		/* catalog does not exist, so the log file also
		 * shouldn't exist */
		if (fp != NULL) {
			logger_fatal("logger_new: there is no logger catalog, "
				     "but there is a log file.\n"
				     "Are you sure you are using the correct "
				     "combination of database\n"
				     "(--dbpath) and log directory "
				     "(--set %s_logdir)?\n",
				     fn, 0, 0);
		}

		lg->catalog_bid = logbat_new(TYPE_int, BATSIZE, PERSISTENT);
		lg->catalog_nme = logbat_new(TYPE_str, BATSIZE, PERSISTENT);
		lg->dcatalog = logbat_new(TYPE_oid, BATSIZE, PERSISTENT);
		if (lg->catalog_bid == NULL || lg->catalog_nme == NULL || lg->dcatalog == NULL)
			logger_fatal("Logger_new: cannot create catalog bats",
				     0, 0, 0);
		if (debug & 1)
			fprintf(stderr, "#create %s catalog\n", fn);

		/* give the catalog bats names so we can find them
		 * next time */
		bid = lg->catalog_bid->batCacheid;
		BBPincref(bid, TRUE);
		snprintf(bak, sizeof(bak), "%s_catalog_bid", fn);
		if (BBPrename(lg->catalog_bid->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);

		bid = lg->catalog_nme->batCacheid;
		BBPincref(bid, TRUE);
		snprintf(bak, sizeof(bak), "%s_catalog_nme", fn);
		if (BBPrename(lg->catalog_nme->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);

		bid = lg->dcatalog->batCacheid;
		BBPincref(bid, TRUE);
		snprintf(bak, sizeof(bak), "%s_dcatalog", fn);
		if (BBPrename(lg->dcatalog->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);

		if (GDKcreatedir(filename) != GDK_SUCCEED) {
			logger_fatal("logger_new: cannot create directory for log file %s\n",
				     filename, 0, 0);
			goto error;
		}
		if ((fp = fopen(filename, "w")) == NULL) {
			logger_fatal("logger_new: cannot create log file %s\n",
				     filename, 0, 0);
			goto error;
		}
		lg->id ++;
		if (fprintf(fp, "%06d\n\n" LLFMT "\n", lg->version, lg->id) < 0) {
			fclose(fp);
			unlink(filename);
			logger_fatal("logger_new: writing log file %s failed",
				     filename, 0, 0);
		}
		if (fflush(fp) < 0 ||
#if defined(_MSC_VER)
		    _commit(_fileno(fp)) < 0 ||
#elif defined(HAVE_FDATASYNC)
		    fdatasync(fileno(fp)) < 0 ||
#elif defined(HAVE_FSYNC)
		    fsync(fileno(fp)) < 0 ||
#endif
		    fclose(fp) < 0) {
			unlink(filename);
			logger_fatal("logger_new: closing log file %s failed",
				     filename, 0, 0);
		}
		fp = NULL;

		if (bm_subcommit(lg, lg->catalog_bid, lg->catalog_nme, lg->catalog_bid, lg->catalog_nme, lg->dcatalog, NULL, lg->debug) != GDK_SUCCEED) {
			/* cannot commit catalog, so remove log */
			unlink(filename);
			goto error;
		}
	} else {
		/* find the persistent catalog. As non persistent bats
		 * require a logical reference we also add a logical
		 * reference for the persistent bats */
		BUN p, q;
		BAT *b = BATdescriptor(catalog_bid), *n, *d;

		if (b == 0)
			logger_fatal("Logger_new: inconsistent database, catalog does not exist", 0, 0, 0);

		snprintf(bak, sizeof(bak), "%s_catalog_nme", fn);
		catalog_nme = BBPindex(bak);
		n = BATdescriptor(catalog_nme);
		if (n == 0)
			logger_fatal("Logger_new: inconsistent database, catalog_nme does not exist", 0, 0, 0);

		snprintf(bak, sizeof(bak), "%s_dcatalog", fn);
		dcatalog = BBPindex(bak);
		d = BATdescriptor(dcatalog);
		if (d == 0) {
			/* older database: create dcatalog and convert
			 * catalog_bid and catalog_nme to
			 * dense-headed */
			d = logbat_new(TYPE_oid, BATSIZE, PERSISTENT);
			if (d == NULL)
				logger_fatal("Logger_new: cannot create "
					     "dcatalog bat", 0, 0, 0);
			BBPincref(d->batCacheid, TRUE);
			if (BBPrename(d->batCacheid, bak) < 0)
				logger_fatal("Logger_new: BBPrename to %s "
					     "failed", bak, 0, 0);
			if (!BAThdense(b) || !BAThdense(n)) {
				/* we need to convert catalog_bid and
				 * catalog_nme to be dense-headed; we
				 * do this by replacing the two with
				 * new, dense versions */
				BATiter bi, ni;
				BUN r;
				const oid *o;
				BAT *b2, *n2;
				bat list[5];

				list[0] = 0;
				list[1] = b->batCacheid;
				list[2] = n->batCacheid;
				if ((b2 = logbat_new(b->ttype, BATSIZE, PERSISTENT)) == NULL)
					logger_fatal("Logger_new: cannot create BAT", 0, 0, 0);
				if ((n2 = logbat_new(n->ttype, BATSIZE, PERSISTENT)) == NULL)
					logger_fatal("Logger_new: cannot create BAT", 0, 0, 0);
				list[3] = b2->batCacheid;
				list[4] = n2->batCacheid;
				logger_switch_bat(b, b2, fn, "catalog_bid");
				logger_switch_bat(n, n2, fn, "catalog_nme");
				bi = bat_iterator(b);
				ni = bat_iterator(n);
				BATloop(b, p, q) {
					o = (const oid *) BUNhloc(bi, p);
					r = BUNfnd(BATmirror(n), o);
					if (r != BUN_NONE) {
						if (BUNappend(b2, BUNtloc(bi, p), 0) != GDK_SUCCEED ||
						    BUNappend(n2, BUNtvar(ni, r), 0) != GDK_SUCCEED)
							logger_fatal("Logger_new: cannot append to new catalog BATs", 0, 0, 0);
					}
				}
				BBPunfix(b->batCacheid);
				BBPunfix(n->batCacheid);
				b = b2;
				n = n2;
				if (TMsubcommit_list(list, 5) != GDK_SUCCEED)
					logger_fatal("Logger_new: committing new catalog_bid/catalog_nme failed", 0, 0, 0);
			}
		}

		/* the catalog exists, and so should the log file */
		if (fp == NULL) {
			logger_fatal("logger_new: there is a logger catalog, but no log file.\n"
				     "Are you sure you are using the correct combination of database\n"
				     "(--dbpath) and log directory (--set %s_logdir)?\n"
				     "If you have done a recent update of the server, it may be that your\n"
				     "logs are in an old location.  You should then either use\n"
				     "--set %s_logdir=<path to old log directory> or move the old log\n"
				     "directory to the new location (%s).\n",
				     fn, fn, lg->dir);
		}
		lg->catalog_bid = b;
		lg->catalog_nme = n;
		lg->dcatalog = d;
		BATloop(b, p, q) {
			bat bid = *(log_bid *) Tloc(b, p);
			oid pos = p;

			if (BUNfnd(lg->dcatalog, &pos) == BUN_NONE)
				BBPincref(bid, TRUE);
		}
	}
	lg->freed = logbat_new(TYPE_int, 1, TRANSIENT);
	if (lg->freed == NULL)
		logger_fatal("Logger_new: failed to create freed bat", 0, 0, 0);
	snprintf(bak, sizeof(bak), "%s_freed", fn);
	if (BBPrename(lg->freed->batCacheid, bak) < 0)
		logger_fatal("Logger_new: BBPrename to %s failed",
			     bak, 0, 0);
	snapshots_bid = logger_find_bat(lg, "snapshots_bid");
	if (snapshots_bid == 0) {
		lg->seqs_id = logbat_new(TYPE_int, 1, TRANSIENT);
		lg->seqs_val = logbat_new(TYPE_lng, 1, TRANSIENT);
		lg->dseqs = logbat_new(TYPE_oid, 1, TRANSIENT);
		if (lg->seqs_id == NULL ||
		    lg->seqs_val == NULL ||
		    lg->dseqs == NULL)
			logger_fatal("Logger_new: cannot create seqs bats",
				     0, 0, 0);

		/* create LOG_SID sequence number */
		if (BUNappend(lg->seqs_id, &id, FALSE) != GDK_SUCCEED ||
		    BUNappend(lg->seqs_val, &lg->id, FALSE) != GDK_SUCCEED)
			logger_fatal("Logger_new: failed to append value to "
				     "sequences bat", 0, 0, 0);

		lg->snapshots_bid = logbat_new(TYPE_int, 1, PERSISTENT);
		lg->snapshots_tid = logbat_new(TYPE_int, 1, PERSISTENT);
		lg->dsnapshots = logbat_new(TYPE_oid, 1, PERSISTENT);
		if (lg->snapshots_bid == NULL ||
		    lg->snapshots_tid == NULL ||
		    lg->dsnapshots == NULL)
			logger_fatal("Logger_new: failed to create snapshots "
				     "bats", 0, 0, 0);

		snprintf(bak, sizeof(bak), "%s_snapshots_bid", fn);
		if (BBPrename(lg->snapshots_bid->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);
		logger_add_bat(lg, lg->snapshots_bid, "snapshots_bid");

		snprintf(bak, sizeof(bak), "%s_snapshots_tid", fn);
		if (BBPrename(lg->snapshots_tid->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);
		logger_add_bat(lg, lg->snapshots_tid, "snapshots_tid");

		snprintf(bak, sizeof(bak), "%s_dsnapshots", fn);
		if (BBPrename(lg->dsnapshots->batCacheid, bak) < 0)
			logger_fatal("Logger_new: BBPrename to %s failed",
				     bak, 0, 0);
		logger_add_bat(lg, lg->dsnapshots, "dsnapshots");

		if (bm_subcommit(lg, lg->catalog_bid, lg->catalog_nme, lg->catalog_bid, lg->catalog_nme, lg->dcatalog, NULL, lg->debug) != GDK_SUCCEED)
			logger_fatal("Logger_new: commit failed", 0, 0, 0);
	} else {
		bat seqs_id = logger_find_bat(lg, "seqs_id");
		bat seqs_val = logger_find_bat(lg, "seqs_val");
		bat snapshots_tid = logger_find_bat(lg, "snapshots_tid");
		bat dsnapshots = logger_find_bat(lg, "dsnapshots");
		int needcommit = 0;
		int dbg = GDKdebug;

		if (seqs_id) {
			BAT *o_id;
			BAT *o_val;

			/* don't check these bats since they will be fixed */
			GDKdebug &= ~CHECKMASK;
			o_id = BATdescriptor(seqs_id);
			o_val = BATdescriptor(seqs_val);
			GDKdebug = dbg;

			if (o_id == NULL || o_val == NULL)
				logger_fatal("Logger_new: inconsistent database: cannot find seqs bats", 0, 0, 0);

			lg->seqs_id = BATcopy(o_id, TYPE_void, TYPE_int, 1, TRANSIENT);
			lg->seqs_val = BATcopy(o_val, TYPE_void, TYPE_lng, 1, TRANSIENT);
			BBPunfix(o_id->batCacheid);
			BBPunfix(o_val->batCacheid);
			BATseqbase(lg->seqs_id, 0);
			BATseqbase(lg->seqs_val, 0);
		} else {
			lg->seqs_id = logbat_new(TYPE_int, 1, TRANSIENT);
			lg->seqs_val = logbat_new(TYPE_lng, 1, TRANSIENT);
		}
		lg->dseqs = logbat_new(TYPE_oid, 1, TRANSIENT);
		if (lg->seqs_id == NULL ||
		    lg->seqs_val == NULL ||
		    lg->dseqs == NULL)
			logger_fatal("Logger_new: cannot create seqs bats",
				     0, 0, 0);

		GDKdebug &= ~CHECKMASK;
		lg->snapshots_bid = BATdescriptor(snapshots_bid);
		if (lg->snapshots_bid == 0)
			logger_fatal("Logger_new: inconsistent database, snapshots_bid does not exist", 0, 0, 0);
		lg->snapshots_tid = BATdescriptor(snapshots_tid);
		if (lg->snapshots_tid == 0)
			logger_fatal("Logger_new: inconsistent database, snapshots_tid does not exist", 0, 0, 0);
		GDKdebug = dbg;
		if (lg->snapshots_bid->htype == TYPE_oid) {
			BAT *b;
			assert(lg->snapshots_tid->htype == TYPE_oid);
			b = BATcopy(lg->snapshots_bid, TYPE_void, lg->snapshots_bid->ttype, 1, PERSISTENT);
			BATseqbase(b, 0);
			BATsetaccess(b, BAT_READ);
			snprintf(bak, sizeof(bak), "tmp_%o", lg->snapshots_bid->batCacheid);
			BBPrename(lg->snapshots_bid->batCacheid, bak);
			BATmode(lg->snapshots_bid, TRANSIENT);
			snprintf(bak, sizeof(bak), "%s_snapshots_bid", fn);
			BBPrename(b->batCacheid, bak);
			logbat_destroy(lg->snapshots_bid);
			lg->snapshots_bid = b;
			logger_add_bat(lg, b, "snapshots_bid");
			b = BATcopy(lg->snapshots_tid, TYPE_void, lg->snapshots_tid->ttype, 1, PERSISTENT);
			BATseqbase(b, 0);
			BATsetaccess(b, BAT_READ);
			snprintf(bak, sizeof(bak), "tmp_%o", lg->snapshots_tid->batCacheid);
			BBPrename(lg->snapshots_tid->batCacheid, bak);
			BATmode(lg->snapshots_tid, TRANSIENT);
			snprintf(bak, sizeof(bak), "%s_snapshots_tid", fn);
			BBPrename(b->batCacheid, bak);
			logbat_destroy(lg->snapshots_tid);
			lg->snapshots_tid = b;
			logger_add_bat(lg, b, "snapshots_tid");
			needcommit = 1;
		}

		if (dsnapshots) {
			lg->dsnapshots = BATdescriptor(dsnapshots);
			if (lg->dsnapshots == 0)
				logger_fatal("Logger_new: inconsistent database, snapshots_tid does not exist", 0, 0, 0);
		} else {
			lg->dsnapshots = logbat_new(TYPE_oid, 1, PERSISTENT);
			snprintf(bak, sizeof(bak), "%s_dsnapshots", fn);
			if (BBPrename(lg->dsnapshots->batCacheid, bak) < 0)
				logger_fatal("Logger_new: BBPrename to %s failed", bak, 0, 0);
			logger_add_bat(lg, lg->dsnapshots, "dsnapshots");
			needcommit = 1;
		}
		GDKdebug &= ~CHECKMASK;
		if (needcommit && bm_commit(lg) != LOG_OK)
			logger_fatal("Logger_new: commit failed", 0, 0, 0);
		GDKdebug = dbg;
	}

	if (fp != NULL) {
#if SIZEOF_OID == 8
		char cvfile[BUFSIZ];
#endif

		if (check_version(lg, fp) != GDK_SUCCEED) {
			goto error;
		}

#if SIZEOF_OID == 8
		/* When a file *_32-64-convert exists in the database,
		 * it was left there by the BBP initialization code
		 * when it did a conversion of 32-bit OIDs to 64 bits
		 * (see the comment above fixoidheapcolumn and
		 * fixoidheap in gdk_bbp).  It the file exists, we
		 * first create a file called convert-32-64 in the log
		 * directory and we write the current log ID into that
		 * file.  After this file is created, we delete the
		 * *_32-64-convert file in the database.  We then know
		 * that while reading the logs, we have to read OID
		 * values as 32 bits (this is indicated by setting the
		 * read32bitoid flag).  When we're done reading the
		 * logs, we remove the file (and reset the flag).  If
		 * we get interrupted before we have written this
		 * file, the file in the database will still exist, so
		 * the next time we're started, BBPinit will not
		 * convert OIDs (that was done before we got
		 * interrupted), but we will still know to convert the
		 * OIDs ourselves.  If we get interrupted after we
		 * have deleted the file from the database, we check
		 * whether the file convert-32-64 exists and if it
		 * contains the expected ID.  If it does, we again
		 * know that we have to convert.  If the ID is not
		 * what we expect, the conversion was apparently done
		 * already, and so we can delete the file. */

		snprintf(cvfile, sizeof(cvfile),
			 "%s%c%s%c%s%cconvert-32-64",
			 GDKgetenv("gdk_dbpath"),
			 DIR_SEP, logdir, DIR_SEP, fn, DIR_SEP);
		snprintf(bak, sizeof(bak), "%s_32-64-convert", fn);
		{
			FILE *fp1;
			long off; /* type long required by ftell() & fseek() */
			int curid;

			/* read the current log id without disturbing
			 * the file pointer */
			off = ftell(fp);
			if (fscanf(fp, "%d", &curid) != 1)
				curid = -1; /* shouldn't happen? */
			fseek(fp, off, SEEK_SET);

			if ((fp1 = fopen(bak, "r")) != NULL) {
				/* file indicating that we need to do
				 * a 32->64 bit OID conversion exists;
				 * record the fact in case we get
				 * interrupted, and set the flag so
				 * that we actually do what's asked */
				fclose(fp1);
				/* first create a versioned file using
				 * the current log id */
				if ((fp1 = fopen(cvfile, "w")) == NULL ||
				    fprintf(fp1, "%d\n", curid) < 2 ||
				    fflush(fp1) != 0 || /* make sure it's save on disk */
#if defined(_MSC_VER)
				    _commit(_fileno(fp1)) < 0 ||
#elif defined(HAVE_FDATASYNC)
				    fdatasync(fileno(fp1)) < 0 ||
#elif defined(HAVE_FSYNC)
				    fsync(fileno(fp1)) < 0 ||
#endif
				    fclose(fp1) != 0)
					logger_fatal("Logger_new: failed to write %s\n", cvfile, 0, 0);
				/* then remove the unversioned file
				 * that gdk_bbp created (in this
				 * order!) */
				unlink(bak);
				/* set the flag that we need to convert */
				lg->read32bitoid = 1;
			} else if ((fp1 = fopen(cvfile, "r")) != NULL) {
				/* the versioned conversion file
				 * exists: check version */
				int newid;

				if (fscanf(fp1, "%d", &newid) == 1 &&
				    newid == curid) {
					/* versions match, we need to
					 * convert */
					lg->read32bitoid = 1;
				}
				fclose(fp1);
				if (!lg->read32bitoid) {
					/* no conversion, so we can
					 * remove the versioned
					 * file */
					unlink(cvfile);
				}
			}
		}
#endif
		logger_readlogs(lg, fp, filename);
		fclose(fp);
		fp = NULL;
#if SIZEOF_OID == 8
		if (lg->read32bitoid) {
			/* we converted, remove versioned file and
			 * reset conversion flag */
			unlink(cvfile);
			lg->read32bitoid = 0;
		}
#endif
		if (lg->postfuncp)
			(*lg->postfuncp)(lg);
	}
	return lg;
      error:
	if (fp)
		fclose(fp);
	if (lg)
		GDKfree(lg);
	return NULL;
}

logger *
logger_create(int debug, const char *fn, const char *logdir, int version, preversionfix_fptr prefuncp, postversionfix_fptr postfuncp)
{
	logger *lg;

	printf("# Start processing logs %s/%s version %d\n",fn,logdir,version);
	fflush(stdout);
	lg = logger_new(debug, fn, logdir, version, prefuncp, postfuncp);

	if (!lg)
		return NULL;
	if (logger_open(lg) == LOG_ERR) {
		logger_destroy(lg);

		return NULL;
	}
	printf("# Finished processing logs %s/%s\n",fn,logdir);
	GDKsetenv("recovery","finished");
	fflush(stdout);
	if (lg->changes &&
	    (logger_restart(lg) != LOG_OK ||
	     logger_cleanup(lg) != LOG_OK)) {
		logger_destroy(lg);

		return NULL;
	}
	return lg;
}

void
logger_destroy(logger *lg)
{
	if (lg->catalog_bid) {
		BUN p, q;
		BAT *b = lg->catalog_bid;

		logger_cleanup(lg);

		/* free resources */
		BATloop(b, p, q) {
			bat bid = *(log_bid *) Tloc(b, p);
			oid pos = p;

			if (BUNfnd(lg->dcatalog, &pos) == BUN_NONE)
				BBPdecref(bid, TRUE);
		}

		BBPdecref(lg->catalog_bid->batCacheid, TRUE);
		BBPdecref(lg->catalog_nme->batCacheid, TRUE);
		BBPdecref(lg->dcatalog->batCacheid, TRUE);
		logbat_destroy(lg->catalog_bid);
		logbat_destroy(lg->catalog_nme);
		logbat_destroy(lg->dcatalog);
		logbat_destroy(lg->freed);
	}
	GDKfree(lg->fn);
	GDKfree(lg->dir);
	logger_close(lg);
	GDKfree(lg);
}

int
logger_exit(logger *lg)
{
	FILE *fp;
	char filename[BUFSIZ];

	logger_close(lg);
	if (GDKmove(0, lg->dir, LOGFILE, NULL, lg->dir, LOGFILE, "bak") != GDK_SUCCEED) {
		fprintf(stderr, "!ERROR: logger_exit: rename %s to %s.bak in %s failed\n",
			LOGFILE, LOGFILE, lg->dir);
		return LOG_ERR;
	}

	snprintf(filename, sizeof(filename), "%s%s", lg->dir, LOGFILE);
	if ((fp = fopen(filename, "w")) != NULL) {
		char ext[BUFSIZ];

		if (fprintf(fp, "%06d\n\n", lg->version) < 0) {
			(void) fclose(fp);
			fprintf(stderr, "!ERROR: logger_exit: write to %s failed\n",
				filename);
			return LOG_ERR;
		}
		lg->id ++;

		if (logger_commit(lg) != LOG_OK) {
			(void) fclose(fp);
			fprintf(stderr, "!ERROR: logger_exit: logger_commit failed\n");
			return LOG_ERR;
		}

		if (fprintf(fp, LLFMT "\n", lg->id) < 0) {
			(void) fclose(fp);
			fprintf(stderr, "!ERROR: logger_exit: write to %s failed\n",
				filename);
			return LOG_ERR;
		}

		if (fflush(fp) < 0 ||
#if defined(_MSC_VER)
		    _commit(_fileno(fp)) < 0 ||
#elif defined(HAVE_FDATASYNC)
		    fdatasync(fileno(fp)) < 0 ||
#elif defined(HAVE_FSYNC)
		    fsync(fileno(fp)) < 0 ||
#endif
		    fclose(fp) < 0) {
			fprintf(stderr, "!ERROR: logger_exit: flush of %s failed\n",
				filename);
			return LOG_ERR;
		}

		/* atomic action, switch to new log, keep old for
		 * later cleanup actions */
		snprintf(ext, sizeof(ext), "bak-" LLFMT, lg->id);

		if (GDKmove(0, lg->dir, LOGFILE, "bak", lg->dir, LOGFILE, ext) != GDK_SUCCEED) {
			fprintf(stderr, "!ERROR: logger_exit: rename %s.bak to %s.%s failed\n",
				LOGFILE, LOGFILE, ext);
			return LOG_ERR;
		}

		lg->changes = 0;
	} else {
		fprintf(stderr, "!ERROR: logger_exit: could not create %s\n",
			filename);
		GDKerror("logger_exit: could not open %s\n", filename);
		return LOG_ERR;
	}
	return LOG_OK;
}

int
logger_restart(logger *lg)
{
	int res = 0;

	if ((res = logger_exit(lg)) == LOG_OK)
		res = logger_open(lg);

	return res;
}

int
logger_cleanup(logger *lg)
{
	char buf[BUFSIZ];
	char id[BUFSIZ];
	FILE *fp = NULL;

	snprintf(buf, sizeof(buf), "%s%s.bak-" LLFMT, lg->dir, LOGFILE, lg->id);

	if (lg->debug & 1)
		fprintf(stderr, "#logger_cleanup %s\n", buf);

	if ((fp = fopen(buf, "r")) == NULL) {
		fprintf(stderr, "!ERROR: logger_cleanup: cannot open file %s\n", buf);
		return LOG_ERR;
	}

	/* skip catalog */
	while (fgets(id, sizeof(id), fp) != NULL && id[0] != '\n')
		;

	while (fgets(id, sizeof(id), fp) != NULL) {
		char *e = strchr(id, '\n');

		if (e)
			*e = 0;
		GDKunlink(0, lg->dir, LOGFILE, id);
	}
	fclose(fp);
	snprintf(buf, sizeof(buf), "bak-" LLFMT, lg->id);

	GDKunlink(0, lg->dir, LOGFILE, buf);

	return LOG_OK;
}

lng
logger_changes(logger *lg)
{
	return lg->changes;
}

int
logger_sequence(logger *lg, int seq, lng *id)
{
	BUN p = log_find(lg->seqs_id, lg->dseqs, seq);

	if (p != BUN_NONE) {
		*id = *(lng *) Tloc(lg->seqs_val, p);

		return 1;
	}
	return 0;
}

/*
 * Changes made to the BAT descriptor should be stored in the log
 * files.  Actually, we need to save the descriptor file, perhaps we
 * should simply introduce a versioning scheme.
 */
int
log_bat_persists(logger *lg, BAT *b, const char *name)
{
	char *ha, *ta;
	int len;
	char buf[BUFSIZ];
	logformat l;
	int havevoid = 0;
	int flag = (b->batPersistence == PERSISTENT) ? LOG_USE : LOG_CREATE;
	BUN p;

	l.nr = 0;
	if (flag == LOG_USE) {
#ifndef NDEBUG
		assert(b->batRole == PERSISTENT);
		assert(0 <= b->H->heap.farmid && b->H->heap.farmid < MAXFARMS);
		assert(BBPfarms[b->H->heap.farmid].roles & (1 << PERSISTENT));
		if (b->H->vheap) {
			assert(0 <= b->H->vheap->farmid && b->H->vheap->farmid < MAXFARMS);
			assert(BBPfarms[b->H->vheap->farmid].roles & (1 << PERSISTENT));
		}
		assert(0 <= b->T->heap.farmid && b->T->heap.farmid < MAXFARMS);
		assert(BBPfarms[b->T->heap.farmid].roles & (1 << PERSISTENT));
		if (b->T->vheap) {
			assert(0 <= b->T->vheap->farmid && b->T->vheap->farmid < MAXFARMS);
			assert(BBPfarms[b->T->vheap->farmid].roles & (1 << PERSISTENT));
		}
#endif
		l.nr = b->batCacheid;
	}
	l.flag = flag;
	l.tid = lg->tid;
	lg->changes++;
	if (log_write_format(lg, &l) == LOG_ERR ||
	    log_write_string(lg, name) == LOG_ERR)
		return LOG_ERR;

	if (lg->debug & 1)
		fprintf(stderr, "#persists bat %s (%d) %s\n",
			name, b->batCacheid,
			(flag == LOG_USE) ? "use" : "create");

	if (flag == LOG_USE) {
		assert(b->batRole == PERSISTENT);
		assert(b->H->heap.farmid == 0);
		assert(b->H->vheap == NULL ||
		       BBPfarms[b->H->vheap->farmid].roles & (1 << PERSISTENT));
		assert(b->T->heap.farmid == 0);
		assert(b->T->vheap == NULL ||
		       BBPfarms[b->T->vheap->farmid].roles & (1 << PERSISTENT));
		if ((p = log_find(lg->snapshots_bid, lg->dsnapshots, b->batCacheid)) != BUN_NONE &&
		    p >= lg->snapshots_tid->batInserted) {
			BUNinplace(lg->snapshots_tid, p, NULL, &lg->tid, FALSE);
		} else {
			if (p != BUN_NONE) {
				oid pos = p;
				BUNappend(lg->dsnapshots, &pos, FALSE);
			}
			BUNappend(lg->snapshots_bid, &b->batCacheid, FALSE);
			BUNappend(lg->snapshots_tid, &lg->tid, FALSE);
		}
		return LOG_OK;
	}

	ha = ATOMname(b->htype);
	if (b->htype == TYPE_void && BAThdense(b)) {
		ha = "vid";
		havevoid = 1;
	}
	ta = ATOMname(b->ttype);
	if (!havevoid && b->ttype == TYPE_void && BATtdense(b)) {
		ta = "vid";
	}
	len = snprintf(buf, sizeof(buf), "%s,%s", ha, ta);
	len++;			/* include EOS */
	if (!mnstr_writeInt(lg->log, len) ||
	    mnstr_write(lg->log, buf, 1, len) != (ssize_t) len) {
		fprintf(stderr, "!ERROR: log_bat_persists: write failed\n");
		return LOG_ERR;
	}

	if (lg->debug & 1)
		fprintf(stderr, "#Logged new bat [%s,%s] %s " BUNFMT " (%d)\n",
			ha, ta, name, BATcount(b), b->batCacheid);
	return log_bat(lg, b, name);
}

int
log_bat_transient(logger *lg, const char *name)
{
	log_bid bid = logger_find_bat(lg, name);
	logformat l;
	BUN p;

	l.flag = LOG_DESTROY;
	l.tid = lg->tid;
	l.nr = 0;
	lg->changes++;

	/* if this is a snapshot bat, we need to skip all changes */
	if ((p = log_find(lg->snapshots_bid, lg->dsnapshots, bid)) != BUN_NONE) {
	//	int tid = *(int*)Tloc(lg->snapshots_tid, p);
#ifndef NDEBUG
		assert(BBP_desc(bid)->S.role == PERSISTENT);
		assert(0 <= BBP_desc(bid)->H.heap.farmid && BBP_desc(bid)->H.heap.farmid < MAXFARMS);
		assert(BBPfarms[BBP_desc(bid)->H.heap.farmid].roles & (1 << PERSISTENT));
		if (BBP_desc(bid)->H.vheap) {
			assert(0 <= BBP_desc(bid)->H.vheap->farmid && BBP_desc(bid)->H.vheap->farmid < MAXFARMS);
			assert(BBPfarms[BBP_desc(bid)->H.vheap->farmid].roles & (1 << PERSISTENT));
		}
		assert(0 <= BBP_desc(bid)->T.heap.farmid && BBP_desc(bid)->T.heap.farmid < MAXFARMS);
		assert(BBPfarms[BBP_desc(bid)->T.heap.farmid].roles & (1 << PERSISTENT));
		if (BBP_desc(bid)->T.vheap) {
			assert(0 <= BBP_desc(bid)->T.vheap->farmid && BBP_desc(bid)->T.vheap->farmid < MAXFARMS);
			assert(BBPfarms[BBP_desc(bid)->T.vheap->farmid].roles & (1 << PERSISTENT));
		}
#endif
	//	if (lg->tid == tid)
		if (p >= lg->snapshots_tid->batInserted) {
			BUNinplace(lg->snapshots_tid, p, NULL, &lg->tid, FALSE);
		} else {
			oid pos = p;
			BUNappend(lg->dsnapshots, &pos, FALSE);
			BUNappend(lg->snapshots_tid, &lg->tid, FALSE);
			BUNappend(lg->snapshots_bid, &bid, FALSE);
		}
	//	else
	//		printf("%d != %d\n", lg->tid, tid);
	//	assert(lg->tid == tid);
	}

	if (log_write_format(lg, &l) == LOG_ERR ||
	    log_write_string(lg, name) == LOG_ERR) {
		fprintf(stderr, "!ERROR: log_bat_transient: write failed\n");
		return LOG_ERR;
	}

	if (lg->debug & 1)
		fprintf(stderr, "#Logged destroyed bat %s\n", name);
	return LOG_OK;
}

int
log_delta(logger *lg, BAT *uid, BAT *uval, const char *name)
{
	gdk_return ok = GDK_SUCCEED;
	logformat l;
	BUN p;

	assert(uid->ttype == TYPE_oid || !uid->ttype);
	if (lg->debug & 128) {
		/* logging is switched off */
		return LOG_OK;
	}

	l.tid = lg->tid;
	l.nr = (BUNlast(uval) - BUNfirst(uval));
	lg->changes += l.nr;

	if (l.nr) {
		BATiter ii = bat_iterator(uid);
		BATiter vi = bat_iterator(uval);
		gdk_return (*wh) (const void *, stream *, size_t) = BATatoms[TYPE_oid].atomWrite;
		gdk_return (*wt) (const void *, stream *, size_t) = BATatoms[uval->ttype].atomWrite;

		l.flag = LOG_UPDATE;
		if (log_write_format(lg, &l) == LOG_ERR ||
		    log_write_string(lg, name) == LOG_ERR)
			return LOG_ERR;

		for (p = BUNfirst(uid); p < BUNlast(uid) && ok == GDK_SUCCEED; p++) {
			const void *id = BUNtail(ii, p);
			const void *val = BUNtail(vi, p);

			ok = wh(id, lg->log, 1);
			ok = (ok != GDK_SUCCEED) ? ok : wt(val, lg->log, 1);
		}

		if (lg->debug & 1)
			fprintf(stderr, "#Logged %s " LLFMT " inserts\n", name, l.nr);
	}
	if (ok != GDK_SUCCEED)
		fprintf(stderr, "!ERROR: log_delta: write failed\n");
	return (ok == GDK_SUCCEED) ? LOG_OK : LOG_ERR;
}

int
log_bat(logger *lg, BAT *b, const char *name)
{
	gdk_return ok = GDK_SUCCEED;
	logformat l;
	BUN p;

	if (lg->debug & 128) {
		/* logging is switched off */
		return LOG_OK;
	}

	l.tid = lg->tid;
	l.nr = (BUNlast(b) - b->batInserted);
	lg->changes += l.nr;

	if (l.nr) {
		BATiter bi = bat_iterator(b);
		gdk_return (*wh) (const void *, stream *, size_t) = BATatoms[b->htype].atomWrite;
		gdk_return (*wt) (const void *, stream *, size_t) = BATatoms[b->ttype].atomWrite;

		l.flag = LOG_INSERT;
		if (log_write_format(lg, &l) == LOG_ERR ||
		    log_write_string(lg, name) == LOG_ERR)
			return LOG_ERR;

		if (b->htype == TYPE_void &&
		    b->ttype > TYPE_void &&
		    b->ttype < TYPE_str &&
		    !isVIEW(b)) {
			const void *t = BUNtail(bi, b->batInserted);

			ok = wt(t, lg->log, (size_t)l.nr);
		} else {
			for (p = b->batInserted; p < BUNlast(b) && ok == GDK_SUCCEED; p++) {
				const void *h = BUNhead(bi, p);
				const void *t = BUNtail(bi, p);

				ok = wh(h, lg->log, 1);
				ok = (ok != GDK_SUCCEED) ? ok : wt(t, lg->log, 1);
			}
		}

		if (lg->debug & 1)
			fprintf(stderr, "#Logged %s " LLFMT " inserts\n", name, l.nr);
	}
	l.nr = (b->batFirst - b->batDeleted);
	lg->changes += l.nr;

	if (l.nr && ok == GDK_SUCCEED) {
		BATiter bi = bat_iterator(b);
		gdk_return (*wh) (const void *, stream *, size_t) = BATatoms[b->htype].atomWrite;
		gdk_return (*wt) (const void *, stream *, size_t) = BATatoms[b->ttype].atomWrite;

		l.flag = LOG_DELETE;
		if (log_write_format(lg, &l) == LOG_ERR ||
		    log_write_string(lg, name) == LOG_ERR)
			return LOG_ERR;

		for (p = b->batDeleted; p < b->batFirst && ok == GDK_SUCCEED; p++) {
			const void *h = BUNhead(bi, p);
			const void *t = BUNtail(bi, p);

			ok = wh(h, lg->log, 1);
			ok = (ok != GDK_SUCCEED) ? ok : wt(t, lg->log, 1);
		}

		if (lg->debug & 1)
			fprintf(stderr, "#Logged %s " LLFMT " deletes\n", name, l.nr);
	}
	if (ok != GDK_SUCCEED)
		fprintf(stderr, "!ERROR: log_bat: write failed\n");
	return (ok == GDK_SUCCEED) ? LOG_OK : LOG_ERR;
}

int
log_bat_clear(logger *lg, const char *name)
{
	logformat l;

	if (lg->debug & 128) {
		/* logging is switched off */
		return LOG_OK;
	}

	l.nr = 1;
	l.tid = lg->tid;
	lg->changes += l.nr;

	l.flag = LOG_CLEAR;
	if (log_write_format(lg, &l) == LOG_ERR ||
	    log_write_string(lg, name) == LOG_ERR)
		return LOG_ERR;

	if (lg->debug & 1)
		fprintf(stderr, "#Logged clear %s\n", name);

	return LOG_OK;
}

int
log_tstart(logger *lg)
{
	logformat l;

	l.flag = LOG_START;
	l.tid = ++lg->tid;
	l.nr = lg->tid;

	if (lg->debug & 1)
		fprintf(stderr, "#log_tstart %d\n", lg->tid);

	return log_write_format(lg, &l);
}

#define DBLKSZ 8192
#define DBLKMASK 8191
#define SEGSZ 64*DBLKSZ
static char zeros[DBLKSZ] = { 0 };

static gdk_return
pre_allocate(logger *lg)
{
	lng p;

	if (mnstr_fgetpos(lg->log, &p) != 0)
		return GDK_FAIL;
	if (p + DBLKSZ > lg->end) {
		lng s = p;

		if (p > lg->end) {
			lg->end = (p & ~DBLKMASK);
			if (p > DBLKSZ)
				p -= DBLKSZ;
		}
		if (p < lg->end) {
			p = (lg->end - p);
			if (mnstr_write(lg->log, zeros, (size_t) p, 1) < 0)
				return GDK_FAIL;
			lg->end += p;
			p = 0;
		}
		for (; p < SEGSZ; p += DBLKSZ, lg->end += DBLKSZ) {
			if (mnstr_write(lg->log, zeros, DBLKSZ, 1) < 0)
				return GDK_FAIL;
		}
		if (mnstr_fsetpos(lg->log, s) < 0)
			return GDK_FAIL;
	}
	return GDK_SUCCEED;
}

int
log_tend(logger *lg)
{
	logformat l;
	gdk_return res = GDK_SUCCEED;

	if (lg->debug & 1)
		fprintf(stderr, "#log_tend %d\n", lg->tid);

	if (DELTAdirty(lg->snapshots_bid)) {
		/* sub commit all new snapshots */
		BAT *cands, *tids, *bids;

		tids = bm_tids(lg->snapshots_tid, lg->dsnapshots);
		cands = BATsubselect(lg->snapshots_tid, tids, &lg->tid, &lg->tid,
				    TRUE, TRUE, FALSE);
		if (tids == NULL || cands == NULL) {
			fprintf(stderr, "!ERROR: log_tend: subselect failed\n");
			return LOG_ERR;
		}
		bids = BATproject(cands, lg->snapshots_bid);
		BBPunfix(cands->batCacheid);
		BBPunfix(tids->batCacheid);
		if (bids == NULL) {
			fprintf(stderr, "!ERROR: log_tend: semijoin failed\n");
			return LOG_ERR;
		}
		res = bm_subcommit(lg, bids, NULL, lg->snapshots_bid,
				   lg->snapshots_tid, lg->dsnapshots, NULL, lg->debug);
		BBPunfix(bids->batCacheid);
	}
	l.flag = LOG_END;
	l.tid = lg->tid;
	l.nr = lg->tid;
	if (res != GDK_SUCCEED ||
	    log_write_format(lg, &l) == LOG_ERR ||
	    mnstr_flush(lg->log) ||
	    mnstr_fsync(lg->log) ||
	    pre_allocate(lg) != GDK_SUCCEED) {
		fprintf(stderr, "!ERROR: log_tend: write failed\n");
		return LOG_ERR;
	}
	return LOG_OK;
}

int
log_abort(logger *lg)
{
	logformat l;

	if (lg->debug & 1)
		fprintf(stderr, "#log_abort %d\n", lg->tid);

	l.flag = LOG_END;
	l.tid = lg->tid;
	l.nr = -1;

	if (log_write_format(lg, &l) == LOG_ERR)
		return LOG_ERR;

	return LOG_OK;
}

static int
log_sequence_(logger *lg, int seq, lng val, int flush)
{
	logformat l;

	l.flag = LOG_SEQ;
	l.tid = lg->tid;
	l.nr = seq;

	if (lg->debug & 1)
		fprintf(stderr, "#log_sequence_ (%d," LLFMT ")\n", seq, val);

	if (log_write_format(lg, &l) == LOG_ERR ||
	    !mnstr_writeLng(lg->log, val) ||
	    (flush && mnstr_flush(lg->log)) ||
	    (flush && mnstr_fsync(lg->log)) ||
	    pre_allocate(lg) != GDK_SUCCEED) {
		fprintf(stderr, "!ERROR: log_sequence_: write failed\n");
		return LOG_ERR;
	}
	return LOG_OK;
}

static int
log_sequence_nrs(logger *lg)
{
	BATiter sii = bat_iterator(lg->seqs_id);
	BATiter svi = bat_iterator(lg->seqs_val);
	BUN p, q;
	int ok = LOG_OK;

	BATloop(lg->seqs_id, p, q) {
		const int *id = (const int *) BUNtloc(sii, p);
		const lng *val = (const lng *) BUNtloc(svi, p);
		oid pos = p;

		if (BUNfnd(lg->dseqs, &pos) == BUN_NONE)
			ok |= log_sequence_(lg, *id, *val, 0);
	}
	if (ok != LOG_OK ||
	    mnstr_flush(lg->log) ||
	    mnstr_fsync(lg->log)) {
		fprintf(stderr, "!ERROR: log_sequence_nrs: write failed\n");
		return LOG_ERR;
	}
	return ok;
}

/* a transaction in it self */
int
log_sequence(logger *lg, int seq, lng val)
{
	BUN p;

	if (lg->debug & 1)
		fprintf(stderr, "#log_sequence (%d," LLFMT ")\n", seq, val);

	if ((p = log_find(lg->seqs_id, lg->dseqs, seq)) != BUN_NONE &&
	    p >= lg->seqs_id->batInserted) {
		BUNinplace(lg->seqs_val, p, NULL, &val, FALSE);
	} else {
		if (p != BUN_NONE) {
			oid pos = p;
			BUNappend(lg->dseqs, &pos, FALSE);
		}
		BUNappend(lg->seqs_id, &seq, FALSE);
		BUNappend(lg->seqs_val, &val, FALSE);
	}
	return log_sequence_(lg, seq, val, 1);
}

static int
bm_commit(logger *lg)
{
	BUN p, q;
	BAT *b = lg->catalog_bid;
	BAT *n = logbat_new(TYPE_str, BATcount(lg->freed), TRANSIENT);
	gdk_return res;

	/* subcommit the freed bats */
	BATseqbase(n, 0);
	if (BATcount(lg->freed)) {

		BATloop(lg->freed, p, q) {
			bat bid = *(log_bid *) Tloc(lg->freed, p);
			BAT *lb = BATdescriptor(bid);
			str name = BBPname(bid);

			BATmode(lb, TRANSIENT);
			logbat_destroy(lb);
			if (lg->debug & 1)
				fprintf(stderr,
					"#commit deleted (snapshot) %s (%d)\n",
					name, bid);
			BUNappend(n, name, FALSE);
			BBPdecref(bid, TRUE);
		}
	}

	for (p = b->batInserted; p < BUNlast(b); p++) {
		log_bid bid = *(log_bid *) Tloc(b, p);
		BAT *lb;
		oid pos = p;

		if (BUNfnd(lg->dcatalog, &pos) != BUN_NONE)
			continue;

		if (bid == lg->dsnapshots->batCacheid)
			continue;

	       	lb = BATdescriptor(bid);

		assert(lb);
		BATmode(lb, PERSISTENT);
		assert(lb->batRestricted > BAT_WRITE);
		logbat_destroy(lb);

		if (lg->debug & 1)
			fprintf(stderr, "#bm_commit: create %d (%d)\n",
				bid, BBP_lrefs(bid));
	}
	res = bm_subcommit(lg, lg->catalog_bid, lg->catalog_nme, lg->catalog_bid, lg->catalog_nme, lg->dcatalog, n, lg->debug);
	BBPreclaim(n);
	BATclear(lg->freed, FALSE);
	BATcommit(lg->freed);
	return res != GDK_SUCCEED ? LOG_ERR : LOG_OK;
}

log_bid
logger_add_bat(logger *lg, BAT *b, const char *name)
{
	log_bid bid = logger_find_bat(lg, name);

	assert(b->batRestricted > 0 ||
	       b == lg->snapshots_bid ||
	       b == lg->snapshots_tid ||
	       b == lg->dsnapshots ||
	       b == lg->catalog_bid ||
	       b == lg->catalog_nme ||
	       b == lg->dcatalog ||
	       b == lg->seqs_id ||
	       b == lg->seqs_val ||
	       b == lg->dseqs);
	assert(b->batRole == PERSISTENT);
	if (bid) {
		if (bid != b->batCacheid) {
			logger_del_bat(lg, bid);
		} else {
			return bid;
		}
	}
	bid = b->batCacheid;
	if (lg->debug & 1)
		fprintf(stderr, "#create %s\n", name);
	lg->changes += BATcount(b) + 1;
	BUNappend(lg->catalog_bid, &bid, FALSE);
	BUNappend(lg->catalog_nme, name, FALSE);
	BBPincref(bid, TRUE);
	return bid;
}

void
logger_del_bat(logger *lg, log_bid bid)
{
	BAT *b = BATdescriptor(bid);
	BUN p = log_find(lg->catalog_bid, lg->dcatalog, bid), q;

	assert(p != BUN_NONE);

	/* if this is a not logger commited snapshot bat, make it
	 * transient */
	if (p >= lg->catalog_bid->batInserted &&
	    (q = log_find(lg->snapshots_bid, lg->dsnapshots, bid)) != BUN_NONE) {
		
		BUNappend(lg->dsnapshots, &q, FALSE);
		if (lg->debug & 1)
			fprintf(stderr,
				"#logger_del_bat release snapshot %d (%d)\n",
				bid, BBP_lrefs(bid));
		BUNappend(lg->freed, &bid, FALSE);
	} else if (p >= lg->catalog_bid->batInserted) {
		BBPdecref(bid, TRUE);
	} else {
		BUNappend(lg->freed, &bid, FALSE);
	}
	if (b) {
		lg->changes += BATcount(b) + 1;
		BBPunfix(b->batCacheid);
	}
	BUNappend(lg->dcatalog, &p, FALSE);
/*assert(BBP_lrefs(bid) == 0);*/
}

log_bid
logger_find_bat(logger *lg, const char *name)
{
	BATiter cni = bat_iterator(lg->catalog_nme);
	BUN p;

	if (BAThash(lg->catalog_nme, 0) == GDK_SUCCEED) {
		HASHloop_str(cni, cni.b->T->hash, p, name) {
			oid pos = p;
			if (BUNfnd(lg->dcatalog, &pos) == BUN_NONE)
				return *(log_bid *) Tloc(lg->catalog_bid, p);
		}
	} 
	return 0;
}
