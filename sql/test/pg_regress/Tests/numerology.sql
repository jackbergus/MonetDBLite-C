--
-- NUMEROLOGY
-- Test various combinations of numeric types and functions.
--

--
-- Test implicit type conversions
-- This fails for Postgres v6.1 (and earlier?)
--  so let's try explicit conversions for now - tgl 97/05/07
--

CREATE TABLE INT2_TBL(f1 smallint);
INSERT INTO INT2_TBL(f1) VALUES ('0   ');
INSERT INTO INT2_TBL(f1) VALUES ('  1234 ');
INSERT INTO INT2_TBL(f1) VALUES ('    -1234');
INSERT INTO INT2_TBL(f1) VALUES ('32767');
INSERT INTO INT2_TBL(f1) VALUES ('-32767');

CREATE TABLE INT4_TBL(f1 integer);
INSERT INTO INT4_TBL(f1) VALUES ('   0  ');
INSERT INTO INT4_TBL(f1) VALUES ('123456     ');
INSERT INTO INT4_TBL(f1) VALUES ('    -123456');
INSERT INTO INT4_TBL(f1) VALUES ('2147483647');
INSERT INTO INT4_TBL(f1) VALUES ('-2147483647');

CREATE TABLE FLOAT8_TBL(f1 double);
INSERT INTO FLOAT8_TBL(f1) VALUES ('    0.0   ');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1004.30  ');
INSERT INTO FLOAT8_TBL(f1) VALUES ('   -34.84');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e+200');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e-200');


CREATE TABLE TEMP_FLOAT (f1 double);

INSERT INTO TEMP_FLOAT (f1)
  SELECT cast(f1 as double) FROM INT4_TBL;

INSERT INTO TEMP_FLOAT (f1)
  SELECT cast(f1 as double) FROM INT2_TBL;

SELECT '' AS ten, f1 FROM TEMP_FLOAT
  ORDER BY f1;

-- integer

CREATE TABLE TEMP_INT4 (f1 integer);

INSERT INTO TEMP_INT4 (f1)
  SELECT cast(f1 as integer) FROM FLOAT8_TBL
  WHERE (f1 > -2147483647) AND (f1 < 2147483647);

INSERT INTO TEMP_INT4 (f1)
  SELECT cast(f1 as integer) FROM INT2_TBL;

SELECT '' AS nine, f1 FROM TEMP_INT4
  ORDER BY f1;

-- smallint

CREATE TABLE TEMP_INT2 (f1 smallint);

INSERT INTO TEMP_INT2 (f1)
  SELECT cast(f1 as smallint) FROM FLOAT8_TBL
  WHERE (f1 >= -32767) AND (f1 <= 32767);

INSERT INTO TEMP_INT2 (f1)
  SELECT cast(f1 as smallint) FROM INT4_TBL
  WHERE (f1 >= -32767) AND (f1 <= 32767);

SELECT '' AS five, f1 FROM TEMP_INT2
  ORDER BY f1;

--
-- Group-by combinations
--

CREATE TABLE TEMP_GROUP (f1 integer, f2 integer, f3 double);

INSERT INTO TEMP_GROUP
  SELECT 1, (- i.f1), (- f.f1)
  FROM INT4_TBL i, FLOAT8_TBL f;

INSERT INTO TEMP_GROUP
  SELECT 2, i.f1, f.f1
  FROM INT4_TBL i, FLOAT8_TBL f;

SELECT DISTINCT f1 AS two FROM TEMP_GROUP;

SELECT f1 AS two, max(f3) AS max_float, min(f3) as min_float
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, max_float, min_float;

-- GROUP BY a result column name is not legal per SQL92, but we accept it
-- anyway (if the name is not the name of any column exposed by FROM).
SELECT f1 AS two, max(f3) AS max_float, min(f3) AS min_float
  FROM TEMP_GROUP
  GROUP BY two
  ORDER BY two, max_float, min_float;

SELECT f1 AS two, (max(f3) + 1) AS max_plus_1, (min(f3) - 1) AS min_minus_1
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, min_minus_1;

SELECT f1 AS two,
       max(f2) + min(f2) AS max_plus_min,
       min(f3) - 1 AS min_minus_1
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, min_minus_1;

DROP TABLE TEMP_INT2;

DROP TABLE TEMP_INT4;

DROP TABLE TEMP_FLOAT;

DROP TABLE TEMP_GROUP;


DROP TABLE FLOAT8_TBL;
DROP TABLE INT4_TBL;
DROP TABLE INT2_TBL;
