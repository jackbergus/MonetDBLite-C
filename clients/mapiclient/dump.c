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
 * Copyright August 2008-2013 MonetDB B.V.
 * All Rights Reserved.
 */

#include "monetdb_config.h"
#include <monet_options.h>
#include "mapi.h"
#include "stream.h"
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "msqldump.h"

static void
quoted_print(stream *f, const char *s, const char singleq)
{
	mnstr_write(f, singleq ? "'" : "\"", 1, 1);
	while (*s) {
		switch (*s) {
		case '\\':
			mnstr_write(f, "\\", 1, 1);
			mnstr_write(f, s, 1, 1);
			break;
		case '"':
			if (!singleq)
				mnstr_write(f, "\\", 1, 1);
			mnstr_write(f, s, 1, 1);
			break;
		case '\'':
			if (singleq)
				mnstr_write(f, "\\", 1, 1);
			mnstr_write(f, s, 1, 1);
			break;
		case '\n':
			mnstr_write(f, "\\n", 1, 2);
			break;
		case '\t':
			mnstr_write(f, "\\t", 1, 2);
			break;
		default:
			if ((0 < *s && *s < 32) || *s == '\377')
				mnstr_printf(f, "\\%03o", *s & 0377);
			else
				mnstr_write(f, s, 1, 1);
			break;
		}
		s++;
	}
	mnstr_write(f, singleq ? "'" : "\"", 1, 1);
}

static char *actions[] = {
	0,
	"CASCADE",
	"RESTRICT",
	"SET NULL",
	"SET DEFAULT",
};
#define NR_ACTIONS	((int) (sizeof(actions) / sizeof(actions[0])))

static char *
get_schema(Mapi mid)
{
	char *sname = NULL;
	MapiHdl hdl;

	if ((hdl = mapi_query(mid, "SELECT \"current_schema\"")) == NULL || mapi_error(mid))
		goto bailout;
	while ((mapi_fetch_row(hdl)) != 0) {
		sname = mapi_fetch_field(hdl, 0);

		if (mapi_error(mid))
			goto bailout;
	}
	if (mapi_error(mid))
		goto bailout;
	/* copy before closing the handle */
	if (sname)
		sname = strdup(sname);
	mapi_close_handle(hdl);
	return sname;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else
		mapi_explain(mid, stderr);
	return NULL;
}

int
has_systemfunctions(Mapi mid)
{
	MapiHdl hdl;
	int ret;

	if ((hdl = mapi_query(mid,
			      "SELECT \"t\".\"id\" "
			      "FROM \"sys\".\"_tables\" \"t\","
			           "\"sys\".\"schemas\" \"s\" "
			      "WHERE \"t\".\"name\" = 'systemfunctions' AND "
			            "\"t\".\"schema_id\" = \"s\".\"id\" AND "
			            "\"s\".\"name\" = 'sys'")) == NULL ||
	    mapi_error(mid))
		goto bailout;
	ret = mapi_get_row_count(hdl) == 1;
	while ((mapi_fetch_row(hdl)) != 0) {
		if (mapi_error(mid))
			goto bailout;
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	return ret;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else
		mapi_explain(mid, stderr);
	return 0;
}

static int
dump_foreign_keys(Mapi mid, const char *schema, const char *tname, const char *tid, stream *toConsole)
{
	MapiHdl hdl = NULL;
	int cnt, i;
	char *query;
	size_t maxquerylen = 0;

	if (tname != NULL) {
		maxquerylen = 1024 + strlen(tname) + strlen(schema);
		query = malloc(maxquerylen);
		snprintf(query, maxquerylen,
			 "SELECT \"ps\".\"name\","		/* 0 */
			        "\"pkt\".\"name\","		/* 1 */
				"\"pkkc\".\"name\","		/* 2 */
				"\"fkkc\".\"name\","		/* 3 */
				"\"fkkc\".\"nr\","		/* 4 */
				"\"fkk\".\"name\","		/* 5 */
				"\"fkk\".\"action\","		/* 6 */
				"\"fs\".\"name\","		/* 7 */
				"\"fkt\".\"name\" "		/* 8 */
			 "FROM \"sys\".\"_tables\" \"fkt\","
			      "\"sys\".\"objects\" \"fkkc\","
			      "\"sys\".\"keys\" \"fkk\","
			      "\"sys\".\"_tables\" \"pkt\","
			      "\"sys\".\"objects\" \"pkkc\","
			      "\"sys\".\"keys\" \"pkk\","
			      "\"sys\".\"schemas\" \"ps\","
			      "\"sys\".\"schemas\" \"fs\" "
			 "WHERE \"fkt\".\"id\" = \"fkk\".\"table_id\" AND "
			       "\"pkt\".\"id\" = \"pkk\".\"table_id\" AND "
			       "\"fkk\".\"id\" = \"fkkc\".\"id\" AND "
			       "\"pkk\".\"id\" = \"pkkc\".\"id\" AND "
			       "\"fkk\".\"rkey\" = \"pkk\".\"id\" AND "
			       "\"fkkc\".\"nr\" = \"pkkc\".\"nr\" AND "
			       "\"pkt\".\"schema_id\" = \"ps\".\"id\" AND "
			       "\"fkt\".\"schema_id\" = \"fs\".\"id\" AND "
			       "\"fs\".\"name\" = '%s' AND "
			       "\"fkt\".\"name\" = '%s'"
			 "ORDER BY \"fkk\".\"name\", \"nr\"", schema, tname);
	} else if (tid != NULL) {
		maxquerylen = 1024;
		query = malloc(maxquerylen);
		snprintf(query, maxquerylen,
			 "SELECT \"ps\".\"name\","		/* 0 */
			        "\"pkt\".\"name\","		/* 1 */
				"\"pkkc\".\"name\","		/* 2 */
				"\"fkkc\".\"name\","		/* 3 */
				"\"fkkc\".\"nr\","		/* 4 */
				"\"fkk\".\"name\","		/* 5 */
				"\"fkk\".\"action\","		/* 6 */
				"0,"				/* 7 */
				"\"fkt\".\"name\" "		/* 8 */
			 "FROM \"sys\".\"_tables\" \"fkt\","
			      "\"sys\".\"objects\" \"fkkc\","
			      "\"sys\".\"keys\" \"fkk\","
			      "\"sys\".\"_tables\" \"pkt\","
			      "\"sys\".\"objects\" \"pkkc\","
			      "\"sys\".\"keys\" \"pkk\","
			      "\"sys\".\"schemas\" \"ps\""
			 "WHERE \"fkt\".\"id\" = \"fkk\".\"table_id\" AND "
			       "\"pkt\".\"id\" = \"pkk\".\"table_id\" AND "
			       "\"fkk\".\"id\" = \"fkkc\".\"id\" AND "
			       "\"pkk\".\"id\" = \"pkkc\".\"id\" AND "
			       "\"fkk\".\"rkey\" = \"pkk\".\"id\" AND "
			       "\"fkkc\".\"nr\" = \"pkkc\".\"nr\" AND "
			       "\"pkt\".\"schema_id\" = \"ps\".\"id\" AND "
			       "\"fkt\".\"id\" = %s"
			 "ORDER BY \"fkk\".\"name\", \"nr\"", tid);
	} else {
		query = "SELECT \"ps\".\"name\","		/* 0 */
			       "\"pkt\".\"name\","		/* 1 */
			       "\"pkkc\".\"name\","		/* 2 */
			       "\"fkkc\".\"name\","		/* 3 */
			       "\"fkkc\".\"nr\","		/* 4 */
			       "\"fkk\".\"name\","		/* 5 */
			       "\"fkk\".\"action\","		/* 6 */
			       "\"fs\".\"name\","		/* 7 */
			       "\"fkt\".\"name\" "		/* 8 */
			"FROM \"sys\".\"_tables\" \"fkt\","
			     "\"sys\".\"objects\" \"fkkc\","
			     "\"sys\".\"keys\" \"fkk\","
			     "\"sys\".\"_tables\" \"pkt\","
			     "\"sys\".\"objects\" \"pkkc\","
			     "\"sys\".\"keys\" \"pkk\","
			     "\"sys\".\"schemas\" \"ps\","
			     "\"sys\".\"schemas\" \"fs\" "
			"WHERE \"fkt\".\"id\" = \"fkk\".\"table_id\" AND "
			      "\"pkt\".\"id\" = \"pkk\".\"table_id\" AND "
			      "\"fkk\".\"id\" = \"fkkc\".\"id\" AND "
			      "\"pkk\".\"id\" = \"pkkc\".\"id\" AND "
			      "\"fkk\".\"rkey\" = \"pkk\".\"id\" AND "
			      "\"fkkc\".\"nr\" = \"pkkc\".\"nr\" AND "
			      "\"pkt\".\"schema_id\" = \"ps\".\"id\" AND "
			      "\"fkt\".\"schema_id\" = \"fs\".\"id\" AND "
			      "\"fkt\".\"system\" = FALSE "
			"ORDER BY \"fs\".\"name\",\"fkt\".\"name\","
			      "\"fkk\".\"name\", \"nr\"";
	}
	hdl = mapi_query(mid, query);
	if (query != NULL && maxquerylen != 0)
		free(query);
	maxquerylen = 0;
	if (hdl == NULL || mapi_error(mid))
		goto bailout;

	cnt = mapi_fetch_row(hdl);
	while (cnt != 0) {
		char *c_psname = mapi_fetch_field(hdl, 0);
		char *c_ptname = mapi_fetch_field(hdl, 1);
		char *c_pcolumn = mapi_fetch_field(hdl, 2);
		char *c_fcolumn = mapi_fetch_field(hdl, 3);
		char *c_nr = mapi_fetch_field(hdl, 4);
		char *c_fkname = mapi_fetch_field(hdl, 5);
		char *c_faction = mapi_fetch_field(hdl, 6);
		char *c_fsname = mapi_fetch_field(hdl, 7);
		char *c_ftname = mapi_fetch_field(hdl, 8);
		char **fkeys, **pkeys;
		int nkeys = 0;

		if (mapi_error(mid))
			goto bailout;
		assert(strcmp(c_nr, "0") == 0);
		(void) c_nr;	/* pacify compilers in case assertions are disabled */
		nkeys = 1;
		fkeys = malloc(nkeys * sizeof(*fkeys));
		pkeys = malloc(nkeys * sizeof(*pkeys));
		pkeys[nkeys - 1] = c_pcolumn;
		fkeys[nkeys - 1] = c_fcolumn;
		while ((cnt = mapi_fetch_row(hdl)) != 0 && strcmp(mapi_fetch_field(hdl, 4), "0") != 0) {
			nkeys++;
			pkeys = realloc(pkeys, nkeys * sizeof(*pkeys));
			fkeys = realloc(fkeys, nkeys * sizeof(*fkeys));
			pkeys[nkeys - 1] = mapi_fetch_field(hdl, 2);
			fkeys[nkeys - 1] = mapi_fetch_field(hdl, 3);
		}
		if (tname == NULL && tid == NULL) {
			mnstr_printf(toConsole,
				     "ALTER TABLE \"%s\".\"%s\" ADD ",
				     c_fsname, c_ftname);
		} else {
			mnstr_printf(toConsole, ",\n\t");
		}
		if (c_fkname) {
			mnstr_printf(toConsole, "CONSTRAINT \"%s\" ",
				c_fkname);
		}
		mnstr_printf(toConsole, "FOREIGN KEY (");
		for (i = 0; i < nkeys; i++) {
			mnstr_printf(toConsole, "%s\"%s\"",
				     i > 0 ? ", " : "", fkeys[i]);
		}
		mnstr_printf(toConsole, ") REFERENCES \"%s\".\"%s\" (",
			     c_psname, c_ptname);
		for (i = 0; i < nkeys; i++) {
			mnstr_printf(toConsole, "%s\"%s\"",
				     i > 0 ? ", " : "", pkeys[i]);
		}
		mnstr_printf(toConsole, ")");
		free(fkeys);
		free(pkeys);
		if (c_faction) {
			int action = atoi(c_faction);
			int on_update = (action >> 8) & 255;
			int on_delete = action & 255;

			if (0 < on_delete &&
			    on_delete < NR_ACTIONS &&
			    on_delete != 2	   /* RESTRICT -- default */)
				mnstr_printf(toConsole, " ON DELETE %s",
					     actions[on_delete]);
			if (0 < on_update &&
			    on_update < NR_ACTIONS &&
			    on_update != 2	   /* RESTRICT -- default */)
				mnstr_printf(toConsole, " ON UPDATE %s",
					     actions[on_update]);
		}
		if (tname == NULL && tid == NULL)
			mnstr_printf(toConsole, ";\n");

		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (mapi_error(mid))
		goto bailout;
	if (hdl)
		mapi_close_handle(hdl);
	return 0;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else if (mapi_error(mid))
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else if (mapi_error(mid))
		mapi_explain(mid, stderr);

	return 1;
}

static const char *
toUpper(const char *s)
{
	static char toupperbuf[64];
	size_t i;
	size_t len = strlen(s);

	if (len >= sizeof(toupperbuf))
		return s;	/* too long: it's not *that* important */
	for (i = 0; i < len; i++)
		toupperbuf[i] = toupper((int)s[i]);
	toupperbuf[i] = '\0';
	return toupperbuf;
}

static int dump_column_definition(
	Mapi mid,
	stream *toConsole,
	const char *schema,
	const char *tname,
	const char *tid,
	int foreign);

static int
dump_type(Mapi mid, stream *toConsole, char *c_type, char *c_type_digits, char *c_type_scale)
{
	int space = 0;

	/* map wrd type to something legal */
	if (strcmp(c_type, "wrd") == 0) {
		if (strcmp(c_type_scale, "32") == 0)
			c_type = "int";
		else
			c_type = "bigint";
	}
	if (strcmp(c_type, "boolean") == 0) {
		space = mnstr_printf(toConsole, "BOOLEAN");
	} else if (strcmp(c_type, "int") == 0) {
		space = mnstr_printf(toConsole, "INTEGER");
	} else if (strcmp(c_type, "smallint") == 0) {
		space = mnstr_printf(toConsole, "SMALLINT");
	} else if (strcmp(c_type, "tinyint") == 0) {
		space = mnstr_printf(toConsole, "TINYINT");
	} else if (strcmp(c_type, "bigint") == 0) {
		space = mnstr_printf(toConsole, "BIGINT");
	} else if (strcmp(c_type, "date") == 0) {
		space = mnstr_printf(toConsole, "DATE");
	} else if (strcmp(c_type, "month_interval") == 0) {
		if (strcmp(c_type_digits, "1") == 0)
			space = mnstr_printf(toConsole, "INTERVAL YEAR");
		else if (strcmp(c_type_digits, "2") == 0)
			space = mnstr_printf(toConsole, "INTERVAL YEAR TO MONTH");
		else if (strcmp(c_type_digits, "3") == 0)
			space = mnstr_printf(toConsole, "INTERVAL MONTH");
		else
			fprintf(stderr, "Internal error: unrecognized month interval %s\n", c_type_digits);
	} else if (strcmp(c_type, "sec_interval") == 0) {
		if (strcmp(c_type_digits, "4") == 0)
			space = mnstr_printf(toConsole, "INTERVAL DAY");
		else if (strcmp(c_type_digits, "5") == 0)
			space = mnstr_printf(toConsole, "INTERVAL DAY TO HOUR");
		else if (strcmp(c_type_digits, "6") == 0)
			space = mnstr_printf(toConsole, "INTERVAL DAY TO MINUTE");
		else if (strcmp(c_type_digits, "7") == 0)
			space = mnstr_printf(toConsole, "INTERVAL DAY TO SECOND");
		else if (strcmp(c_type_digits, "8") == 0)
			space = mnstr_printf(toConsole, "INTERVAL HOUR");
		else if (strcmp(c_type_digits, "9") == 0)
			space = mnstr_printf(toConsole, "INTERVAL HOUR TO MINUTE");
		else if (strcmp(c_type_digits, "10") == 0)
			space = mnstr_printf(toConsole, "INTERVAL HOUR TO SECOND");
		else if (strcmp(c_type_digits, "11") == 0)
			space = mnstr_printf(toConsole, "INTERVAL MINUTE");
		else if (strcmp(c_type_digits, "12") == 0)
			space = mnstr_printf(toConsole, "INTERVAL MINUTE TO SECOND");
		else if (strcmp(c_type_digits, "13") == 0)
			space = mnstr_printf(toConsole, "INTERVAL SECOND");
		else
			fprintf(stderr, "Internal error: unrecognized second interval %s\n", c_type_digits);
	} else if (strcmp(c_type, "clob") == 0 ||
		   (strcmp(c_type, "varchar") == 0 &&
		    strcmp(c_type_digits, "0") == 0)) {
		space = mnstr_printf(toConsole, "CHARACTER LARGE OBJECT");
		if (strcmp(c_type_digits, "0") != 0)
			space += mnstr_printf(toConsole, "(%s)", c_type_digits);
	} else if (strcmp(c_type, "blob") == 0) {
		space = mnstr_printf(toConsole, "BINARY LARGE OBJECT");
		if (strcmp(c_type_digits, "0") != 0)
			space += mnstr_printf(toConsole, "(%s)", c_type_digits);
	} else if (strcmp(c_type, "timestamp") == 0 ||
		   strcmp(c_type, "timestamptz") == 0) {
		space = mnstr_printf(toConsole, "TIMESTAMP");
		if (strcmp(c_type_digits, "7") != 0)
			space += mnstr_printf(toConsole, "(%d)", atoi(c_type_digits) - 1);
		if (strcmp(c_type, "timestamptz") == 0)
			space += mnstr_printf(toConsole, " WITH TIME ZONE");
	} else if (strcmp(c_type, "time") == 0 ||
		   strcmp(c_type, "timetz") == 0) {
		space = mnstr_printf(toConsole, "TIME");
		if (strcmp(c_type_digits, "1") != 0)
			space += mnstr_printf(toConsole, "(%d)", atoi(c_type_digits) - 1);
		if (strcmp(c_type, "timetz") == 0)
			space += mnstr_printf(toConsole, " WITH TIME ZONE");
	} else if (strcmp(c_type, "real") == 0) {
		if (strcmp(c_type_digits, "24") == 0 &&
		    strcmp(c_type_scale, "0") == 0)
			space = mnstr_printf(toConsole, "REAL");
		else if (strcmp(c_type_scale, "0") == 0)
			space = mnstr_printf(toConsole, "FLOAT(%s)", c_type_digits);
		else
			space = mnstr_printf(toConsole, "FLOAT(%s,%s)",
					c_type_digits, c_type_scale);
	} else if (strcmp(c_type, "double") == 0) {
		if (strcmp(c_type_digits, "53") == 0 &&
		    strcmp(c_type_scale, "0") == 0)
			space = mnstr_printf(toConsole, "DOUBLE");
		else if (strcmp(c_type_scale, "0") == 0)
			space = mnstr_printf(toConsole, "FLOAT(%s)", c_type_digits);
		else
			space = mnstr_printf(toConsole, "FLOAT(%s,%s)",
					c_type_digits, c_type_scale);
	} else if (strcmp(c_type, "decimal") == 0 &&
		   strcmp(c_type_digits, "1") == 0 &&
		   strcmp(c_type_scale, "0") == 0) {
		space = mnstr_printf(toConsole, "DECIMAL");
	} else if (strcmp(c_type, "table") == 0) {
		mnstr_printf(toConsole, "TABLE ");
		dump_column_definition(mid, toConsole, NULL, NULL, c_type_digits, 1);
	} else if (strcmp(c_type_digits, "0") == 0) {
		space = mnstr_printf(toConsole, "%s", toUpper(c_type));
	} else if (strcmp(c_type_scale, "0") == 0) {
		space = mnstr_printf(toConsole, "%s(%s)",
				toUpper(c_type), c_type_digits);
	} else {
		space = mnstr_printf(toConsole, "%s(%s,%s)",
				toUpper(c_type), c_type_digits, c_type_scale);
	}
	return space;
}

static int
dump_column_definition(Mapi mid, stream *toConsole, const char *schema, const char *tname, const char *tid, int foreign)
{
	MapiHdl hdl = NULL;
	char *query;
	size_t maxquerylen;
	int cnt;
	int slen;
	int cap;
#define CAP(X) ((cap = (int) (X)) < 0 ? 0 : cap)

	maxquerylen = 1024;
	if (tid == NULL)
		maxquerylen += strlen(tname) + strlen(schema);
	if ((query = malloc(maxquerylen)) == NULL)
		goto bailout;

	mnstr_printf(toConsole, "(\n");

	if (tid)
		snprintf(query, maxquerylen,
			 "SELECT \"c\".\"name\","		/* 0 */
				"\"c\".\"type\","		/* 1 */
				"\"c\".\"type_digits\","	/* 2 */
				"\"c\".\"type_scale\","		/* 3 */
				"\"c\".\"null\","		/* 4 */
				"\"c\".\"default\","		/* 5 */
				"\"c\".\"number\" "		/* 6 */
			 "FROM \"sys\".\"_columns\" \"c\" "
			 "WHERE \"c\".\"table_id\" = %s "
			 "ORDER BY \"number\"", tid);
	else
		snprintf(query, maxquerylen,
			 "SELECT \"c\".\"name\","		/* 0 */
				"\"c\".\"type\","		/* 1 */
				"\"c\".\"type_digits\","	/* 2 */
				"\"c\".\"type_scale\","		/* 3 */
				"\"c\".\"null\","		/* 4 */
				"\"c\".\"default\","		/* 5 */
				"\"c\".\"number\" "		/* 6 */
			 "FROM \"sys\".\"_columns\" \"c\", "
			      "\"sys\".\"_tables\" \"t\", "
			      "\"sys\".\"schemas\" \"s\" "
			 "WHERE \"c\".\"table_id\" = \"t\".\"id\" "
			 "AND '%s' = \"t\".\"name\" "
			 "AND \"t\".\"schema_id\" = \"s\".\"id\" "
			 "AND \"s\".\"name\" = '%s' "
			 "ORDER BY \"number\"", tname, schema);
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;

	slen = mapi_get_len(hdl, 0);
	cnt = 0;
	while ((mapi_fetch_row(hdl)) != 0) {
		char *c_name = mapi_fetch_field(hdl, 0);
		char *c_type = mapi_fetch_field(hdl, 1);
		char *c_type_digits = mapi_fetch_field(hdl, 2);
		char *c_type_scale = mapi_fetch_field(hdl, 3);
		char *c_null = mapi_fetch_field(hdl, 4);
		char *c_default = mapi_fetch_field(hdl, 5);
		int space;

		if (mapi_error(mid))
			goto bailout;
		if (cnt)
			mnstr_printf(toConsole, ",\n");

		mnstr_printf(toConsole, "\t\"%s\"%*s ",
			     c_name, CAP(slen - strlen(c_name)), "");
		space = dump_type(mid, toConsole, c_type, c_type_digits, c_type_scale);
		if (strcmp(c_null, "false") == 0) {
			mnstr_printf(toConsole, "%*s NOT NULL",
					CAP(13 - space), "");
			space = 13;
		}
		if (c_default != NULL)
			mnstr_printf(toConsole, "%*s DEFAULT %s",
					CAP(13 - space), "", c_default);
		cnt++;
		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;
	/* presumably we don't need to order on id, since there should
	   only be a single primary key, but it doesn't hurt, and the
	   code is then close to the code for the uniqueness
	   constraint */
	if (tid)
		snprintf(query, maxquerylen,
			 "SELECT \"kc\".\"name\","		/* 0 */
				"\"kc\".\"nr\", "		/* 1 */
				"\"k\".\"name\", "		/* 2 */
				"\"k\".\"id\" "			/* 3 */
			 "FROM \"sys\".\"objects\" \"kc\", "
			      "\"sys\".\"keys\" \"k\" "
			 "WHERE \"kc\".\"id\" = \"k\".\"id\" AND "
			       "\"k\".\"table_id\" = %s AND "
			       "\"k\".\"type\" = 0 "
			 "ORDER BY \"id\", \"nr\"", tid);
	else
		snprintf(query, maxquerylen,
			 "SELECT \"kc\".\"name\","		/* 0 */
				"\"kc\".\"nr\", "		/* 1 */
				"\"k\".\"name\", "		/* 2 */
				"\"k\".\"id\" "			/* 3 */
			 "FROM \"sys\".\"objects\" \"kc\", "
			      "\"sys\".\"keys\" \"k\", "
			      "\"sys\".\"schemas\" \"s\", "
			      "\"sys\".\"_tables\" \"t\" "
			 "WHERE \"kc\".\"id\" = \"k\".\"id\" AND "
			       "\"k\".\"table_id\" = \"t\".\"id\" AND "
			       "\"k\".\"type\" = 0 AND "
			       "\"t\".\"schema_id\" = \"s\".\"id\" AND "
			       "\"s\".\"name\" = '%s' AND "
			       "\"t\".\"name\" = '%s' "
			 "ORDER BY \"id\", \"nr\"", schema, tname);
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	cnt = 0;
	while ((mapi_fetch_row(hdl)) != 0) {
		char *c_column = mapi_fetch_field(hdl, 0);
		char *k_name = mapi_fetch_field(hdl, 2);

		if (mapi_error(mid))
			goto bailout;
		if (cnt == 0) {
			mnstr_printf(toConsole, ",\n\t");
			if (k_name) {
				mnstr_printf(toConsole, "CONSTRAINT \"%s\" ",
					k_name);
			}
			mnstr_printf(toConsole, "PRIMARY KEY (");
		} else
			mnstr_printf(toConsole, ", ");
		mnstr_printf(toConsole, "\"%s\"", c_column);
		cnt++;
		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (cnt)
		mnstr_printf(toConsole, ")");
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;

	if (tid)
		snprintf(query, maxquerylen,
			 "SELECT \"kc\".\"name\","		/* 0 */
				"\"kc\".\"nr\", "		/* 1 */
				"\"k\".\"name\", "		/* 2 */
				"\"k\".\"id\" "			/* 3 */
			 "FROM \"sys\".\"objects\" \"kc\", "
			      "\"sys\".\"keys\" \"k\" "
			 "WHERE \"kc\".\"id\" = \"k\".\"id\" AND "
			       "\"k\".\"table_id\" = %s AND "
			       "\"k\".\"type\" = 1 "
			 "ORDER BY \"id\", \"nr\"", tid);
	else
		snprintf(query, maxquerylen,
			 "SELECT \"kc\".\"name\","		/* 0 */
				"\"kc\".\"nr\", "		/* 1 */
				"\"k\".\"name\", "		/* 2 */
				"\"k\".\"id\" "			/* 3 */
			 "FROM \"sys\".\"objects\" \"kc\", "
			      "\"sys\".\"keys\" \"k\", "
			      "\"sys\".\"schemas\" \"s\", "
			      "\"sys\".\"_tables\" \"t\" "
			 "WHERE \"kc\".\"id\" = \"k\".\"id\" AND "
			       "\"k\".\"table_id\" = \"t\".\"id\" AND "
			       "\"k\".\"type\" = 1 AND "
			       "\"t\".\"schema_id\" = \"s\".\"id\" AND "
			       "\"s\".\"name\" = '%s' AND "
			       "\"t\".\"name\" = '%s' "
			 "ORDER BY \"id\", \"nr\"", schema, tname);
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	cnt = 0;
	while ((mapi_fetch_row(hdl)) != 0) {
		char *c_column = mapi_fetch_field(hdl, 0);
		char *kc_nr = mapi_fetch_field(hdl, 1);
		char *k_name = mapi_fetch_field(hdl, 2);

		if (mapi_error(mid))
			goto bailout;
		if (strcmp(kc_nr, "0") == 0) {
			if (cnt)
				mnstr_write(toConsole, ")", 1, 1);
			mnstr_printf(toConsole, ",\n\t");
			if (k_name) {
				mnstr_printf(toConsole, "CONSTRAINT \"%s\" ",
					k_name);
			}
			mnstr_printf(toConsole, "UNIQUE (");
			cnt = 1;
		} else
			mnstr_printf(toConsole, ", ");
		mnstr_printf(toConsole, "\"%s\"", c_column);
		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (cnt)
		mnstr_write(toConsole, ")", 1, 1);
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;

	if (foreign &&
	    dump_foreign_keys(mid, schema, tname, tid, toConsole))
		goto bailout;

	mnstr_printf(toConsole, "\n");

	mnstr_printf(toConsole, ")");

	free(query);
	return 0;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else if (mapi_error(mid))
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else if (mapi_error(mid))
		mapi_explain(mid, stderr);
	if (query != NULL)
		free(query);
	return 1;
}

int
describe_table(Mapi mid, char *schema, char *tname, stream *toConsole, int foreign)
{
	int cnt;
	MapiHdl hdl = NULL;
	char *query;
	char *view = NULL;
	size_t maxquerylen;
	char *sname = NULL;

	if (schema == NULL) {
		if ((sname = strchr(tname, '.')) != NULL) {
			size_t len = sname - tname;

			sname = malloc(len + 1);
			strncpy(sname, tname, len);
			sname[len] = 0;
			tname += len + 1;
		} else if ((sname = get_schema(mid)) == NULL) {
			return 1;
		}
		schema = sname;
	}

	maxquerylen = 512 + strlen(tname) + strlen(schema);

	query = malloc(maxquerylen);
	snprintf(query, maxquerylen,
		 "SELECT \"t\".\"name\", \"t\".\"query\" "
		 "FROM \"sys\".\"_tables\" \"t\", \"sys\".\"schemas\" \"s\" "
		 "WHERE \"s\".\"name\" = '%s' "
		 "AND \"t\".\"schema_id\" = \"s\".\"id\" "
		 "AND \"t\".\"name\" = '%s'",
		 schema, tname);

	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	cnt = 0;
	while ((mapi_fetch_row(hdl)) != 0) {
		cnt++;
		view = mapi_fetch_field(hdl, 1);
	}
	if (mapi_error(mid)) {
		view = NULL;
		goto bailout;
	}
	if (view)
		view = strdup(view);
	mapi_close_handle(hdl);
	hdl = NULL;

	if (cnt != 1) {
		if (cnt == 0)
			fprintf(stderr, "table %s.%s does not exist\n", schema, tname);
		else
			fprintf(stderr, "table %s.%s is not unique, corrupt catalog?\n",
					schema, tname);
		goto bailout;
	}

	if (view) {
		/* the table is actually a view */
		mnstr_printf(toConsole, "%s\n", view);
		goto doreturn;
	}

	mnstr_printf(toConsole, "CREATE TABLE \"%s\".\"%s\" ", schema, tname);

	if (dump_column_definition(mid, toConsole, schema, tname, NULL, foreign))
		goto bailout;
	mnstr_printf(toConsole, ";\n");

	snprintf(query, maxquerylen,
		 "SELECT \"i\".\"name\", "		/* 0 */
			"\"k\".\"name\", "		/* 1 */
			"\"kc\".\"nr\", "		/* 2 */
			"\"c\".\"name\" "		/* 3 */
		 "FROM \"sys\".\"idxs\" AS \"i\" LEFT JOIN \"sys\".\"keys\" AS \"k\" "
				"ON \"i\".\"name\" = \"k\".\"name\", "
		      "\"sys\".\"objects\" AS \"kc\", "
		      "\"sys\".\"_columns\" AS \"c\", "
		      "\"sys\".\"schemas\" \"s\", "
		      "\"sys\".\"_tables\" AS \"t\" "
		 "WHERE \"i\".\"table_id\" = \"t\".\"id\" AND "
		       "\"i\".\"id\" = \"kc\".\"id\" AND "
		       "\"t\".\"id\" = \"c\".\"table_id\" AND "
		       "\"kc\".\"name\" = \"c\".\"name\" AND "
		       "(\"k\".\"type\" IS NULL OR \"k\".\"type\" = 1) AND "
		       "\"t\".\"schema_id\" = \"s\".\"id\" AND "
		       "\"s\".\"name\" = '%s' AND "
		       "\"t\".\"name\" = '%s' "
		 "ORDER BY \"i\".\"name\", \"kc\".\"nr\"", schema, tname);
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	cnt = 0;
	while (mapi_fetch_row(hdl) != 0) {
		char *i_name = mapi_fetch_field(hdl, 0);
		char *k_name = mapi_fetch_field(hdl, 1);
		char *kc_nr = mapi_fetch_field(hdl, 2);
		char *c_name = mapi_fetch_field(hdl, 3);

		if (mapi_error(mid))
			goto bailout;
		if (k_name != NULL) {
			/* unique key, already handled */
			continue;
		}

		if (strcmp(kc_nr, "0") == 0) {
			if (cnt)
				mnstr_printf(toConsole, ");\n");
			mnstr_printf(toConsole,
				     "CREATE INDEX \"%s\" ON \"%s\".\"%s\" (",
				     i_name, schema, tname);
			cnt = 1;
		} else
			mnstr_printf(toConsole, ", ");
		mnstr_printf(toConsole, "\"%s\"", c_name);
		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (cnt)
		mnstr_printf(toConsole, ");\n");
	if (mapi_error(mid))
		goto bailout;

  doreturn:
	if (hdl)
		mapi_close_handle(hdl);
	if (view)
		free(view);
	if (query != NULL)
		free(query);
	if (sname != NULL)
		free(sname);
	return 0;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else if (mapi_error(mid))
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else if (mapi_error(mid))
		mapi_explain(mid, stderr);
	if (view)
		free(view);
	if (sname != NULL)
		free(sname);
	if (query != NULL)
		free(query);
	return 1;
}

int
describe_sequence(Mapi mid, char *schema, char *tname, stream *toConsole)
{
	MapiHdl hdl = NULL;
	char *query;
	size_t maxquerylen;
	char *sname = NULL;

	if (schema == NULL) {
		if ((sname = strchr(tname, '.')) != NULL) {
			size_t len = sname - tname;

			sname = malloc(len + 1);
			strncpy(sname, tname, len);
			sname[len] = 0;
			tname += len + 1;
		} else if ((sname = get_schema(mid)) == NULL) {
			return 1;
		}
		schema = sname;
	}

	maxquerylen = 512 + strlen(tname) + strlen(schema);

	query = malloc(maxquerylen);
	snprintf(query, maxquerylen,
		"SELECT \"s\".\"name\","
		     "\"seq\".\"name\","
		     "get_value_for(\"s\".\"name\",\"seq\".\"name\"),"
		     "\"seq\".\"minvalue\","
		     "\"seq\".\"maxvalue\","
		     "\"seq\".\"increment\","
		     "\"seq\".\"cycle\" "
		"FROM \"sys\".\"sequences\" \"seq\", "
		     "\"sys\".\"schemas\" \"s\" "
		"WHERE \"s\".\"id\" = \"seq\".\"schema_id\" "
		  "AND \"s\".\"name\" = '%s' "
		  "AND \"seq\".\"name\" = '%s' "
		"ORDER BY \"s\".\"name\",\"seq\".\"name\"",
		schema, tname);

	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;

	while (mapi_fetch_row(hdl) != 0) {
		char *schema = mapi_fetch_field(hdl, 0);
		char *name = mapi_fetch_field(hdl, 1);
		char *start = mapi_fetch_field(hdl, 2);
		char *minvalue = mapi_fetch_field(hdl, 3);
		char *maxvalue = mapi_fetch_field(hdl, 4);
		char *increment = mapi_fetch_field(hdl, 5);
		char *cycle = mapi_fetch_field(hdl, 6);

		mnstr_printf(toConsole,
				 "CREATE SEQUENCE \"%s\".\"%s\" START WITH %s",
				 schema, name, start);
		if (strcmp(increment, "1") != 0)
			mnstr_printf(toConsole, " INCREMENT BY %s", increment);
		if (strcmp(minvalue, "0") != 0)
			mnstr_printf(toConsole, " MINVALUE %s", minvalue);
		if (strcmp(maxvalue, "0") != 0)
			mnstr_printf(toConsole, " MAXVALUE %s", maxvalue);
		mnstr_printf(toConsole, " %sCYCLE;\n", strcmp(cycle, "true") == 0 ? "" : "NO ");
		if (mnstr_errnr(toConsole)) {
			mapi_close_handle(hdl);
			hdl = NULL;
			goto bailout;
		}
	}
	if (mapi_error(mid))
		goto bailout;
	if (sname != NULL)
		free(sname);
	if (query != NULL)
		free(query);
	mapi_close_handle(hdl);
	hdl = NULL;
	return 0;

bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else if (mapi_error(mid))
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else if (mapi_error(mid))
		mapi_explain(mid, stderr);
	if (sname != NULL)
		free(sname);
	if (query != NULL)
		free(query);
	return 1;
}

int
describe_schema(Mapi mid, char *sname, stream *toConsole)
{
	MapiHdl hdl = NULL;
	char schemas[256];

	snprintf(schemas, 256,
		"SELECT \"s\".\"name\", \"a\".\"name\" "
		"FROM \"sys\".\"schemas\" \"s\", "
		     "\"sys\".\"auths\" \"a\" "
		"WHERE \"s\".\"authorization\" = \"a\".\"id\" AND "
		      "\"s\".\"name\" = '%s' "
		"ORDER BY \"s\".\"name\"",
		sname);

	if ((hdl = mapi_query(mid, schemas)) == NULL || mapi_error(mid)) {
		if (hdl) {
			if (mapi_result_error(hdl))
				mapi_explain_result(hdl, stderr);
			else
				mapi_explain_query(hdl, stderr);
			mapi_close_handle(hdl);
		} else
			mapi_explain(mid, stderr);

		return 1;
	}

	while (mapi_fetch_row(hdl) != 0) {
		char *sname = mapi_fetch_field(hdl, 0);
		char *aname = mapi_fetch_field(hdl, 1);

		mnstr_printf(toConsole, "CREATE SCHEMA \"%s\"", sname);
		if (strcmp(aname, "sysadmin") != 0) {
			mnstr_printf(toConsole,
					 " AUTHORIZATION \"%s\"", aname);
		}
		mnstr_printf(toConsole, ";\n");
	}

	return 0;
}

int
dump_table_data(Mapi mid, char *schema, char *tname, stream *toConsole,
		const char useInserts)
{
	int cnt, i;
	MapiHdl hdl = NULL;
	char *query;
	size_t maxquerylen;
	int *string = NULL;
	char *sname = NULL;

	if (schema == NULL) {
		if ((sname = strchr(tname, '.')) != NULL) {
			size_t len = sname - tname;

			sname = malloc(len + 1);
			strncpy(sname, tname, len);
			sname[len] = 0;
			tname += len + 1;
		} else if ((sname = get_schema(mid)) == NULL) {
			return 1;
		}
		schema = sname;
	}

	maxquerylen = 512 + strlen(tname) + strlen(schema);
	query = malloc(maxquerylen);

	snprintf(query, maxquerylen,
		 "SELECT \"t\".\"name\", \"t\".\"query\" "
		 "FROM \"sys\".\"_tables\" \"t\", \"sys\".\"schemas\" \"s\" "
		 "WHERE \"s\".\"name\" = '%s' "
		 "AND \"t\".\"schema_id\" = \"s\".\"id\" "
		 "AND \"t\".\"name\" = '%s'",
		 schema, tname);

	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	if (mapi_rows_affected(hdl) != 1) {
		if (mapi_rows_affected(hdl) == 0)
			fprintf(stderr, "table '%s.%s' does not exist\n", schema, tname);
		else
			fprintf(stderr, "table '%s.%s' is not unique\n", schema, tname);
		goto bailout;
	}
	while ((mapi_fetch_row(hdl)) != 0) {
		if (mapi_fetch_field(hdl, 1)) {
			/* the table is actually a view */
			goto doreturn;
		}
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;

	if (!useInserts) {
		snprintf(query, maxquerylen, "SELECT count(*) FROM \"%s\".\"%s\"",
			 schema, tname);
		if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
			goto bailout;
		if (mapi_fetch_row(hdl)) {
			char *cntfld = mapi_fetch_field(hdl, 0);

			if (strcmp(cntfld, "0") == 0) {
				/* no records to dump, so return early */
				goto doreturn;
			}

			mnstr_printf(toConsole,
					 "COPY %s RECORDS INTO \"%s\".\"%s\" "
					 "FROM stdin USING DELIMITERS '\\t','\\n','\"';\n",
					 cntfld, schema, tname);
		}
		mapi_close_handle(hdl);
		hdl = NULL;
	}

	snprintf(query, maxquerylen, "SELECT * FROM \"%s\".\"%s\"",
		 schema, tname);
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;

	cnt = mapi_get_field_count(hdl);
	string = malloc(sizeof(int) * cnt);
	for (i = 0; i < cnt; i++) {
		string[i] = 0;
		if (strcmp(mapi_get_type(hdl, i), "char") == 0 ||
		    strcmp(mapi_get_type(hdl, i), "varchar") == 0 ||
		    strcmp(mapi_get_type(hdl, i), "clob") == 0) {
			string[i] = 1;
		}
	}
	while (mapi_fetch_row(hdl)) {
		char *s;

		if (useInserts)
			mnstr_printf(toConsole, "INSERT INTO \"%s\".\"%s\" VALUES (",
					schema, tname);

		for (i = 0; i < cnt; i++) {
			s = mapi_fetch_field(hdl, i);
			if (s == NULL)
				mnstr_printf(toConsole, "NULL");
			else if (string[i]) {
				/* write double or single-quoted string with
				   certain characters escaped */
				quoted_print(toConsole, s, useInserts);
			} else
				mnstr_printf(toConsole, "%s", s);

			if (useInserts) {
				if (i < cnt - 1)
					mnstr_printf(toConsole, ", ");
				else
					mnstr_printf(toConsole, ");\n");
			} else {
				if (i < cnt - 1)
					mnstr_write(toConsole, "\t", 1, 1);
				else
					mnstr_write(toConsole, "\n", 1, 1);
			}
		}
		if (mnstr_errnr(toConsole))
			goto bailout;
	}
	if (mapi_error(mid))
		goto bailout;
	free(string);

  doreturn:
	if (hdl)
		mapi_close_handle(hdl);
	if (query != NULL)
		free(query);
	if (sname != NULL)
		free(sname);
	return 0;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else if (mapi_error(mid))
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else if (mapi_error(mid))
		mapi_explain(mid, stderr);
	if (sname != NULL)
		free(sname);
	if (query != NULL)
		free(query);
	if (string != NULL)
		free(string);
	return 1;
}

int
dump_table(Mapi mid, char *schema, char *tname, stream *toConsole, int describe, int foreign, const char useInserts)
{
	int rc;

	rc = describe_table(mid, schema, tname, toConsole, foreign);
	if (rc == 0 && !describe)
		rc = dump_table_data(mid, schema, tname, toConsole, useInserts);
	return rc;
}

static int
dump_external_functions(Mapi mid, const char *schema, const char *fname, stream *toConsole, const char dumpSystem)
{
	const char functions[] =
		"SELECT \"f\".\"id\","
		       "\"f\".\"name\","
		       "\"f\".\"mod\","
		       "\"f\".\"func\","
		       "\"a\".\"name\","
		       "\"a\".\"type\","
		       "\"a\".\"type_digits\","
		       "\"a\".\"type_scale\","
		       "\"a\".\"number\", "
			   "\"s\".\"name\" "
		"FROM \"sys\".\"args\" \"a\","
		     "\"sys\".\"functions\" \"f\", "
			 "\"sys\".\"schemas\" \"s\" "
		"WHERE \"f\".\"sql\" = FALSE AND "
		      "\"a\".\"func_id\" = \"f\".\"id\" AND "
			  "\"f\".\"schema_id\" = \"s\".\"id\" "
		      "%s %s "
		"ORDER BY \"f\".\"id\", \"a\".\"number\"";
	char query[512];
	MapiHdl hdl;
	char *prev_f_id = NULL;
	char *prev_f_mod = NULL;
	char *prev_f_func = NULL;
	char *prev_a_name = NULL;
	char *prev_a_type = NULL;
	char *prev_a_type_digits = NULL;
	char *prev_a_type_scale = NULL;
	char *sep = NULL;

	snprintf(query, sizeof(query), functions,
			dumpSystem ? "" : "AND \"f\".\"id\"",
			dumpSystem ? "" : has_systemfunctions(mid) ? "NOT IN (SELECT \"function_id\" FROM \"sys\".\"systemfunctions\")" : "> 2000");
	if ((hdl = mapi_query(mid, query)) == NULL || mapi_error(mid))
		goto bailout;
	while (!mnstr_errnr(toConsole) && mapi_fetch_row(hdl) != 0) {
		char *f_id = mapi_fetch_field(hdl, 0);
		char *f_name = mapi_fetch_field(hdl, 1);
		char *f_mod = mapi_fetch_field(hdl, 2);
		char *f_func = mapi_fetch_field(hdl, 3);
		char *a_name = mapi_fetch_field(hdl, 4);
		char *a_type = mapi_fetch_field(hdl, 5);
		char *a_type_digits = mapi_fetch_field(hdl, 6);
		char *a_type_scale = mapi_fetch_field(hdl, 7);
		char *a_number = mapi_fetch_field(hdl, 8);
		char *s_name = mapi_fetch_field(hdl, 9);

		if (schema != NULL && strcmp(s_name, schema) != 0)
			continue;
		if (fname != NULL && strcmp(f_name, fname) != 0)
			continue;

		if (prev_f_id == NULL || strcmp(prev_f_id, f_id) != 0) {
			if (prev_f_id) {
				mnstr_printf(toConsole, ")");
				if (strcmp(prev_a_name, "result") == 0) {
					mnstr_printf(toConsole, " RETURNS ");
					dump_type(mid, toConsole, prev_a_type, prev_a_type_digits, prev_a_type_scale);
				}
				mnstr_printf(toConsole,
					     " EXTERNAL NAME \"%s\".\"%s\";\n",
					     prev_f_mod, prev_f_func);
				free(prev_f_id);
				free(prev_f_mod);
				free(prev_f_func);
				free(prev_a_name);
				free(prev_a_type);
				free(prev_a_type_digits);
				free(prev_a_type_scale);
			}
			if (strcmp(a_name, "result") == 0) {
				mnstr_printf(toConsole,
					     "CREATE FUNCTION \"%s\"(",
					     f_name);
			} else
				mnstr_printf(toConsole,
					     "CREATE PROCEDURE \"%s\"(",
					     f_name);
			prev_f_id = strdup(f_id);
			prev_f_mod = strdup(f_mod);
			prev_f_func = strdup(f_func);
			prev_a_name = strdup(a_name);
			prev_a_type = strdup(a_type);
			prev_a_type_digits = strdup(a_type_digits);
			prev_a_type_scale = strdup(a_type_scale);
			sep = "";
		}
		if (strcmp(a_name, "result") != 0 ||
		    strcmp(a_number, "0") != 0) {
			mnstr_printf(toConsole, "%s\"%s\" ", sep, a_name);
			dump_type(mid, toConsole, a_type, a_type_digits, a_type_scale);
			sep = ", ";
		}
	}
	if (prev_f_id) {
		mnstr_printf(toConsole, ")");
		if (strcmp(prev_a_name, "result") == 0) {
			mnstr_printf(toConsole, " RETURNS ");
			dump_type(mid, toConsole, prev_a_type, prev_a_type_digits, prev_a_type_scale);
		}
		mnstr_printf(toConsole,
			     " EXTERNAL NAME \"%s\".\"%s\";\n",
			     prev_f_mod, prev_f_func);
		free(prev_f_id);
	}
	if (prev_f_mod)
		free(prev_f_mod);
	if (prev_f_func)
		free(prev_f_func);
	if (prev_a_name)
		free(prev_a_name);
	if (prev_a_type)
		free(prev_a_type);
	if (prev_a_type_digits)
		free(prev_a_type_digits);
	if (prev_a_type_scale)
		free(prev_a_type_scale);

	mapi_close_handle(hdl);
	return mnstr_errnr(toConsole) ? 1 : 0;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else
		mapi_explain(mid, stderr);
	return 1;
}

int
dump_functions(Mapi mid, stream *toConsole, const char *sname, const char *fname)
{
	const char functions[] =
		"SELECT \"f\".\"func\", \"f\".\"name\", \"s\".\"name\" "
		"FROM \"sys\".\"schemas\" \"s\","
		     "\"sys\".\"functions\" \"f\" "
		"WHERE \"f\".\"sql\" = TRUE AND "
		      "\"s\".\"id\" = \"f\".\"schema_id\""
			  "%s %s "
		      "%s%s%s "
		"ORDER BY \"f\".\"id\"";
	MapiHdl hdl;
	char *q;
	size_t l;
	char dumpSystem;
	char *schema = NULL;

	if (sname == NULL) {
		if (fname == NULL) {
			schema = NULL;
		} else if ((schema = strchr(fname, '.')) != NULL) {
			size_t len = schema - fname;

			schema = malloc(len + 1);
			strncpy(schema, fname, len);
			schema[len] = 0;
			fname += len + 1;
		} else if ((schema = get_schema(mid)) == NULL) {
			return 1;
		}
		sname = schema;
	}

	dumpSystem = sname && fname;

	if (dump_external_functions(mid, sname, fname, toConsole, dumpSystem)) {
		if (schema)
			free(schema);
		return 1;
	}
	l = sizeof(functions) + (sname ? strlen(sname) : 0) + 100;
	q = malloc(l);
	snprintf(q, l, functions,
		 dumpSystem ? "" : "AND \"f\".\"id\"",
		 dumpSystem ? "" : has_systemfunctions(mid) ? "NOT IN (SELECT \"function_id\" FROM \"sys\".\"systemfunctions\")" : "> 2000",
		 sname ? " AND \"s\".\"name\" = '" : "",
		 sname ? sname : "",
		 sname ? "'" : "");
	hdl = mapi_query(mid, q);
	free(q);
	if (hdl == NULL || mapi_error(mid))
		goto bailout;
	while (!mnstr_errnr(toConsole) && mapi_fetch_row(hdl) != 0) {
		char *query = mapi_fetch_field(hdl, 0);
		char *f_name = mapi_fetch_field(hdl, 1);
		char *s_name = mapi_fetch_field(hdl, 2);

		if (sname != NULL && strcmp(sname, s_name) != 0)
			continue;
		if (fname != NULL && strcmp(fname, f_name) != 0)
			continue;

		mnstr_printf(toConsole, "%s\n", query);
	}
	if (mapi_error(mid))
		goto bailout;
	if (schema)
		free(schema);
	mapi_close_handle(hdl);
	return mnstr_errnr(toConsole) ? 1 : 0;

  bailout:
	if (schema)
		free(schema);
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else
		mapi_explain(mid, stderr);
	return 1;
}

int
dump_database(Mapi mid, stream *toConsole, int describe, const char useInserts)
{
	const char *start = "START TRANSACTION";
	const char *end = "ROLLBACK";
	const char *chkhash =
		"SELECT \"id\" "
		"FROM \"sys\".\"functions\" "
		"WHERE \"name\" = 'password_hash'";
	const char *createhash =
		"CREATE FUNCTION \"password_hash\" (\"username\" STRING) "
		"RETURNS STRING "
		"EXTERNAL NAME \"sql\".\"password\"";
	const char *drophash = "DROP FUNCTION \"password_hash\"";
	const char *users =
		"SELECT \"ui\".\"name\", "
		       "\"ui\".\"fullname\", "
		       "\"password_hash\"(\"ui\".\"name\"), "
		       "\"s\".\"name\" "
		"FROM \"sys\".\"db_user_info\" \"ui\", "
		     "\"sys\".\"schemas\" \"s\" "
		"WHERE \"ui\".\"default_schema\" = \"s\".\"id\" AND "
		      "\"ui\".\"name\" <> 'monetdb' "
		"ORDER BY \"ui\".\"name\"";
	const char *roles =
		"SELECT \"name\" "
		"FROM \"sys\".\"auths\" "
		"WHERE \"name\" NOT IN (SELECT \"name\" "
				       "FROM \"sys\".\"db_user_info\") AND "
		      "\"grantor\" <> 0 "
		"ORDER BY \"name\"";
	const char *grants =
		"SELECT \"a1\".\"name\", "
		       "\"a2\".\"name\" "
		"FROM \"sys\".\"auths\" \"a1\", "
		     "\"sys\".\"auths\" \"a2\", "
		     "\"sys\".\"user_role\" \"ur\" "
		"WHERE \"a1\".\"id\" = \"ur\".\"login_id\" AND "
		      "\"a2\".\"id\" = \"ur\".\"role_id\" "
		"ORDER BY \"a1\".\"name\", \"a2\".\"name\"";
	const char *table_grants =
		"SELECT \"s\".\"name\", \"t\".\"name\", "
		       "\"a\".\"name\", "
		       "CASE WHEN \"p\".\"privileges\" = 1 THEN 'SELECT' "
			    "WHEN \"p\".\"privileges\" = 2 THEN 'UPDATE' "
			    "WHEN \"p\".\"privileges\" = 4 THEN 'INSERT' "
			    "WHEN \"p\".\"privileges\" = 8 THEN 'DELETE' "
			    "WHEN \"p\".\"privileges\" = 16 THEN 'EXECUTE' "
			    "WHEN \"p\".\"privileges\" = 32 THEN 'GRANT' END, "
		       "\"g\".\"name\", \"p\".\"grantable\" "
		"FROM \"sys\".\"schemas\" \"s\", \"sys\".\"tables\" \"t\", "
		     "\"sys\".\"auths\" \"a\", \"sys\".\"privileges\" \"p\", "
		     "\"sys\".\"auths\" \"g\" "
		"WHERE \"p\".\"obj_id\" = \"t\".\"id\" AND "
		      "\"p\".\"auth_id\" = \"a\".\"id\" AND "
		      "\"t\".\"schema_id\" = \"s\".\"id\" AND "
		      "\"t\".\"system\" = FALSE AND "
		      "\"p\".\"grantor\" = \"g\".\"id\"";
	const char *column_grants =
		"SELECT \"s\".\"name\", \"t\".\"name\", "
		       "\"c\".\"name\", \"a\".\"name\", "
		       "CASE WHEN \"p\".\"privileges\" = 1 THEN 'SELECT' "
			    "WHEN \"p\".\"privileges\" = 2 THEN 'UPDATE' "
			    "WHEN \"p\".\"privileges\" = 4 THEN 'INSERT' "
			    "WHEN \"p\".\"privileges\" = 8 THEN 'DELETE' "
			    "WHEN \"p\".\"privileges\" = 16 THEN 'EXECUTE' "
			    "WHEN \"p\".\"privileges\" = 32 THEN 'GRANT' END, "
		       "\"g\".\"name\", \"p\".\"grantable\" "
		"FROM \"sys\".\"schemas\" \"s\", \"sys\".\"tables\" \"t\", "
		     "\"sys\".\"columns\" \"c\", \"sys\".\"auths\" \"a\", "
		     "\"sys\".\"privileges\" \"p\", \"sys\".\"auths\" \"g\" "
		"WHERE \"p\".\"obj_id\" = \"c\".\"id\" AND "
		      "\"c\".\"table_id\" = \"t\".\"id\" AND "
		      "\"p\".\"auth_id\" = \"a\".\"id\" AND "
		      "\"t\".\"schema_id\" = \"s\".\"id\" AND "
		      "\"t\".\"system\" = FALSE AND "
		      "\"p\".\"grantor\" = \"g\".\"id\"";
	const char *schemas =
		"SELECT \"s\".\"name\", \"a\".\"name\" "
		"FROM \"sys\".\"schemas\" \"s\", "
		     "\"sys\".\"auths\" \"a\" "
		"WHERE \"s\".\"authorization\" = \"a\".\"id\" AND "
		      "\"s\".\"name\" NOT IN ('sys', 'tmp') "
		"ORDER BY \"s\".\"name\"";
	/* alternative, but then need to handle NULL in second column:
	   SELECT "s"."name", "a"."name"
	   FROM "sys"."schemas" "s"
		LEFT OUTER JOIN "sys"."auths" "a"
		     ON "s"."authorization" = "a"."id" AND
		"s"."name" NOT IN ('sys', 'tmp')
	   ORDER BY "s"."name"

	   This may be needed after a sequence:

	   CREATE USER "voc" WITH PASSWORD 'voc' NAME 'xxx' SCHEMA "sys";
	   CREATE SCHEMA "voc" AUTHORIZATION "voc";
	   ALTER USER "voc" SET SCHEMA "voc";
	   DROP USER "voc";

	   In this case, the authorization value for voc in the
	   schemas table has no corresponding value in the auths table
	   anymore.
	 */
	const char *sequences1 =
		"SELECT \"sch\".\"name\",\"seq\".\"name\" "
		"FROM \"sys\".\"schemas\" \"sch\", "
		     "\"sys\".\"sequences\" \"seq\" "
		"WHERE \"sch\".\"id\" = \"seq\".\"schema_id\" "
		"ORDER BY \"sch\".\"name\",\"seq\".\"name\"";
	const char *sequences2 =
		"SELECT \"s\".\"name\","
		     "\"seq\".\"name\","
		     "get_value_for(\"s\".\"name\",\"seq\".\"name\"),"
		     "\"seq\".\"minvalue\","
		     "\"seq\".\"maxvalue\","
		     "\"seq\".\"increment\","
		     "\"seq\".\"cycle\" "
		"FROM \"sys\".\"sequences\" \"seq\", "
		     "\"sys\".\"schemas\" \"s\" "
		"WHERE \"s\".\"id\" = \"seq\".\"schema_id\" "
		"ORDER BY \"s\".\"name\",\"seq\".\"name\"";
	const char *tables_and_functions =
		"WITH \"tf_xYzzY\" AS ("
			"SELECT \"s\".\"name\" AS \"sname\", "
			       "\"f\".\"name\" AS \"name\", "
			       "\"f\".\"id\" AS \"id\", "
			       "\"f\".\"func\" AS \"func\" "
			"FROM \"sys\".\"schemas\" \"s\", "
			     "\"sys\".\"functions\" \"f\" "
			"WHERE \"f\".\"sql\" = TRUE AND "
			      "\"s\".\"id\" = \"f\".\"schema_id\" "
			      "%s"  /* and f.id not in systemfunctions */
			"UNION "
			"SELECT \"s\".\"name\" AS \"sname\", "
			       "\"t\".\"name\" AS \"name\", "
			       "\"t\".\"id\" AS \"id\", "
			       "CAST(NULL AS VARCHAR(8196)) AS \"func\" "
			"FROM \"sys\".\"schemas\" \"s\", "
			     "\"sys\".\"_tables\" \"t\" "
			"WHERE \"t\".\"type\" BETWEEN 0 AND 1 AND "
			      "\"t\".\"system\" = FALSE AND "
			      "\"s\".\"id\" = \"t\".\"schema_id\" AND "
			      "\"s\".\"name\" <> 'tmp' "
			"UNION "
			"SELECT \"s\".\"name\" AS \"sname\", "
			       "\"tr\".\"name\" AS \"name\", "
			       "\"tr\".\"id\" AS \"id\", "
			       "\"tr\".\"statement\" AS \"func\" "
			"FROM \"sys\".\"triggers\" \"tr\", "
			     "\"sys\".\"schemas\" \"s\", "
			     "\"sys\".\"_tables\" \"t\" "
			"WHERE \"s\".\"id\" = \"t\".\"schema_id\" AND "
			      "\"t\".\"id\" = \"tr\".\"table_id\""
		") "
		"SELECT * FROM \"tf_xYzzY\" ORDER BY \"tf_xYzzY\".\"id\"";
	char *sname;
	char *curschema = NULL;
	MapiHdl hdl;
	int create_hash_func = 0;
	int rc = 0;
	char query[1024];

	/* start a transaction for the dump */
	if (!describe)
		mnstr_printf(toConsole, "START TRANSACTION;\n");

	if ((hdl = mapi_query(mid, start)) == NULL || mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;

	sname = get_schema(mid);
	if (sname == NULL)
		goto bailout2;
	if (strcmp(sname, "sys") == 0 || strcmp(sname, "tmp") == 0) {
		free(sname);
		sname = NULL;

		/* dump roles */
		if ((hdl = mapi_query(mid, roles)) == NULL || mapi_error(mid))
			goto bailout;

		while (mapi_fetch_row(hdl) != 0) {
			char *name = mapi_fetch_field(hdl, 0);

			mnstr_printf(toConsole, "CREATE ROLE \"%s\";\n", name);
		}
		if (mapi_error(mid))
			goto bailout;
		mapi_close_handle(hdl);

		/* dump users, part 1 */
		/* first make sure the password_hash function exists */
		if ((hdl = mapi_query(mid, chkhash)) == NULL ||
		    mapi_error(mid))
			goto bailout;
		create_hash_func = mapi_rows_affected(hdl) == 0;
		mapi_close_handle(hdl);
		if (create_hash_func) {
			if ((hdl = mapi_query(mid, createhash)) == NULL ||
			    mapi_error(mid))
				goto bailout;
			mapi_close_handle(hdl);
		}

		if ((hdl = mapi_query(mid, users)) == NULL || mapi_error(mid))
			goto bailout;

		while (mapi_fetch_row(hdl) != 0) {
			char *uname = mapi_fetch_field(hdl, 0);
			char *fullname = mapi_fetch_field(hdl, 1);
			char *pwhash = mapi_fetch_field(hdl, 2);
			char *sname = mapi_fetch_field(hdl, 3);

			mnstr_printf(toConsole, "CREATE USER \"%s\"", uname);
			if (describe)
				mnstr_printf(toConsole,
					     " WITH ENCRYPTED PASSWORD '%s'"
					     " NAME '%s' SCHEMA \"%s\";\n",
					     pwhash, fullname, sname);
			else
				mnstr_printf(toConsole,
					     " WITH ENCRYPTED PASSWORD '%s'"
					     " NAME '%s' SCHEMA \"sys\";\n",
					     pwhash, fullname);
		}
		if (mapi_error(mid))
			goto bailout;
		mapi_close_handle(hdl);

		/* dump schemas */
		if ((hdl = mapi_query(mid, schemas)) == NULL ||
		    mapi_error(mid))
			goto bailout;

		while (mapi_fetch_row(hdl) != 0) {
			char *sname = mapi_fetch_field(hdl, 0);
			char *aname = mapi_fetch_field(hdl, 1);

			mnstr_printf(toConsole, "CREATE SCHEMA \"%s\"", sname);
			if (strcmp(aname, "sysadmin") != 0) {
				mnstr_printf(toConsole,
					     " AUTHORIZATION \"%s\"", aname);
			}
			mnstr_printf(toConsole, ";\n");
		}
		if (mapi_error(mid))
			goto bailout;
		mapi_close_handle(hdl);

		if (!describe) {
			/* dump users, part 2 */
			if ((hdl = mapi_query(mid, users)) == NULL ||
			    mapi_error(mid))
				goto bailout;

			while (mapi_fetch_row(hdl) != 0) {
				char *uname = mapi_fetch_field(hdl, 0);
				char *sname = mapi_fetch_field(hdl, 3);

				if (strcmp(sname, "sys") == 0)
					continue;
				mnstr_printf(toConsole,
					     "ALTER USER \"%s\" "
					     "SET SCHEMA \"%s\";\n",
					     uname, sname);
			}
			if (mapi_error(mid))
				goto bailout;
			mapi_close_handle(hdl);
		}

		/* clean up -- not strictly necessary due to ROLLBACK */
		if (create_hash_func) {
			if ((hdl = mapi_query(mid, drophash)) == NULL ||
			    mapi_error(mid))
				goto bailout;
			mapi_close_handle(hdl);
		}

		/* grant user privileges */
		if ((hdl = mapi_query(mid, grants)) == NULL || mapi_error(mid))
			goto bailout;

		while (mapi_fetch_row(hdl) != 0) {
			char *uname = mapi_fetch_field(hdl, 0);
			char *rname = mapi_fetch_field(hdl, 1);

			mnstr_printf(toConsole, "GRANT \"%s\" TO ", rname);
			if (strcmp(uname, "public") == 0)
				mnstr_printf(toConsole, "PUBLIC");
			else
				mnstr_printf(toConsole, "\"%s\"", uname);
			/* optional WITH ADMIN OPTION and FROM
			   (CURRENT_USER|CURRENT_ROLE) are ignored by
			   server, so we can't dump them */
			mnstr_printf(toConsole, ";\n");
		}
		if (mapi_error(mid))
			goto bailout;
		mapi_close_handle(hdl);
	} else {
		mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n", sname);
		curschema = strdup(sname);
	}

	/* dump sequences, part 1 */
	if ((hdl = mapi_query(mid, sequences1)) == NULL || mapi_error(mid))
		goto bailout;

	while (mapi_fetch_row(hdl) != 0) {
		char *schema = mapi_fetch_field(hdl, 0);
		char *name = mapi_fetch_field(hdl, 1);

		if (sname != NULL && strcmp(schema, sname) != 0)
			continue;
		mnstr_printf(toConsole,
			     "CREATE SEQUENCE \"%s\".\"%s\" AS INTEGER;\n",
			     schema, name);
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;

	/* dump tables and functions */
	if (dump_external_functions(mid, NULL, NULL, toConsole, 0))
		goto bailout;
	snprintf(query, sizeof(query), tables_and_functions,
		 has_systemfunctions(mid) ? "AND \"f\".\"id\" NOT IN (SELECT \"function_id\" FROM \"sys\".\"systemfunctions\") " : "");
	if ((hdl = mapi_query(mid, query)) == NULL ||
	    mapi_error(mid))
		goto bailout;

	while (rc == 0 &&
	       !mnstr_errnr(toConsole) &&
	       mapi_fetch_row(hdl) != 0) {
		char *schema = mapi_fetch_field(hdl, 0);
		char *tname = mapi_fetch_field(hdl, 1);
		char *func = mapi_fetch_field(hdl, 3);

		if (mapi_error(mid))
			goto bailout;
		if (schema == NULL) {
			/* cannot happen, but make analysis tools happy */
			continue;
		}
		if (sname != NULL && strcmp(schema, sname) != 0)
			continue;
		if (curschema == NULL || strcmp(schema, curschema) != 0) {
			if (curschema)
				free(curschema);
			curschema = strdup(schema);
			mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n",
				     curschema);
		}
		if (func == NULL) {
			schema = strdup(schema);
			tname = strdup(tname);
			rc = dump_table(mid, schema, tname, toConsole, describe, describe, useInserts);
			free(schema);
			free(tname);
		} else
			mnstr_printf(toConsole, "%s\n", func);
	}
	if (curschema) {
		if (strcmp(sname ? sname : "sys", curschema) != 0) {
			mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n",
				     sname ? sname : "sys");
		}
		free(curschema);
		curschema = strdup(sname ? sname : "sys");
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);
	hdl = NULL;
	if (mnstr_errnr(toConsole))
		goto bailout2;

	if (!describe) {
		if (dump_foreign_keys(mid, NULL, NULL, NULL, toConsole))
			goto bailout2;

		/* dump sequences, part 2 */
		if ((hdl = mapi_query(mid, sequences2)) == NULL ||
		    mapi_error(mid))
			goto bailout;

		while (mapi_fetch_row(hdl) != 0) {
			char *schema = mapi_fetch_field(hdl, 0);
			char *name = mapi_fetch_field(hdl, 1);
			char *restart = mapi_fetch_field(hdl, 2);
			char *minvalue = mapi_fetch_field(hdl, 3);
			char *maxvalue = mapi_fetch_field(hdl, 4);
			char *increment = mapi_fetch_field(hdl, 5);
			char *cycle = mapi_fetch_field(hdl, 6);

			if (sname != NULL && strcmp(schema, sname) != 0)
				continue;

			mnstr_printf(toConsole,
				     "ALTER SEQUENCE \"%s\".\"%s\" RESTART WITH %s",
				     schema, name, restart);
			if (strcmp(increment, "1") != 0)
				mnstr_printf(toConsole, " INCREMENT BY %s", increment);
			if (strcmp(minvalue, "0") != 0)
				mnstr_printf(toConsole, " MINVALUE %s", minvalue);
			if (strcmp(maxvalue, "0") != 0)
				mnstr_printf(toConsole, " MAXVALUE %s", maxvalue);
			mnstr_printf(toConsole, " %sCYCLE;\n", strcmp(cycle, "true") == 0 ? "" : "NO ");
			if (mnstr_errnr(toConsole)) {
				mapi_close_handle(hdl);
				hdl = NULL;
				goto bailout2;
			}
		}
		if (mapi_error(mid))
			goto bailout;
		mapi_close_handle(hdl);
	}

	if ((hdl = mapi_query(mid, table_grants)) == NULL || mapi_error(mid))
		goto bailout;

	while (mapi_fetch_row(hdl) != 0) {
		char *schema = mapi_fetch_field(hdl, 0);
		char *tname = mapi_fetch_field(hdl, 1);
		char *aname = mapi_fetch_field(hdl, 2);
		char *priv = mapi_fetch_field(hdl, 3);
		char *grantable = mapi_fetch_field(hdl, 5);

		if (sname != NULL && strcmp(schema, sname) != 0)
			continue;
		if (curschema == NULL || strcmp(schema, curschema) != 0) {
			if (curschema)
				free(curschema);
			curschema = strdup(schema);
			mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n",
				     curschema);
		}
		mnstr_printf(toConsole, "GRANT %s ON \"%s\" TO \"%s\"",
			     priv, tname, aname);
		if (strcmp(grantable, "1") == 0)
			mnstr_printf(toConsole, " WITH GRANT OPTION");
		mnstr_printf(toConsole, ";\n");
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);

	if ((hdl = mapi_query(mid, column_grants)) == NULL || mapi_error(mid))
		goto bailout;

	while (mapi_fetch_row(hdl) != 0) {
		char *schema = mapi_fetch_field(hdl, 0);
		char *tname = mapi_fetch_field(hdl, 1);
		char *cname = mapi_fetch_field(hdl, 2);
		char *aname = mapi_fetch_field(hdl, 3);
		char *priv = mapi_fetch_field(hdl, 4);
		char *grantable = mapi_fetch_field(hdl, 6);

		if (sname != NULL && strcmp(schema, sname) != 0)
			continue;
		if (curschema == NULL || strcmp(schema, curschema) != 0) {
			if (curschema)
				free(curschema);
			curschema = strdup(schema);
			mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n",
				     curschema);
		}
		mnstr_printf(toConsole, "GRANT %s(\"%s\") ON \"%s\" TO \"%s\"",
			     priv, cname, tname, aname);
		if (strcmp(grantable, "1") == 0)
			mnstr_printf(toConsole, " WITH GRANT OPTION");
		mnstr_printf(toConsole, ";\n");
	}
	if (mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);

	if (curschema) {
		if (strcmp(sname ? sname : "sys", curschema) != 0) {
			mnstr_printf(toConsole, "SET SCHEMA \"%s\";\n",
				     sname ? sname : "sys");
		}
		free(curschema);
		curschema = NULL;
	}

	if ((hdl = mapi_query(mid, end)) == NULL || mapi_error(mid))
		goto bailout;
	mapi_close_handle(hdl);

	/* finally commit the whole transaction */
	if (!describe)
		mnstr_printf(toConsole, "COMMIT;\n");

	return rc;

  bailout:
	if (hdl) {
		if (mapi_result_error(hdl))
			mapi_explain_result(hdl, stderr);
		else
			mapi_explain_query(hdl, stderr);
		mapi_close_handle(hdl);
	} else
		mapi_explain(mid, stderr);

  bailout2:
	hdl = mapi_query(mid, end);
	if (hdl)
		mapi_close_handle(hdl);
	return 1;
}

void
dump_version(Mapi mid, stream *toConsole, const char *prefix)
{
	MapiHdl hdl;
	char *dbname = NULL, *uri = NULL, *dbver = NULL, *dbrel = NULL;
	char *name, *val;

	if ((hdl = mapi_query(mid,
			      "SELECT \"name\", \"value\" "
			      "FROM sys.env() AS env "
			      "WHERE \"name\" IN ('gdk_dbname', "
					"'monet_version', "
					"'monet_release', "
					"'merovingian_uri')")) == NULL ||
			mapi_error(mid))
		goto cleanup;

	while ((mapi_fetch_row(hdl)) != 0) {
		name = mapi_fetch_field(hdl, 0);
		val = mapi_fetch_field(hdl, 1);

		if (mapi_error(mid))
			goto cleanup;

		if (name != NULL && val != NULL) {
			if (strcmp(name, "gdk_dbname") == 0) {
				assert(dbname == NULL);
				dbname = *val == '\0' ? NULL : strdup(val);
			} else if (strcmp(name, "monet_version") == 0) {
				assert(dbver == NULL);
				dbver = *val == '\0' ? NULL : strdup(val);
			} else if (strcmp(name, "monet_release") == 0) {
				assert(dbrel == NULL);
				dbrel = *val == '\0' ? NULL : strdup(val);
			} else if (strcmp(name, "merovingian_uri") == 0) {
				assert(uri == NULL);
				uri = strdup(val);
			}
		}
	}
	if (uri != NULL) {
		if (dbname != NULL)
			free(dbname);
		dbname = uri;
	}
	if (dbname != NULL && dbver != NULL) {
		mnstr_printf(toConsole, "%s MonetDB v%s%s%s%s, '%s'\n",
			     prefix,
				 dbver,
				 dbrel != NULL ? " (" : "",
				 dbrel != NULL ? dbrel : "",
				 dbrel != NULL ? ")" : "",
				 dbname);
	}

  cleanup:
	if (dbname != NULL)
		free(dbname);
	if (dbver != NULL)
		free(dbver);
	if (dbrel != NULL)
		free(dbrel);
	if (hdl)
		mapi_close_handle(hdl);
}
