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

/**********************************************************************
 * SQLGetConnectOption()
 * CLI Compliance: deprecated in ODBC 3.0 (replaced by SQLGetConnectAttr())
 * Provided here for old (pre ODBC 3.0) applications and driver managers.
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCDbc.h"
#include "ODBCUtil.h"

static SQLRETURN
SQLGetConnectOption_(ODBCDbc *dbc,
		     SQLUSMALLINT Option,
		     SQLPOINTER ValuePtr)
{
	/* use mapping as described in ODBC 3 SDK Help file */
	switch (Option) {
		/* connection attributes (ODBC 1 and 2 only) */
	case SQL_ACCESS_MODE:
	case SQL_AUTOCOMMIT:
	case SQL_LOGIN_TIMEOUT:
	case SQL_ODBC_CURSORS:
	case SQL_OPT_TRACE:
	case SQL_PACKET_SIZE:
	case SQL_TRANSLATE_OPTION:
	case SQL_TXN_ISOLATION:
		/* 32 bit integer argument */
		return SQLGetConnectAttr_(dbc, Option, ValuePtr, 0, NULL);
	case SQL_QUIET_MODE:
		/* 32/64 bit integer argument */
		return SQLGetConnectAttr_(dbc, Option, ValuePtr, 0, NULL);
	case SQL_CURRENT_QUALIFIER:
	case SQL_OPT_TRACEFILE:
	case SQL_TRANSLATE_DLL:
		/* null terminated string argument */
		return SQLGetConnectAttr_(dbc, Option, ValuePtr,
					  SQL_MAX_OPTION_STRING_LENGTH, NULL);
	default:
		/* Invalid attribute/option identifier */
		addDbcError(dbc, "HY092", NULL, 0);
		break;
	}

	return SQL_ERROR;
}

SQLRETURN SQL_API
SQLGetConnectOption(SQLHDBC ConnectionHandle,
		    SQLUSMALLINT Option,
		    SQLPOINTER ValuePtr)
{
	ODBCDbc *dbc = (ODBCDbc *) ConnectionHandle;

#ifdef ODBCDEBUG
	ODBCLOG("SQLGetConnectOption " PTRFMT " %s\n",
		PTRFMTCAST ConnectionHandle, translateConnectOption(Option));
#endif

	if (!isValidDbc(dbc))
		return SQL_INVALID_HANDLE;
	clearDbcErrors(dbc);

	return SQLGetConnectOption_(dbc, Option, ValuePtr);
}

SQLRETURN SQL_API
SQLGetConnectOptionA(SQLHDBC ConnectionHandle,
		     SQLUSMALLINT Option,
		     SQLPOINTER ValuePtr)
{
	return SQLGetConnectOption(ConnectionHandle, Option, ValuePtr);
}

SQLRETURN SQL_API
SQLGetConnectOptionW(SQLHDBC ConnectionHandle,
		     SQLUSMALLINT Option,
		     SQLPOINTER ValuePtr)
{
	ODBCDbc *dbc = (ODBCDbc *) ConnectionHandle;
	SQLRETURN rc;
	SQLPOINTER ptr;

#ifdef ODBCDEBUG
	ODBCLOG("SQLGetConnectOptionW " PTRFMT " %s\n",
		PTRFMTCAST ConnectionHandle, translateConnectOption(Option));
#endif

	if (!isValidDbc(dbc))
		return SQL_INVALID_HANDLE;

	clearDbcErrors(dbc);

	switch (Option) {
	/* all string attributes */
	case SQL_CURRENT_QUALIFIER:
	case SQL_OPT_TRACEFILE:
	case SQL_TRANSLATE_DLL:
		ptr = (SQLPOINTER) malloc(SQL_MAX_OPTION_STRING_LENGTH);
		break;
	default:
		ptr = ValuePtr;
		break;
	}

	rc = SQLGetConnectOption_(dbc, Option, ptr);

	if (ptr != ValuePtr) {
		if (SQL_SUCCEEDED(rc)) {
			SQLSMALLINT n = (SQLSMALLINT) strlen((char *) ptr);
			SQLSMALLINT *nullp = NULL;

			fixWcharOut(rc, ptr, n, ValuePtr,
				    SQL_MAX_OPTION_STRING_LENGTH, nullp, 2,
				    addDbcError, dbc);
		}
		free(ptr);
	}

	return rc;
}
