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
 * Copyright August 2008-2009 MonetDB B.V.
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
 * SQLTables()
 * CLI Compliance: X/Open
 *
 * Author: Martin van Dinther
 * Date  : 30 aug 2002
 *
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"
#include "ODBCUtil.h"


static SQLRETURN
SQLTables_(ODBCStmt *stmt,
	   SQLCHAR *szCatalogName, SQLSMALLINT nCatalogNameLength,
	   SQLCHAR *szSchemaName, SQLSMALLINT nSchemaNameLength,
	   SQLCHAR *szTableName, SQLSMALLINT nTableNameLength,
	   SQLCHAR *szTableType, SQLSMALLINT nTableTypeLength)
{
	RETCODE rc;

	/* buffer for the constructed query to do meta data retrieval */
	char *query = NULL;

	/* convert input string parameters to normal null terminated C strings */
	fixODBCstring(szCatalogName, nCatalogNameLength, SQLSMALLINT, addStmtError, stmt, return SQL_ERROR);
	fixODBCstring(szSchemaName, nSchemaNameLength, SQLSMALLINT, addStmtError, stmt, return SQL_ERROR);
	fixODBCstring(szTableName, nTableNameLength, SQLSMALLINT, addStmtError, stmt, return SQL_ERROR);
	fixODBCstring(szTableType, nTableTypeLength, SQLSMALLINT, addStmtError, stmt, return SQL_ERROR);

#ifdef ODBCDEBUG
	ODBCLOG("\"%.*s\" \"%.*s\" \"%.*s\" \"%.*s\"\n",
		nCatalogNameLength, szCatalogName ? (char *) szCatalogName : "",
		nSchemaNameLength, szSchemaName ? (char *) szSchemaName : "",
		nTableNameLength, szTableName ? (char *) szTableName : "",
		nTableTypeLength, szTableType ? (char *) szTableType : "");
#endif

	/* SQLTables returns a table with the following columns:
	   VARCHAR      table_cat
	   VARCHAR      table_schem
	   VARCHAR      table_name
	   VARCHAR      table_type
	   VARCHAR      remarks
	 */

	/* Check first on the special cases */
	if (nSchemaNameLength == 0 &&
	    nTableNameLength == 0 &&
	    szCatalogName &&
	    strcmp((char *) szCatalogName, SQL_ALL_CATALOGS) == 0) {
		/* Special case query to fetch all Catalog names. */
		/* Note: Catalogs are not supported so the result set
		   will be empty. */
		query = strdup("select "
			       "cast('' as varchar(1)) as table_cat, "
			       "cast('' as varchar(1)) as table_schem, "
			       "cast('' as varchar(1)) as table_name, "
			       "cast('' as varchar(1)) as table_type, "
			       "cast('' as varchar(1)) as remarks "
			       "where 0 = 1");
	} else if (nCatalogNameLength == 0 &&
		   nTableNameLength == 0 &&
		   szSchemaName &&
		   strcmp((char *) szSchemaName, SQL_ALL_SCHEMAS) == 0) {
		/* Special case query to fetch all Schema names. */
		query = strdup("select cast(null as varchar(1)) as table_cat, "
			       "name as table_schem, "
			       "cast('' as varchar(1)) as table_name, "
			       "cast('' as varchar(1)) as table_type, "
			       "cast('' as varchar(1)) as remarks "
			       "from sys.\"schemas\" order by table_schem");
	} else if (nCatalogNameLength == 0 &&
		   nSchemaNameLength == 0 &&
		   nTableNameLength == 0 &&
		   szTableType &&
		   strcmp((char *) szTableType, SQL_ALL_TABLE_TYPES) == 0) {
		/* Special case query to fetch all Table type names. */
		query = strdup("select distinct "
			       "cast(null as varchar(1)) as table_cat, "
			       "cast('' as varchar(1)) as table_schem, "
			       "cast('' as varchar(1)) as table_name, "
			       "case when t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 0 then cast('TABLE' as varchar(20)) "
			       "when t.\"type\" = 0 and t.\"system\" = true and t.\"temporary\" = 0 then cast('SYSTEM TABLE' as varchar(20)) "
			       "when t.\"type\" = 1 then cast('VIEW' as varchar(20)) "
			       "when t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 1 then cast('LOCAL TEMPORARY' as varchar(20)) "
			       "else cast('INTERNAL TABLE TYPE' as varchar(20)) end as table_type, "
			       "cast('' as varchar(1)) as remarks "
			       "from sys.\"tables\" t order by table_type");
	} else {
		/* no special case argument values */
		char *query_end;

		/* construct the query now */
		query = (char *) malloc(1000 + nSchemaNameLength + nTableNameLength + ((nTableTypeLength + 1) / 5) * 67);
		assert(query);
		query_end = query;

		strcpy(query_end,
		       "select "
		       "cast(null as varchar(1)) as table_cat, "
		       "s.\"name\" as table_schem, "
		       "t.\"name\" as table_name, "
		       "case when t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 0 then cast('TABLE' as varchar(20)) "
		       "when t.\"type\" = 0 and t.\"system\" = true and t.\"temporary\" = 0 then cast('SYSTEM TABLE' as varchar(20)) "
		       "when t.\"type\" = 1 then cast('VIEW' as varchar(20)) "
		       "when t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 1 then cast('LOCAL TEMPORARY' as varchar(20)) "
		       "else cast('INTERNAL TABLE TYPE' as varchar(20)) end as table_type, "
		       "cast('' as varchar(1)) as remarks "
		       "from sys.\"schemas\" s, sys.\"tables\" t "
		       "where s.\"id\" = t.\"schema_id\"");
		query_end += strlen(query_end);

		/* dependent on the input parameter values we must add a
		   variable selection condition dynamically */

		/* Construct the selection condition query part */
		if (nCatalogNameLength > 0) {
			/* filtering requested on catalog name */
			/* we do not support catalog names, so ignore it */
		}

		if (nSchemaNameLength > 0) {
			/* filtering requested on schema name */
			/* use LIKE when it contains a wildcard '%' or a '_' */
			/* TODO: the wildcard may be escaped. Check it
			   and maybe convert it. */
			sprintf(query_end, " and s.\"name\" %s '%.*s'",
				memchr(szSchemaName, '%', nSchemaNameLength) || memchr(szSchemaName, '_', nSchemaNameLength) ? "like" : "=",
				nSchemaNameLength,
				(char*)szSchemaName);
			query_end += strlen(query_end);
		}

		if (nTableNameLength > 0) {
			/* filtering requested on table name */
			/* use LIKE when it contains a wildcard '%' or a '_' */
			/* TODO: the wildcard may be escaped.  Check
			   it and may be convert it. */
			sprintf(query_end, " and t.\"name\" %s '%.*s'",
				memchr(szTableName, '%', nTableNameLength) || memchr(szTableName, '_', nTableNameLength) ? "like" : "=",
				nTableNameLength,
				(char*)szTableName);
			query_end += strlen(query_end);
		}

		if (nTableTypeLength > 0) {
			/* filtering requested on table type */
			char buf[17];	/* the longest string is "GLOBAL TEMPORARY" */
			int i, j;

			strcpy(query_end, " and (1 = 0");
			query_end += strlen(query_end);
			for (i = j = 0; i < nTableTypeLength + 1; i++) {
				if (i == nTableTypeLength || szTableType[i] == ',') {
					if (j > 16 || j == 0) {
						j = 0;
						continue;
					}
					buf[j] = 0;
					if (strcmp(buf, "VIEW") == 0)
						strcpy(query_end, " or t.\"type\" = 1");
					else if (strcmp(buf, "TABLE") == 0)
						strcpy(query_end, " or (t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 0)");
					else if (strcmp(buf, "SYSTEM TABLE") == 0)
						strcpy(query_end, " or (t.\"type\" = 0 and t.\"system\" = true and t.\"temporary\" = 0)");
					else if (strcmp(buf, "LOCAL TEMPORARY") == 0)
						strcpy(query_end, " or (t.\"type\" = 0 and t.\"system\" = false and t.\"temporary\" = 1)");
					query_end += strlen(query_end);
					j = 0;
				} else if (j < 17 && szTableType[i] != '\'' && (j > 0 || szTableType[i] != ' '))
					buf[j++] = szTableType[i];
			}
			strcpy(query_end, ")");
			query_end += strlen(query_end);
		}

		/* add the ordering */
		strcpy(query_end,
		       " order by table_type, table_schem, table_name");
		query_end += strlen(query_end);
		assert(query_end - query < 1000 + nSchemaNameLength + nTableNameLength + nTableTypeLength);
	}

	/* query the MonetDB data dictionary tables */

	rc = SQLExecDirect_(stmt, (SQLCHAR *) query, SQL_NTS);

	free(query);

	return rc;
}

SQLRETURN SQL_API
SQLTables(SQLHSTMT hStmt,
	  SQLCHAR *szCatalogName, SQLSMALLINT nCatalogNameLength,
	  SQLCHAR *szSchemaName, SQLSMALLINT nSchemaNameLength,
	  SQLCHAR *szTableName, SQLSMALLINT nTableNameLength,
	  SQLCHAR *szTableType, SQLSMALLINT nTableTypeLength)
{
	ODBCStmt *stmt = (ODBCStmt *) hStmt;

#ifdef ODBCDEBUG
	ODBCLOG("SQLTables " PTRFMT " ", PTRFMTCAST hStmt);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	return SQLTables_(stmt,
			  szCatalogName, nCatalogNameLength,
			  szSchemaName, nSchemaNameLength,
			  szTableName, nTableNameLength,
			  szTableType, nTableTypeLength);
}

#ifdef WITH_WCHAR
SQLRETURN SQL_API
SQLTablesA(SQLHSTMT hStmt,
	   SQLCHAR *szCatalogName, SQLSMALLINT nCatalogNameLength,
	   SQLCHAR *szSchemaName, SQLSMALLINT nSchemaNameLength,
	   SQLCHAR *szTableName, SQLSMALLINT nTableNameLength,
	   SQLCHAR *szTableType, SQLSMALLINT nTableTypeLength)
{
	return SQLTables(hStmt,
			 szCatalogName, nCatalogNameLength,
			 szSchemaName, nSchemaNameLength,
			 szTableName, nTableNameLength,
			 szTableType, nTableTypeLength);
}

SQLRETURN SQL_API
SQLTablesW(SQLHSTMT hStmt,
	   SQLWCHAR * szCatalogName, SQLSMALLINT nCatalogNameLength,
	   SQLWCHAR * szSchemaName, SQLSMALLINT nSchemaNameLength,
	   SQLWCHAR * szTableName, SQLSMALLINT nTableNameLength,
	   SQLWCHAR * szTableType, SQLSMALLINT nTableTypeLength)
{
	ODBCStmt *stmt = (ODBCStmt *) hStmt;
	SQLRETURN rc = SQL_ERROR;
	SQLCHAR *catalog = NULL, *schema = NULL, *table = NULL, *type = NULL;

#ifdef ODBCDEBUG
	ODBCLOG("SQLTablesW " PTRFMT " ", PTRFMTCAST hStmt);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	fixWcharIn(szCatalogName, nCatalogNameLength, SQLCHAR, catalog, addStmtError, stmt, goto exit);
	fixWcharIn(szSchemaName, nSchemaNameLength, SQLCHAR, schema, addStmtError, stmt, goto exit);
	fixWcharIn(szTableName, nTableNameLength, SQLCHAR, table, addStmtError, stmt, goto exit);
	fixWcharIn(szTableType, nTableTypeLength, SQLCHAR, type, addStmtError, stmt, goto exit);

	rc = SQLTables_(stmt, catalog, SQL_NTS, schema, SQL_NTS, table, SQL_NTS, type, SQL_NTS);

      exit:
	if (catalog)
		free(catalog);
	if (schema)
		free(schema);
	if (table)
		free(table);
	if (type)
		free(type);

	return rc;
}
#endif /* WITH_WCHAR */
