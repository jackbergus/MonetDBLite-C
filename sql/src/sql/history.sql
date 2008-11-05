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

-- QUERY HISTORY
-- The query history mechanism of MonetDB/SQL relies on a few hooks 
-- inside the kernel. The most important one is the SQL global 
-- variable 'history', which is used by all sessions.
-- It is set automatically at the end of this script.

-- Whenever a query is compiled and added to the cache, it is also entered
-- into the 'queryHistory' table using a hardwired call to 'keepQuery'.

create table queryHistory(
	id wrd primary key,
	defined timestamp,	-- when entered into the cache
	name string,		-- database user name
	query string,
	parse bigint,		-- time in usec
	optimize bigint 	-- time in usec
);

-- Each query call is stored in the table callHistory using 'keepCall'.
-- At regular intervals the query history table should be cleaned.
-- This can be done manually on the SQL console, or be integrated
-- in the keepQuery and keepCall upon need.
-- The parameters are geared at understanding the resource claims
-- The footprint depicts the amount of memory used to keep all
-- relevant intermediates and persistent bats in memory .
-- The xsize parameter is indicative for the amount of intermediate
-- results produced. And rsize the non-rendered data to be shipped.
-- All timing in usec
create table callHistory(
	id wrd references queryHistory(id), -- references query plan
	ctime timestamp,	-- time the first statement was executed
	arguments string,
	xtime bigint,		-- time from the first statement until result export
	rtime bigint,		-- time to ship the result to the client
	cores int,			-- max number of parallel threads used
	load int,			-- percentage of CPU used by cores
	foot bigint, 		-- footprint for all bats in the plan
	xsize bigint,		-- storage size of intermediates created
	rsize bigint,		-- storage size of the result set
	tuples bigint,		-- number of tuples in the result set
	inblock bigint,		-- number of physical blocks read
	oublock bigint		-- number of physical blocks written
);

create view queryLog as
select * from queryHistory qd, callHistory ql
where qd.id= ql.id;

-- the signature is used in the kernel, don't change it
create procedure keepQuery(
	i wrd,
	query string,
	parse bigint,
	optimize bigint) 
begin
	insert into queryHistory
	values(i, now(), user, query, parse, optimize);
end;

-- the signature is used in the kernel, don't change it
create procedure keepCall(
	id wrd, -- references query plan
	ctime timestamp,	-- time the first statement was executed
	arguments string,
	xtime bigint,		-- time from the first statement until result export
	rtime bigint,		-- time to ship the result to the client
	cores int,			-- max number of parallel threads used
	load int,			-- percentage of CPU used by cores
	foot bigint, 		-- footprint for all bats in the plan
	xsize bigint,		-- storage size of intermediates created
	rsize bigint,		-- storage size of the result set
	tuples bigint,		-- number of tuples in the result set
	inblock bigint,		-- number of physical blocks read
	oublock bigint		-- number of physical blocks written
)
begin
	insert into callHistory
	values( id, ctime, arguments, xtime, rtime, cores,
		load, foot, xsize, rsize, tuples, inblock, oublock );
end;

set history=true;
