/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

#ifndef _MAL_GARBAGE_
#define _MAL_GARBAGE_
#include "opt_support.h"

opt_export int OPTgarbageCollectorImplementation(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);

#define OPTDEBUGgarbageCollector  if ( optDebug & ((lng) 1 <<DEBUG_OPT_GARBAGE) )

#endif
