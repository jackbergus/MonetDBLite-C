create table test978043 (x integer, y varchar(1024));
insert into test978043 (y) select name from ptables where system = true;
drop table test978043;
