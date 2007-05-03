create PROCEDURE p1()
BEGIN
	declare id int;
	set id = 0;
END;

create PROCEDURE p1(id int)
BEGIN
	declare id int;
	set id = 0;
END;


create PROCEDURE p2(id int)
BEGIN
	set id = 0;
END;

create PROCEDURE p3(id int, name varchar(1024))
BEGIN
	declare id int;
	set id = 0;
END;

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p1;

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p1();

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p2 (int, varchar(1024));

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p2 (int);

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p3 (int, varchar(1024));

select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

--to test the dependencies
--create PROCEDURE p1()
--BEGIN
--	declare id int;
--	set id = p1(1);
--END;

--DROP ALL PROCEDURE p1;

DROP ALL PROCEDURE p1 CASCADE;

select name from functions where name = 'p1' or name = 'f1';

create PROCEDURE p1()
BEGIN
	declare id int;
	set id = 0;
END;

DROP FUNCTION p1;
DROP FUNCTION p1 ();
DROP ALL FUNCTION p1;
select name from functions where name = 'p1' or name = 'p2' or name = 'p3';

DROP PROCEDURE p1;
