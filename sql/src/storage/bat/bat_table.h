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

#ifndef BAT_TABLE_H
#define BAT_TABLE_H

#include "sql_storage.h"
#include "bat_storage.h"
#include "bat_utils.h"

/* initialize bat storage call back functions interface */
extern int bat_table_init( table_functions *tf );

extern BAT* delta_full_bat( sql_column *c, sql_delta *bat, int temp, BAT *d, BAT *s);

#endif /*BAT_TABLE_H*/
