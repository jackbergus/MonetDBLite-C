CREATE TABLE tab0(col0 INTEGER, col1 INTEGER, col2 INTEGER);
CREATE TABLE tab1(col0 INTEGER, col1 INTEGER, col2 INTEGER);
CREATE TABLE tab2(col0 INTEGER, col1 INTEGER, col2 INTEGER);

INSERT INTO tab0 VALUES (89,91,82), (35,97,1), (24,86,33);
INSERT INTO tab1 VALUES (64,10,57), (3,26,54), (80,13,96);
INSERT INTO tab2 VALUES (7,31,27), (79,17,38), (78,59,26);

SELECT DISTINCT * FROM tab2, tab1 AS cor0 CROSS JOIN tab1 WHERE cor0.col1 NOT BETWEEN tab2.col0 AND ( NULL );

SELECT ALL * FROM tab1, tab2, tab2 AS cor0 WHERE + tab2.col2 BETWEEN ( tab1.col0 ) AND NULL;

SELECT * FROM tab0, tab2 AS cor0 WHERE ( - tab0.col0 ) BETWEEN ( cor0.col2 ) AND ( NULL );

DROP TABLE tab0;
DROP TABLE tab1;
DROP TABLE tab2;
