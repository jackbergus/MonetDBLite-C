INSERT INTO t1 SELECT * FROM t2;
INSERT INTO t2 SELECT * FROM t1;
COMMIT;
