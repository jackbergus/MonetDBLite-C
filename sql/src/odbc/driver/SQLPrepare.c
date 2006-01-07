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
 * Portions created by CWI are Copyright (C) 1997-2006 CWI.
 * All Rights Reserved.
 */

/*
 * This code was created by Peter Harvey (mostly during Christmas 98/99).
 * This code is LGPL. Please ensure that this message remains in future
 * distributions and uses of this code (thats about all I get out of it).
 * - Peter Harvey pharvey@codebydesign.com
 * 
 * This file has been modified for the MonetDB project.  See the file
 * Copyright in this directory for more information.
 */

/**********************************************************************
 * SQLPrepare
 * CLI Compliance: ISO 92
 *
 * Author: Martin van Dinther
 * Date  : 30 aug 2002
 *
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"
#include "ODBCUtil.h"


void
ODBCResetStmt(ODBCStmt *stmt)
{
	SQLFreeStmt_(stmt, SQL_CLOSE);
	setODBCDescRecCount(stmt->ImplParamDescr, 0);

	stmt->queryid = -1;
	stmt->nparams = 0;
	stmt->State = INITED;
}

SQLRETURN
SQLPrepare_(ODBCStmt *stmt, SQLCHAR *szSqlStr, SQLINTEGER nSqlStrLength)
{
	char *query, *s;
	MapiMsg ret;
	MapiHdl hdl;
	int nrParams;
	ODBCDescRec *rec;
	int i;

	hdl = stmt->hdl;

	if (stmt->State >= EXECUTED1 || (stmt->State == EXECUTED0 && mapi_more_results(hdl))) {
		/* Invalid cursor state */
		addStmtError(stmt, "24000", NULL, 0);
		return SQL_ERROR;
	}

	/* check input parameter */
	if (szSqlStr == NULL) {
		/* Invalid use of null pointer */
		addStmtError(stmt, "HY009", NULL, 0);
		return SQL_ERROR;
	}

	fixODBCstring(szSqlStr, nSqlStrLength, addStmtError, stmt);
	/* TODO: convert ODBC escape sequences ( {d 'value'} or {t 'value'} or
	   {ts 'value'} or {escape 'e-char'} or {oj outer-join} or
	   {fn scalar-function} etc. ) to MonetDB SQL syntax */
	query = ODBCTranslateSQL(szSqlStr, (size_t) nSqlStrLength, stmt->noScan);
#ifdef ODBCDEBUG
	ODBCLOG("SQLPrepare: \"%s\"\n", query);
#endif
	s = malloc(strlen(query) + 9);
	strcat(strcpy(s, "prepare "), query);
	free(query);

	ODBCResetStmt(stmt);

	ret = mapi_query_handle(hdl, s);
	free(s);
	s = NULL;
	if (ret != MOK || (s = mapi_result_error(hdl)) != NULL) {
		/* XXX more fine-grained control required */
		/* Syntax error or access violation */
		addStmtError(stmt, "42000", s, 0);
		return SQL_ERROR;
	}
	nrParams = mapi_rows_affected(hdl);
	setODBCDescRecCount(stmt->ImplParamDescr, nrParams);
	rec = stmt->ImplParamDescr->descRec + 1;
	for (i = 0; i < nrParams; i++, rec++) {
		struct sql_types *tp;
		int concise_type;

		mapi_fetch_row(hdl);
		s = mapi_fetch_field(hdl, 0); /* type */
		rec->sql_desc_type_name = (SQLCHAR *) strdup(s);
		concise_type = ODBCConciseType(s);
		for (tp = ODBC_sql_types; tp->concise_type; tp++)
			if (concise_type == tp->concise_type)
				break;
		rec->sql_desc_concise_type = tp->concise_type;
		rec->sql_desc_type = tp->type;
		rec->sql_desc_datetime_interval_code = tp->code;
		if (tp->precision != UNAFFECTED)
			rec->sql_desc_precision = tp->precision;
		if (tp->datetime_interval_precision != UNAFFECTED)
			rec->sql_desc_datetime_interval_precision = tp->datetime_interval_precision;
		rec->sql_desc_fixed_prec_scale = tp->fixed;
		rec->sql_desc_num_prec_radix = tp->radix;
		rec->sql_desc_unsigned = tp->radix == 0 ? SQL_TRUE : SQL_FALSE;

		if (rec->sql_desc_concise_type == SQL_CHAR || rec->sql_desc_concise_type == SQL_VARCHAR)
			rec->sql_desc_case_sensitive = SQL_TRUE;
		else
			rec->sql_desc_case_sensitive = SQL_FALSE;

		s = mapi_fetch_field(hdl, 1); /* digits */
		rec->sql_desc_length = atoi(s);

		s = mapi_fetch_field(hdl, 2); /* scale */
		rec->sql_desc_scale = atoi(s);

		rec->sql_desc_local_type_name = (SQLCHAR *) strdup("");
		rec->sql_desc_nullable = SQL_NULLABLE;
		rec->sql_desc_parameter_type = SQL_PARAM_INPUT;
		rec->sql_desc_rowver = SQL_FALSE;
		rec->sql_desc_unnamed = SQL_UNNAMED;

		/* unused fields */
		rec->sql_desc_auto_unique_value = 0;
		rec->sql_desc_base_column_name = NULL;
		rec->sql_desc_base_table_name = NULL;
		rec->sql_desc_catalog_name = NULL;
		rec->sql_desc_data_ptr = NULL;
		rec->sql_desc_display_size = 0;
		rec->sql_desc_indicator_ptr = NULL;
		rec->sql_desc_label = NULL;
		rec->sql_desc_literal_prefix = NULL;
		rec->sql_desc_literal_suffix = NULL;
		rec->sql_desc_octet_length_ptr = NULL;
		rec->sql_desc_schema_name = NULL;
		rec->sql_desc_searchable = 0;
		rec->sql_desc_table_name = NULL;
		rec->sql_desc_updatable = 0;

		/* this must come after other fields have been
		 * initialized */
		rec->sql_desc_length = ODBCDisplaySize(rec);
		rec->sql_desc_display_size = rec->sql_desc_length;
		rec->sql_desc_octet_length = rec->sql_desc_length;
	}

	/* update the internal state */
	stmt->queryid = mapi_get_tableid(hdl);
	stmt->nparams = nrParams;
	stmt->State = PREPARED1;	/* XXX or PREPARED0, depending on query */

	return SQL_SUCCESS;
}

SQLRETURN SQL_API
SQLPrepare(SQLHSTMT hStmt, SQLCHAR *szSqlStr, SQLINTEGER nSqlStrLength)
{
#ifdef ODBCDEBUG
	ODBCLOG("SQLPrepare " PTRFMT "\n", PTRFMTCAST hStmt);
#endif

	if (!isValidStmt((ODBCStmt *) hStmt))
		return SQL_INVALID_HANDLE;

	clearStmtErrors((ODBCStmt *) hStmt);

	return SQLPrepare_((ODBCStmt *) hStmt, szSqlStr, nSqlStrLength);
}

#ifdef WITH_WCHAR
SQLRETURN SQL_API
SQLPrepareA(SQLHSTMT hStmt, SQLCHAR *szSqlStr, SQLINTEGER nSqlStrLength)
{
	return SQLPrepare(hStmt, szSqlStr, nSqlStrLength);
}

SQLRETURN SQL_API
SQLPrepareW(SQLHSTMT hStmt, SQLWCHAR * szSqlStr, SQLINTEGER nSqlStrLength)
{
	ODBCStmt *stmt = (ODBCStmt *) hStmt;
	SQLCHAR *sql;
	SQLRETURN rc;

#ifdef ODBCDEBUG
	ODBCLOG("SQLPrepareW " PTRFMT "\n", PTRFMTCAST hStmt);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	fixWcharIn(szSqlStr, nSqlStrLength, sql, addStmtError, stmt, return SQL_ERROR);

	rc = SQLPrepare_(stmt, sql, SQL_NTS);

	if (sql)
		free(sql);

	return rc;
}
#endif /* WITH_WCHAR */
