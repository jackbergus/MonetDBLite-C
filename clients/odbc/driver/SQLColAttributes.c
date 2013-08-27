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
 * SQLColAttributes()
 * CLI Compliance: deprecated in ODBC 3.0 (replaced by SQLColAttribute())
 * Provided here for old (pre ODBC 3.0) applications and driver managers.
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"
#include "ODBCUtil.h"

static SQLRETURN
SQLColAttributes_(ODBCStmt *stmt,
		  SQLUSMALLINT ColumnNumber,
		  SQLUSMALLINT FieldIdentifier,
		  SQLPOINTER CharacterAttributePtr,
		  SQLSMALLINT BufferLength,
		  SQLSMALLINT *StringLengthPtr,
		  SQLLEN *NumericAttributePtr)
{
	SQLRETURN rc;
	SQLLEN value;

	/* use mapping as described in ODBC 3 SDK Help file */
	switch (FieldIdentifier) {
	case SQL_COLUMN_NAME:
		FieldIdentifier = SQL_DESC_NAME;
		break;
	case SQL_COLUMN_NULLABLE:
		FieldIdentifier = SQL_DESC_NULLABLE;
		break;
	case SQL_COLUMN_COUNT:
		FieldIdentifier = SQL_DESC_COUNT;
		break;
	}
	rc = SQLColAttribute_(stmt, ColumnNumber, FieldIdentifier, CharacterAttributePtr, BufferLength, StringLengthPtr, &value);

	/* TODO: implement special semantics for FieldIdentifiers:
	 * SQL_COLUMN_TYPE, SQL_COLUMN_NAME, SQL_COLUMN_NULLABLE and
	 * SQL_COLUMN_COUNT.  See ODBC 3 SDK Help file,
	 * SQLColAttributes Mapping. */
/*
	if (FieldIdentifier == SQL_COLUMN_TYPE && value == concise datetime type) {
		map return value for date, time, and timestamp codes;
	}
*/
	if (NumericAttributePtr)
		*NumericAttributePtr = value;
	return rc;
}

SQLRETURN SQL_API
SQLColAttributes(SQLHSTMT StatementHandle,
		 SQLUSMALLINT ColumnNumber,
		 SQLUSMALLINT FieldIdentifier,
		 SQLPOINTER CharacterAttributePtr,
		 SQLSMALLINT BufferLength,
		 SQLSMALLINT *StringLengthPtr,
		 SQLLEN *NumericAttributePtr)
{
	ODBCStmt *stmt = (ODBCStmt *) StatementHandle;

#ifdef ODBCDEBUG
	ODBCLOG("SQLColAttributes " PTRFMT " %u %s\n",
		PTRFMTCAST StatementHandle,
		(unsigned int) ColumnNumber,
		translateFieldIdentifier(FieldIdentifier));
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	return SQLColAttributes_(stmt,
				 ColumnNumber,
				 FieldIdentifier,
				 CharacterAttributePtr,
				 BufferLength,
				 StringLengthPtr,
				 NumericAttributePtr);
}

SQLRETURN SQL_API
SQLColAttributesA(SQLHSTMT StatementHandle,
		  SQLUSMALLINT ColumnNumber,
		  SQLUSMALLINT FieldIdentifier,
		  SQLPOINTER CharacterAttributePtr,
		  SQLSMALLINT BufferLength,
		  SQLSMALLINT *StringLengthPtr,
		  SQLLEN *NumericAttributePtr)
{
	return SQLColAttributes(StatementHandle,
				ColumnNumber,
				FieldIdentifier,
				CharacterAttributePtr,
				BufferLength,
				StringLengthPtr,
				NumericAttributePtr);
}

SQLRETURN SQL_API
SQLColAttributesW(SQLHSTMT StatementHandle,
		  SQLUSMALLINT ColumnNumber,
		  SQLUSMALLINT FieldIdentifier,
		  SQLPOINTER CharacterAttributePtr,
		  SQLSMALLINT BufferLength,
		  SQLSMALLINT *StringLengthPtr,
		  SQLLEN *NumericAttributePtr)
{
	ODBCStmt *stmt = (ODBCStmt *) StatementHandle;
	SQLPOINTER ptr;
	SQLRETURN rc;
	SQLSMALLINT n;

#ifdef ODBCDEBUG
	ODBCLOG("SQLColAttributesW " PTRFMT " %u %s\n",
		PTRFMTCAST StatementHandle,
		(unsigned int) ColumnNumber,
		translateFieldIdentifier(FieldIdentifier));
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	switch (FieldIdentifier) {
	/* all string atributes */
	case SQL_DESC_BASE_COLUMN_NAME:
	case SQL_DESC_BASE_TABLE_NAME:
	case SQL_DESC_CATALOG_NAME:	/* SQL_COLUMN_QUALIFIER_NAME */
	case SQL_DESC_LABEL:		/* SQL_COLUMN_LABEL */
	case SQL_DESC_LITERAL_PREFIX:
	case SQL_DESC_LITERAL_SUFFIX:
	case SQL_DESC_LOCAL_TYPE_NAME:
	case SQL_DESC_NAME:
	case SQL_DESC_SCHEMA_NAME:	/* SQL_COLUMN_OWNER_NAME */
	case SQL_DESC_TABLE_NAME:	/* SQL_COLUMN_TABLE_NAME */
	case SQL_DESC_TYPE_NAME:	/* SQL_COLUMN_TYPE_NAME */
		rc = SQLColAttributes_(stmt, ColumnNumber, FieldIdentifier,
				       NULL, 0, &n, NumericAttributePtr);
		if (!SQL_SUCCEEDED(rc))
			return rc;
		clearStmtErrors(stmt);
		n++;		/* account for NUL byte */
		ptr = (SQLPOINTER) malloc(n);
		break;
	default:
		n = BufferLength;
		ptr = CharacterAttributePtr;
		break;
	}

	rc = SQLColAttributes_(stmt, ColumnNumber, FieldIdentifier, ptr,
			       n, &n, NumericAttributePtr);

	if (ptr != CharacterAttributePtr) {
		if (SQL_SUCCEEDED(rc)) {
			fixWcharOut(rc, ptr, n, CharacterAttributePtr,
				    BufferLength, StringLengthPtr, 2,
				    addStmtError, stmt);
		}
		free(ptr);
	} else if (StringLengthPtr)
		*StringLengthPtr = n;

	return rc;
}
