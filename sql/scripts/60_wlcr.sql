-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0.  If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright 1997 - July 2008 CWI, August 2008 - 2017 MonetDB B.V.

-- Workload Capture and Replay

declare replaythreshold integer;
set replaythreshold = 0;

declare replaylog string;
set replaylog = '/tmp/wlcr';

create procedure setmaster()
external name wlcr.setmaster;

create procedure stopmaster()
external name wlcr.stop;

create procedure replay(dbname string)
external name wlcr.replay;

create procedure setreplica(dbname string)
external name wlcr.setreplica;

