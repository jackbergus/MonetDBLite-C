/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
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
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

#include "monetdb_config.h"
#include "sql_datetime.h"
#include "sql_string.h"
#include <stdlib.h>

int
parse_interval_qualifier(mvc *sql, struct dlist *pers, int *sk, int *ek)
{
	*sk = iyear;
	*ek = isec;

	if (pers) {
		dlist *s = pers->h->data.lval;

		assert(s->h->type == type_int);
		*ek = *sk = s->h->data.i_val;

		if (dlist_length(pers) == 2) {
			dlist *e = pers->h->next->data.lval;

			assert(e->h->type == type_int);
			*ek = e->h->data.i_val;
		}
	}
	if (*sk > *ek) {
		snprintf(sql->errstr, ERRSIZE, _("End interval field is larger than the start field\n"));
		return -1;
	}
	if ((*sk == iyear || *sk == imonth) && *ek > imonth) {
		snprintf(sql->errstr, ERRSIZE, _("Correct interval ranges are year-month or day-seconds\n"));
		return -1;
	}
	if (*sk == iyear || *sk == imonth)
		return 0;
	return 1;
}

lng 
qualifier2multiplier( int sk )
{
	lng mul = 1;

	switch (sk) {
	case iyear:
		mul *= 12;
	case imonth:
		break;

	case iday:
		mul *= 24;
	case ihour:
		mul *= 60;
	case imin:
		mul *= 60;
	case isec:
		break;
	default:
		return -1;
	}
	return mul;
}

static int
parse_interval_(mvc *sql, lng sign, char *str, int sk, int ek, lng *i)
{
	char *n = NULL;
	lng val = 0;
	char sep = ':';
	int type;
	lng mul;

	if (*str == '-') {
		sign *= -1; 
		str++;
	}
	mul = sign;
		
	switch (sk) {
	case iyear:
		mul *= 12;
	case imonth:
		sep = '-';
		type = 0;
		break;

	case iday:
		mul *= 24;
		sep = ' ';
	case ihour:
		mul *= 60;
	case imin:
		mul *= 60;
	case isec:
		type = 1;
		break;

	default:
		if (sql)
			snprintf(sql->errstr, ERRSIZE, _("Internal error: parse_interval: bad value for sk (%d)\n"), sk);
		return -1;
	}

	val = strtol(str, &n, 10);
	switch (sk) {
	case imonth:
		if (val >= 12) {
			snprintf(sql->errstr, ERRSIZE, _("Overflow detected in months (" LLFMT ")\n"), val);
			return -1;
		}
		break;
	case ihour:
		if (val >= 24) {
			snprintf(sql->errstr, ERRSIZE, _("Overflow detected in hours (" LLFMT ")\n"), val);
			return -1;
		}
		break;
	case imin:
		if (val >= 60) {
			snprintf(sql->errstr, ERRSIZE, _("Overflow detected in minutes (" LLFMT ")\n"), val);
			return -1;
		}
		break;
	case isec:
		if (val >= 60) {
			snprintf(sql->errstr, ERRSIZE, _("Overflow detected in seconds (" LLFMT ")\n"), val);
			return -1;
		}
		break;
	}
	val *= mul;
	*i += val;
	if (ek != sk) {
		if (*n != sep) {
			if (sql)
				snprintf(sql->errstr, ERRSIZE, _("Interval field seperator \'%c\' missing\n"), sep);
			return -1;
		}
		return parse_interval_(sql, sign, n + 1, sk + 1, ek, i);
	} else {
		return type;
	}
}

int
parse_interval(mvc *sql, lng sign, char *str, int sk, int ek, lng *i)
{
	char *n = NULL;
	lng val = 0;
	char sep = ':';
	int type;
	lng mul;

	if (*str == '-') {
		sign *= -1; 
		str++;
	}
	mul = sign;
		
	switch (sk) {
	case iyear:
		mul *= 12;
	case imonth:
		sep = '-';
		type = 0;
		break;

	case iday:
		mul *= 24;
		sep = ' ';
	case ihour:
		mul *= 60;
	case imin:
		mul *= 60;
	case isec:
		type = 1;
		break;

	default:
		if (sql)
			snprintf(sql->errstr, ERRSIZE, _("Internal error: parse_interval: bad value for sk (%d)\n"), sk);
		return -1;
	}

	val = strtol(str, &n, 10);
	val *= mul;
	*i += val;
	if (ek != sk) {
		if (*n != sep) {
			if (sql)
				snprintf(sql->errstr, ERRSIZE, _("Interval field seperator \'%c\' missing\n"), sep);
			return -1;
		}
		return parse_interval_(sql, sign, n + 1, sk + 1, ek, i);
	} else {
		return type;
	}
}

int interval_from_str(char *str, int d, lng *val)
{
	int sk = digits2sk(d);
	int ek = digits2ek(d);
	*val = 0;
	return parse_interval(NULL, 1, str, sk, ek, val);
}



char *
datetime_field(itype f)
{
	switch (f) {
	case iyear:
		return "year";
	case imonth:
		return "month";
	case iday:
		return "day";
	case ihour:
		return "hour";
	case imin:
		return "minute";
	case isec:
		return "second";
	}
	return "year";
}

int inttype2digits( int sk, int ek )
{
	switch(sk) {
	case iyear:
		if(ek == iyear) 
			return 1;
		return 2;
	case imonth:
		return 3;
	case iday:
		switch(ek) {
		case iday: 
			return 4;
		case ihour:
			return 5;
		case imin:
			return 6;
		default:
			return 7;
		}
	case ihour:
		switch(ek) {
		case ihour:
			return 8;
		case imin:
			return 9;
		default:
			return 10;
		}
	case imin:
		if(ek == imin) 
			return 11;
		return 12;
	case isec:
		return 13;
	}
	return 1;
}

int digits2sk( int digits)
{
	int sk = iyear;
	
	if (digits > 2)
		sk = imonth;
	if (digits > 3)
		sk = iday;
	if (digits > 7)
		sk = ihour;
	if (digits > 10)
		sk = imin;
	if (digits > 12)
		sk = isec;
	return sk;
}

int digits2ek( int digits)
{
	int ek = iyear;
	
	if (digits == 2 || digits == 3)
		ek = imonth;
	if (digits == 4)
		ek = iday;
	if (digits == 5 || digits == 8)
		ek = ihour;
	if (digits == 6 || digits == 9 || digits == 11)
		ek = imin;
	if (digits == 7 || digits == 10 || digits == 12 || digits == 13)
		ek = isec;
	return ek;
}

