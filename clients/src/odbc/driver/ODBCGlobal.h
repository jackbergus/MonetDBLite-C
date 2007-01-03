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
 * Portions created by CWI are Copyright (C) 1997-2007 CWI.
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

/**********************************************
 * ODBCGlobal.h
 *
 * Description:
 * The global MonetDB ODBC include file which
 * includes all needed external include files.
 *
 * Author: Martin van Dinther
 * Date  : 30 aug 2002
 *
 **********************************************/

#ifndef _H_ODBCGLOBAL
#define _H_ODBCGLOBAL

#include "clients_config.h"

#ifdef WIN32
#include <windows.h>
/* indicate to sqltypes.h that windows.h has already been included and
   that it doesn't have to define Windows constants */
#define ALREADY_HAVE_WINDOWS_TYPE
#endif

/**** Define the ODBC Version this ODBC driver complies with ****/
#define ODBCVER 0x0352		/* Important: this must be defined before include of sqlext.h */

/* some general defines */
#define MONETDB_ODBC_VER     "03.52"	/* must be synchronous with ODBCVER */
#define MONETDB_DRIVER_NAME  "MonetDBODBClib"
#define MONETDB_DRIVER_VER   "1.00"
#define MONETDB_PRODUCT_NAME "MonetDB ODBC driver"
#define MONETDB_SERVER_NAME  "MonetDB"

#define WITH_WCHAR	1
#define ODBCDEBUG	1

#ifdef WIN32
#ifndef LIBMONETODBC
#define odbc_export extern __declspec(dllimport)
#else
#define odbc_export extern __declspec(dllexport)
#endif
#else
#define odbc_export extern
#endif

/* standard ODBC driver include files */
#include <sqltypes.h>		/* ODBC C typedefs */
/* Note: sqlext.h includes sql.h so it is not needed here to be included */
/* Note2: if you include sql.h it will give an error because it will find
	src/sql/common/sql.h instead, which is not the one we need */
#include <sqlext.h>		/* ODBC API definitions and prototypes */
#include <sqlucode.h>		/* ODBC Unicode defs and prototypes */

/* standard ODBC driver installer & configurator include files */
#include <odbcinst.h>		/* ODBC installer definitions and prototypes */

/* standard C include files */
#include <string.h>		/* for strcpy() etc. */
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <assert.h>

#ifdef NATIVE_WIN32
#define strdup _strdup
#endif

#ifndef HAVE_SSIZE_T
#if SIZEOF_SIZE_T == SIZEOF_INT
typedef int ssize_t;

#define HAVE_SSIZE_T 1
#else
#if SIZEOF_SIZE_T == SIZEOF_LONG
typedef long ssize_t;

#define HAVE_SSIZE_T 1
#else
#ifdef _WIN64
typedef __int64 ssize_t;

#define HAVE_SSIZE_T 1
#endif
#endif
#endif
#endif

/* define printf format for printing pointer values */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901
#define PTRFMT		"%p"
#define PTRFMTCAST		/* no cast needed */
#elif SIZEOF_VOID_P == SIZEOF_INT
#define PTRFMT		"%x"
#define PTRFMTCAST	(unsigned int)
#elif SIZEOF_VOID_P == SIZEOF_LONG
#define PTRFMT		"%lx"
#define PTRFMTCAST	(unsigned long)
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG
#define PTRFMT		"%llx"
#define PTRFMTCAST	(unsigned long long)
#elif SIZEOF_VOID_P == SIZEOF___INT64
#define PTRFMT		"%I64x"
#define PTRFMTCAST	(unsigned __int64)
#else
#error no definition for PTRFMT
#endif

/* these functions are called from within the library */
SQLRETURN SQLAllocHandle_(SQLSMALLINT nHandleType, SQLHANDLE nInputHandle, SQLHANDLE *pnOutputHandle);
SQLRETURN SQLEndTran_(SQLSMALLINT nHandleType, SQLHANDLE nHandle, SQLSMALLINT nCompletionType);
SQLRETURN SQLFreeHandle_(SQLSMALLINT handleType, SQLHANDLE handle);
SQLRETURN SQLGetDiagRec_(SQLSMALLINT handleType, SQLHANDLE handle, SQLSMALLINT recNumber, SQLCHAR *sqlState, SQLINTEGER *nativeErrorPtr, SQLCHAR *messageText, SQLSMALLINT bufferLength, SQLSMALLINT *textLengthPtr);

#ifdef ODBCDEBUG
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901
#define ODBCLOG(...)	do {						\
				char *s = getenv("ODBCDEBUG");		\
				if (s && *s) {				\
					FILE *f;			\
					f = fopen(s, "a");		\
					if (f) {			\
						fprintf(f, __VA_ARGS__); \
						fclose(f);		\
					}				\
				}					\
			} while (0)
#else
extern void ODBCLOG(const char *fmt, ...);
#endif
#endif

#endif
