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
 * Copyright August 2008-2010 MonetDB B.V.
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
 * SQLBindCol()
 * CLI Compliance: ISO 92
 *
 * Author: Martin van Dinther
 * Date  : 30 Aug 2002
 *
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"


SQLRETURN SQL_API
SQLBindCol(SQLHSTMT hStmt,
	   SQLUSMALLINT nCol,
	   SQLSMALLINT nTargetType,
	   SQLPOINTER pTargetValue,
	   SQLINTEGER nTargetValueMax,
	   SQLINTEGER *pnLengthOrIndicator)
{
	ODBCStmt *stmt = (ODBCStmt *) hStmt;
	ODBCDesc *desc;		/* Application Row Descriptor */

#ifdef ODBCDEBUG
	ODBCLOG("SQLBindCol " PTRFMT " %d %d %d\n", PTRFMTCAST hStmt, nCol, nTargetType, nTargetValueMax);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	assert(stmt->Dbc);

	clearStmtErrors(stmt);

	/* check input parameters */
	/* column number 0 (Bookmark column) is not supported */
	if (nCol == 0) {
		if (nTargetType == SQL_C_BOOKMARK || nTargetType == SQL_C_VARBOOKMARK) {
			/* Optional feature not implemented */
			addStmtError(stmt, "HYC00", NULL, 0);
		} else {
			/* Restricted data type attribute violation */
			addStmtError(stmt, "07006", NULL, 0);
		}
		return SQL_ERROR;
	}
	if (stmt->State >= EXECUTED1 && nCol > stmt->ImplRowDescr->sql_desc_count) {
		/* Invalid descriptor index */
		addStmtError(stmt, "07009", NULL, 0);
		return SQL_ERROR;
	}

	/* For safety: limit the maximum number of columns to bind */
	if (nCol > MONETDB_MAX_BIND_COLS) {
		/* General error */
		addStmtError(stmt, "HY000", "Maximum number of bind columns (8192) exceeded", 0);
		return SQL_ERROR;
	}

	/* can't let SQLSetDescField below do this check since it
	   returns the wrong error code if the type is incorrect */
	switch (nTargetType) {
	case SQL_C_CHAR:
	case SQL_C_WCHAR:
	case SQL_C_BINARY:
	case SQL_C_BIT:
	case SQL_C_STINYINT:
	case SQL_C_UTINYINT:
	case SQL_C_TINYINT:
	case SQL_C_SSHORT:
	case SQL_C_USHORT:
	case SQL_C_SHORT:
	case SQL_C_SLONG:
	case SQL_C_ULONG:
	case SQL_C_LONG:
	case SQL_C_SBIGINT:
	case SQL_C_UBIGINT:
	case SQL_C_NUMERIC:
	case SQL_C_FLOAT:
	case SQL_C_DOUBLE:
	case SQL_C_TYPE_DATE:
	case SQL_C_TYPE_TIME:
	case SQL_C_TYPE_TIMESTAMP:
	case SQL_C_INTERVAL_YEAR:
	case SQL_C_INTERVAL_MONTH:
	case SQL_C_INTERVAL_YEAR_TO_MONTH:
	case SQL_C_INTERVAL_DAY:
	case SQL_C_INTERVAL_HOUR:
	case SQL_C_INTERVAL_MINUTE:
	case SQL_C_INTERVAL_SECOND:
	case SQL_C_INTERVAL_DAY_TO_HOUR:
	case SQL_C_INTERVAL_DAY_TO_MINUTE:
	case SQL_C_INTERVAL_DAY_TO_SECOND:
	case SQL_C_INTERVAL_HOUR_TO_MINUTE:
	case SQL_C_INTERVAL_HOUR_TO_SECOND:
	case SQL_C_INTERVAL_MINUTE_TO_SECOND:
	case SQL_C_GUID:
	case SQL_C_DEFAULT:
		break;
	default:
		/* Invalid application buffer type */
		addStmtError(stmt, "HY003", NULL, 0);
		return SQL_ERROR;
	}

	if (nTargetValueMax < 0) {
		/* Invalid string or buffer length */
		addStmtError(stmt, "HY090", NULL, 0);
		return SQL_ERROR;
	}

	desc = stmt->ApplRowDescr;

	if (pTargetValue == NULL && nCol == desc->sql_desc_count) {
		int i = desc->sql_desc_count - 1;

		while (i > 0 && desc->descRec[i].sql_desc_data_ptr == NULL)
			i--;
		setODBCDescRecCount(desc, i);
	} else {
		ODBCDescRec *rec;
		SQLRETURN rc;

		if (nCol > desc->sql_desc_count)
			setODBCDescRecCount(desc, nCol);
		rc = SQLSetDescField_(desc, nCol, SQL_DESC_CONCISE_TYPE, (SQLPOINTER) (ssize_t) nTargetType, 0);
		if (!SQL_SUCCEEDED(rc))
			return rc;
		rec = &desc->descRec[nCol];
		rec->sql_desc_octet_length = nTargetValueMax;
		rec->sql_desc_data_ptr = pTargetValue;
		rec->sql_desc_indicator_ptr = pnLengthOrIndicator;
		rec->sql_desc_octet_length_ptr = pnLengthOrIndicator;
	}

	return SQL_SUCCESS;
}
