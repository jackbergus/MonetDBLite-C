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

/*
 * This code was created by Peter Harvey (mostly during Christmas 98/99).
 * This code is LGPL. Please ensure that this message remains in future
 * distributions and uses of this code (thats about all I get out of it).
 * - Peter Harvey pharvey@codebydesign.com
 *
 * This file has been modified for the MonetDB project.  See the file
 * Copyright in this directory for more information.
 */

/*****************************************************************************
 * SQLFetchScroll()
 * CLI Compliance: ISO 92
 *
 * Note: this function is not supported (yet), it returns an error.
 *
 * Author: Martin van Dinther, Sjoerd Mullender
 * Date  : 30 aug 2002
 *
 *****************************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"


SQLRETURN
SQLFetchScroll_(ODBCStmt *stmt,
		SQLSMALLINT FetchOrientation,
		SQLLEN FetchOffset)
{
	assert(stmt->hdl);

	if ((stmt->cursorType == SQL_CURSOR_FORWARD_ONLY ||
	     stmt->cursorScrollable == SQL_NONSCROLLABLE) &&
	    FetchOrientation != SQL_FETCH_NEXT) {
		/* Fetch type out of range */
		addStmtError(stmt, "HY106", NULL, 0);
		return SQL_ERROR;
	}
#define RowSetSize	(stmt->ApplRowDescr->sql_desc_array_size)

	assert(stmt->startRow >= 0);
	switch (FetchOrientation) {
	case SQL_FETCH_NEXT:
		stmt->startRow += stmt->rowSetSize;
		break;
	case SQL_FETCH_FIRST:
		stmt->startRow = 0;
		break;
	case SQL_FETCH_LAST:
		if (stmt->rowcount < RowSetSize)
			stmt->startRow = 0;
		else
			stmt->startRow = stmt->rowcount - RowSetSize;
		break;
	case SQL_FETCH_PRIOR:
		if (stmt->startRow == 0) {
			/* before start */
			stmt->startRow = 0;
			stmt->rowSetSize = 0;
			stmt->State = FETCHED;
			return SQL_NO_DATA;
		}
		if (stmt->startRow < (SQLLEN) RowSetSize) {
			/* Attempt to fetch before the result set
			 * returned the first rowset */
			addStmtError(stmt, "01S06", NULL, 0);
			stmt->startRow = 0;
		} else
			stmt->startRow = stmt->startRow - RowSetSize;
		break;
	case SQL_FETCH_RELATIVE:
		if ((stmt->startRow > 0 || stmt->rowSetSize > 0 ||
		     FetchOffset <= 0) &&
		    ((SQLULEN) stmt->startRow < stmt->rowcount ||
		     FetchOffset >= 0)) {
			if ((stmt->startRow == 0 && stmt->rowSetSize == 0 &&
			     FetchOffset <= 0) ||
			    (stmt->startRow == 0 && stmt->rowSetSize > 0 &&
			     FetchOffset < 0) ||
			    (stmt->startRow > 0 &&
			     stmt->startRow + FetchOffset < 1 &&
			     (FetchOffset > (SQLLEN) RowSetSize ||
			      -FetchOffset > (SQLLEN) RowSetSize))) {
				/* before start */
				stmt->startRow = 0;
				stmt->rowSetSize = 0;
				stmt->State = FETCHED;
				return SQL_NO_DATA;
			}
			if (stmt->startRow > 0 &&
			    stmt->startRow + FetchOffset < 1 &&
			    FetchOffset <= (SQLLEN) RowSetSize &&
			    -FetchOffset <= (SQLLEN) RowSetSize) {
				/* Attempt to fetch before the result
				 * set returned the first rowset */
				addStmtError(stmt, "01S06", NULL, 0);
				stmt->startRow = 0;
				break;
			}
			if (stmt->startRow + FetchOffset >= 0 &&
			    stmt->startRow + FetchOffset < (SQLLEN) stmt->rowcount) {
				stmt->startRow += FetchOffset;
				break;
			}
			if (stmt->startRow + FetchOffset >= (SQLLEN) stmt->rowcount ||
			    (stmt->startRow >= (SQLLEN) stmt->rowcount &&
			     FetchOffset >= 0)) {
				/* after end */
				stmt->startRow = stmt->rowcount;
				stmt->rowSetSize = 0;
				stmt->State = FETCHED;
				return SQL_NO_DATA;
			}
			/* all bases should have been covered above */
			assert(0);
		}
		/* fall through */
	case SQL_FETCH_ABSOLUTE:
		if (FetchOffset < 0) {
			if ((unsigned int) -FetchOffset <= stmt->rowcount) {
				stmt->startRow = stmt->rowcount + FetchOffset;
				break;
			}
			stmt->startRow = 0;
			if ((unsigned int) -FetchOffset > RowSetSize) {
				/* before start */
				stmt->State = FETCHED;
				stmt->rowSetSize = 0;
				return SQL_NO_DATA;
			}
			/* Attempt to fetch before the result set
			   returned the first rowset */
			addStmtError(stmt, "01S06", NULL, 0);
			break;
		}
		if (FetchOffset == 0) {
			/* before start */
			stmt->startRow = 0;
			stmt->rowSetSize = 0;
			stmt->State = FETCHED;
			return SQL_NO_DATA;
		}
		if ((SQLULEN) FetchOffset > stmt->rowcount) {
			/* after end */
			stmt->startRow = stmt->rowcount;
			stmt->rowSetSize = 0;
			stmt->State = FETCHED;
			return SQL_NO_DATA;
		}
		stmt->startRow = FetchOffset - 1;
		break;
	case SQL_FETCH_BOOKMARK:
		/* Optional feature not implemented */
		addStmtError(stmt, "HYC00", NULL, 0);
		return SQL_ERROR;
	default:
		/* Fetch type out of range */
		addStmtError(stmt, "HY106", NULL, 0);
		return SQL_ERROR;
	}

	return SQLFetch_(stmt);
}

SQLRETURN SQL_API
SQLFetchScroll(SQLHSTMT StatementHandle,
	       SQLSMALLINT FetchOrientation,
	       SQLLEN FetchOffset)
{
	ODBCStmt *stmt = (ODBCStmt *) StatementHandle;

#ifdef ODBCDEBUG
	ODBCLOG("SQLFetchScroll " PTRFMT " %s " LENFMT "\n",
		PTRFMTCAST StatementHandle,
		translateFetchOrientation(FetchOrientation),
		LENCAST FetchOffset);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	/* check statement cursor state, query should be executed */
	if (stmt->State < EXECUTED0 || stmt->State == EXTENDEDFETCHED) {
		/* Function sequence error */
		addStmtError(stmt, "HY010", NULL, 0);
		return SQL_ERROR;
	}
	if (stmt->State == EXECUTED0) {
		/* Invalid cursor state */
		addStmtError(stmt, "24000", NULL, 0);
		return SQL_ERROR;
	}

	return SQLFetchScroll_(stmt, FetchOrientation, FetchOffset);
}
