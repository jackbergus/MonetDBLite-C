SELECT DISTINCT - 0 AS col1;
CREATE TABLE tab0(col0 INTEGER, col1 INTEGER, col2 INTEGER);
CREATE TABLE tab2(col0 INTEGER, col1 INTEGER, col2 INTEGER);
SELECT DISTINCT - COUNT ( DISTINCT 74 ) AS col1 FROM tab0 AS cor0 CROSS JOIN tab2 AS cor1;
DROP TABLE tab2;
DROP TABLE tab0;

