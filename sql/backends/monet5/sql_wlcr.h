/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2017 MonetDB B.V.
 */

#ifndef SQL_WLR_H
#define SQL_WLR_H

#include <streams.h>
#include <mal.h>
#include <mal_client.h>
#include <sql_mvc.h>
#include <sql_qc.h>

sql_export str WLRinit(void);
sql_export str WLRreplicate(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRwaitformaster(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRtransaction(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRreplaythreshold(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRfinish(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRquery(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRcatalog(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRchange(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRgeneric(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRappend(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRdelete(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRupdate(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
sql_export str WLRclear_table(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);

#endif /*SQL_WLR_H*/
