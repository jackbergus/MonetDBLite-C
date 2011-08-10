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
 * Copyright August 2008-2011 MonetDB B.V.
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
 * SQLStatistics()
 * CLI Compliance: ISO 92
 *
 * Note: catalogs are not supported, we ignore any value set for
 * szCatalogName.
 *
 * Author: Martin van Dinther, Sjoerd Mullender
 * Date  : 30 aug 2002
 *
 **********************************************************************/

#include "ODBCGlobal.h"
#include "ODBCStmt.h"
#include "ODBCUtil.h"


static SQLRETURN
SQLStatistics_(ODBCStmt *stmt,
	       SQLCHAR *CatalogName,
	       SQLSMALLINT NameLength1,
	       SQLCHAR *SchemaName,
	       SQLSMALLINT NameLength2,
	       SQLCHAR *TableName,
	       SQLSMALLINT NameLength3,
	       SQLUSMALLINT Unique,
	       SQLUSMALLINT Reserved)
{
	RETCODE rc;

	/* buffer for the constructed query to do meta data retrieval */
	char *query = NULL;
	char *query_end = NULL;

	fixODBCstring(TableName, NameLength3, SQLSMALLINT,
		      addStmtError, stmt, return SQL_ERROR);
	fixODBCstring(SchemaName, NameLength2, SQLSMALLINT,
		      addStmtError, stmt, return SQL_ERROR);
	fixODBCstring(CatalogName, NameLength1, SQLSMALLINT,
		      addStmtError, stmt, return SQL_ERROR);

#ifdef ODBCDEBUG
	ODBCLOG("\"%.*s\" \"%.*s\" \"%.*s\" %u %u\n",
		(int) NameLength1, (char *) CatalogName,
		(int) NameLength2, (char *) SchemaName,
		(int) NameLength3, (char *) TableName,
		(unsigned int) Unique, (unsigned int) Reserved);
#endif

	/* check for valid Unique argument */
	switch (Unique) {
	case SQL_INDEX_ALL:
	case SQL_INDEX_UNIQUE:
		break;
	default:
		/* Uniqueness option type out of range */
		addStmtError(stmt, "HY100", NULL, 0);
		return SQL_ERROR;
	}

	/* check for valid Reserved argument */
	switch (Reserved) {
	case SQL_ENSURE:
	case SQL_QUICK:
		break;
	default:
		/* Accuracy option type out of range */
		addStmtError(stmt, "HY101", NULL, 0);
		return SQL_ERROR;
	}


	/* check if a valid (non null, not empty) table name is supplied */
	if (TableName == NULL) {
		/* Invalid use of null pointer */
		addStmtError(stmt, "HY009", NULL, 0);
		return SQL_ERROR;
	}
	if (NameLength3 == 0) {
		/* Invalid string or buffer length */
		addStmtError(stmt, "HY090", NULL, 0);
		return SQL_ERROR;
	}

	/* construct the query now */
	query = (char *) malloc(1200 + NameLength3 + NameLength2);
	assert(query);
	query_end = query;

	/* SQLStatistics returns a table with the following columns:
	   VARCHAR      table_cat
	   VARCHAR      table_schem
	   VARCHAR      table_name NOT NULL
	   SMALLINT     non_unique
	   VARCHAR      index_qualifier
	   VARCHAR      index_name
	   SMALLINT     type NOT NULL
	   SMALLINT     ordinal_position
	   VARCHAR      column_name
	   CHAR(1)      asc_or_desc
	   INTEGER      cardinality
	   INTEGER      pages
	   VARCHAR      filter_condition
	 */
	/* TODO: finish the SQL query */
	sprintf(query_end,
		"select "
		"cast(null as varchar(1)) as table_cat, "
		"s.\"name\" as table_schem, "
		"t.\"name\" as table_name, "
		"case when k.\"name\" is null then cast(1 as smallint) "
		"else cast(0 as smallint) end as non_unique, "
		"cast(null as varchar(1)) as index_qualifier, "
		"i.\"name\" as index_name, "
		"case i.\"type\" when 0 then cast(%d as smallint) "
		"else cast(%d as smallint) end as type, "
		"cast(kc.\"nr\" as smallint) as ordinal_position, "
		"c.\"name\" as column_name, "
		"cast(null as char(1)) as asc_or_desc, "
		"cast(null as integer) as cardinality, "
		"cast(null as integer) as pages, "
		"cast(null as varchar(1)) as filter_condition "
		"from sys.\"idxs\" i, sys.\"schemas\" s, sys.\"tables\" t, "
		"sys.\"columns\" c,  sys.\"objects\" kc, sys.\"keys\" k "
		"where i.\"table_id\" = t.\"id\" and "
		"t.\"schema_id\" = s.\"id\" and "
		"i.\"id\" = kc.\"id\" and "
		"t.\"id\" = c.\"table_id\" and "
		"kc.\"name\" = c.\"name\" and "
		"(k.\"type\" is null or k.\"type\" = 1)",
		SQL_INDEX_HASHED, SQL_INDEX_OTHER);
	query_end += strlen(query_end);

	/* Construct the selection condition query part */
	/* search pattern is not allowed for table name so use = and not LIKE */
	sprintf(query_end, " and t.\"name\" = '%.*s'",
		NameLength3, (char*)TableName);
	query_end += strlen(query_end);

	if (SchemaName != NULL) {
		/* filtering requested on schema name */
		/* search pattern is not allowed so use = and not LIKE */
		sprintf(query_end, " and s.\"name\" = '%.*s'",
			NameLength2, (char*)SchemaName);
		query_end += strlen(query_end);
	}

	/* add the ordering */
	strcpy(query_end,
	       " order by non_unique, type, index_qualifier, index_name, "
	       "ordinal_position");
	query_end += strlen(query_end);
	assert(query_end - query < 1200 + NameLength3 + NameLength2);

	/* query the MonetDB data dictionary tables */
	rc = SQLExecDirect_(stmt,
			    (SQLCHAR *) query,
			    (SQLINTEGER) (query_end - query));

	free(query);

	return rc;
}

SQLRETURN SQL_API
SQLStatistics(SQLHSTMT StatementHandle,
	      SQLCHAR *CatalogName,
	      SQLSMALLINT NameLength1,
	      SQLCHAR *SchemaName,
	      SQLSMALLINT NameLength2,
	      SQLCHAR *TableName,
	      SQLSMALLINT NameLength3,
	      SQLUSMALLINT Unique,
	      SQLUSMALLINT Reserved)
{
	ODBCStmt *stmt = (ODBCStmt *) StatementHandle;

#ifdef ODBCDEBUG
	ODBCLOG("SQLStatistics " PTRFMT " ", PTRFMTCAST StatementHandle);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	return SQLStatistics_(stmt,
			      CatalogName, NameLength1,
			      SchemaName, NameLength2,
			      TableName, NameLength3,
			      Unique,
			      Reserved);
}

#ifdef WITH_WCHAR
SQLRETURN SQL_API
SQLStatisticsA(SQLHSTMT StatementHandle,
	       SQLCHAR *CatalogName,
	       SQLSMALLINT NameLength1,
	       SQLCHAR *SchemaName,
	       SQLSMALLINT NameLength2,
	       SQLCHAR *TableName,
	       SQLSMALLINT NameLength3,
	       SQLUSMALLINT Unique,
	       SQLUSMALLINT Reserved)
{
	return SQLStatistics(StatementHandle,
			     CatalogName, NameLength1,
			     SchemaName, NameLength2,
			     TableName, NameLength3,
			     Unique,
			     Reserved);
}

SQLRETURN SQL_API
SQLStatisticsW(SQLHSTMT StatementHandle,
	       SQLWCHAR *CatalogName,
	       SQLSMALLINT NameLength1,
	       SQLWCHAR *SchemaName,
	       SQLSMALLINT NameLength2,
	       SQLWCHAR *TableName,
	       SQLSMALLINT NameLength3,
	       SQLUSMALLINT Unique,
	       SQLUSMALLINT Reserved)
{
	ODBCStmt *stmt = (ODBCStmt *) StatementHandle;
	SQLRETURN rc = SQL_ERROR;
	SQLCHAR *catalog = NULL, *schema = NULL, *table = NULL;

#ifdef ODBCDEBUG
	ODBCLOG("SQLStatisticsW " PTRFMT " ", PTRFMTCAST StatementHandle);
#endif

	if (!isValidStmt(stmt))
		 return SQL_INVALID_HANDLE;

	clearStmtErrors(stmt);

	fixWcharIn(CatalogName, NameLength1, SQLCHAR, catalog,
		   addStmtError, stmt, goto exit);
	fixWcharIn(SchemaName, NameLength2, SQLCHAR, schema,
		   addStmtError, stmt, goto exit);
	fixWcharIn(TableName, NameLength3, SQLCHAR, table,
		   addStmtError, stmt, goto exit);

	rc = SQLStatistics_(stmt,
			    catalog, SQL_NTS,
			    schema, SQL_NTS,
			    table, SQL_NTS,
			    Unique,
			    Reserved);

      exit:
	if (catalog)
		free(catalog);
	if (schema)
		free(schema);
	if (table)
		free(table);

	return rc;
}
#endif /* WITH_WCHAR */
