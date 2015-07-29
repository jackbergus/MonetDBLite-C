/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

#include "monetdb_config.h"
#include "res_table.h"
#include "sql_types.h"

static void
bat_incref(bat bid)
{
	BBPincref(bid, TRUE);
}

static void
bat_decref(bat bid)
{
	BBPdecref(bid, TRUE);
}


res_table *
res_table_create(sql_trans *tr, int res_id, int nr_cols, int type, res_table *next, void *O)
{
	BAT *order = (BAT*)O;
	res_table *t = ZNEW(res_table);

	(void) tr;
	t->id = res_id;

	t->query_type = type;
	t->nr_cols = nr_cols;
	t->cur_col = 0;
	t->cols = NEW_ARRAY(res_col, nr_cols);
	memset((char*) t->cols, 0, nr_cols * sizeof(res_col));
	t->tsep = t->rsep = t->ssep = t->ns = NULL;

	t->order = 0;
	if (order) {
		t->order = order->batCacheid;
		bat_incref(t->order);
	} 
	t->next = next;
	return t;
}

res_col *
res_col_create(sql_trans *tr, res_table *t, const char *tn, const char *name, const char *typename, int digits, int scale, int mtype, void *val)
{
	res_col *c = t->cols + t->cur_col;
	BAT *b;

	if (!sql_find_subtype(&c->type, typename, digits, scale)) 
		sql_init_subtype(&c->type, sql_trans_bind_type(tr, NULL, typename), digits, scale);
	c->tn = _STRDUP(tn);
	c->name = _STRDUP(name);
	c->b = 0;
	c->p = NULL;
	c->mtype = mtype;
	if (mtype == TYPE_bat) {
		b = (BAT*)val;
	} else { // wrap scalar values in BATs for result consistency
		b = BATnew(TYPE_void, mtype, 0, TRANSIENT);
		assert (b != NULL);
		BUNappend(b, val, FALSE);
		BATsetcount(b, 1);
		BATseqbase(b, 0);
		BATsettrivprop(b);
	}
	c->b = b->batCacheid;
	bat_incref(c->b);
	t->cur_col++;
	assert(t->cur_col <= t->nr_cols);
	return c;
}

static void
res_col_destroy(res_col *c)
{
	if (c->b) {
		bat_decref(c->b);
	} else {
		_DELETE(c->p);
	}
	_DELETE(c->name);
	_DELETE(c->tn);
}


void
res_table_destroy(res_table *t)
{
	int i;

	for (i = 0; i < t->nr_cols; i++) {
		res_col *c = t->cols + i;

		res_col_destroy(c);
	}
	if (t->order)
		bat_decref(t->order);
	_DELETE(t->cols);
	if (t->tsep)
		_DELETE(t->tsep);
	if (t->rsep)
		_DELETE(t->rsep);
	if (t->ssep)
		_DELETE(t->ssep);
	if (t->ns)
		_DELETE(t->ns);
	_DELETE(t);
}

res_table *
res_tables_remove(res_table *results, res_table *t)
{
	res_table *r = results;

	if (r == t) {
		results = t->next;
	} else {
		for (; r; r = r->next) {
			if (r->next == t) {
				r->next = t->next;
				break;
			}
		}
	}
	res_table_destroy(t);
	return results;
}

void
res_tables_destroy(res_table *tab)
{
	if (tab) {
		res_table *r = tab, *t;

		for (t = r; t; t = r) {
			r = t->next;
			res_table_destroy(t);
		}
	}
}

res_table *
res_tables_find(res_table *results, int res_id)
{
	res_table *r = results;

	for (; r; r = r->next) {
		if (r->id == res_id)
			return r;
	}
	return NULL;
}
