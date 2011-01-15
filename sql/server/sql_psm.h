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

#ifndef _SQL_PSM_H_
#define _SQL_PSM_H_

#include <sql_list.h>
#include "sql_symbol.h"
#include "sql_statement.h"

extern stmt *psm(mvc *sql, symbol *sym);

extern stmt * sequential_block (mvc *sql, sql_subtype *res, dlist *blk, char *opt_name, int is_func);


#endif /* _SQL_PSM_H_ */
