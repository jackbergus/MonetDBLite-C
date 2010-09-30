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

#include "sql_config.h"
#include "bat_logger.h"
#include "bat_utils.h"

logger *bat_logger = NULL;

static int
bl_preversion( int oldversion, int newversion)
{
#define CATALOG_FEB2010 50000

	(void)newversion;
	if (oldversion == CATALOG_FEB2010) {
		catalog_version = oldversion;
		return 0;
	}
	return -1;
}

static void 
bl_postversion( void *lg) 
{
	(void)lg;
	if (catalog_version == CATALOG_FEB2010) {
		size_t i;
		BAT *o, *b;
		char *s_nil = ATOMnilptr(TYPE_str);
		fprintf(stdout, "# upgrading catalog from Feb2010\n");
		fflush(stdout);

		o = temp_descriptor(logger_find_bat(lg, "sys__tables_id"));
		/* no sys tables, easy upgrade */
		if (!o)
			return ;
		b = bat_new( TYPE_void, TYPE_bit, BATcount(o));
		memset(Tloc(b,BUNfirst(b)), 0, sizeof(bit)*BATcount(o));
		BATsetcount(b, BATcount(o));
		logger_add_bat(lg, b, "sys__tables_readonly");
		bat_destroy(o);
		bat_destroy(b);

		o = temp_descriptor(logger_find_bat(lg, "sys__columns_id"));
		if (!o)
			return ;
		b = bat_new( TYPE_void, TYPE_str, BATcount(o));
		for(i=0; i< BATcount(o); i++) 
			BUNappend(b, s_nil, TRUE);
		logger_add_bat(lg, b, "sys__columns_storage");
		bat_destroy(o);
		bat_destroy(b);

		o = temp_descriptor(logger_find_bat(lg, "tmp__tables_id"));
		if (!o)
			return ;
		b = bat_new( TYPE_void, TYPE_bit, BATcount(o));
		memset(Tloc(b,BUNfirst(b)), 0, sizeof(bit)*BATcount(o));
		BATsetcount(b, BATcount(o));
		logger_add_bat(lg, b, "tmp__tables_readonly");
		bat_destroy(o);
		bat_destroy(b);

		o = temp_descriptor(logger_find_bat(lg, "tmp__columns_id"));
		if (!o)
			return ;
		b = bat_new( TYPE_void, TYPE_str, BATcount(o));
		for(i=0; i< BATcount(o); i++) 
			BUNappend(b, s_nil, TRUE);
		logger_add_bat(lg, b, "tmp__columns_storage");
		bat_destroy(o);
		bat_destroy(b);
	
		/* mark that the rest is fixed on sql level */
	}
}

static int 
bl_create(char *logdir, char *dbname, int cat_version)
{
	if (bat_logger)
		return LOG_ERR;
	bat_logger = logger_create(0, "sql", logdir, dbname, cat_version, NULL, bl_preversion, bl_postversion);
	if (bat_logger)
		return LOG_OK;
	return LOG_ERR;
}

static void 
bl_destroy(void)
{
	logger *l = bat_logger;

	bat_logger = NULL;
	if (l) {
		logger_exit(l);
		logger_destroy(l);
	}
}

static int 
bl_restart(void)
{
	if (bat_logger)
		return logger_restart(bat_logger);
	return LOG_OK;
}

static int
bl_cleanup(void)
{
	if (bat_logger)
		return logger_cleanup(bat_logger);
	return LOG_OK;
}

static int
bl_changes(void)
{	
	return (int) MIN(logger_changes(bat_logger), GDK_int_max);
}

static int 
bl_get_sequence(int seq, lng *id)
{
	return logger_sequence(bat_logger, seq, id);
}

static int
bl_log_isnew(void)
{
	if (BATcount(bat_logger->catalog) > 10) {
		return 0;
	}
	return 1;
}

static int 
bl_tstart(void)
{
	return log_tstart(bat_logger);
}

static int 
bl_tend(void)
{
	return log_tend(bat_logger);
}

static int 
bl_sequence(int seq, lng id)
{
	return log_sequence(bat_logger, seq, id);
}

int 
bat_logger_init( logger_functions *lf )
{
	lf->create = bl_create;
	lf->destroy = bl_destroy;
	lf->restart = bl_restart;
	lf->cleanup = bl_cleanup;
	lf->changes = bl_changes;
	lf->get_sequence = bl_get_sequence;
	lf->log_isnew = bl_log_isnew;
	lf->log_tstart = bl_tstart;
	lf->log_tend = bl_tend;
	lf->log_sequence = bl_sequence;
	return LOG_OK;
}
