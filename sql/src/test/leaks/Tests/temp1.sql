create temporary table x  ( i int, j int );

select 'transient', count(*) from bbp() as bbp where kind = 'tran';
select 'persistent', count(*) from bbp() as bbp where kind = 'pers';
