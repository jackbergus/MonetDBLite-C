-- The contents of this file are subject to the MonetDB Public License
-- Version 1.1 (the "License"); you may not use this file except in
-- compliance with the License. You may obtain a copy of the License at
-- http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
--
-- Software distributed under the License is distributed on an "AS IS"
-- basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
-- License for the specific language governing rights and limitations
-- under the License.
--
-- The Original Code is the MonetDB Database System.
--
-- The Initial Developer of the Original Code is CWI.
-- Copyright August 2008- MonetDB B.V.
-- All Rights Reserved.

create function bbp () 
	returns table (id int, name string, htype string, ttype string, count BIGINT, refcnt int, lrefcnt int, location string, heat int, dirty string, status string, kind string) 
	external name sql.bbp;
