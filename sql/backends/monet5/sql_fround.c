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

#include "monetdb_config.h"
#include "sql.h"
#include "sql_result.h"
#include "sql_gencode.h"
#include <sql_storage.h>
#include <sql_scenario.h>
#include <store_sequence.h>
#include <sql_datetime.h>
#include <rel_optimizer.h>
#include <rel_distribute.h>
#include <rel_select.h>
#include <rel_exp.h>
#include <rel_dump.h>
#include <rel_bin.h>
#include "clients.h"
#include "mal_instruction.h"

/* Windows doesn't have round or trunc, but it does have floor and ceil */
#ifndef HAVE_ROUND
static inline double
round(double val)
{
	/* round to nearest integer, away from zero */
	if (val < 0)
		return -floor(-val + 0.5);
	else
		return floor(val + 0.5);
}
#endif

#ifndef HAVE_TRUNC
static inline double
trunc(double val)
{
	/* round to integer, towards zero */
	if (val < 0)
		return ceil(val);
	else
		return floor(val);
}
#endif

#define CONCAT_2(a, b)		a##b
#define CONCAT_3(a, b, c)	a##b##c

#define NIL(t)			CONCAT_2(t, _nil)
#define TPE(t)			CONCAT_2(TYPE_, t)
#define GDKmin(t)		CONCAT_3(GDK_, t, _min)
#define GDKmax(t)		CONCAT_3(GDK_, t, _max)
#define FUN(a, b)		CONCAT_3(a, _, b)

#define STRING(a)		#a

#define TYPE flt
#include "sql_fround_impl.h"
#undef TYPE

#define TYPE dbl
#include "sql_fround_impl.h"
#undef TYPE
