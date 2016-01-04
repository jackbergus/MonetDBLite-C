/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

#ifndef _MAL_PROFILER_H
#define _MAL_PROFILER_H

#include "mal_client.h"

#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif

#ifdef HAVE_SYS_RESOURCE_H
# include <sys/resource.h>
typedef struct rusage Rusage;
#endif

typedef struct tms Tms;
typedef struct Mallinfo Mallinfo;

#define PROFevent   0
#define PROFtime    1
#define PROFthread  2
#define PROFpc      3
#define PROFfunc    4
#define PROFticks   5
#define PROFcpu     6
#define PROFmemory  7
#define PROFreads   8
#define PROFwrites  9
#define PROFrbytes  10
#define PROFwbytes  11
#define PROFstmt    12
#define PROFaggr    13
#define PROFprocess 14
#define PROFuser    15
#define PROFstart   16
#define PROFtype    17
#define PROFdot     18
#define PROFflow   19
#define PROFping   20	/* heartbeat ping messages */
#define PROFfootprint 21
#define PROFnuma 22

mal_export int getProfileCounter(int idx);
mal_export str openProfilerStream(stream *fd);
mal_export str closeProfilerStream(void);

mal_export void profilerEvent(oid usr, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci, int start);
mal_export void profilerHeartbeatEvent(char *msg);
mal_export str setLogFile(stream *fd, Module cntxt, const char *fname);
mal_export str setLogStream(Module cntxt, const char *host, int port);
mal_export str setLogStreamStream(Module cntxt, stream *s);
mal_export str setStartPoint(Module cntxt, const char *mod, const char *fcn);
mal_export str setEndPoint(Module cntxt, const char *mod, const char *fcn);

mal_export str startProfiler(oid user, int mode, int beat);
mal_export str stopProfiler(void);
mal_export void setHeartbeat(int delay);
mal_export str cleanupProfiler(void);
mal_export void initHeartbeat(void);
mal_export double HeartbeatCPUload(void);

mal_export stream *getProfilerStream(void);

mal_export void MPresetProfiler(stream *fdout);

mal_export int malProfileMode;

mal_export void clearTrace(void);
mal_export BAT *getTrace(const char *ev);
mal_export int getTraceType(const char *nme);
mal_export void TRACEtable(BAT **r);

mal_export lng getDiskSpace(void);
mal_export lng getDiskReads(void);
mal_export lng getDiskWrites(void);
mal_export lng getUserTime(void);
mal_export lng getSystemTime(void);
mal_export void profilerGetCPUStat(lng *user, lng *nice, lng *sys, lng *idle, lng *iowait);
mal_export void _initTrace(void);

#endif
