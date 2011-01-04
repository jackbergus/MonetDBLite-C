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
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef _MEROVINGIAN_H
#define _MEROVINGIAN_H 1

#include "sql_config.h"
#include <stdio.h>
#include <netinet/in.h> /* struct sockaddr_in */

#include "utils/utils.h" /* confkeyval */

#define SOCKPTR struct sockaddr *
#ifdef HAVE_SOCKLEN_T
#define SOCKLEN socklen_t
#else
#define SOCKLEN int
#endif

typedef char* err;

#define freeErr(X) GDKfree(X)
#define getErrMsg(X) X
#define NO_ERR (err)0

/* when not writing to stderr, one has to flush, make it easy to do so */
#define Mfprintf(S, ...) \
	fprintf(S, __VA_ARGS__); \
	fflush(S);

char *newErr(char *fmt, ...);
void terminateProcess(void *p);
void logFD(int fd, char *type, char *dbname, long long int pid, FILE *stream);

typedef struct _dpair {
	int out;          /* where to read stdout messages from */
	int err;          /* where to read stderr messages from */
	pid_t pid;        /* this process' id */
	char *dbname;     /* the database that this server serves */
	struct _dpair* next;
}* dpair;

extern char *_mero_mserver;
extern char *_mero_conffile;
extern dpair _mero_topdp;
extern pthread_mutex_t _mero_topdp_lock;
extern int _mero_keep_logging;
extern char _mero_keep_listening;
extern FILE *_mero_streamout;
extern FILE *_mero_streamerr;
extern int _mero_exit_timeout;
extern unsigned short _mero_port;
extern int _mero_discoveryttl;
extern FILE *_mero_discout;
extern FILE *_mero_discerr;
extern unsigned short _mero_controlport;
extern FILE *_mero_ctlout;
extern FILE *_mero_ctlerr;
extern int _mero_broadcastsock;
extern struct sockaddr_in _mero_broadcastaddr;
extern char _mero_hostname[128];
extern char _mero_controlpass[128];
extern char *_mero_msglogfile;
extern char *_mero_errlogfile;
extern confkeyval *_mero_props;

#endif

/* vim:set ts=4 sw=4 noexpandtab: */
