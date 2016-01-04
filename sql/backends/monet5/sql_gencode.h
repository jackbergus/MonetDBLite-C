/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

#ifndef _SQL2MAL_H
#define _SQL2MAL_H

#include <sql.h>
#include <mal_backend.h>
#include <sql_atom.h>
#include <sql_statement.h>
#include <sql_env.h>
#include <sql_mvc.h>
#include <mal_function.h>

sql5_export Symbol backend_dumpproc(backend *be, Client c, cq *q, stmt *s);
sql5_export int backend_callinline(backend *be, Client c, stmt *s, int add_end);
sql5_export void backend_call(backend *be, Client c, cq *q);
sql5_export void initSQLreferences(void);
sql5_export int monet5_resolve_function(ptr M, sql_func *f);
sql5_export int backend_create_func(backend *be, sql_func *f, list *restypes, list *ops);

#endif /* _SQL2MAL_H */
