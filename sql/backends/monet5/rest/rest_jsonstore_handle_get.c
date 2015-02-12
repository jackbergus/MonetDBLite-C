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
 * Copyright August 2008-2015 MonetDB B.V.
 * All Rights Reserved.
 */

#include "monetdb_config.h"
#include <stdio.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <string.h>
#include <math.h>
#include "mal_mapi.h"
#include "mal_client.h"
#include "mal_linker.h"
#include "stream.h"
#include "sql_scenario.h"
#include <mapi.h>
#include <rest_jsonstore.h>
#include <rest_jsonstore_handle_get.h>
#include "mal_backend.h"

static str RESTsqlQuery(char **result, char * query);
static char * result_ok = "select true as ok;";
static int char0 = 1;
static int place = 2;
static int line = 30;

static str
RESTsqlQuery(char **result, char * query)
{
	str msg = MAL_SUCCEED;
	str qmsg = MAL_SUCCEED;
	char * resultstring = NULL;
	struct buffer * resultbuffer;
	stream * resultstream;
	Client c;
	bstream *fin = NULL;
	int len = 0;
	backend *be;

	resultbuffer = buffer_create(BLOCK);
	resultstream = buffer_wastream(resultbuffer, "resultstring");

	c = MCinitClient(CONSOLE, fin, resultstream);
	c->nspace = newModule(NULL, putName("user", 4));

	// TODO: lookup user_id in bat
	c->user = 1;
	initLibraries();
	msg = setScenario(c, "sql");
	msg = SQLinitClient(c);
	MSinitClientPrg(c, "user", "main");
	(void) MCinitClientThread(c);
	// TODO: check that be <> NULL
	be = (backend*)c->sqlcontext;
	be->output_format = OFMT_JSON;

	qmsg = SQLstatementIntern(c, &query, "rest", TRUE, TRUE, NULL);
	if (qmsg == MAL_SUCCEED) {
		resultstring = buffer_get_buf(resultbuffer);
		*result = GDKstrdup(resultstring);
		free(resultstring);
	} else {
		len = strlen(qmsg) + 19;
		resultstring = malloc(len);
		snprintf(resultstring, len, "{ \"error\": \"%s\" }\n", qmsg);
		*result = GDKstrdup(resultstring);
		free(resultstring);
	}
	buffer_destroy(resultbuffer);
	msg = SQLexitClient(c);
	return msg;
}

str RESTunknown(char **result)
{
	str msg = MAL_SUCCEED;
	char * querytext = "select 'Unknown' as error;";
	msg = RESTsqlQuery(result, querytext);
	return msg;
}

str RESTwelcome(char **result)
{
	str msg = MAL_SUCCEED;
	// TODO: get version from variable
	char * querytext = "select 'Welcome' as jsonstore, '(unreleased)' as version;";
	msg = RESTsqlQuery(result, querytext);
	return msg;
}

str RESTallDBs(char **result)
{
	str msg = MAL_SUCCEED;
	char * querytext = "select substring(name, 6, length(name) -5) as name from tables where name like 'json!_%'ESCAPE'!';";
	msg = RESTsqlQuery(result, querytext);
	return msg;
}

str RESTuuid(char **result)
{
	str msg = MAL_SUCCEED;
	char * querytext = "select uuid() as uuid;";
	msg = RESTsqlQuery(result, querytext);
	return msg;
}

str RESTcreateDB(char ** result, char * dbname)
{
	str msg = MAL_SUCCEED;
	char * querytext = NULL;
	char * query = 
		"CREATE TABLE json_%s (        "
		"_id uuid, _rev VARCHAR(34),   "
                "deleted BOOLEAN,              "
		"js json);                     "
		"CREATE TABLE jsondesign_%s (  "
		"_id varchar(128),             "
		"_rev VARCHAR(34),             "
		"design json);                 "
		"CREATE TABLE jsonblob_%s (    "
		"_id uuid,                     "
		"mimetype varchar(128),        "
		"filename varchar(128),        "
                "deleted BOOLEAN,               "
	        "value clob);                  ";

	size_t len = 3 * strlen(dbname) + (14 * line) - (3 * place) + char0;
	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, dbname, dbname);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}

	query = "CREATE FUNCTION %s_update_doc "
                "( doc_id VARCHAR(36),         "
                "  doc json )                  "
                "  RETURNS TABLE ( OK BOOLEAN )"
                "BEGIN                         "
                " DECLARE ISNEW INTEGER;       "
                " DECLARE VERSION INT;         "
                " DECLARE NEWVER VARCHAR(6);   "
                " SET ISNEW = (SELECT          "
                "  COUNT(*) FROM json_%s       "
                "  WHERE _id = doc_id);        "
                "   IF (ISNEW = 0) THEN        "
                "    SET NEWVER = '1';         "
                "   ELSE                       "
                "    SET VERSION = (           "
                "     SELECT MAX(              "
                "      CAST(                   "
                "       SUBSTRING(_rev,        "
                "        1,POSITION('-'        "
                "         IN _rev) - 1)        "
                "       AS INT) + 1)           "
                "     FROM json_%s             "
                "     WHERE _id =              "
                "      doc_id);                "
                "     SET NEWVER =             "
                "      CAST(VERSION AS         "
                "       VARCHAR(6));           "
                "   END IF;                    "
                "  INSERT INTO json_%s (       "
                "   _id, _rev, deleted, js )   "
                "  VALUES ( doc_id,            "
                "   CONCAT(NEWVER,             "
                "    CONCAT('-',               "
                "     md5(doc))),              "
                "   FALSE,                     "
                "   doc );                     "
                "  RETURN                      "
                "   SELECT TRUE;               "
                "END;                          ";

	len = 4 * strlen(dbname) + (39 * line) - (4 * place) + char0;

	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, dbname, dbname, dbname);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTdeleteDB(char ** result, char * dbname)
{
	str msg = MAL_SUCCEED;
	char * querytext = NULL;
	char * query =
		"DROP FUNCTION %s_update_doc;  "
		"DROP TABLE json_%s;           "
		"DROP TABLE jsonblob_%s;       "
		"DROP TABLE jsondesign_%s;     ";
	size_t len = 4 * strlen(dbname) + (4 * line) - (4 * place) + char0;

	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, dbname, dbname);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTcreateDoc(char ** result, char * dbname, const char * doc)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + 2 * strlen(doc)+ 93 + char0;
	char * querytext = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "INSERT INTO json_%s (_id, _rev, deleted, js) VALUES (uuid(), concat('1-', md5('%s')), FALSE, '%s');", dbname, doc, doc);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"&2 1 -1\n") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTdbInfo(char **result, char * dbname)
{
	str msg = MAL_SUCCEED;
	char * querytext = NULL;
	char * query = "WITH curr_%s(maxrev,          "
                       "             _id) AS (        "
                       "SELECT MAX(CAST(              "
                       " SUBSTRING(_rev,1,            "
                       " POSITION('-' IN _rev) - 1)   "
                       " AS INT)), _id                "
                       "FROM json_%s                  "
                       "GROUP BY _id)                 "
                       "SELECT json_%s._id,           "
                       "json_%s._rev,                 "
                       "json_%s.js                    "
                       "FROM curr_%s,                 "
                       "json_%s                       "
                       "WHERE curr_%s._id =           "
                       " json_%s._id                  "
                       "AND json_%s.deleted = FALSE   "
                       "AND curr_%s.maxrev =          "
                       " CAST(SUBSTRING(_rev,         "
                       " 1,POSITION('-' IN _rev) - 1) "
	               "AS INT);                      ";
	size_t len = 11 * strlen(dbname) + (20 * line) - (11 * place) + char0;

	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, dbname, dbname, dbname,
		 dbname, dbname, dbname, dbname,
		 dbname, dbname, dbname);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	return msg;
}

str RESTgetDoc(char ** result, char * dbname, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	char * querytext = NULL;
	char * query = "WITH curr_%s(maxrev,          "
                       "             _id) AS (        "
                       "SELECT MAX(CAST(              "
                       " SUBSTRING(_rev,1,            "
                       " POSITION('-' IN _rev) - 1)   "
                       " AS INT)), _id                "
                       "FROM json_%s                  "
                       "WHERE _id = '%s'              "
                       "GROUP BY _id)                 "
                       "SELECT json_%s._id,           "
                       "json_%s._rev,                 "
                       "json_%s.js                    "
                       "FROM curr_%s,                 "
                       "json_%s                       "
                       "WHERE curr_%s._id =           "
                       " json_%s._id                  "
                       "AND json_%s.deleted = FALSE   "
                       "AND curr_%s.maxrev =          "
                       " CAST(SUBSTRING(_rev,         "
                       " 1,POSITION('-' IN _rev) - 1) "
	               "AS INT);                      ";
	size_t len = 11 * strlen(dbname) + (1 * strlen(doc_id)) + (21 * line) - (12 * place) + char0;

	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, dbname, doc_id, dbname, 
		 dbname, dbname, dbname, dbname,
		 dbname, dbname, dbname, dbname);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	return msg;

}

str RESTupdateDoc(char ** result, char * dbname, const char * doc, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc) + strlen(doc_id) + 35 + char0;
	char * querytext = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "SELECT * FROM %s_update_doc ('%s', '%s');", dbname, doc_id, doc);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	return msg;
}

str RESTdeleteDoc(char ** result, char * dbname, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc_id) + 47 + 1;
	char * querytext = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "UPDATE json_%s SET deleted = TRUE WHERE _id = '%s';", dbname, doc_id);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"&2 1 -1\n") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTerror(char **result, int rest_command)
{
	str msg = MAL_SUCCEED;
	char * querytext;
	switch (rest_command) {
	case MONETDB_REST_MISSING_DATABASENAME:
		querytext = "SELECT 'Missing Database Name' AS error;";
		break;
	case MONETDB_REST_NO_PARAMETER_ALLOWED:
		querytext = "SELECT 'No Parameter Allowed' AS error;";
		break;
	case MONETDB_REST_NO_ATTACHMENT_PATH:
		querytext = "SELECT 'Missing Attachment PATH' AS error;";
		break;
	default:
		/* error, unknown command */
		querytext = "SELECT 'Unknown Error' as error;";
	}
	msg = RESTsqlQuery(result, querytext);
	return msg;
}

str RESTinsertAttach(char ** result, char * dbname, const char * attachment, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	char * querytext = NULL;
/*
	char * query =
		"INSERT INTO jsonblob_%s (     "
		"    _id, mimetype,            "
		"    filename, value )         "
		"VALUES (                      "
		"''%s'',                       "
		"'''', ''\"text/plain\"'',     "
		"''%s'');                      ";
	size_t len = strlen(dbname) + strlen(doc_id) + strlen(attachment) 
		+ (7 * line) - (3 * place) + char0;
*/
	size_t len;
	char * attach64;
	char * query =
	  "INSERT INTO jsonblob_%s ( _id, mimetype, filename, deleted, value ) VALUES ( '%s', '', '\"text/plain\"', FALSE, '%s');";

	BIO *bio;
	BIO *b64;
	FILE* stream;
	int encodedSize = 4*ceil((double)strlen(attachment)/3);
	attach64 = malloc(encodedSize+1);

	stream = fmemopen(attach64, encodedSize+1, "w");
	b64 = BIO_new(BIO_f_base64());
	bio = BIO_new_fp(stream, BIO_NOCLOSE);
	bio = BIO_push(b64, bio);
	BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
	BIO_write(bio, attachment, strlen(attachment));
	(void)BIO_flush(bio);
	BIO_free_all(bio);
	fclose(stream);

	len = strlen(dbname) + strlen(doc_id) + strlen(attach64)
		+ 112 + char0;

	querytext = malloc(len);
	snprintf(querytext, len, query, dbname, doc_id, attach64);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (attach64 != NULL) {
		free(attach64);
	}
	return msg;
}

str RESTgetAttach(char ** result, char * dbname, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc_id) + 40;
	char * querytext = NULL;
	BIO *bio;
	BIO *b64;
	int len01 = 0;
	int inputLen = 0;
	int decodeLen = 0;
	int padding = 0;
	char * attach64;
	char * attach01;
	FILE* stream;

	querytext = malloc(len);
	snprintf(querytext, len, "SELECT clob FROM jsonblob_%s WHERE _id = '%s';", dbname, doc_id);

	msg = RESTsqlQuery(result, querytext);

	/*
	  TODO: get the base64 encoded attachment from the resultset 
	        and replace the current value of result
	*/
	attach64 = *result;
	inputLen = strlen(attach64);

	if (attach64[inputLen - 1] == '=' && attach64[inputLen - 2] == '=') {
	  padding = 2;
	} else if (attach64[inputLen - 1] == '=') {
	  padding = 1;
	}
	decodeLen = (int)inputLen*0.75 - padding;

	attach01 = (char*)malloc(decodeLen+1);
	stream = fmemopen(attach64, strlen(attach64), "r");

	b64 = BIO_new(BIO_f_base64());
	bio = BIO_new_fp(stream, BIO_NOCLOSE);
	bio = BIO_push(b64, bio);
	BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
	len01 = BIO_read(bio, attach01, strlen(attach64));
	//Can test here if len == decodeLen - if not, then return an error
	attach01[len01] = '\0';

	BIO_free_all(bio);
	fclose(stream);

	if (attach01 != NULL) {
		free(attach01);
	}
	if (querytext != NULL) {
		free(querytext);
	}
	return msg;
}

str RESTdeleteAttach(char ** result, char * dbname, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc_id) + 37 + 1;
	char * querytext = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "DELETE FROM jsonblob_%s WHERE _id = '%s';", dbname, doc_id);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"&2 3 -1\n") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTinsertDesign(char ** result, char * dbname, const char * doc_id, const char * doc)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc_id) + 2 * strlen(doc) + 85 + char0;
	char * querytext = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "INSERT INTO jsondesign_%s (_id, _rev, design ) VALUES ( '%s', concat('1-', md5('%s')), '%s');", dbname, doc_id, doc, doc);

	msg = RESTsqlQuery(result, querytext);
	if (querytext != NULL) {
		free(querytext);
	}
	if (strcmp(*result,"&2 1 -1\n") == 0) {
	  msg = RESTsqlQuery(result, result_ok);
	}
	return msg;
}

str RESTgetDesign(char ** result, char * dbname, const char * doc_id)
{
	str msg = MAL_SUCCEED;
	size_t len = strlen(dbname) + strlen(doc_id) + 108 + char0;
	char * querytext = NULL;
	char * begin_query;
	char * end_query;
	size_t query_len;
	char * viewquery = NULL;

	querytext = malloc(len);
	snprintf(querytext, len, "SELECT json_text(json_path(design, 'views.foo'), 'query') AS query FROM jsondesign_%s WHERE _id = '%s' LIMIT 1;", dbname, doc_id);

	msg = RESTsqlQuery(result, querytext);
	/*
	  First implementation of running views stored in a json document
	  Missing error handling and sanity checks. They will be added 
	  when the API and the corresponding implementation get are 
	  defined. For now this is only a proof of concept that the idea
	  will work. Not production ready.
	 */
	if (msg == MAL_SUCCEED) {
		begin_query = strstr((const char *)*result, "{ query , \"");
		end_query = strstr((const char *)*result, " \" }");
		query_len = strlen(begin_query + 12) - strlen(end_query) + 1;
		viewquery = malloc(query_len);
		snprintf(viewquery, query_len, "%s", begin_query + 12);
		msg = RESTsqlQuery(result, viewquery);
	}
	if (querytext != NULL) {
		free(querytext);
	}
	if (viewquery != NULL) {
		free(viewquery);
	}
	return msg;
}
