START TRANSACTION;

CREATE TABLE foo(bar integer);
INSERT INTO foo VALUES(0);
INSERT INTO foo VALUES(1);
INSERT INTO foo VALUES(2);
INSERT INTO foo VALUES(3);
INSERT INTO foo VALUES(4);
INSERT INTO foo VALUES(5);
INSERT INTO foo VALUES(6);
INSERT INTO foo VALUES(7);
INSERT INTO foo VALUES(8);
INSERT INTO foo VALUES(9);
INSERT INTO foo VALUES(10);
INSERT INTO foo VALUES(11);
INSERT INTO foo VALUES(12);
INSERT INTO foo VALUES(13);
INSERT INTO foo VALUES(14);
INSERT INTO foo VALUES(15);
INSERT INTO foo VALUES(16);
INSERT INTO foo VALUES(16);
INSERT INTO foo VALUES(18);
INSERT INTO foo VALUES(19);

PREPARE select * from foo where bar<?;
SET reply_size = 10;
exec 2(12);

ROLLBACK;
