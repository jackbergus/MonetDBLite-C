/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

#include "monetdb_config.h"
#include "sql_atom.h"
#include <sql_string.h>
#include <sql_decimal.h>

static int atom_debug = 0;

static atom *
atom_create( sql_allocator *sa )
{
	atom *a;
	a = SA_NEW(sa, atom);

	memset(&a->data, 0, sizeof(a->data));
	a->d = dbl_nil;
	a->varid = -1;
	return a;
}

static ValPtr
SA_VALcopy(sql_allocator *sa, ValPtr d, ValPtr s)
{
	if (!ATOMextern(s->vtype)) {
		*d = *s;
	} else if (s->val.pval == 0) {
		d->val.pval = ATOMnil(s->vtype);
		d->vtype = s->vtype;
	} else if (s->vtype == TYPE_str) {
		d->vtype = TYPE_str;
		d->val.sval = sa_strdup(sa, s->val.sval);
		d->len = strLen(d->val.sval);
	} else if (s->vtype == TYPE_bit) {
		d->vtype = s->vtype;
		d->len = 1;
		d->val.btval = s->val.btval;
	} else {
		ptr p = s->val.pval;

		d->vtype = s->vtype;
		d->len = ATOMlen(d->vtype, p);
		d->val.pval = sa_alloc(sa, d->len);
		memcpy(d->val.pval, p, d->len);
	}
	return d;
}

atom *
atom_bool( sql_allocator *sa, sql_subtype *tpe, bit val)
{
	atom *a = atom_create(sa);
	
	a->isnull = 0;
	a->tpe = *tpe;
	a->data.vtype = tpe->type->localtype;
	a->data.val.btval = val;
	a->data.len = 0;
	return a;
}

atom *
atom_int( sql_allocator *sa, sql_subtype *tpe,
#ifdef HAVE_HGE
	hge val
#else
	lng val
#endif
)
{
	if (tpe->type->eclass == EC_FLT) {
		return atom_float(sa, tpe, (double) val);
	} else {
		atom *a = atom_create(sa);

		a->isnull = 0;
		a->tpe = *tpe;
		a->data.vtype = tpe->type->localtype;
		switch (ATOMstorage(a->data.vtype)) {
		case TYPE_bte:
			a->data.val.btval = (bte) val;
			break;
		case TYPE_sht:
			a->data.val.shval = (sht) val;
			break;
		case TYPE_int:
			a->data.val.ival = (int) val;
			break;
		case TYPE_wrd:
			a->data.val.wval = (wrd) val;
			break;
		case TYPE_oid:
			a->data.val.oval = (oid) val;
			break;
		case TYPE_lng:
			a->data.val.lval = (lng) val;
			break;
#ifdef HAVE_HGE
		case TYPE_hge:
			a->data.val.hval = val;
			break;
#endif
		default:
			printf("atom_int %d\n", a->data.vtype);
			assert(0);
		}
		a->d = (dbl) val;
		a->data.len = 0;
		if (atom_debug)
			fprintf(stderr, "atom_int(%s,%.40g)\n", tpe->type->sqlname, (dbl)val);
		return a;
	}
}

#ifdef HAVE_HGE
hge
#else
lng
#endif
atom_get_int(atom *a)
{
#ifdef HAVE_HGE
	hge r = 0;
#else
	lng r = 0;
#endif

	if (!a->isnull) {
		switch (ATOMstorage(a->data.vtype)) {
		case TYPE_bte:
			r = a->data.val.btval;
			break;
		case TYPE_sht:
			r = a->data.val.shval;
			break;
		case TYPE_int:
			r = a->data.val.ival;
			break;
		case TYPE_oid:
			r = a->data.val.oval;
			break;
		case TYPE_wrd:
			r = a->data.val.wval;
			break;
		case TYPE_lng:
			r = a->data.val.lval;
			break;
#ifdef HAVE_HGE
		case TYPE_hge:
			r = a->data.val.hval;
			break;
#endif
		}
	}
	return r;
}


atom *
atom_dec(sql_allocator *sa, sql_subtype *tpe,
#ifdef HAVE_HGE
	hge val,
#else
	lng val,
#endif
	double dval)
{
	atom *a = atom_int(sa, tpe, val);
	if (a) 
		a -> d = dval;
	return a;
}

atom *
atom_string(sql_allocator *sa, sql_subtype *tpe, const char *val)
{
	atom *a = atom_create(sa);

	a->isnull = 1;
	a->tpe = *tpe;
	a->data.val.sval = NULL;
	a->data.vtype = TYPE_str;
	a->data.len = 0;
	if (val) {
		a->isnull = 0;
		a->data.val.sval = (char*)val;
		a->data.len = (int)strlen(a->data.val.sval);
	}

	if (atom_debug)
		fprintf(stderr, "atom_string(%s,%s)\n", tpe->type->sqlname, val);
	return a;
}

atom *
atom_float(sql_allocator *sa, sql_subtype *tpe, double val)
{
	atom *a = atom_create(sa);

	a->isnull = 0;
	a->tpe = *tpe;
	if (tpe->type->localtype == TYPE_dbl)
		a->data.val.dval = val;
	else {
		assert((dbl) GDK_flt_min <= val && val <= (dbl) GDK_flt_max);
		a->data.val.fval = (flt) val;
	}
	a->data.vtype = tpe->type->localtype;
	a->data.len = 0;
	if (atom_debug)
		fprintf(stderr, "atom_float(%s,%f)\n", tpe->type->sqlname, val);
	return a;
}

atom *
atom_general(sql_allocator *sa, sql_subtype *tpe, const char *val)
{
	atom *a;
	ptr p = NULL;

	if (atom_debug)
		fprintf(stderr, "atom_general(%s,%s)\n", tpe->type->sqlname, val);

	if (tpe->type->localtype == TYPE_str)
		return atom_string(sa, tpe, val);
	a = atom_create(sa);
	a->tpe = *tpe;
	a->data.val.pval = NULL;
	a->data.vtype = tpe->type->localtype;
	a->data.len = 0;

	assert(a->data.vtype >= 0);

	if (val) {
		int type = a->data.vtype;

		a->isnull = 0;
		if (ATOMstorage(type) == TYPE_str) {
			a->isnull = 0;
			a->data.val.sval = (char*)sql2str(sa_strdup(sa, val));
			a->data.len = (int)strlen(a->data.val.sval);
		} else { 
			int res = ATOMfromstr(type, &p, &a->data.len, val);

			/* no result or nil means error (SQL has NULL not nil) */
			if (res < 0 || !p || ATOMcmp(type, p, ATOMnilptr(type)) == 0) {
				/*_DELETE(val);*/
				if (p)
					GDKfree(p);
				return NULL;
			}
			VALset(&a->data, a->data.vtype, p);
			SA_VALcopy(sa, &a->data, &a->data);

			if (p && ATOMextern(a->data.vtype) == 0)
				GDKfree(p);
			/*_DELETE(val);*/
		}
	} else { 
		p = ATOMnilptr(a->data.vtype);
		VALset(&a->data, a->data.vtype, p);
		a->isnull = 1;
	}
	return a;
}

atom *
atom_ptr( sql_allocator *sa, sql_subtype *tpe, void *v)
{
	atom *a = atom_create(sa);
	a->tpe = *tpe;
	a->isnull = 0;
	a->data.vtype = TYPE_ptr;
	VALset(&a->data, a->data.vtype, &v);
	a->data.len = 0;
	return a;
}

char *
atom2string(sql_allocator *sa, atom *a)
{
	char buf[BUFSIZ], *p = NULL;
	void *v;

	if (a->isnull)
		return sa_strdup(sa, "NULL");
	switch (a->data.vtype) { 
#ifdef HAVE_HGE
	case TYPE_hge:
	{	char *_buf = buf;
		int _bufsiz = BUFSIZ;
		hgeToStr(&_buf, &_bufsiz, &a->data.val.hval);
		break;
	}
#endif
	case TYPE_lng:
		sprintf(buf, LLFMT, a->data.val.lval);
		break;
	case TYPE_wrd:
		sprintf(buf, SSZFMT, a->data.val.wval);
		break;
	case TYPE_oid:
		sprintf(buf, OIDFMT "@0", a->data.val.oval);
		break;
	case TYPE_int:
		sprintf(buf, "%d", a->data.val.ival);
		break;
	case TYPE_sht:
		sprintf(buf, "%d", a->data.val.shval);
		break;
	case TYPE_bte:
		sprintf(buf, "%d", a->data.val.btval);
		break;
	case TYPE_bit:
		if (a->data.val.btval)
			return sa_strdup(sa, "true");
		return sa_strdup(sa, "false");
	case TYPE_flt:
		sprintf(buf, "%f", a->data.val.fval);
		break;
	case TYPE_dbl:
		sprintf(buf, "%f", a->data.val.dval);
		break;
	case TYPE_str:
		if (a->data.val.sval)
			return sa_strdup(sa, a->data.val.sval);
		else
			sprintf(buf, "NULL");
		break;
        default:  
		v = &a->data.val.ival;
		if (ATOMvarsized(a->data.vtype))
			v = a->data.val.pval;
		if (ATOMformat(a->data.vtype, v, &p) < 0) {
                	snprintf(buf, BUFSIZ, "atom2string(TYPE_%d) not implemented", a->data.vtype);
		} else {
			 char *r = sa_strdup(sa, p);
			 _DELETE(p);
			 return r;
		}
	}
	return sa_strdup(sa, buf);
}

char *
atom2sql(atom *a)
{
	int ec = a->tpe.type->eclass;
	char buf[BUFSIZ];

	if (a->data.vtype == TYPE_str && EC_INTERVAL(ec))
		ec = EC_STRING; 
	/* todo handle NULL's early */
	switch (ec) {
	case EC_BIT:
		assert( a->data.vtype == TYPE_bit);
		if (a->data.val.btval)
			return _STRDUP("true");
		return _STRDUP("false");
	case EC_CHAR:
	case EC_STRING:
		assert (a->data.vtype == TYPE_str);
		if (a->data.val.sval)
			sprintf(buf, "'%s'", a->data.val.sval);
		else
			sprintf(buf, "NULL");
		break;
	case EC_BLOB:
		/* TODO atom to string */
		break;
	case EC_MONTH: 
	case EC_SEC: {
		lng v;
		switch (a->data.vtype) {
		case TYPE_lng:
			v = a->data.val.lval;
			break;
		case TYPE_int:
			v = a->data.val.ival;
			break;
		case TYPE_sht:
			v = a->data.val.shval;
			break;
		case TYPE_bte:
			v = a->data.val.btval;
			break;
		default:
			v = 0;
			break;
		}
		switch (a->tpe.digits) {
		case 1:		/* year */
			v /= 12;
			break;
		case 2:		/* year to month */
		case 3:		/* month */
			break;
		case 4:		/* day */
			v /= 60 * 60 * 24;
			break;
		case 5:		/* day to hour */
		case 8:		/* hour */
			v /= 60 * 60;
			break;
		case 6:		/* day to minute */
		case 9:		/* hour to minute */
		case 11:	/* minute */
			v /= 60;
			break;
		case 7:		/* day to second */
		case 10:	/* hour to second */
		case 12:	/* minute to second */
		case 13:	/* second */
			break;
		}
		if (a->tpe.digits < 4) {
			sprintf(buf, LLFMT, v);
		} else {
			lng sec = v/1000;
			lng msec = v%1000;
			sprintf(buf, LLFMT "." LLFMT, sec, msec);
		}
		break;
	}
	case EC_NUM:
		switch (a->data.vtype) {
#ifdef HAVE_HGE
		case TYPE_hge:
		{	char *_buf = buf;
			int _bufsiz = BUFSIZ;
			hgeToStr(&_buf, &_bufsiz, &a->data.val.hval);
			break;
		}
#endif
		case TYPE_lng:
			sprintf(buf, LLFMT, a->data.val.lval);
			break;
		case TYPE_int:
			sprintf(buf, "%d", a->data.val.ival);
			break;
		case TYPE_sht:
			sprintf(buf, "%d", a->data.val.shval);
			break;
		case TYPE_bte:
			sprintf(buf, "%d", a->data.val.btval);
			break;
		default:
			break;
		}
		break;
	case EC_DEC: {
#ifdef HAVE_HGE
		hge v = 0;
#else
		lng v = 0;
#endif
		switch (a->data.vtype) {
#ifdef HAVE_HGE
		case TYPE_hge: v = a->data.val.hval; break;
#endif
		case TYPE_lng: v = a->data.val.lval; break;
		case TYPE_int: v = a->data.val.ival; break;
		case TYPE_sht: v = a->data.val.shval; break;
		case TYPE_bte: v = a->data.val.btval; break;
		default: break;
		}
		return decimal_to_str(v, &a->tpe);
	}
	case EC_FLT:
		if (a->data.vtype == TYPE_dbl)
			sprintf(buf, "%f", a->data.val.dval);
		else
			sprintf(buf, "%f", a->data.val.fval);
		break;
	case EC_TIME:
	case EC_DATE:
	case EC_TIMESTAMP:
		if (a->data.vtype == TYPE_str) {
			if (a->data.val.sval)
				sprintf(buf, "%s '%s'", a->tpe.type->sqlname, 
					a->data.val.sval);
			else
				sprintf(buf, "NULL");
		}
		break;
        default:
                snprintf(buf, BUFSIZ, "atom2sql(TYPE_%d) not implemented", a->data.vtype);
	}
	return _STRDUP(buf);
}


sql_subtype *
atom_type(atom *a)
{
	return &a->tpe;
}

atom *
atom_dup(sql_allocator *sa, atom *a)
{
	atom *r = atom_create(sa);

	*r = *a;
	r->tpe = a->tpe;
	if (!a->isnull) 
		SA_VALcopy(sa, &r->data, &a->data);
	return r;
}

unsigned int
atom_num_digits( atom *a ) 
{
#ifdef HAVE_HGE
	hge v = 0;
#else
	lng v = 0;
#endif
	int inlen = 1;

	switch(a->tpe.type->localtype) {
	case TYPE_bte:
		v = a->data.val.btval;
		break;
	case TYPE_sht:
		v = a->data.val.shval;
		break;
	case TYPE_int:
		v = a->data.val.ival;
		break;
	case TYPE_lng:
		v = a->data.val.lval;
		break;
#ifdef HAVE_HGE
	case TYPE_hge:
		v = a->data.val.hval;
		break;
#endif
	default:
		return 64;
	}
	/* count the number of digits in the input */
	while (v /= 10)
		inlen++;
	return inlen;
}

#ifdef HAVE_HGE
hge scales[39] = {
	(hge) LL_CONSTANT(1),
	(hge) LL_CONSTANT(10),
	(hge) LL_CONSTANT(100),
	(hge) LL_CONSTANT(1000),
	(hge) LL_CONSTANT(10000),
	(hge) LL_CONSTANT(100000),
	(hge) LL_CONSTANT(1000000),
	(hge) LL_CONSTANT(10000000),
	(hge) LL_CONSTANT(100000000),
	(hge) LL_CONSTANT(1000000000),
	(hge) LL_CONSTANT(10000000000),
	(hge) LL_CONSTANT(100000000000),
	(hge) LL_CONSTANT(1000000000000),
	(hge) LL_CONSTANT(10000000000000),
	(hge) LL_CONSTANT(100000000000000),
	(hge) LL_CONSTANT(1000000000000000),
	(hge) LL_CONSTANT(10000000000000000),
	(hge) LL_CONSTANT(100000000000000000),
	(hge) LL_CONSTANT(1000000000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(100000000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(1000000000000000000),
	(hge) LL_CONSTANT(10000000000000000000U) * LL_CONSTANT(10000000000000000000U)
};
#else
lng scales[19] = {
	LL_CONSTANT(1),
	LL_CONSTANT(10),
	LL_CONSTANT(100),
	LL_CONSTANT(1000),
	LL_CONSTANT(10000),
	LL_CONSTANT(100000),
	LL_CONSTANT(1000000),
	LL_CONSTANT(10000000),
	LL_CONSTANT(100000000),
	LL_CONSTANT(1000000000),
	LL_CONSTANT(10000000000),
	LL_CONSTANT(100000000000),
	LL_CONSTANT(1000000000000),
	LL_CONSTANT(10000000000000),
	LL_CONSTANT(100000000000000),
	LL_CONSTANT(1000000000000000),
	LL_CONSTANT(10000000000000000),
	LL_CONSTANT(100000000000000000),
	LL_CONSTANT(1000000000000000000)
};
#endif
/* cast atom a to type tp (success == 1, fail == 0) */
int 
atom_cast(atom *a, sql_subtype *tp) 
{
	sql_subtype *at = &a->tpe;

	if (!a->isnull) {
		if (subtype_cmp(at, tp) == 0) 
			return 1;
		/* need to do a cast, start simple is atom type a subtype of tp */
		if ((at->type->eclass == tp->type->eclass || 
		    (EC_VARCHAR(at->type->eclass) && EC_VARCHAR(tp->type->eclass))) &&
		    at->type->localtype == tp->type->localtype &&
		   (EC_TEMP(tp->type->eclass) || !tp->digits|| at->digits <= tp->digits) &&
		   (!tp->type->scale || at->scale == tp->scale)) {
			*at = *tp;
			return 1;
		}
		if (at->type->eclass == EC_NUM && tp->type->eclass == EC_NUM &&
	    	    at->type->localtype <= tp->type->localtype) {
			/* cast numerics */
			switch( tp->type->localtype) {
			case TYPE_bte:
				if (at->type->localtype != TYPE_bte) 
					return 0;
				break;
			case TYPE_sht:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.shval = a->data.val.btval;
				else if (at->type->localtype != TYPE_sht)
					return 0;
				break;
			case TYPE_int:
#if SIZEOF_OID == SIZEOF_INT
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_INT
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.ival = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.ival = a->data.val.shval;
				else if (at->type->localtype != TYPE_int) 
					return 0;
				break;
			case TYPE_lng:
#if SIZEOF_OID == SIZEOF_LNG
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_LNG
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.lval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.lval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.lval = a->data.val.ival;
				else if (at->type->localtype != TYPE_lng) 
					return 0;
				break;
#ifdef HAVE_HGE
			case TYPE_hge:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.hval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.hval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.hval = a->data.val.ival;
				else if (at->type->localtype == TYPE_lng) 
					a->data.val.hval = a->data.val.lval;
				else if (at->type->localtype != TYPE_hge) 
					return 0;
				break;
#endif
			default:
				return 0;
			}
			a->tpe = *tp;
			a->data.vtype = tp->type->localtype;
			return 1;
		}
		if (at->type->eclass == EC_DEC && tp->type->eclass == EC_DEC &&
		    at->type->localtype <= tp->type->localtype &&
		    at->digits <= tp->digits /* &&
		    at->scale <= tp->scale*/) {
#ifdef HAVE_HGE
			hge mul = 1, div = 0, rnd = 0;
#else
			lng mul = 1, div = 0, rnd = 0;
#endif
			/* cast numerics */
			switch( tp->type->localtype) {
			case TYPE_bte:
				if (at->type->localtype != TYPE_bte) 
					return 0;
				break;
			case TYPE_sht:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.shval = a->data.val.btval;
				else if (at->type->localtype != TYPE_sht) 
					return 0;
				break;
			case TYPE_int:
#if SIZEOF_OID == SIZEOF_INT
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_INT
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.ival = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.ival = a->data.val.shval;
				else if (at->type->localtype != TYPE_int) 
					return 0;
				break;
			case TYPE_lng:
#if SIZEOF_OID == SIZEOF_LNG
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_LNG
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.lval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.lval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.lval = a->data.val.ival;
				else if (at->type->localtype != TYPE_lng) 
					return 0;
				break;
#ifdef HAVE_HGE
			case TYPE_hge:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.hval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.hval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.hval = a->data.val.ival;
				else if (at->type->localtype == TYPE_lng) 
					a->data.val.hval = a->data.val.lval;
				else if (at->type->localtype != TYPE_hge) 
					return 0;
				break;
#endif
			default:
				return 0;
			}
			/* fix scale */
			if (tp->scale >= at->scale) {
				mul = scales[tp->scale-at->scale];
			} else {
				/* only round when going to a lower scale */
				mul = scales[at->scale-tp->scale];
				rnd = mul>>1;
				div = 1;
			}
			a->tpe = *tp;
			a->data.vtype = tp->type->localtype;
#ifdef HAVE_HGE
			if (a->data.vtype == TYPE_hge) {
				a->data.val.hval += rnd;
				if (div)
					a->data.val.hval /= mul;
				else
					a->data.val.hval *= mul;
			} else if (a->data.vtype == TYPE_lng) {
				if (!div && ((hge) GDK_lng_min > (hge) a->data.val.lval * mul || (hge) a->data.val.lval * mul > (hge) GDK_lng_max))
					return 0;
				a->data.val.lval += (lng)rnd;
				if (div)
					a->data.val.lval /= (lng) mul;
				else
					a->data.val.lval *= (lng) mul;
			} else if (a->data.vtype == TYPE_int) {
				if (!div && ((hge) GDK_int_min > (hge) a->data.val.ival * mul || (hge) a->data.val.ival * mul > (hge) GDK_int_max))
					return 0;
				a->data.val.ival += (int)rnd;
				if (div)
					a->data.val.ival /= (int) mul;
				else
					a->data.val.ival *= (int) mul;
			} else if (a->data.vtype == TYPE_sht) {
				if (!div && ((hge) GDK_sht_min > (hge) a->data.val.shval * mul || (hge) a->data.val.shval * mul > (hge) GDK_sht_max))
					return 0;
				a->data.val.shval += (sht)rnd;
				if (div)
					a->data.val.shval /= (sht) mul;
				else
					a->data.val.shval *= (sht) mul;
			} else if (a->data.vtype == TYPE_bte) {
				if (!div && ((hge) GDK_bte_min > (hge) a->data.val.btval * mul || (hge) a->data.val.btval * mul > (hge) GDK_bte_max))
					return 0;
				a->data.val.btval += (bte)rnd;
				if (div)
					a->data.val.btval /= (bte) mul;
				else
					a->data.val.btval *= (bte) mul;
			}
#else
			if (a->data.vtype == TYPE_lng) {
				a->data.val.lval += rnd;
				if (div)
					a->data.val.lval /= mul;
				else
					a->data.val.lval *= mul;
			} else if (a->data.vtype == TYPE_int) {
				if (!div && ((lng) GDK_int_min > (lng) a->data.val.ival * mul || (lng) a->data.val.ival * mul > (lng) GDK_int_max))
					return 0;
				a->data.val.ival += (int)rnd;
				if (div)
					a->data.val.ival /= (int) mul;
				else
					a->data.val.ival *= (int) mul;
			} else if (a->data.vtype == TYPE_sht) {
				if (!div && ((lng) GDK_sht_min > (lng) a->data.val.shval * mul || (lng) a->data.val.shval * mul > (lng) GDK_sht_max))
					return 0;
				a->data.val.shval += (sht)rnd;
				if (div)
					a->data.val.shval /= (sht) mul;
				else
					a->data.val.shval *= (sht) mul;
			} else if (a->data.vtype == TYPE_bte) {
				if (!div && ((lng) GDK_bte_min > (lng) a->data.val.btval * mul || (lng) a->data.val.btval * mul > (lng) GDK_bte_max))
					return 0;
				a->data.val.btval += (bte)rnd;
				if (div)
					a->data.val.btval /= (bte) mul;
				else
					a->data.val.btval *= (bte) mul;
			}
#endif
			return 1;
		}
		/* truncating decimals */
		if (at->type->eclass == EC_DEC && tp->type->eclass == EC_DEC &&
		    at->type->localtype >= tp->type->localtype &&
		    at->digits >= tp->digits && 
			(at->digits - tp->digits) == (at->scale - tp->scale)) {
#ifdef HAVE_HGE
			hge mul = 1, rnd = 0, val = 0;
#else
			lng mul = 1, rnd = 0, val = 0;
#endif

			/* fix scale */

			/* only round when going to a lower scale */
			mul = scales[at->scale-tp->scale];
			rnd = mul>>1;

#ifdef HAVE_HGE
			if (a->data.vtype == TYPE_hge) {
				val = a->data.val.hval;
			} else
#endif
			if (a->data.vtype == TYPE_lng) {
				val = a->data.val.lval;
			} else if (a->data.vtype == TYPE_int) {
				val = a->data.val.ival;
			} else if (a->data.vtype == TYPE_sht) {
				val = a->data.val.shval;
			} else if (a->data.vtype == TYPE_bte) {
				val = a->data.val.btval;
			}

			val += rnd;
			val /= mul;

			a->tpe = *tp;
			a->data.vtype = tp->type->localtype;
#ifdef HAVE_HGE
			if (a->data.vtype == TYPE_hge) {
				a->data.val.hval = val;
			} else if (a->data.vtype == TYPE_lng) {
				if ( ((hge) GDK_lng_min > val || val > (hge) GDK_lng_max))
					return 0;
				a->data.val.lval = (lng) val;
			} else if (a->data.vtype == TYPE_int) {
				if ( ((hge) GDK_int_min > val || val > (hge) GDK_int_max))
					return 0;
				a->data.val.ival = (int) val;
			} else if (a->data.vtype == TYPE_sht) {
				if ( ((hge) GDK_sht_min > val || val > (hge) GDK_sht_max))
					return 0;
				a->data.val.shval = (sht) val;
			} else if (a->data.vtype == TYPE_bte) {
				if ( ((hge) GDK_bte_min > val || val > (hge) GDK_bte_max))
					return 0;
				a->data.val.btval = (bte) val;
			}
#else
			if (a->data.vtype == TYPE_lng) {
				a->data.val.lval = (lng) val;
			} else if (a->data.vtype == TYPE_int) {
				if ( ((lng) GDK_int_min > val || val > (lng) GDK_int_max))
					return 0;
				a->data.val.ival = (int) val;
			} else if (a->data.vtype == TYPE_sht) {
				if ( ((lng) GDK_sht_min > val || val > (lng) GDK_sht_max))
					return 0;
				a->data.val.shval = (sht) val;
			} else if (a->data.vtype == TYPE_bte) {
				if ( ((lng) GDK_bte_min > val || val > (lng) GDK_bte_max))
					return 0;
				a->data.val.btval = (bte) val;
			}
#endif
			return 1;
		}
		if (at->type->eclass == EC_NUM && tp->type->eclass == EC_DEC &&
		    at->type->localtype <= tp->type->localtype &&
		    (at->digits <= tp->digits || atom_num_digits(a) <= tp->digits) &&
		    at->scale <= tp->scale) {
#ifdef HAVE_HGE
			hge mul = 1;
#else
			lng mul = 1;
#endif
			/* cast numerics */
			switch( tp->type->localtype) {
			case TYPE_bte:
				if (at->type->localtype != TYPE_bte) 
					return 0;
				break;
			case TYPE_sht:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.shval = a->data.val.btval;
				else if (at->type->localtype != TYPE_sht) 
					return 0;
				break;
			case TYPE_int:
#if SIZEOF_OID == SIZEOF_INT
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_INT
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.ival = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.ival = a->data.val.shval;
				else if (at->type->localtype != TYPE_int) 
					return 0;
				break;
			case TYPE_lng:
#if SIZEOF_OID == SIZEOF_LNG
			case TYPE_oid:
#endif
#if SIZEOF_WRD == SIZEOF_LNG
			case TYPE_wrd:
#endif
				if (at->type->localtype == TYPE_bte) 
					a->data.val.lval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.lval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.lval = a->data.val.ival;
				else if (at->type->localtype != TYPE_lng) 
					return 0;
				break;
#ifdef HAVE_HGE
			case TYPE_hge:
				if (at->type->localtype == TYPE_bte) 
					a->data.val.hval = a->data.val.btval;
				else if (at->type->localtype == TYPE_sht) 
					a->data.val.hval = a->data.val.shval;
				else if (at->type->localtype == TYPE_int) 
					a->data.val.hval = a->data.val.ival;
				else if (at->type->localtype == TYPE_lng) 
					a->data.val.hval = a->data.val.lval;
				else if (at->type->localtype != TYPE_hge) 
					return 0;
				break;
#endif
			default:
				return 0;
			}
			/* fix scale */
			mul = scales[tp->scale-at->scale];
			a->tpe = *tp;
			a->data.vtype = tp->type->localtype;
#ifdef HAVE_HGE
			if (a->data.vtype == TYPE_hge) {
				a->data.val.hval *= mul;
			}
			else if (a->data.vtype == TYPE_lng) {
				if ((hge) GDK_lng_min > (hge) a->data.val.lval * mul || (hge) a->data.val.lval * mul > (hge) GDK_lng_max)
					return 0;
				a->data.val.ival *= (int) mul;
			}
			else if (a->data.vtype == TYPE_int) {
				if ((hge) GDK_int_min > (hge) a->data.val.ival * mul || (hge) a->data.val.ival * mul > (hge) GDK_int_max)
					return 0;
				a->data.val.ival *= (int) mul;
			}
			else if (a->data.vtype == TYPE_sht) {
				if ((hge) GDK_sht_min > (hge) a->data.val.shval * mul || (hge) a->data.val.shval * mul > (hge) GDK_sht_max)
					return 0;
				a->data.val.shval *= (sht) mul;
			}
			else if (a->data.vtype == TYPE_bte) {
				if ((hge) GDK_bte_min > (hge) a->data.val.btval * mul || (hge) a->data.val.btval * mul > (hge) GDK_bte_max)
					return 0;
				a->data.val.btval *= (bte) mul;
			}
#else
			if (a->data.vtype == TYPE_lng) {
				a->data.val.lval *= mul;
			}
			else if (a->data.vtype == TYPE_int) {
				if ((lng) GDK_int_min > (lng) a->data.val.ival * mul || (lng) a->data.val.ival * mul > (lng) GDK_int_max)
					return 0;
				a->data.val.ival *= (int) mul;
			}
			else if (a->data.vtype == TYPE_sht) {
				if ((lng) GDK_sht_min > (lng) a->data.val.shval * mul || (lng) a->data.val.shval * mul > (lng) GDK_sht_max)
					return 0;
				a->data.val.shval *= (sht) mul;
			}
			else if (a->data.vtype == TYPE_bte) {
				if ((lng) GDK_bte_min > (lng) a->data.val.btval * mul || (lng) a->data.val.btval * mul > (lng) GDK_bte_max)
					return 0;
				a->data.val.btval *= (bte) mul;
			}
#endif
			return 1;
		}
		if ((at->type->eclass == EC_DEC || 
		     at->type->eclass == EC_NUM) && 
		    tp->type->eclass == EC_FLT) {
			if (a->d == dbl_nil) {
				ptr p = &a->d;
				char *s;
#ifdef HAVE_HGE
				hge dec = 0;
#else
				lng dec = 0;
#endif
				int len = 0, res = 0;
				/* cast decimals to doubles */
				switch( at->type->localtype) {
				case TYPE_bte:
					dec = a->data.val.btval;
					break;
				case TYPE_sht:
					dec = a->data.val.shval;
					break;
				case TYPE_int:
					dec = a->data.val.ival;
					break;
				case TYPE_lng:
					dec = a->data.val.lval;
					break;
#ifdef HAVE_HGE
				case TYPE_hge:
					dec = a->data.val.hval;
					break;
#endif
				default:
					return 0;
				}
				s = decimal_to_str(dec, at);
				len = sizeof(double);
				res = ATOMfromstr(TYPE_dbl, &p, &len, s);
				GDKfree(s);
				if (res <= 0)
					return 0;
			}
			if (tp->type->localtype == TYPE_dbl)
				a->data.val.dval = a->d;
			else {
				if ((dbl) GDK_flt_min > a->d || a->d > (dbl) GDK_flt_max)
					return 0;
				a->data.val.fval = (flt) a->d;
			}
			a->tpe = *tp;
			a->data.vtype = tp->type->localtype;
			return 1;
		}
	} else {
		ptr p = NULL;

		a->tpe = *tp;
		a->data.vtype = tp->type->localtype;
		p = ATOMnilptr(a->data.vtype);
		VALset(&a->data, a->data.vtype, p);
		return 1;
	}
	return 0;
}

int 
atom_neg( atom *a )
{
	switch( a->tpe.type->localtype) {
	case TYPE_bte:
		a->data.val.btval = -a->data.val.btval;
		break;
	case TYPE_sht:
		a->data.val.shval = -a->data.val.shval;
		break;
	case TYPE_int:
		a->data.val.ival = -a->data.val.ival;
		break;
	case TYPE_lng:
		a->data.val.lval = -a->data.val.lval;
		break;
#ifdef HAVE_HGE
	case TYPE_hge:
		a->data.val.hval = -a->data.val.hval;
		break;
#endif
	case TYPE_flt:
		a->data.val.fval = -a->data.val.fval;
		break;
	case TYPE_dbl:
		a->data.val.dval = -a->data.val.dval;
		if (a->data.val.dval == dbl_nil)
			return -1;
		break;
	default:
		return -1;
	}
	if (a->d != dbl_nil && a->tpe.type->localtype != TYPE_dbl)
		a->d = -a->d;
	return 0;
}

int 
atom_cmp(atom *a1, atom *a2)
{
	if ( a1->tpe.type->localtype != a2->tpe.type->localtype) 
		return -1;
	if ( a1->isnull != a2->isnull)
		return -1;
	if ( a1->isnull)
		return 0;
	return VALcmp(&a1->data, &a2->data);
}

atom * 
atom_add(atom *a1, atom *a2)
{
	if (a1->tpe.type->localtype != a2->tpe.type->localtype) 
		return NULL;
	switch(a1->tpe.type->localtype) {
	case TYPE_bte:
			a1->data.val.btval += a2->data.val.btval;
			a1->d = (dbl) a1->data.val.btval;
			break;
	case TYPE_sht:
			a1->data.val.shval += a2->data.val.shval;
			a1->d = (dbl) a1->data.val.shval;
			break;
	case TYPE_int:
			a1->data.val.ival += a2->data.val.ival;
			a1->d = (dbl) a1->data.val.ival;
			break;
	case TYPE_lng:
			a1->data.val.lval += a2->data.val.lval;
			a1->d = (dbl) a1->data.val.lval;
			break;
#ifdef HAVE_HGE
	case TYPE_hge:
			a1->data.val.hval += a2->data.val.hval;
			a1->d = (dbl) a1->data.val.hval;
			break;
#endif
	case TYPE_flt:
			a1->data.val.fval += a2->data.val.fval;
			a1->d = (dbl) a1->data.val.fval;
			break;
	case TYPE_dbl:
			a1->data.val.dval += a2->data.val.dval;
			a1->d = (dbl) a1->data.val.dval;
	default:
			break;
	}
	return a1;
}

atom * 
atom_sub(atom *a1, atom *a2)
{
	if (a1->tpe.type->localtype != a2->tpe.type->localtype) 
		return NULL;
	switch(a1->tpe.type->localtype) {
	case TYPE_bte:
			a1->data.val.btval -= a2->data.val.btval;
			a1->d = (dbl) a1->data.val.btval;
			break;
	case TYPE_sht:
			a1->data.val.shval -= a2->data.val.shval;
			a1->d = (dbl) a1->data.val.shval;
			break;
	case TYPE_int:
			a1->data.val.ival -= a2->data.val.ival;
			a1->d = (dbl) a1->data.val.ival;
			break;
	case TYPE_lng:
			a1->data.val.lval -= a2->data.val.lval;
			a1->d = (dbl) a1->data.val.lval;
			break;
#ifdef HAVE_HGE
	case TYPE_hge:
			a1->data.val.hval -= a2->data.val.hval;
			a1->d = (dbl) a1->data.val.hval;
			break;
#endif
	case TYPE_flt:
			a1->data.val.fval -= a2->data.val.fval;
			a1->d = (dbl) a1->data.val.fval;
			break;
	case TYPE_dbl:
			a1->data.val.dval -= a2->data.val.dval;
			a1->d = (dbl) a1->data.val.dval;
	default:
			break;
	}
	return a1;
}
