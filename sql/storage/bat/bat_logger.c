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
#include "bat_logger.h"
#include "bat_utils.h"
#include "sql_types.h" /* EC_POS */

logger *bat_logger = NULL;

static int
bl_preversion( int oldversion, int newversion)
{
#define CATALOG_OCT2014 52100

	(void)newversion;
	if (oldversion == CATALOG_OCT2014) {
		catalog_version = oldversion;
		return 0;
	}
	return -1;
}

static char *
N( char *buf, char *pre, char *schema, char *post)
{
	if (pre)
		snprintf(buf, 64, "%s_%s_%s", pre, schema, post);
	else
		snprintf(buf, 64, "%s_%s", schema, post);
	return buf;
}

static void 
bl_postversion( void *lg) 
{
	(void)lg;
	if (catalog_version <= CATALOG_OCT2014) {
		BAT *te, *tn, *tne;
		BATiter tei, tni;
		char *s = "sys", n[64];
		BUN p,q;

		te = temp_descriptor(logger_find_bat(lg, N(n, NULL, s, "types_eclass")));
		tn = temp_descriptor(logger_find_bat(lg, N(n, NULL, s, "types_sqlname")));
		if (!te || !tn)
			return;
		tei = bat_iterator(te);
		tni = bat_iterator(tn);
		tne = BATnew(TYPE_void, TYPE_int, BATcount(te), PERSISTENT);
		if (!tne)
			return;
        	BATseqbase(tne, te->hseqbase);
		for(p=BUNfirst(te), q=BUNlast(te); p<q; p++) {
			int eclass = *(int*)BUNtail(tei, p);
			char *name = BUNtail(tni, p);

			if (eclass >= EC_POS && strcmp(name, "oid") != 0)
				eclass++;
			else if (strcmp(name, "oid") == 0)
				eclass = EC_POS;
			BUNappend(tne, &eclass, TRUE);
		}
		tne = BATsetaccess(tne, BAT_READ);
		logger_add_bat(lg, tne, N(n, NULL, s, "types_eclass"));
		bat_destroy(te);
		bat_destroy(tn);
	}
}

static int 
bl_create(int debug, const char *logdir, int cat_version)
{
	if (bat_logger)
		return LOG_ERR;
	bat_logger = logger_create(debug, "sql", logdir, cat_version, bl_preversion, bl_postversion);
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
	if (BATcount(bat_logger->catalog_bid) > 10) {
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
