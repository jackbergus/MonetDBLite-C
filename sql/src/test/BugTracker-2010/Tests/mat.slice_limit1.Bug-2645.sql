create table slice_test (x int, y int, val int);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 0, 1, 12985);
insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

insert into slice_test values ( 1, 1, 28323);
insert into slice_test values ( 3, 5, 89439);

set trace = 'none'; -- non-documented feature to not get any trace output
create function tracelog()
	returns table (
		event integer,		-- event counter
		clk varchar(20), 	-- wallclock, no mtime in kernel
		pc varchar(50), 	-- module.function[nr]
		thread int, 		-- thread identifier
		ticks integer, 		-- time in microseconds
		reads integer, 		-- number of blocks read
		writes integer, 	-- number of blocks written
		rbytes integer,		-- amount of bytes touched
		wbytes integer,		-- amount of bytes written
		type string,		-- return types
		stmt string			-- actual statement executed
	)
	external name sql.dump_trace;

TRACE select x,y from slice_test limit 1;
-- When mitosis was activated (i.e., the MAL plan contains mat.*() statements,
-- then there sould also be at least one mat.slice() statement.
SELECT count(*) FROM
( SELECT count(*) AS mat       FROM tracelog() WHERE stmt LIKE '% := mat.%'       ) as m,
( SELECT count(*) AS mat_slice FROM tracelog() WHERE stmt LIKE '% := mat.slice(%' ) as ms
WHERE ( mat = 0 AND mat_slice = 0 ) OR ( mat > 0 AND mat_slice > 0 );

TRACE select cast(x as string)||'-bla-'||cast(y as string) from slice_test limit 1;
-- When mitosis was activated (i.e., the MAL plan contains mat.*() statements,
-- then there sould also be at least one mat.slice() statement.
SELECT count(*) FROM
( SELECT count(*) AS mat       FROM tracelog() WHERE stmt LIKE '% := mat.%'       ) as m,
( SELECT count(*) AS mat_slice FROM tracelog() WHERE stmt LIKE '% := mat.slice(%' ) as ms
WHERE ( mat = 0 AND mat_slice = 0 ) OR ( mat > 0 AND mat_slice > 0 );

drop function tracelog;

drop table slice_test;

