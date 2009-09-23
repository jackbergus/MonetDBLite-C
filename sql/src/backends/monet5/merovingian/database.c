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

/* NOTE: for this file to work correctly, SABAOTHinit must be called. */

#include "sql_config.h"
#include "mal_sabaoth.h"
#include <stdio.h> /* fprintf, rename */
#include <unistd.h> /* stat, rmdir, unlink, ioctl */
#include <dirent.h> /* readdir */
#include <sys/stat.h> /* mkdir, stat, umask */
#include <sys/types.h> /* mkdir, readdir */
#include <errno.h>
#include "utils.h"

/* check if dbname matches [A-Za-z0-9-_]+ */
char* db_validname(char *dbname) {
	size_t c;
	char buf[8096];

	if (dbname[0] == '\0')
		return(strdup("database name should not be an empty string"));
	for (c = 0; dbname[c] != '\0'; c++) {
		if (
				!(dbname[c] >= 'A' && dbname[c] <= 'Z') &&
				!(dbname[c] >= 'a' && dbname[c] <= 'z') &&
				!(dbname[c] >= '0' && dbname[c] <= '9') &&
				!(dbname[c] == '-') &&
				!(dbname[c] == '_')
		   )
		{
			snprintf(buf, sizeof(buf), "invalid character "
					"'%c' at " SZFMT " in database name '%s'",
					dbname[c], c, dbname);
			return(strdup(buf));
		}
	}

	return(NULL);
}

char* db_create(char* dbname) {
	sabdb *stats;
	size_t c;
	char* e;
	char* dbfarm;
	char buf[8096];
	char path[8096];
	FILE *f;

	if ((e = db_validname(dbname)) != NULL)
		return(e);

	/* the argument is the database to create, see what Sabaoth can
	 * tell us about it */
	if ((e = SABAOTHgetStatus(&stats, dbname)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", e);
		GDKfree(e);
		return(strdup(buf));
	}

	/* if sabaoth doesn't know, then it's green light for us! */
	if (stats != NULL) {
		SABAOTHfreeStatus(&stats);
		snprintf(buf, sizeof(buf), "database '%s' already exists", dbname);
		return(strdup(buf));
	}

	if ((e = SABAOTHgetDBfarm(&dbfarm)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", e);
		GDKfree(e);
		return(strdup(buf));
	}

	/* create the directory */
	c = snprintf(path, sizeof(path), "%s/%s", dbfarm, dbname);
	if (c >= sizeof(path)) {
		GDKfree(dbfarm);
		return(strdup("path/dbname combination too long, "
				"path would get truncated"));
	}
	if (mkdir(path, 0755) == -1) {
		snprintf(buf, sizeof(buf), "unable to create %s: %s",
				dbname, strerror(errno));
		GDKfree(dbfarm);
		return(strdup(buf));
	}

	/* perform another length check, with the .maintenance file,
	 * which happens to be the longest */
	c = snprintf(path, sizeof(path), "%s/%s/.maintenance",
			dbfarm, dbname);
	if (c >= sizeof(path)) {
		/* try to cleanup */
		snprintf(path, sizeof(path), "%s/%s", dbfarm, dbname);
		rmdir(path);
		GDKfree(dbfarm);
		return(strdup("path/dbname combination too long, "
				"filenames inside would get truncated"));
	}

	/* put this database under maintenance, make sure no race condition
	 * ever can happen, by putting it under maintenance before it even
	 * exists for Merovingian */
	fclose(fopen(path, "w"));

	/* avoid GDK making fugly complaints */
	snprintf(path, sizeof(path), "%s/%s/.gdk_lock", dbfarm, dbname);
	f = fopen(path, "w");
	/* to all insanity, .gdk_lock is "valid" if it contains a
	 * ':', which it does by pure coincidence of time having a
	 * ':' in there twice... */
	if (fwrite("bla:", 1, 4, f) < 4) {
		snprintf(buf, sizeof(buf), "cannot write lock file: %s",
				strerror(errno));
		GDKfree(dbfarm);
		return(strdup(buf));
	}
	fclose(f);

	/* generate a vault key */
	snprintf(path, sizeof(path), "%s/%s/.vaultkey", dbfarm, dbname);
	if ((e = generatePassphraseFile(path)) != NULL) {
		GDKfree(dbfarm);
		return(e);
	}

	/* without an .uplog file, Merovingian won't work, this
	 * needs to be last to avoid race conditions */
	snprintf(path, sizeof(path), "%s/%s/.uplog", dbfarm, dbname);
	fclose(fopen(path, "w"));

	GDKfree(dbfarm);
	return(NULL);
}

/* recursive helper function to delete a directory */
static char* deletedir(char *dir) {
	DIR *d;
	struct dirent *e;
	struct stat s;
	char buf[8096];
	char path[PATHLENGTH + 1];

	d = opendir(dir);
	if (d == NULL) {
		/* silently return if we cannot find the directory; it's
		 * probably already deleted */
		if (errno == ENOENT)
			return(NULL);
		snprintf(buf, sizeof(buf), "unable to open dir %s: %s",
				dir, strerror(errno));
		return(strdup(buf));
	}
	while ((e = readdir(d)) != NULL) {
		snprintf(path, sizeof(path), "%s/%s", dir, e->d_name);
		if (stat(path, &s) == -1) {
			snprintf(buf, sizeof(buf), "unable to stat file %s: %s",
					path, strerror(errno));
			closedir(d);
			return(strdup(buf));
		}

		if (S_ISREG(s.st_mode) || S_ISLNK(s.st_mode)) {
			if (unlink(path) == -1) {
				snprintf(buf, sizeof(buf), "unable to unlink file %s: %s",
						path, strerror(errno));
				closedir(d);
				return(strdup(buf));
			}
		} else if (S_ISDIR(s.st_mode)) {
			char* er;
			/* recurse, ignore . and .. */
			if (strcmp(e->d_name, ".") != 0 &&
					strcmp(e->d_name, "..") != 0 &&
					(er = deletedir(path)) != NULL)
			{
				closedir(d);
				return(er);
			}
		} else {
			/* fifos, block, char devices etc, we don't do */
			snprintf(buf, sizeof(buf), "not a regular file: %s", path);
			closedir(d);
			return(strdup(buf));
		}
	}
	closedir(d);
	if (rmdir(dir) == -1) {
		snprintf(buf, sizeof(buf), "unable to remove directory %s: %s",
				dir, strerror(errno));
		return(strdup(buf));
	}

	return(NULL);
}

char* db_destroy(char* dbname) {
	sabdb* stats;
	char* e;
	char buf[8096];

	if (dbname[0] == '\0')
		return(strdup("database name should not be an empty string"));

	/* the argument is the database to destroy, see what Sabaoth can
	 * tell us about it */
	if ((e = SABAOTHgetStatus(&stats, dbname)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", e);
		GDKfree(e);
		return(strdup(buf));
	}

	if (stats == NULL) {
		snprintf(buf, sizeof(buf), "no such database: %s", dbname);
		return(strdup(buf));
	}

	if (stats->state == SABdbRunning) {
		snprintf(buf, sizeof(buf), "database '%s' is still running, "
				"please stop database first", dbname);
		SABAOTHfreeStatus(&stats);
		return(strdup(buf));
	}

	/* annoyingly we have to delete file by file, and
	 * directories recursively... */
	if ((e = deletedir(stats->path)) != NULL) {
		snprintf(buf, sizeof(buf), "failed to destroy '%s': %s",
				dbname, e);
		GDKfree(e);
		SABAOTHfreeStatus(&stats);
		return(strdup(buf));
	}
	SABAOTHfreeStatus(&stats);

	return(NULL);
}

char* db_rename(char *olddb, char *newdb) {
	char new[1024];
	char buf[8096];
	char *p;
	sabdb* stats;

	if (olddb[0] == '\0' || newdb[0] == '\0')
		return(strdup("database name should not be an empty string"));

	/* check if dbname matches [A-Za-z0-9-_]+ */
	if ((p = db_validname(newdb)) != NULL)
		return(p);

	if ((p = SABAOTHgetStatus(&stats, olddb)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", p);
		GDKfree(p);
		return(strdup(buf));
	}

	if (stats == NULL) {
		snprintf(buf, sizeof(buf), "no such database: %s", olddb);
		return(strdup(buf));
	}

	if (stats->state == SABdbRunning) {
		snprintf(buf, sizeof(buf), "database '%s' is still running, "
				"please stop database first", olddb);
		SABAOTHfreeStatus(&stats);
		return(strdup(buf));
	}

	/* construct path to new database */
	snprintf(new, sizeof(new), "%s", stats->path);
	p = strrchr(new, '/');
	if (p == NULL) {
		snprintf(buf, sizeof(buf), "non-absolute database path? '%s'",
				stats->path);
		SABAOTHfreeStatus(&stats);
		return(strdup(buf));
	}
	snprintf(p + 1, sizeof(new) - (p + 1 - new), "%s", newdb);

	/* Renaming is as simple as changing the directory name.  Since the
	 * logdir is below it, we don't need to bother about that either. */
	if (rename(stats->path, new) != 0) {
		snprintf(buf, sizeof(buf), "failed to rename database from "
				"'%s' to '%s': %s\n", stats->path, new, strerror(errno));
		SABAOTHfreeStatus(&stats);
		return(strdup(buf));
	}

	SABAOTHfreeStatus(&stats);
	return(NULL);
}

char* db_lock(char *dbname) {
	char *e;
	sabdb *stats;
	char path[8096];
	char buf[8096];
	FILE *f;

	/* the argument is the database to take under maintenance, see
	 * what Sabaoth can tell us about it */
	if ((e = SABAOTHgetStatus(&stats, dbname)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", e);
		GDKfree(e);
		return(strdup(buf));
	}

	if (stats == NULL) {
		snprintf(buf, sizeof(buf), "no such database: %s", dbname);
		return(strdup(buf));
	}

	if (stats->locked == 1) {
		SABAOTHfreeStatus(&stats);
		snprintf(buf, sizeof(buf), "database '%s' already is "
				"under maintenance", dbname);
		return(strdup(buf));
	}

	/* put this database in maintenance mode */
	snprintf(path, sizeof(path), "%s/.maintenance", stats->path);
	SABAOTHfreeStatus(&stats);
	if ((f = fopen(path, "w")) == NULL) {
		snprintf(buf, sizeof(buf), "could not create '%s' for '%s': %s",
				path, dbname, strerror(errno));
		return(strdup(buf));
	}
	fclose(f); /* no biggie if it fails, file is already there */

	return(NULL);
}

char *db_release(char *dbname) {
	char *e;
	sabdb *stats;
	char path[8096];
	char buf[8096];

	/* the argument is the database to take under maintenance, see
	 * what Sabaoth can tell us about it */
	if ((e = SABAOTHgetStatus(&stats, dbname)) != MAL_SUCCEED) {
		snprintf(buf, sizeof(buf), "internal error: %s", e);
		GDKfree(e);
		return(strdup(buf));
	}

	if (stats == NULL) {
		snprintf(buf, sizeof(buf), "no such database: %s", dbname);
		return(strdup(buf));
	}

	if (stats->locked != 1) {
		SABAOTHfreeStatus(&stats);
		snprintf(buf, sizeof(buf), "database '%s' is not "
				"under maintenance", dbname);
		return(strdup(buf));
	}

	/* get this database out of maintenance mode */
	snprintf(path, sizeof(path), "%s/.maintenance", stats->path);
	SABAOTHfreeStatus(&stats);
	if (unlink(path) != 0) {
		snprintf(buf, sizeof(buf), "could not remove '%s' for '%s': %s",
				path, dbname, strerror(errno));
		return(strdup(buf));
	}

	return(NULL);
}
