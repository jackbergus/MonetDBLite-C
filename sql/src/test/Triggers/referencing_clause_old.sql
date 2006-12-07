--this test only tests the sintax
--the semantic should also be tested after the syntax test

create table t1 (id int, name varchar(1024));

--test when trigger event is UPDATE
insert into t1 values(10, 'monetdb');
insert into t1 values(20, 'monet');


create trigger test1
	after update on t1 referencing old row as old_row
	for each row insert into t1 values(0, 'update_old_row');

create trigger test2
	after update on t1 referencing old row old_row
	for each row insert into t1 values(1, 'update_old_row');

create trigger test3
	after update on t1 referencing old as old_row
	for each row insert into t1 values(2, 'update_old_row');

create trigger test4
	after update on t1 referencing old old_row
	for each row insert into t1 values(3, 'update_old_row');


update t1 set name = 'mo' where id = 10;

select * from t1;

delete from t1 where id >1;

drop trigger test1;
drop trigger test2;
drop trigger test3;
drop trigger test4;

--test when trigger event is DELETE
insert into t1 values(10, 'monetdb');
insert into t1 values(20, 'monet');

create trigger test1
	after delete on t1 referencing old row as old_row
	for each row insert into t1 values(0, 'delete_old_row');

create trigger test2
	after delete on t1 referencing old row old_row
	for each row insert into t1 values(1, 'delete_old_row');

create trigger test3
	after delete on t1 referencing old as old_row
	for each row insert into t1 values(2, 'delete_old_row');

create trigger test4
	after delete on t1 referencing old old_row
	for each row insert into t1 values(3, 'delete_old_row');


select * from t1;

delete from t1 where id >1;

drop trigger test1;
drop trigger test2;
drop trigger test3;
drop trigger test4;

--test error messages
--old row and old table are not allowed if the Trigger event is INSERT

insert into t1 values(10, 'monetdb');
insert into t1 values(20, 'monet');

create trigger test1
	after insert on t1 referencing old row as old_row
	for each row insert into t1 values(0, 'insert_old_row');

create trigger test2
	after insert on t1 referencing old row old_row
	for each row insert into t1 values(1, 'insert_old_row');

create trigger test3
	after insert on t1 referencing old as old_row
	for each row insert into t1 values(2, 'insert_old_row');

create trigger test4
	after insert on t1 referencing old old_row
	for each row insert into t1 values(3, 'insert_old_row');


select * from t1;

delete from t1 where id >1;

--test with old row and old table and mixed 

insert into t1 values(10, 'monetdb');
insert into t1 values(20, 'monet');

create trigger test1
	after update on t1 referencing old row as old_row, old table as old_table
	for each row insert into t1 values(0, 'insert_old_row_table');

create trigger test2
	after update on t1 referencing old row old_row, new row as new_row
	for each row insert into t1 values(1, 'insert_old_new_row');

create trigger test3
	after update on t1 referencing old table as old_table, new table as new_table
	for each row insert into t1 values(2, 'insert_old__new_table');

create trigger test4
	after update on t1 referencing old row as old_row, new table as new_table
	for each row insert into t1 values(3, 'insert_old_row_new_table');

create trigger test5
	after update on t1 referencing old table as old_table, new row as new_row
	for each row insert into t1 values(3, 'insert_old_table_new_row');


select * from t1;

delete from t1 where id >1;

drop trigger test1;
drop trigger test2;
drop trigger test3;
drop trigger test4;
drop trigger test5;

--test stanger combinations

insert into t1 values(10, 'monetdb');
insert into t1 values(20, 'monet');

create trigger test1
	after update on t1 referencing old row as old_row, new table as new_table
	for each row insert into t1 values(0, 'update_old_row__new_table');

create trigger test2
	after insert on t1 referencing old row old_row, new row as new_row
	for each row insert into t1 values(1, 'insert_old_new_row');

create trigger test3
	after delete on t1 referencing old row old_row, new row as new_row
	for each row insert into t1 values(1, 'delete_old_new_row');

create trigger test4
	after delete on t1 referencing old row as old_row, new table as new_table
	for each row insert into t1 values(3, 'delete_old_row_new_table');

create trigger test5
	after insert on t1 referencing old table as old_table, new row as new_row
	for each row insert into t1 values(3, 'insert_old_table_new_row');


select * from t1;

delete from t1 where id >1;

drop trigger test1;
drop trigger test2;
drop trigger test3;
drop trigger test4;
drop trigger test5;

--Cleanup
drop table t1;
