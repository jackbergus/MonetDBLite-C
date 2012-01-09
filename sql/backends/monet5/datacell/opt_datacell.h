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
 * Copyright August 2008-2012 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef _OPT_DATACELL_
#define _OPT_DATACELL_
#include "opt_prelude.h"
#include "opt_support.h"
#include "opt_pipes.h"

#define OPTDEBUGdatacell  if (optDebug & (1 << DEBUG_OPT_DATACELL))
opt_export str OPTdatacell(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr p);
opt_export int OPTdatacellImplementation(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);

#endif
