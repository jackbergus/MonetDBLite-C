-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0.  If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.

-- Experimental oid index

create procedure sys.createorderindex(sys string, tab string, col string)
	external name sql.createorderindex;

create procedure sys.droporderindex(sys string, tab string, col string)
	external name sql.droporderindex;


