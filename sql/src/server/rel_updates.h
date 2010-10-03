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

#ifndef _REL_UPDATES_H_
#define _REL_UPDATES_H_

#include <stdio.h>
#include <stdarg.h>
#include <sql_list.h>
#include "sql_symbol.h"
#include "sql_statement.h"

extern sql_rel *rel_update( sql_rel *t, sql_rel *updates, list *exps);
extern sql_rel *rel_insert( sql_rel *t, sql_rel *inserts);
extern sql_rel *rel_delete( sql_rel *t, sql_rel *deletes);

extern sql_rel *rel_updates(mvc *sql, symbol *sym);

#endif /*_REL_UPDATES_H_*/
