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
 * Portions created by CWI are Copyright (C) 1997-2008 CWI.
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
 * SQLGetConnectAttr()
 * CLI Compliance: ISO 92
 *
 * Author: Martin van Dinther
 * Date  : 30 aug 2002
 *
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCDbc.h"
#include "ODBCUtil.h"


SQLRETURN
SQLGetConnectAttr_(ODBCDbc *dbc, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER BufferLength, SQLINTEGER *StringLength)
{
	/* check input parameters */
	if (ValuePtr == NULL) {
		/* Invalid use of null pointer */
		addDbcError(dbc, "HY009", NULL, 0);
		return SQL_ERROR;
	}

	switch (Attribute) {
	case SQL_ATTR_ACCESS_MODE:
		*(SQLUINTEGER *) ValuePtr = SQL_MODE_READ_WRITE;
		break;
	case SQL_ATTR_ASYNC_ENABLE:
		*(SQLUINTEGER *) ValuePtr = SQL_ASYNC_ENABLE_OFF;
		break;
	case SQL_ATTR_AUTO_IPD:
		/* TODO implement automatic filling of IPD
		   See also SQLSetStmtAttr.c for SQL_ATTR_ENABLE_AUTO_IPD
		 */
		*(SQLUINTEGER *) ValuePtr = SQL_FALSE;
		break;
	case SQL_ATTR_AUTOCOMMIT:
		*(SQLUINTEGER *) ValuePtr = dbc->sql_attr_autocommit;
		break;
	case SQL_ATTR_CONNECTION_DEAD:
		*(SQLUINTEGER *) ValuePtr = dbc->mid && mapi_is_connected(dbc->mid) ? SQL_CD_FALSE : SQL_CD_TRUE;
		break;
	case SQL_ATTR_CONNECTION_TIMEOUT:
		*(SQLUINTEGER *) ValuePtr = 0;	/* no timeout */
		break;
	case SQL_ATTR_LOGIN_TIMEOUT:
		*(SQLUINTEGER *) ValuePtr = 0;	/* no timeout */
		break;
	case SQL_ATTR_METADATA_ID:
		*(SQLUINTEGER *) ValuePtr = SQL_FALSE;
		break;
	case SQL_ATTR_ODBC_CURSORS:
		*(SQLUINTEGER *) ValuePtr = SQL_CUR_USE_IF_NEEDED;
		break;
	case SQL_ATTR_TRACE:
		*(SQLUINTEGER *) ValuePtr = SQL_OPT_TRACE_OFF;
		break;
	case SQL_ATTR_CURRENT_CATALOG:
		copyString(dbc->dbname, ValuePtr, BufferLength, StringLength, SQLINTEGER, addDbcError, dbc);
		break;

/* TODO: implement all the other Connection Attributes */
	case SQL_ATTR_DISCONNECT_BEHAVIOR:
	case SQL_ATTR_ENLIST_IN_DTC:
	case SQL_ATTR_ENLIST_IN_XA:
	case SQL_ATTR_PACKET_SIZE:
	case SQL_ATTR_QUIET_MODE:
	case SQL_ATTR_TRACEFILE:
	case SQL_ATTR_TRANSLATE_LIB:
	case SQL_ATTR_TRANSLATE_OPTION:
	case SQL_ATTR_TXN_ISOLATION:
		/* Optional feature not implemented */
		addDbcError(dbc, "HYC00", NULL, 0);
		return SQL_ERROR;
	default:
		/* Invalid attribute/option identifier */
		addDbcError(dbc, "HY092", NULL, 0);
		return SQL_ERROR;
	}

	return dbc->Error ? SQL_SUCCESS_WITH_INFO : SQL_SUCCESS;
}

SQLRETURN SQL_API
SQLGetConnectAttr(SQLHDBC hDbc, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER BufferLength, SQLINTEGER *StringLength)
{
#ifdef ODBCDEBUG
	ODBCLOG("SQLGetConnectAttr " PTRFMT " %d\n", PTRFMTCAST hDbc, Attribute);
#endif

	if (!isValidDbc((ODBCDbc *) hDbc))
		return SQL_INVALID_HANDLE;

	clearDbcErrors((ODBCDbc *) hDbc);

	return SQLGetConnectAttr_((ODBCDbc *) hDbc, Attribute, ValuePtr, BufferLength, StringLength);
}

#ifdef WITH_WCHAR
SQLRETURN SQL_API
SQLGetConnectAttrA(SQLHDBC hDbc, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER BufferLength, SQLINTEGER *StringLength)
{
	return SQLGetConnectAttr(hDbc, Attribute, ValuePtr, BufferLength, StringLength);
}

SQLRETURN SQL_API
SQLGetConnectAttrW(SQLHDBC hDbc, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER BufferLength, SQLINTEGER *StringLength)
{
	ODBCDbc *dbc = (ODBCDbc *) hDbc;
	SQLRETURN rc;
	SQLPOINTER ptr;
	SQLINTEGER n;

#ifdef ODBCDEBUG
	ODBCLOG("SQLGetConnectAttrW " PTRFMT " %d\n", PTRFMTCAST hDbc, Attribute);
#endif

	if (!isValidDbc(dbc))
		return SQL_INVALID_HANDLE;

	clearDbcErrors(dbc);

	switch (Attribute) {
		/* all string attributes */
	case SQL_ATTR_CURRENT_CATALOG:
		n = BufferLength * 4;
		ptr = (SQLPOINTER) malloc(n);
		break;
	default:
		n = BufferLength;
		ptr = ValuePtr;
		break;
	}

	rc = SQLGetConnectAttr_(dbc, Attribute, ptr, n, &n);

	if (ptr !=ValuePtr) {
		SQLSMALLINT nn = (SQLSMALLINT) n;

		fixWcharOut(rc, ptr, nn, ValuePtr, BufferLength, StringLength, 2, addDbcError, dbc);
	} else if (StringLength)
		*StringLength = n;

	return rc;
}
#endif /* WITH_WCHAR */
