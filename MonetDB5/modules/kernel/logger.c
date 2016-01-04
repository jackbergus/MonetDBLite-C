/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

/*
 * @f logger
 * @a N. J. Nes
 * @v 2.0
 * @+ The Transaction Logger
 * In the philosophy of MonetDB, transaction management overhead should only
 * be paid when necessary. Transaction management is for this purpose
 * implemented as a separate module and applications are required to
 * obey the transaction policy, e.g. obtaining/releasing locks.
 *
 * This module is designed to support efficient logging of the SQL database.
 * Once loaded, the SQL compiler will insert the proper calls at
 * transaction commit to include the changes in the log file.
 *
 * The logger uses a directory to store its log files. One master log file
 * stores information about the version of the logger and the transaction
 * log files. This file is a simple ascii file with the following format:
 *  @code{6DIGIT-VERSION\n[log file number \n]*]*}
 * The transaction log files have a binary format, which stores fixed size
 * logformat headers (flag,nr,bid), where the flag is the type of update logged.
 * The nr field indicates how many changes there were (in case of inserts/deletes).
 * The bid stores the bid identifier.
 *
 * The key decision to be made by the user is the location of the log file.
 * Ideally, it should be stored in fail-safe environment, or at least
 * the log and databases should be on separate disk columns.
 *
 * This file system may reside on the same hardware as the database server
 * and therefore the writes are done to the same disk, but could also
 * reside on another system and then the changes are flushed through the network.
 * The logger works under the assumption that it is called to safeguard
 * updates on the database when it has an exclusive lock on
 * the latest version. This lock should be guaranteed by the calling
 * transaction manager first.
 *
 * Finding the updates applied to a BAT is relatively easy, because each
 * BAT contains a delta structure. On commit these changes are
 * written to the log file and the delta management is reset. Since each
 * commit is written to the same log file, the beginning and end are
 * marked by a log identifier.
 *
 * A server restart should only (re)process blocks which are completely
 * written to disk. A log replay therefore ends in a commit or abort on
 * the changed bats. Once all logs have been read, the changes to
 * the bats are made persistent, i.e. a bbp sub-commit is done.
 *
 * @+ Module Definition
 */
/*
 * @+ Implementation Code
 */
#include "monetdb_config.h"
#include "gdk.h"
#include "gdk_logger.h"
#include "mal.h"
#include "mal_exception.h"

#ifdef WIN32
#define logger_export extern __declspec(dllexport)
#else
#define logger_export extern
#endif

/* the wrappers */
logger_export str logger_create_wrap( logger *L, int *debug, str *fn, str *dirname, int *version);

str
logger_create_wrap( logger *L, int *debug, str *fn, str *dirname, int *version)
{
	logger *l = logger_create(*debug, *fn, *dirname, *version, NULL, NULL);

	if (l) {
		*(logger**)L = l;
		return MAL_SUCCEED;
	}
	throw(MAL, "logger.create", OPERATION_FAILED "database %s version %d" ,
		*dirname, *version);
}

logger_export str logger_destroy_wrap(void *ret, logger *L ) ;

str
logger_destroy_wrap(void *ret, logger *L )
{
	logger *l = *(logger**)L;
	(void) ret;
	if (l) {
		logger_destroy(l);
		return MAL_SUCCEED;
	}
	throw(MAL, "logger.destroy", OPERATION_FAILED);
}

logger_export gdk_return logger_exit_wrap(logger *L );

gdk_return
logger_exit_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && logger_exit(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return logger_restart_wrap(logger *L );

gdk_return
logger_restart_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && logger_restart(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return logger_cleanup_wrap(logger *L );

gdk_return
logger_cleanup_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && logger_cleanup(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return logger_changes_wrap(int *r, logger *L );

gdk_return
logger_changes_wrap(int *r, logger *L )
{
	logger *l = *(logger**)L;
	if (l) {
		*r = (int) MIN(logger_changes(l), GDK_int_max);
		return GDK_SUCCEED;
	}
	*r = 0;
	return GDK_FAIL;
}

logger_export gdk_return log_tstart_wrap(logger *L );

gdk_return
log_tstart_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && log_tstart(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_tend_wrap(logger *L );

gdk_return
log_tend_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && log_tend(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_abort_wrap(logger *L );

gdk_return
log_abort_wrap(logger *L )
{
	logger *l = *(logger**)L;
	if (l && log_abort(l) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_delta_wrap(logger *L, BAT *uid, BAT *b, str nme );

gdk_return
log_delta_wrap(logger *L, BAT *uid, BAT *b, str nme )
{
	logger *l = *(logger**)L;
	if (l && log_delta(l, uid, b, nme) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_bat_wrap(logger *L, BAT *b, str nme );

gdk_return
log_bat_wrap(logger *L, BAT *b, str nme )
{
	logger *l = *(logger**)L;
	if (l && log_bat(l, b, nme) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_bat_clear_wrap(logger *L, str nme );

gdk_return
log_bat_clear_wrap(logger *L, str nme )
{
	logger *l = *(logger**)L;
	if (l && log_bat_clear(l, nme) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_bat_persists_wrap(logger *L, BAT *b, str nme );

gdk_return
log_bat_persists_wrap(logger *L, BAT *b, str nme )
{
	logger *l = *(logger**)L;
	if (l && log_bat_persists(l, b, nme) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return log_bat_transient_wrap(logger *L, str nme );

gdk_return
log_bat_transient_wrap(logger *L, str nme )
{
	logger *l = *(logger**)L;
	if (l && log_bat_transient(l, nme) == LOG_OK)
		return GDK_SUCCEED;
	return GDK_FAIL;
}

logger_export gdk_return logger_add_bat_wrap( int *bid, logger *L, BAT *b, str nme );

gdk_return
logger_add_bat_wrap( int *bid, logger *L, BAT *b, str nme )
{
	logger *l = *(logger**)L;
	if (l) {
		*bid = logger_add_bat(l, b, nme);
		return GDK_SUCCEED;
	}
	return GDK_FAIL;
}

logger_export gdk_return logger_del_bat_wrap( logger *L, int *bid );

gdk_return
logger_del_bat_wrap( logger *L, int *bid )
{
	logger *l = *(logger**)L;
	if (l) {
		logger_del_bat(l, *bid);
		return GDK_SUCCEED;
	}
	return GDK_FAIL;
}

logger_export gdk_return logger_find_bat_wrap( int *bid, logger *L, str nme );

gdk_return
logger_find_bat_wrap( int *bid, logger *L, str nme )
{
	logger *l = *(logger**)L;
	if (l) {
		*bid = logger_find_bat(l, nme);
		return GDK_SUCCEED;
	}
	return GDK_FAIL;
}
