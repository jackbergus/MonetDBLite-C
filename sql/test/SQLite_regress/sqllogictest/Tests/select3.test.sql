CREATE TABLE t1(a INTEGER, b INTEGER, c INTEGER, d INTEGER, e INTEGER);
INSERT INTO t1(e,c,b,d,a) VALUES(NULL,102,NULL,101,104);
INSERT INTO t1(a,c,d,e,b) VALUES(107,106,108,109,105);
INSERT INTO t1(e,d,b,a,c) VALUES(110,114,112,NULL,113);
INSERT INTO t1(d,c,e,a,b) VALUES(116,119,117,115,NULL);
INSERT INTO t1(c,d,b,e,a) VALUES(123,122,124,NULL,121);
INSERT INTO t1(a,d,b,e,c) VALUES(127,128,129,126,125);
INSERT INTO t1(e,c,a,d,b) VALUES(132,134,131,133,130);
INSERT INTO t1(a,d,b,e,c) VALUES(138,136,139,135,137);
INSERT INTO t1(e,c,d,a,b) VALUES(144,141,140,142,143);
INSERT INTO t1(b,a,e,d,c) VALUES(145,149,146,NULL,147);
INSERT INTO t1(b,c,a,d,e) VALUES(151,150,153,NULL,NULL);
INSERT INTO t1(c,e,a,d,b) VALUES(155,157,159,NULL,158);
INSERT INTO t1(c,b,a,d,e) VALUES(161,160,163,164,162);
INSERT INTO t1(b,d,a,e,c) VALUES(167,NULL,168,165,166);
INSERT INTO t1(d,b,c,e,a) VALUES(171,170,172,173,174);
INSERT INTO t1(e,c,a,d,b) VALUES(177,176,179,NULL,175);
INSERT INTO t1(b,e,a,d,c) VALUES(181,180,182,183,184);
INSERT INTO t1(c,a,b,e,d) VALUES(187,188,186,189,185);
INSERT INTO t1(d,b,c,e,a) VALUES(190,194,193,192,191);
INSERT INTO t1(a,e,b,d,c) VALUES(199,197,198,196,195);
INSERT INTO t1(b,c,d,a,e) VALUES(NULL,202,203,201,204);
INSERT INTO t1(c,e,a,b,d) VALUES(208,NULL,NULL,206,207);
INSERT INTO t1(c,e,a,d,b) VALUES(214,210,213,212,211);
INSERT INTO t1(b,c,a,d,e) VALUES(218,215,216,217,219);
INSERT INTO t1(b,e,d,a,c) VALUES(223,221,222,220,224);
INSERT INTO t1(d,e,b,a,c) VALUES(226,227,228,229,225);
INSERT INTO t1(a,c,b,e,d) VALUES(234,231,232,230,233);
INSERT INTO t1(e,b,a,c,d) VALUES(237,236,239,NULL,238);
INSERT INTO t1(e,c,b,a,d) VALUES(NULL,244,240,243,NULL);
INSERT INTO t1(e,d,c,b,a) VALUES(246,248,247,249,245);

-- query I rowsort x0
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query I rowsort x0
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query II rowsort x1
SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
;
-- 60 values hashing to f5182c92f97475673097a499ce82ae64

-- query II rowsort x1
SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to f5182c92f97475673097a499ce82ae64

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,4
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
 ORDER BY 3,2,5,1,4
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x2
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2,1,5
;
-- 55 values hashing to 625899fde153a4e776b22705ac30f7fb

-- query IIIII rowsort x3
SELECT a,
       a+b*2+c*3+d*4,
       e,
       d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
;
-- 15 values hashing to a9ad8d5d73081dc1d90969f10a494afa

-- query IIIII rowsort x3
SELECT a,
       a+b*2+c*3+d*4,
       e,
       d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 4,2,3,5
;
-- 15 values hashing to a9ad8d5d73081dc1d90969f10a494afa

-- query III rowsort x4
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 90 values hashing to 0f041784f194ec63cf2a252e8dc9b8d2

-- query III rowsort x4
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 1,2,3
;
-- 90 values hashing to 0f041784f194ec63cf2a252e8dc9b8d2

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND b>c
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND b>c
 ORDER BY 3,2
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,3,1
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
   AND b>c
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 1,2
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
;

-- query IIII rowsort x5
SELECT b,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
 ORDER BY 4,2
;

-- query IIIII rowsort x6
SELECT e,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
;
-- 80 values hashing to 1165928153cf03fadf7d270e4efc8a8b

-- query IIIII rowsort x6
SELECT e,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
 ORDER BY 3,1,5,2,4
;
-- 80 values hashing to 1165928153cf03fadf7d270e4efc8a8b

-- query IIIII rowsort x6
SELECT e,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
;
-- 80 values hashing to 1165928153cf03fadf7d270e4efc8a8b

-- query IIIII rowsort x6
SELECT e,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 4,1,5,3,2
;
-- 80 values hashing to 1165928153cf03fadf7d270e4efc8a8b

-- query I rowsort x7
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 30 values hashing to f54b614acd4cb798dba29ba05152f26d

-- query I rowsort x7
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to f54b614acd4cb798dba29ba05152f26d

-- query I rowsort x8
SELECT d-e
  FROM t1
 WHERE b>c
    OR a>b
;
-- 24 values hashing to b60e9de3a50740f40cca35b98a056b8c

-- query I rowsort x8
SELECT d-e
  FROM t1
 WHERE b>c
    OR a>b
 ORDER BY 1
;
-- 24 values hashing to b60e9de3a50740f40cca35b98a056b8c

-- query I rowsort x9
SELECT d
  FROM t1
 WHERE a>b
    OR d>e
;
-- 22 values hashing to 785796b507b0f3998ec9b04e74fa565b

-- query I rowsort x9
SELECT d
  FROM t1
 WHERE a>b
    OR d>e
 ORDER BY 1
;
-- 22 values hashing to 785796b507b0f3998ec9b04e74fa565b

-- query I rowsort x9
SELECT d
  FROM t1
 WHERE d>e
    OR a>b
;
-- 22 values hashing to 785796b507b0f3998ec9b04e74fa565b

-- query I rowsort x9
SELECT d
  FROM t1
 WHERE d>e
    OR a>b
 ORDER BY 1
;
-- 22 values hashing to 785796b507b0f3998ec9b04e74fa565b

-- query IIIIIII rowsort x10
SELECT abs(a),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE a>b
;
-- 119 values hashing to de49937f8a76d58e90ee610d71c5d209

-- query IIIIIII rowsort x10
SELECT abs(a),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE a>b
 ORDER BY 7,3,5,1,6
;
-- 119 values hashing to de49937f8a76d58e90ee610d71c5d209

-- query III rowsort x11
SELECT d,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 90 values hashing to df4215319598e8101abcb5c7509649e8

-- query III rowsort x11
SELECT d,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,3
;
-- 90 values hashing to df4215319598e8101abcb5c7509649e8

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
 ORDER BY 2,1,3
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1,3
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,1
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR d NOT BETWEEN 110 AND 150
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query III rowsort x12
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 72 values hashing to 5026537fcfcc7d06e2928e16f9b160fc

-- query IIIIII rowsort x13
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       (a+b+c+d+e)/5,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 180 values hashing to 704e7ed2a17c496a3ca2ea1e4441eb40

-- query IIIIII rowsort x13
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       (a+b+c+d+e)/5,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 4,5
;
-- 180 values hashing to 704e7ed2a17c496a3ca2ea1e4441eb40

-- query IIIIII rowsort x14
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       b-c,
       c
  FROM t1
 WHERE c>d
;
-- 78 values hashing to 014a4e77c58e1d60b4cbbcae9e6fd9f8

-- query IIIIII rowsort x14
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       b-c,
       c
  FROM t1
 WHERE c>d
 ORDER BY 1,5,3,2
;
-- 78 values hashing to 014a4e77c58e1d60b4cbbcae9e6fd9f8

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 2,1
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query II rowsort x15
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 1,2
;
-- 14 values hashing to 16eb6166e5b95fff42a33edd3a48d743

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 5,1,3,4,2,6
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 6,5,1,2,4
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2,3,4,6
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIIII rowsort x16
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c,
       b,
       abs(a),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
 ORDER BY 4,3,1
;
-- 54 values hashing to 53281ade33cc2a4f0c7178ec3fb32ac9

-- query IIIII rowsort x17
SELECT a-b,
       d,
       c-d,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
;
-- 125 values hashing to 576840b23ec5d6d330aa4d3e0dc39f72

-- query IIIII rowsort x17
SELECT a-b,
       d,
       c-d,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
 ORDER BY 3,5,1,2
;
-- 125 values hashing to 576840b23ec5d6d330aa4d3e0dc39f72

-- query IIIII rowsort x17
SELECT a-b,
       d,
       c-d,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
;
-- 125 values hashing to 576840b23ec5d6d330aa4d3e0dc39f72

-- query IIIII rowsort x17
SELECT a-b,
       d,
       c-d,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
 ORDER BY 5,1,3
;
-- 125 values hashing to 576840b23ec5d6d330aa4d3e0dc39f72

-- query IIIII rowsort x18
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       a+b*2+c*3+d*4,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to 8db9d8b1ba3193ca98ca00b75b91c254

-- query IIIII rowsort x18
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       a+b*2+c*3+d*4,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,1,4
;
-- 50 values hashing to 8db9d8b1ba3193ca98ca00b75b91c254

-- query III rowsort x19
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
;
-- 90 values hashing to 92f7b45a92fe532b1299be0000c55ad3

-- query III rowsort x19
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
 ORDER BY 3,2,1
;
-- 90 values hashing to 92f7b45a92fe532b1299be0000c55ad3

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 3,2,4,5
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE b>c
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE b>c
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2,4
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIII rowsort x20
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,1,4,3,2
;
-- -2
-- 1902
-- 129
-- 127
-- 127

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,5,4,7,1,3
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
 ORDER BY 4,3,1
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query IIIIIII rowsort x21
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       c,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 5,4,2
;
-- 49 values hashing to c6962d3e1379a8ba798e11d0212e4c52

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,3
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
 ORDER BY 3,1,2
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND (e>c OR e<d)
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query III rowsort x22
SELECT a,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND (e>c OR e<d)
 ORDER BY 2,1
;
-- 24 values hashing to 751c63ea90408c884abfeed87b4bb660

-- query IIIIIII rowsort x23
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       d-e,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
;
-- 182 values hashing to a296d6044702bfcca834c0a3e55f6ba2

-- query IIIIIII rowsort x23
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       d-e,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
 ORDER BY 7,5,6
;
-- 182 values hashing to a296d6044702bfcca834c0a3e55f6ba2

-- query IIIIIII rowsort x23
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       d-e,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 182 values hashing to a296d6044702bfcca834c0a3e55f6ba2

-- query IIIIIII rowsort x23
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       d-e,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,6,4,5,3,1,7
;
-- 182 values hashing to a296d6044702bfcca834c0a3e55f6ba2

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND a>b
;

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND a>b
 ORDER BY 2,1
;

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND a>b
   AND (e>a AND e<b)
;

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND a>b
   AND (e>a AND e<b)
 ORDER BY 1,2
;

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND a>b
;

-- query II rowsort x24
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND a>b
 ORDER BY 2,1
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 3,1,4,2
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,4
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 3,4,1,2
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x25
SELECT a+b*2+c*3,
       abs(b-c),
       d,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND (c<=d-2 OR c>=d+2)
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,1,2
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
   AND a>b
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
   AND a>b
 ORDER BY 3,1
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND a>b
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 1,2,3
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
;

-- query III rowsort x26
SELECT b-c,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2,3
;

-- query IIIII rowsort x27
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       e,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
;
-- 65 values hashing to e7caf19cab674a9b810cf6eecbc4dd1f

-- query IIIII rowsort x27
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       e,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
 ORDER BY 2,3
;
-- 65 values hashing to e7caf19cab674a9b810cf6eecbc4dd1f

-- query I rowsort x28
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query I rowsort x28
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query IIIIII rowsort x29
SELECT a+b*2+c*3+d*4,
       a-b,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
;
-- 96 values hashing to 666008eb6a2f5ac71610c3222b7e526b

-- query IIIIII rowsort x29
SELECT a+b*2+c*3+d*4,
       a-b,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 6,5,3,4
;
-- 96 values hashing to 666008eb6a2f5ac71610c3222b7e526b

-- query III rowsort x30
SELECT a-b,
       a,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
;
-- 24 values hashing to ee8e768686f5954a5ddd0a36e7dc490e

-- query III rowsort x30
SELECT a-b,
       a,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 1,3,2
;
-- 24 values hashing to ee8e768686f5954a5ddd0a36e7dc490e

-- query III rowsort x30
SELECT a-b,
       a,
       c
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
;
-- 24 values hashing to ee8e768686f5954a5ddd0a36e7dc490e

-- query III rowsort x30
SELECT a-b,
       a,
       c
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,3,1
;
-- 24 values hashing to ee8e768686f5954a5ddd0a36e7dc490e

-- query IIIIII rowsort x31
SELECT b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       b,
       c-d,
       a+b*2
  FROM t1
;
-- 180 values hashing to e803e5295107a58c50597423e0b571b7

-- query IIIIII rowsort x31
SELECT b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       b,
       c-d,
       a+b*2
  FROM t1
 ORDER BY 4,5,1,2,3
;
-- 180 values hashing to e803e5295107a58c50597423e0b571b7

-- query IIIII rowsort x32
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 804f8389c33b35bc51e0fc6d89adf857

-- query IIIII rowsort x32
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,2,4
;
-- 10 values hashing to 804f8389c33b35bc51e0fc6d89adf857

-- query I rowsort x33
SELECT a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 18 values hashing to 5d782557f607a892c3a0d52c06aae3ca

-- query I rowsort x33
SELECT a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 1
;
-- 18 values hashing to 5d782557f607a892c3a0d52c06aae3ca

-- query I rowsort x33
SELECT a+b*2
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 18 values hashing to 5d782557f607a892c3a0d52c06aae3ca

-- query I rowsort x33
SELECT a+b*2
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 18 values hashing to 5d782557f607a892c3a0d52c06aae3ca

-- query IIIIII rowsort x34
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       a,
       d-e,
       b
  FROM t1
 WHERE d>e
;
-- 66 values hashing to 3bcdb2890ff4528da0929919501bb028

-- query IIIIII rowsort x34
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       a,
       d-e,
       b
  FROM t1
 WHERE d>e
 ORDER BY 6,2,1,4,5,3
;
-- 66 values hashing to 3bcdb2890ff4528da0929919501bb028

-- query IIIIII rowsort x35
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       abs(b-c),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 114 values hashing to 79b36002d97af06b70dbd04e09768ea6

-- query IIIIII rowsort x35
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       abs(b-c),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,4,5,3
;
-- 114 values hashing to 79b36002d97af06b70dbd04e09768ea6

-- query IIIIII rowsort x35
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       abs(b-c),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR (e>a AND e<b)
;
-- 114 values hashing to 79b36002d97af06b70dbd04e09768ea6

-- query IIIIII rowsort x35
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       abs(b-c),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR (e>a AND e<b)
 ORDER BY 3,4,6,1,5
;
-- 114 values hashing to 79b36002d97af06b70dbd04e09768ea6

-- query III rowsort x36
SELECT e,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
;
-- 33 values hashing to acb7faddee415dc26b2a6146b018a2e5

-- query III rowsort x36
SELECT e,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 33 values hashing to acb7faddee415dc26b2a6146b018a2e5

-- query III rowsort x36
SELECT e,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
;
-- 33 values hashing to acb7faddee415dc26b2a6146b018a2e5

-- query III rowsort x36
SELECT e,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
 ORDER BY 2,1,3
;
-- 33 values hashing to acb7faddee415dc26b2a6146b018a2e5

-- query III rowsort x37
SELECT (a+b+c+d+e)/5,
       d-e,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 21 values hashing to 8604975782e66cb0d8a41bbc6616943b

-- query III rowsort x37
SELECT (a+b+c+d+e)/5,
       d-e,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 1,2,3
;
-- 21 values hashing to 8604975782e66cb0d8a41bbc6616943b

-- query III rowsort x37
SELECT (a+b+c+d+e)/5,
       d-e,
       d
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to 8604975782e66cb0d8a41bbc6616943b

-- query III rowsort x37
SELECT (a+b+c+d+e)/5,
       d-e,
       d
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,3,1
;
-- 21 values hashing to 8604975782e66cb0d8a41bbc6616943b

-- query III rowsort x38
SELECT a,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 90 values hashing to 04e6fdff07da4c8f095e13082e8e00f4

-- query III rowsort x38
SELECT a,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 1,3
;
-- 90 values hashing to 04e6fdff07da4c8f095e13082e8e00f4

-- query IIIIIII rowsort x39
SELECT abs(b-c),
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
;
-- 210 values hashing to 00d975fcd333dceae276901cb144bc31

-- query IIIIIII rowsort x39
SELECT abs(b-c),
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 4,3,1,7,2
;
-- 210 values hashing to 00d975fcd333dceae276901cb144bc31

-- query I rowsort x40
SELECT a-b
  FROM t1
 WHERE a>b
    OR c BETWEEN b-2 AND d+2
;
-- 24 values hashing to e06610bd9fa1097f42e363fcc8d6546f

-- query I rowsort x40
SELECT a-b
  FROM t1
 WHERE a>b
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 24 values hashing to e06610bd9fa1097f42e363fcc8d6546f

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND c>d
;
-- 1918

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND c>d
 ORDER BY 1
;
-- 1918

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND b>c
   AND d NOT BETWEEN 110 AND 150
;
-- 1918

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND b>c
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 1918

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
   AND b>c
;
-- 1918

-- query I rowsort x41
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
   AND b>c
 ORDER BY 1
;
-- 1918

-- query I rowsort x42
SELECT a+b*2+c*3
  FROM t1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query I rowsort x42
SELECT a+b*2+c*3
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,1,2
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 1,3
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND (a>b-2 AND a<b+2)
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query III rowsort x43
SELECT b,
       a+b*2,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 139
-- 416
-- 138
-- 143
-- 428
-- 142

-- query IIIIIII rowsort x44
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
;
-- 56 values hashing to a50fc61a88af6982597f73b3314f59da

-- query IIIIIII rowsort x44
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 4,2
;
-- 56 values hashing to a50fc61a88af6982597f73b3314f59da

-- query IIIIIII rowsort x44
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 56 values hashing to a50fc61a88af6982597f73b3314f59da

-- query IIIIIII rowsort x44
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 6,1,5,3
;
-- 56 values hashing to a50fc61a88af6982597f73b3314f59da

-- query IIIII rowsort x45
SELECT c-d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 150 values hashing to 0791d44e972a767c2504291f010d4972

-- query IIIII rowsort x45
SELECT c-d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,4,3
;
-- 150 values hashing to 0791d44e972a767c2504291f010d4972

-- query IIIIII rowsort x46
SELECT c-d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 12 values hashing to 9eaadc75d7510bdbda42f0e20cb844ce

-- query IIIIII rowsort x46
SELECT c-d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3,2,5,4,6
;
-- 12 values hashing to 9eaadc75d7510bdbda42f0e20cb844ce

-- query IIIIII rowsort x47
SELECT b-c,
       a+b*2+c*3,
       abs(b-c),
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
;
-- 18 values hashing to 7c35a636d311a88ef8bb09c15b20ad71

-- query IIIIII rowsort x47
SELECT b-c,
       a+b*2+c*3,
       abs(b-c),
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,1,3,6,2
;
-- 18 values hashing to 7c35a636d311a88ef8bb09c15b20ad71

-- query IIIIII rowsort x47
SELECT b-c,
       a+b*2+c*3,
       abs(b-c),
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 18 values hashing to 7c35a636d311a88ef8bb09c15b20ad71

-- query IIIIII rowsort x47
SELECT b-c,
       a+b*2+c*3,
       abs(b-c),
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,3
;
-- 18 values hashing to 7c35a636d311a88ef8bb09c15b20ad71

-- query IIIII rowsort x48
SELECT c,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to cae83537053e6a1c420be61ebf16a9de

-- query IIIII rowsort x48
SELECT c,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,5,2,1,3
;
-- 130 values hashing to cae83537053e6a1c420be61ebf16a9de

-- query IIIIII rowsort x49
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       abs(a),
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
;
-- 114 values hashing to 0446a9accb80cccec6bc4d954353b3d5

-- query IIIIII rowsort x49
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       abs(a),
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 4,1,3
;
-- 114 values hashing to 0446a9accb80cccec6bc4d954353b3d5

-- query IIIIII rowsort x49
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       abs(a),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
;
-- 114 values hashing to 0446a9accb80cccec6bc4d954353b3d5

-- query IIIIII rowsort x49
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       abs(a),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,2,1,6
;
-- 114 values hashing to 0446a9accb80cccec6bc4d954353b3d5

-- query IIIII rowsort x50
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
;

-- query IIIII rowsort x50
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,5,4,1
;

-- query IIIII rowsort x50
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x50
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,2
;

-- query IIIIIII rowsort x51
SELECT e,
       abs(a),
       a,
       b-c,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 119 values hashing to 7b07e3c0f239408babff1fbcf766a95b

-- query IIIIIII rowsort x51
SELECT e,
       abs(a),
       a,
       b-c,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,3
;
-- 119 values hashing to 7b07e3c0f239408babff1fbcf766a95b

-- query IIIIIII rowsort x52
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       (a+b+c+d+e)/5,
       c-d,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 14 values hashing to ed079ee74d21042f3af7d5b35a3f49c7

-- query IIIIIII rowsort x52
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       (a+b+c+d+e)/5,
       c-d,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 7,3
;
-- 14 values hashing to ed079ee74d21042f3af7d5b35a3f49c7

-- query II rowsort x53
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 60 values hashing to 0bdb710608975d536cdcc249e7766277

-- query II rowsort x53
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 0bdb710608975d536cdcc249e7766277

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR d>e
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR d>e
 ORDER BY 2,4,3,5
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR b>c
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR b>c
 ORDER BY 1,2,3
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR d>e
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query IIIIII rowsort x54
SELECT a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR d>e
 ORDER BY 3,4,5,6,1,2
;
-- 156 values hashing to 0e7e4265ef0ff00ba6f163a5f391c6b6

-- query I rowsort x55
SELECT b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 26 values hashing to b5a149362df4e3e63625f989babd69f3

-- query I rowsort x55
SELECT b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 26 values hashing to b5a149362df4e3e63625f989babd69f3

-- query IIIII rowsort x56
SELECT c,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       abs(b-c),
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
;
-- 106
-- 1067
-- 1612
-- 1
-- -1

-- query IIIII rowsort x56
SELECT c,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       abs(b-c),
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,5,2,3
;
-- 106
-- 1067
-- 1612
-- 1
-- -1

-- query IIIII rowsort x57
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
;
-- 110 values hashing to eb1aebf3bea3b025c376cea652805430

-- query IIIII rowsort x57
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,5
;
-- 110 values hashing to eb1aebf3bea3b025c376cea652805430

-- query IIIII rowsort x57
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
;
-- 110 values hashing to eb1aebf3bea3b025c376cea652805430

-- query IIIII rowsort x57
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,3
;
-- 110 values hashing to eb1aebf3bea3b025c376cea652805430

-- query IIII rowsort x58
SELECT b-c,
       a+b*2,
       c,
       a+b*2+c*3+d*4
  FROM t1
;
-- 120 values hashing to 06fab51c5d572097d0468c8bfc192e5e

-- query IIII rowsort x58
SELECT b-c,
       a+b*2,
       c,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 3,1
;
-- 120 values hashing to 06fab51c5d572097d0468c8bfc192e5e

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND d>e
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND d>e
 ORDER BY 1,3,2
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
   AND a>b
   AND (a>b-2 AND a<b+2)
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
   AND a>b
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND a>b
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 3,2,1
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND d>e
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query III rowsort x59
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND d>e
 ORDER BY 1,2
;
-- 333
-- 132
-- 391
-- 333
-- 182
-- 544

-- query I rowsort x60
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 30 values hashing to 0075716954dbc259c5e8ac65568a6fa7

-- query I rowsort x60
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 0075716954dbc259c5e8ac65568a6fa7

-- query III rowsort x61
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to 648507a4dbddda84349348d9e729301a

-- query III rowsort x61
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,3
;
-- 24 values hashing to 648507a4dbddda84349348d9e729301a

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND (e>a AND e<b)
;
-- 1
-- 2878
-- 579

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND (e>a AND e<b)
 ORDER BY 3,1,2
;
-- 1
-- 2878
-- 579

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
;
-- 1
-- 2878
-- 579

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
 ORDER BY 2,1
;
-- 1
-- 2878
-- 579

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND b>c
;
-- 1
-- 2878
-- 579

-- query III rowsort x62
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND b>c
 ORDER BY 1,3,2
;
-- 1
-- 2878
-- 579

-- query IIIIII rowsort x63
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
;
-- 18 values hashing to 9d671178044eae485f5cf0534e508635

-- query IIIIII rowsort x63
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,1,5,4,6
;
-- 18 values hashing to 9d671178044eae485f5cf0534e508635

-- query II rowsort x64
SELECT d,
       c-d
  FROM t1
;
-- 60 values hashing to 91395206c5a9ae2e3ba90eaaf9fbcad3

-- query II rowsort x64
SELECT d,
       c-d
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 91395206c5a9ae2e3ba90eaaf9fbcad3

-- query I rowsort x65
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
;
-- 0

-- query I rowsort x65
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 0

-- query I rowsort x65
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 0

-- query I rowsort x65
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 0

-- query I rowsort x66
SELECT e
  FROM t1
 WHERE b>c
   AND d>e
;
-- 126
-- 135
-- 230
-- 246

-- query I rowsort x66
SELECT e
  FROM t1
 WHERE b>c
   AND d>e
 ORDER BY 1
;
-- 126
-- 135
-- 230
-- 246

-- query I rowsort x67
SELECT abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to ee5e469b70e69479c72ba919407850bf

-- query I rowsort x67
SELECT abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to ee5e469b70e69479c72ba919407850bf

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query I rowsort x68
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL

-- query II rowsort x69
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 42 values hashing to a9be16fd86cadea20cb762d9a2090294

-- query II rowsort x69
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 1,2
;
-- 42 values hashing to a9be16fd86cadea20cb762d9a2090294

-- query IIII rowsort x70
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
;
-- 44 values hashing to 4e3ac00cf2b93946420454f833057599

-- query IIII rowsort x70
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
 ORDER BY 3,1,2
;
-- 44 values hashing to 4e3ac00cf2b93946420454f833057599

-- query IIIIII rowsort x71
SELECT a+b*2+c*3+d*4+e*5,
       a,
       d,
       (a+b+c+d+e)/5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 180 values hashing to 56e98b4b3a1fa4e42c1c1ab37ec6b275

-- query IIIIII rowsort x71
SELECT a+b*2+c*3+d*4+e*5,
       a,
       d,
       (a+b+c+d+e)/5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 1,2
;
-- 180 values hashing to 56e98b4b3a1fa4e42c1c1ab37ec6b275

-- query IIIII rowsort x72
SELECT a,
       abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
;
-- 100 values hashing to 35ca6f386a2103ff887bdabee6e9f57b

-- query IIIII rowsort x72
SELECT a,
       abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
 ORDER BY 3,1,2
;
-- 100 values hashing to 35ca6f386a2103ff887bdabee6e9f57b

-- query IIIII rowsort x72
SELECT a,
       abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
;
-- 100 values hashing to 35ca6f386a2103ff887bdabee6e9f57b

-- query IIIII rowsort x72
SELECT a,
       abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
 ORDER BY 2,4,5,3
;
-- 100 values hashing to 35ca6f386a2103ff887bdabee6e9f57b

-- query IIIIIII rowsort x73
SELECT abs(b-c),
       d-e,
       c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
;
-- 63 values hashing to af765695bd98c6763d19286966e6a502

-- query IIIIIII rowsort x73
SELECT abs(b-c),
       d-e,
       c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 1,3,7,2,5,4,6
;
-- 63 values hashing to af765695bd98c6763d19286966e6a502

-- query IIIIIII rowsort x73
SELECT abs(b-c),
       d-e,
       c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
;
-- 63 values hashing to af765695bd98c6763d19286966e6a502

-- query IIIIIII rowsort x73
SELECT abs(b-c),
       d-e,
       c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 7,3,4,6,2,1,5
;
-- 63 values hashing to af765695bd98c6763d19286966e6a502

-- query II rowsort x74
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 34 values hashing to 7321b17b6a187df6e53c93c4a884c4ef

-- query II rowsort x74
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 34 values hashing to 7321b17b6a187df6e53c93c4a884c4ef

-- query IIIII rowsort x75
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a+b*2,
       d-e,
       b
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 55 values hashing to 6cd575f6cfe055cbb767f7016afe50dc

-- query IIIII rowsort x75
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a+b*2,
       d-e,
       b
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2,1
;
-- 55 values hashing to 6cd575f6cfe055cbb767f7016afe50dc

-- query IIIIII rowsort x76
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
;
-- 180 values hashing to 42b78d57d03b1997e8e426f74ce3dcb4

-- query IIIIII rowsort x76
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 ORDER BY 6,5
;
-- 180 values hashing to 42b78d57d03b1997e8e426f74ce3dcb4

-- query IIIII rowsort x77
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 40 values hashing to 8101d4d66a4c1d7abfcde0fc4f8d485b

-- query IIIII rowsort x77
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,5,4
;
-- 40 values hashing to 8101d4d66a4c1d7abfcde0fc4f8d485b

-- query IIIII rowsort x78
SELECT a+b*2,
       abs(a),
       e,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 150 values hashing to 38b77b849a6098cb98a50e86ed967db9

-- query IIIII rowsort x78
SELECT a+b*2,
       abs(a),
       e,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 5,2
;
-- 150 values hashing to 38b77b849a6098cb98a50e86ed967db9

-- query IIIIIII rowsort x79
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       c,
       e,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR a>b
;
-- 196 values hashing to ef668449d0dcfaf39a9176380099a7ba

-- query IIIIIII rowsort x79
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       c,
       e,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR a>b
 ORDER BY 4,2,5
;
-- 196 values hashing to ef668449d0dcfaf39a9176380099a7ba

-- query IIIIIII rowsort x79
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       c,
       e,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
    OR d NOT BETWEEN 110 AND 150
;
-- 196 values hashing to ef668449d0dcfaf39a9176380099a7ba

-- query IIIIIII rowsort x79
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       c,
       e,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,6,7,5,3
;
-- 196 values hashing to ef668449d0dcfaf39a9176380099a7ba

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE a>b
    OR c>d
    OR d>e
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE a>b
    OR c>d
    OR d>e
 ORDER BY 1,2
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE d>e
    OR c>d
    OR a>b
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE d>e
    OR c>d
    OR a>b
 ORDER BY 2,1
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE d>e
    OR a>b
    OR c>d
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x80
SELECT c-d,
       b-c
  FROM t1
 WHERE d>e
    OR a>b
    OR c>d
 ORDER BY 1,2
;
-- 56 values hashing to 92f4dc74ff83b62db81402a1d57321c6

-- query II rowsort x81
SELECT abs(b-c),
       a
  FROM t1
 WHERE c>d
;
-- 26 values hashing to 5406a45aaa7e9eb6eac7c2ce28e885ff

-- query II rowsort x81
SELECT abs(b-c),
       a
  FROM t1
 WHERE c>d
 ORDER BY 1,2
;
-- 26 values hashing to 5406a45aaa7e9eb6eac7c2ce28e885ff

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND b>c
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND b>c
 ORDER BY 3,1,5,4,2
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,5,4,2,1
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query IIIII rowsort x82
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,3
;
-- 20 values hashing to 3938ff52656417a17bb221a7e4c3c1f8

-- query III rowsort x83
SELECT b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- -1
-- 333
-- 1612
-- 4
-- 222
-- 1902

-- query III rowsort x83
SELECT b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1,2
;
-- -1
-- 333
-- 1612
-- 4
-- 222
-- 1902

-- query IIIIIII rowsort x84
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
;
-- 210 values hashing to c81b7313892ce609e90e6e0f2b1ca608

-- query IIIIIII rowsort x84
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 ORDER BY 3,1,5,2,6,4,7
;
-- 210 values hashing to c81b7313892ce609e90e6e0f2b1ca608

-- query IIIIII rowsort x85
SELECT a,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
;
-- 180 values hashing to da7a9f1ebbdc3b6c29d8133f7b52278a

-- query IIIIII rowsort x85
SELECT a,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 ORDER BY 2,6,1,4,3
;
-- 180 values hashing to da7a9f1ebbdc3b6c29d8133f7b52278a

-- query IIIII rowsort x86
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       d,
       a
  FROM t1
;
-- 150 values hashing to a823d93738137acbc5cb8b0dd778dc04

-- query IIIII rowsort x86
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       d,
       a
  FROM t1
 ORDER BY 5,3,2,4
;
-- 150 values hashing to a823d93738137acbc5cb8b0dd778dc04

-- query II rowsort x87
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE d>e
;
-- 22 values hashing to 447047f122de558251d285760d37a2b0

-- query II rowsort x87
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE d>e
 ORDER BY 2,1
;
-- 22 values hashing to 447047f122de558251d285760d37a2b0

-- query IIIIIII rowsort x88
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       d-e,
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
;
-- 21 values hashing to bb448dd78cc4a09fcfe69987f3a68624

-- query IIIIIII rowsort x88
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       d-e,
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 7,4,1
;
-- 21 values hashing to bb448dd78cc4a09fcfe69987f3a68624

-- query IIIIII rowsort x89
SELECT c,
       b-c,
       a+b*2+c*3,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 48 values hashing to 80996a703bc2719fae8f2e61e1b2ce0f

-- query IIIIII rowsort x89
SELECT c,
       b-c,
       a+b*2+c*3,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 4,1,2,3,6,5
;
-- 48 values hashing to 80996a703bc2719fae8f2e61e1b2ce0f

-- query IIIIIII rowsort x90
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       abs(b-c),
       d,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
;
-- 210 values hashing to 9c084e33bf63a044a6454554d1b32650

-- query IIIIIII rowsort x90
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       abs(b-c),
       d,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 ORDER BY 3,1,5,6,4
;
-- 210 values hashing to 9c084e33bf63a044a6454554d1b32650

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE b>c
    OR a>b
    OR (c<=d-2 OR c>=d+2)
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE b>c
    OR a>b
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,4,5
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR b>c
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR b>c
 ORDER BY 4,5,1
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIII rowsort x91
SELECT c-d,
       a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 1,5,3
;
-- 130 values hashing to 2f5a32331489c99199941a8889b06f1d

-- query IIIIIII rowsort x92
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
;
-- 210 values hashing to db82e66d4fdb6bf870977f9a0491c75e

-- query IIIIIII rowsort x92
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 4,3,6
;
-- 210 values hashing to db82e66d4fdb6bf870977f9a0491c75e

-- query IIIII rowsort x93
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
;
-- 150 values hashing to 023d03b1fc0a53fbd3a834b23d997a23

-- query IIIII rowsort x93
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 ORDER BY 3,5,4,1,2
;
-- 150 values hashing to 023d03b1fc0a53fbd3a834b23d997a23

-- query IIIIII rowsort x94
SELECT a+b*2+c*3,
       b-c,
       abs(a),
       d,
       (a+b+c+d+e)/5,
       b
  FROM t1
;
-- 180 values hashing to 9be77835aae24e3964177c83aa5a5946

-- query IIIIII rowsort x94
SELECT a+b*2+c*3,
       b-c,
       abs(a),
       d,
       (a+b+c+d+e)/5,
       b
  FROM t1
 ORDER BY 1,5,3,6,4
;
-- 180 values hashing to 9be77835aae24e3964177c83aa5a5946

-- query IIIII rowsort x95
SELECT d,
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 150 values hashing to 3cfed3855169db1b5c3661ccf5f0e01a

-- query IIIII rowsort x95
SELECT d,
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 5,3,1,2,4
;
-- 150 values hashing to 3cfed3855169db1b5c3661ccf5f0e01a

-- query IIIII rowsort x96
SELECT d-e,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 25 values hashing to af6ddfcc0bc5a293d17b418913e3f6c2

-- query IIIII rowsort x96
SELECT d-e,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 5,1,4,2,3
;
-- 25 values hashing to af6ddfcc0bc5a293d17b418913e3f6c2

-- query IIIII rowsort x96
SELECT d-e,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 25 values hashing to af6ddfcc0bc5a293d17b418913e3f6c2

-- query IIIII rowsort x96
SELECT d-e,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,4,3
;
-- 25 values hashing to af6ddfcc0bc5a293d17b418913e3f6c2

-- query IIIII rowsort x97
SELECT (a+b+c+d+e)/5,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
;
-- 95 values hashing to d72582291e1670e53f55f3054e2d3daf

-- query IIIII rowsort x97
SELECT (a+b+c+d+e)/5,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 95 values hashing to d72582291e1670e53f55f3054e2d3daf

-- query IIIII rowsort x97
SELECT (a+b+c+d+e)/5,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
;
-- 95 values hashing to d72582291e1670e53f55f3054e2d3daf

-- query IIIII rowsort x97
SELECT (a+b+c+d+e)/5,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,3,4
;
-- 95 values hashing to d72582291e1670e53f55f3054e2d3daf

-- query III rowsort x98
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 54 values hashing to f8c69dcb44782b0e6c9cbf8319f65a6c

-- query III rowsort x98
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 1,2,3
;
-- 54 values hashing to f8c69dcb44782b0e6c9cbf8319f65a6c

-- query III rowsort x98
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 54 values hashing to f8c69dcb44782b0e6c9cbf8319f65a6c

-- query III rowsort x98
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3
;
-- 54 values hashing to f8c69dcb44782b0e6c9cbf8319f65a6c

-- query IIIIII rowsort x99
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       d,
       c,
       a+b*2+c*3+d*4
  FROM t1
;
-- 180 values hashing to cf32291913a803ba6d9011eefa055f2f

-- query IIIIII rowsort x99
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       d,
       c,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 4,3,5,2,6
;
-- 180 values hashing to cf32291913a803ba6d9011eefa055f2f

-- query IIII rowsort x100
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 32 values hashing to 2e04e05b3c5a93aad1450a5bc5ff2188

-- query IIII rowsort x100
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,1,4,2
;
-- 32 values hashing to 2e04e05b3c5a93aad1450a5bc5ff2188

-- query IIII rowsort x100
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
;
-- 32 values hashing to 2e04e05b3c5a93aad1450a5bc5ff2188

-- query IIII rowsort x100
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2,4,3
;
-- 32 values hashing to 2e04e05b3c5a93aad1450a5bc5ff2188

-- query IIIII rowsort x101
SELECT b-c,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
;
-- 150 values hashing to d927f2df643d7e8a655a8cdc0066227c

-- query IIIII rowsort x101
SELECT b-c,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 4,2,5,1,3
;
-- 150 values hashing to d927f2df643d7e8a655a8cdc0066227c

-- query IIIIIII rowsort x102
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
;
-- 14 values hashing to ba74bb26a6370037d533c7c849d06212

-- query IIIIIII rowsort x102
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
 ORDER BY 2,1,3,4,5
;
-- 14 values hashing to ba74bb26a6370037d533c7c849d06212

-- query IIIIIII rowsort x102
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
;
-- 14 values hashing to ba74bb26a6370037d533c7c849d06212

-- query IIIIIII rowsort x102
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
 ORDER BY 2,7,3,5,4
;
-- 14 values hashing to ba74bb26a6370037d533c7c849d06212

-- query IIIIII rowsort x103
SELECT a+b*2+c*3,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       c-d,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to d9608b5db8bb32de301c6d434dad4f3d

-- query IIIIII rowsort x103
SELECT a+b*2+c*3,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       c-d,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,2,5,3
;
-- 90 values hashing to d9608b5db8bb32de301c6d434dad4f3d

-- query IIIIIII rowsort x104
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 147 values hashing to 246dcfbd66a7d2ae48cdc0f9f7706702

-- query IIIIIII rowsort x104
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,2,6,3,5,7,1
;
-- 147 values hashing to 246dcfbd66a7d2ae48cdc0f9f7706702

-- query II rowsort x105
SELECT b-c,
       a+b*2+c*3
  FROM t1
;
-- 60 values hashing to d22779b3c4030aea43ca75d141ba2372

-- query II rowsort x105
SELECT b-c,
       a+b*2+c*3
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to d22779b3c4030aea43ca75d141ba2372

-- query IIIII rowsort x106
SELECT d-e,
       e,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
;
-- 150 values hashing to 4100f710d68b2dda1c6b3e053f7de62b

-- query IIIII rowsort x106
SELECT d-e,
       e,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 ORDER BY 2,1,4
;
-- 150 values hashing to 4100f710d68b2dda1c6b3e053f7de62b

-- query IIII rowsort x107
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 108 values hashing to c8dfc9265b7c449a83b64290a683723e

-- query IIII rowsort x107
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,2,3
;
-- 108 values hashing to c8dfc9265b7c449a83b64290a683723e

-- query IIIII rowsort x108
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       e,
       b-c
  FROM t1
;
-- 150 values hashing to 3a0dda81c3bad8d55922c7eea65cf868

-- query IIIII rowsort x108
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       e,
       b-c
  FROM t1
 ORDER BY 3,5,4,2,1
;
-- 150 values hashing to 3a0dda81c3bad8d55922c7eea65cf868

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND c>d
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND c>d
 ORDER BY 2,1
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND d>e
   AND c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,3,2
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND d>e
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query III rowsort x109
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 1,2
;
-- 15 values hashing to 3c7ff7791b22cfda8a728f67fd74be3a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
 ORDER BY 1,2
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND c BETWEEN b-2 AND d+2
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND c>d
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query II rowsort x110
SELECT a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND c>d
 ORDER BY 2,1
;
-- 16 values hashing to 17d107726956412fb29fbcad81f2565a

-- query IIIIII rowsort x111
SELECT abs(a),
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 12 values hashing to 36c8af2cf2c693cce358cd6042d0f3a0

-- query IIIIII rowsort x111
SELECT abs(a),
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2,4,5,3
;
-- 12 values hashing to 36c8af2cf2c693cce358cd6042d0f3a0

-- query III rowsort x112
SELECT a,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE a>b
;
-- 51 values hashing to 2abf69b4e4ff11844fc3e958d1984c2d

-- query III rowsort x112
SELECT a,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE a>b
 ORDER BY 2,3
;
-- 51 values hashing to 2abf69b4e4ff11844fc3e958d1984c2d

-- query III rowsort x113
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 9 values hashing to 53ae5a490732e843ec6a8cd9362fd39f

-- query III rowsort x113
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,3
;
-- 9 values hashing to 53ae5a490732e843ec6a8cd9362fd39f

-- query II rowsort x114
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
;
-- 60 values hashing to 6067a805fe438490ef5481669a9dfae0

-- query II rowsort x114
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 6067a805fe438490ef5481669a9dfae0

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,3
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,5,3,2
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
   AND c>d
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIII rowsort x115
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 1,2
;
-- 50 values hashing to a7c4bfdcb5d86488e2bf8c50a2cf6e10

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,5,2,3,4
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR d>e
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR d>e
 ORDER BY 4,2,5,1,3,7
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR d>e
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query IIIIIII rowsort x116
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR d>e
 ORDER BY 1,6,2,4,5,7
;
-- 140 values hashing to e4345f4fe95219d9c12d3c40f128f3b5

-- query II rowsort x117
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 60 values hashing to 131d71f5c4130dea41c5210e648c5aab

-- query II rowsort x117
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 131d71f5c4130dea41c5210e648c5aab

-- query II rowsort x118
SELECT a+b*2,
       b
  FROM t1
;
-- 60 values hashing to e8512cacb92561411fed57fc3eb48ebd

-- query II rowsort x118
SELECT a+b*2,
       b
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to e8512cacb92561411fed57fc3eb48ebd

-- query I rowsort x119
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x119
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x119
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x119
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x120
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
;
-- 26 values hashing to f779b1cf0028b56f46858f31d9448ed0

-- query I rowsort x120
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
 ORDER BY 1
;
-- 26 values hashing to f779b1cf0028b56f46858f31d9448ed0

-- query IIIIIII rowsort x121
SELECT a+b*2,
       d,
       abs(b-c),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
;
-- 77 values hashing to 59e6659e16fd838c46645ad900800f8f

-- query IIIIIII rowsort x121
SELECT a+b*2,
       d,
       abs(b-c),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 6,5,4,7,2
;
-- 77 values hashing to 59e6659e16fd838c46645ad900800f8f

-- query IIIIIII rowsort x122
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       b,
       a+b*2,
       abs(a),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 147 values hashing to 3962de06046bf2f23e40e27fa63ddd38

-- query IIIIIII rowsort x122
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       b,
       a+b*2,
       abs(a),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,7,5,6,3,4,2
;
-- 147 values hashing to 3962de06046bf2f23e40e27fa63ddd38

-- query IIIIIII rowsort x122
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       b,
       a+b*2,
       abs(a),
       a,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 147 values hashing to 3962de06046bf2f23e40e27fa63ddd38

-- query IIIIIII rowsort x122
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       b,
       a+b*2,
       abs(a),
       a,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 6,5
;
-- 147 values hashing to 3962de06046bf2f23e40e27fa63ddd38

-- query III rowsort x123
SELECT c,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
;
-- 45 values hashing to d50c41e742997d1380d4f4655a0dac15

-- query III rowsort x123
SELECT c,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 1,3,2
;
-- 45 values hashing to d50c41e742997d1380d4f4655a0dac15

-- query III rowsort x123
SELECT c,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
;
-- 45 values hashing to d50c41e742997d1380d4f4655a0dac15

-- query III rowsort x123
SELECT c,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,3,1
;
-- 45 values hashing to d50c41e742997d1380d4f4655a0dac15

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR d>e
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR d>e
 ORDER BY 1,2
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>c OR e<d)
    OR d>e
    OR (e>a AND e<b)
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>c OR e<d)
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 2,1
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR (e>c OR e<d)
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x124
SELECT b-c,
       b
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR (e>c OR e<d)
 ORDER BY 2,1
;
-- 44 values hashing to d45a7e6fff4e5feb24199a45099d3eae

-- query II rowsort x125
SELECT (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- 105
-- 127
-- 129

-- query II rowsort x125
SELECT (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- 107
-- 105
-- 127
-- 129

-- query IIIII rowsort x126
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE c>d
;
-- 65 values hashing to e7e1c21489377c85cf0f1d00fcaad3fa

-- query IIIII rowsort x126
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE c>d
 ORDER BY 3,4,5,2,1
;
-- 65 values hashing to e7e1c21489377c85cf0f1d00fcaad3fa

-- query I rowsort x127
SELECT a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 11ccac364a64300285613ac5a623182e

-- query I rowsort x127
SELECT a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to 11ccac364a64300285613ac5a623182e

-- query I rowsort x128
SELECT (a+b+c+d+e)/5
  FROM t1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query I rowsort x128
SELECT (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query II rowsort x129
SELECT a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 30 values hashing to a512bc577af89b7ed951794c489cba1a

-- query II rowsort x129
SELECT a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 30 values hashing to a512bc577af89b7ed951794c489cba1a

-- query II rowsort x130
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
;
-- 44 values hashing to 1794775185d68d144d7201d35801d4df

-- query II rowsort x130
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
 ORDER BY 1,2
;
-- 44 values hashing to 1794775185d68d144d7201d35801d4df

-- query III rowsort x131
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 9 values hashing to 889138d8074073207de471ed31c3745d

-- query III rowsort x131
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,3,2
;
-- 9 values hashing to 889138d8074073207de471ed31c3745d

-- query III rowsort x131
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
;
-- 9 values hashing to 889138d8074073207de471ed31c3745d

-- query III rowsort x131
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,3,1
;
-- 9 values hashing to 889138d8074073207de471ed31c3745d

-- query IIII rowsort x132
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 6c24959fa9cfa848ca2180d31d069f83

-- query IIII rowsort x132
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,4,2
;
-- 20 values hashing to 6c24959fa9cfa848ca2180d31d069f83

-- query IIII rowsort x132
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
;
-- 20 values hashing to 6c24959fa9cfa848ca2180d31d069f83

-- query IIII rowsort x132
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
 ORDER BY 2,1
;
-- 20 values hashing to 6c24959fa9cfa848ca2180d31d069f83

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,4,1
;

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND b>c
;

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 2,3
;

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE b>c
   AND e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
;

-- query IIII rowsort x133
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b-c,
       d
  FROM t1
 WHERE b>c
   AND e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,4,1
;

-- query III rowsort x134
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>a AND e<b)
;
-- 9 values hashing to 34ce1cf392ee2bf1954fbd8f5bc88977

-- query III rowsort x134
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 3,1,2
;
-- 9 values hashing to 34ce1cf392ee2bf1954fbd8f5bc88977

-- query III rowsort x135
SELECT c-d,
       a+b*2+c*3,
       d
  FROM t1
 WHERE a>b
;
-- 51 values hashing to f14a84ddf75757708d0d8b009027f493

-- query III rowsort x135
SELECT c-d,
       a+b*2+c*3,
       d
  FROM t1
 WHERE a>b
 ORDER BY 3,2
;
-- 51 values hashing to f14a84ddf75757708d0d8b009027f493

-- query IIIIIII rowsort x136
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       b-c,
       c,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
;
-- 147 values hashing to df858a683efb658599da65c456748ef4

-- query IIIIIII rowsort x136
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       b-c,
       c,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 4,3,5,1,2,7,6
;
-- 147 values hashing to df858a683efb658599da65c456748ef4

-- query II rowsort x137
SELECT a+b*2+c*3,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 8d6eac4282d6882511230a20417bf479

-- query II rowsort x137
SELECT a+b*2+c*3,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 20 values hashing to 8d6eac4282d6882511230a20417bf479

-- query IIIIIII rowsort x138
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       b,
       d-e,
       (a+b+c+d+e)/5,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 70 values hashing to 03b9c6bc33a4aba7ddad83b45e0f1b1a

-- query IIIIIII rowsort x138
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       b,
       d-e,
       (a+b+c+d+e)/5,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1,2,4,6
;
-- 70 values hashing to 03b9c6bc33a4aba7ddad83b45e0f1b1a

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 2,3
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
 ORDER BY 1,2
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query III rowsort x139
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 21 values hashing to f0c4dfe1769211bf0c301c9007bc5454

-- query IIIIIII rowsort x140
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a,
       abs(b-c),
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 182 values hashing to f1a2f5b1811d37cecb505d691ab13a49

-- query IIIIIII rowsort x140
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a,
       abs(b-c),
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2
;
-- 182 values hashing to f1a2f5b1811d37cecb505d691ab13a49

-- query IIIIII rowsort x141
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a-b,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
;
-- 48 values hashing to 8673acc669acd16171dbeb21976d6d8f

-- query IIIIII rowsort x141
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a-b,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,6,1,2,5,3
;
-- 48 values hashing to 8673acc669acd16171dbeb21976d6d8f

-- query IIIIII rowsort x141
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a-b,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
;
-- 48 values hashing to 8673acc669acd16171dbeb21976d6d8f

-- query IIIIII rowsort x141
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a-b,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 6,5,2,3
;
-- 48 values hashing to 8673acc669acd16171dbeb21976d6d8f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (a>b-2 AND a<b+2)
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 5,1,3
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,1,2,6,4
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x142
SELECT b-c,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
 ORDER BY 5,7,3
;
-- 175 values hashing to feed50bc1ffe0204132473625c16770f

-- query IIIIIII rowsort x143
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       a,
       e,
       a+b*2,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
;
-- 133 values hashing to 0d12bbd4d096b306bc441f1921ba8409

-- query IIIIIII rowsort x143
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       a,
       e,
       a+b*2,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,1,2,7
;
-- 133 values hashing to 0d12bbd4d096b306bc441f1921ba8409

-- query IIIIIII rowsort x143
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       a,
       e,
       a+b*2,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
;
-- 133 values hashing to 0d12bbd4d096b306bc441f1921ba8409

-- query IIIIIII rowsort x143
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       a,
       e,
       a+b*2,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 7,2,6,3,1,5
;
-- 133 values hashing to 0d12bbd4d096b306bc441f1921ba8409

-- query III rowsort x144
SELECT a+b*2+c*3,
       e,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
;
-- 15 values hashing to 8b91e8ae95a1c510da23999745a6f6f0

-- query III rowsort x144
SELECT a+b*2+c*3,
       e,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 3,2,1
;
-- 15 values hashing to 8b91e8ae95a1c510da23999745a6f6f0

-- query III rowsort x144
SELECT a+b*2+c*3,
       e,
       a-b
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 8b91e8ae95a1c510da23999745a6f6f0

-- query III rowsort x144
SELECT a+b*2+c*3,
       e,
       a-b
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,3
;
-- 15 values hashing to 8b91e8ae95a1c510da23999745a6f6f0

-- query IIIII rowsort x145
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 150 values hashing to e48a7e154d1862a3a94a7244246efacb

-- query IIIII rowsort x145
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 5,2,4
;
-- 150 values hashing to e48a7e154d1862a3a94a7244246efacb

-- query IIII rowsort x146
SELECT abs(b-c),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 104 values hashing to bb8f9e931a978480ded2bf7a14866ee7

-- query IIII rowsort x146
SELECT abs(b-c),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,2
;
-- 104 values hashing to bb8f9e931a978480ded2bf7a14866ee7

-- query I rowsort x147
SELECT c
  FROM t1
 WHERE a>b
;
-- 17 values hashing to cdbf29686df3708c211f3102ab678908

-- query I rowsort x147
SELECT c
  FROM t1
 WHERE a>b
 ORDER BY 1
;
-- 17 values hashing to cdbf29686df3708c211f3102ab678908

-- query IIIII rowsort x148
SELECT a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
;
-- 25 values hashing to ba03f62987b959ddabb9d50bdc042c78

-- query IIIII rowsort x148
SELECT a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
 ORDER BY 5,4,3
;
-- 25 values hashing to ba03f62987b959ddabb9d50bdc042c78

-- query IIIII rowsort x148
SELECT a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 25 values hashing to ba03f62987b959ddabb9d50bdc042c78

-- query IIIII rowsort x148
SELECT a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,2,4
;
-- 25 values hashing to ba03f62987b959ddabb9d50bdc042c78

-- query I rowsort x149
SELECT b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
;
-- 24 values hashing to e1cde88d0196bdee91734f7ca7e395fb

-- query I rowsort x149
SELECT b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 24 values hashing to e1cde88d0196bdee91734f7ca7e395fb

-- query I rowsort x149
SELECT b-c
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
;
-- 24 values hashing to e1cde88d0196bdee91734f7ca7e395fb

-- query I rowsort x149
SELECT b-c
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 24 values hashing to e1cde88d0196bdee91734f7ca7e395fb

-- query IIIII rowsort x150
SELECT a+b*2+c*3+d*4+e*5,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       d-e
  FROM t1
;
-- 150 values hashing to a398ba1db1267191ce45e36d9d31e051

-- query IIIII rowsort x150
SELECT a+b*2+c*3+d*4+e*5,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       d-e
  FROM t1
 ORDER BY 1,5,3
;
-- 150 values hashing to a398ba1db1267191ce45e36d9d31e051

-- query IIIIII rowsort x151
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       b-c
  FROM t1
;
-- 180 values hashing to 1c5b84d965d2d9ba73b93a2dd0b2f2c9

-- query IIIIII rowsort x151
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       b-c
  FROM t1
 ORDER BY 2,1,6,4
;
-- 180 values hashing to 1c5b84d965d2d9ba73b93a2dd0b2f2c9

-- query IIII rowsort x152
SELECT abs(a),
       a-b,
       c,
       abs(b-c)
  FROM t1
 WHERE d>e
;
-- 44 values hashing to a43d58e83bb23ff1ad69780741f5418a

-- query IIII rowsort x152
SELECT abs(a),
       a-b,
       c,
       abs(b-c)
  FROM t1
 WHERE d>e
 ORDER BY 2,3,4
;
-- 44 values hashing to a43d58e83bb23ff1ad69780741f5418a

-- query II rowsort x153
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
;
-- 54 values hashing to af52a14c0703b0cc491c68926b0af48e

-- query II rowsort x153
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 54 values hashing to af52a14c0703b0cc491c68926b0af48e

-- query II rowsort x153
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to af52a14c0703b0cc491c68926b0af48e

-- query II rowsort x153
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 54 values hashing to af52a14c0703b0cc491c68926b0af48e

-- query III rowsort x154
SELECT a,
       c,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 78 values hashing to 5329fa42a4799ac324055058aa366b22

-- query III rowsort x154
SELECT a,
       c,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2
;
-- 78 values hashing to 5329fa42a4799ac324055058aa366b22

-- query IIIII rowsort x155
SELECT b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE b>c
;
-- 65 values hashing to 64385d2a13bc167ba111420e6febb518

-- query IIIII rowsort x155
SELECT b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE b>c
 ORDER BY 2,3
;
-- 65 values hashing to 64385d2a13bc167ba111420e6febb518

-- query I rowsort x156
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
;
-- 13 values hashing to 0172871a347e8b585d40146ff17403ac

-- query I rowsort x156
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
 ORDER BY 1
;
-- 13 values hashing to 0172871a347e8b585d40146ff17403ac

-- query II rowsort x157
SELECT a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1067
-- 105
-- 1272
-- 129

-- query II rowsort x157
SELECT a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- 1067
-- 105
-- 1272
-- 129

-- query III rowsort x158
SELECT e,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 90 values hashing to 8c3eae551d7c73bf241fdbaa816e05b4

-- query III rowsort x158
SELECT e,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 1,2
;
-- 90 values hashing to 8c3eae551d7c73bf241fdbaa816e05b4

-- query IIIII rowsort x159
SELECT a+b*2+c*3+d*4,
       d,
       b,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
;
-- 95 values hashing to 093a5214968b2e0db5693baf3ed91467

-- query IIIII rowsort x159
SELECT a+b*2+c*3+d*4,
       d,
       b,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 5,3,2,1,4
;
-- 95 values hashing to 093a5214968b2e0db5693baf3ed91467

-- query IIIII rowsort x159
SELECT a+b*2+c*3+d*4,
       d,
       b,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 95 values hashing to 093a5214968b2e0db5693baf3ed91467

-- query IIIII rowsort x159
SELECT a+b*2+c*3+d*4,
       d,
       b,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,3,5,1
;
-- 95 values hashing to 093a5214968b2e0db5693baf3ed91467

-- query I rowsort x160
SELECT b-c
  FROM t1
;
-- 30 values hashing to c5a2b847c6c21100b32db39349809b0e

-- query I rowsort x160
SELECT b-c
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to c5a2b847c6c21100b32db39349809b0e

-- query IIIIII rowsort x161
SELECT (a+b+c+d+e)/5,
       b-c,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
;
-- 180 values hashing to 7203b58cd5de45742814c45174042c36

-- query IIIIII rowsort x161
SELECT (a+b+c+d+e)/5,
       b-c,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
 ORDER BY 5,1
;
-- 180 values hashing to 7203b58cd5de45742814c45174042c36

-- query IIIIII rowsort x162
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       d-e,
       a+b*2+c*3
  FROM t1
;
-- 180 values hashing to f6654e4c0575740d1cc8c217e7653f7b

-- query IIIIII rowsort x162
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       d-e,
       a+b*2+c*3
  FROM t1
 ORDER BY 3,6,2,1,4,5
;
-- 180 values hashing to f6654e4c0575740d1cc8c217e7653f7b

-- query III rowsort x163
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE c>d
;
-- 39 values hashing to a245f46b4eb4e5f324e4ff1557631696

-- query III rowsort x163
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE c>d
 ORDER BY 2,1
;
-- 39 values hashing to a245f46b4eb4e5f324e4ff1557631696

-- query IIIIIII rowsort x164
SELECT c,
       abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
;
-- 161 values hashing to f5eea00d2d6e134b7bc3c6b4fb048504

-- query IIIIIII rowsort x164
SELECT c,
       abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
 ORDER BY 6,2,3,4,7,1,5
;
-- 161 values hashing to f5eea00d2d6e134b7bc3c6b4fb048504

-- query IIIIIII rowsort x165
SELECT a+b*2,
       c-d,
       d-e,
       abs(a),
       a-b,
       c,
       b
  FROM t1
 WHERE a>b
;
-- 119 values hashing to d65bf72c8bcb9166838b483257204296

-- query IIIIIII rowsort x165
SELECT a+b*2,
       c-d,
       d-e,
       abs(a),
       a-b,
       c,
       b
  FROM t1
 WHERE a>b
 ORDER BY 1,6,2,5,3
;
-- 119 values hashing to d65bf72c8bcb9166838b483257204296

-- query IIIIIII rowsort x166
SELECT abs(b-c),
       c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR c>d
;
-- 182 values hashing to 1067074122ea0e1f2c7d65cce15d84a3

-- query IIIIIII rowsort x166
SELECT abs(b-c),
       c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR c>d
 ORDER BY 2,7,6,5,4,1,3
;
-- 182 values hashing to 1067074122ea0e1f2c7d65cce15d84a3

-- query IIIIIII rowsort x166
SELECT abs(b-c),
       c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR c>d
;
-- 182 values hashing to 1067074122ea0e1f2c7d65cce15d84a3

-- query IIIIIII rowsort x166
SELECT abs(b-c),
       c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR c>d
 ORDER BY 6,3
;
-- 182 values hashing to 1067074122ea0e1f2c7d65cce15d84a3

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR a>b
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR a>b
 ORDER BY 1,3,6,4,2
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE c>d
    OR a>b
    OR d NOT BETWEEN 110 AND 150
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE c>d
    OR a>b
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,5,2
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE a>b
    OR c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query IIIIII rowsort x167
SELECT d-e,
       e,
       a+b*2,
       a+b*2+c*3+d*4,
       abs(a),
       abs(b-c)
  FROM t1
 WHERE a>b
    OR c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 6,1
;
-- 168 values hashing to b33485d8023787693e3e116f2f1847a4

-- query I rowsort x168
SELECT d-e
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
;
-- 17 values hashing to 045f09dca5d37db611533eab1971b231

-- query I rowsort x168
SELECT d-e
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 17 values hashing to 045f09dca5d37db611533eab1971b231

-- query I rowsort x168
SELECT d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
;
-- 17 values hashing to 045f09dca5d37db611533eab1971b231

-- query I rowsort x168
SELECT d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
 ORDER BY 1
;
-- 17 values hashing to 045f09dca5d37db611533eab1971b231

-- query III rowsort x169
SELECT (a+b+c+d+e)/5,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
;
-- 9 values hashing to 14b33901ca82e662d59a8c0dc047726f

-- query III rowsort x169
SELECT (a+b+c+d+e)/5,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,3
;
-- 9 values hashing to 14b33901ca82e662d59a8c0dc047726f

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND b>c
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND b>c
 ORDER BY 1
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND d>e
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND d>e
 ORDER BY 1
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE d>e
   AND b>c
   AND (e>a AND e<b)
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE d>e
   AND b>c
   AND (e>a AND e<b)
 ORDER BY 1
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE b>c
   AND d>e
   AND (e>a AND e<b)
;
-- -4

-- query I rowsort x170
SELECT a-b
  FROM t1
 WHERE b>c
   AND d>e
   AND (e>a AND e<b)
 ORDER BY 1
;
-- -4

-- query I rowsort x171
SELECT abs(a)
  FROM t1
;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query I rowsort x171
SELECT abs(a)
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query IIIIII rowsort x172
SELECT a+b*2+c*3+d*4,
       d,
       a-b,
       abs(a),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to d9813d30017aede3d11579070a9140fc

-- query IIIIII rowsort x172
SELECT a+b*2+c*3+d*4,
       d,
       a-b,
       abs(a),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 3,2,4
;
-- 90 values hashing to d9813d30017aede3d11579070a9140fc

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND d>e
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND d>e
 ORDER BY 2,4,5
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
 ORDER BY 5,1,2
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND d>e
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query IIIII rowsort x173
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 2,4,3,5,1
;
-- 15 values hashing to a4e27795a1a90b88b4bee4165129ad4b

-- query III rowsort x174
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to 67123f9d3cf26afca087a7139944a577

-- query III rowsort x174
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 24 values hashing to 67123f9d3cf26afca087a7139944a577

-- query I rowsort x175
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 26 values hashing to 135a3445021b98b31c75dc892c625ee7

-- query I rowsort x175
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 26 values hashing to 135a3445021b98b31c75dc892c625ee7

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,3
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND (a>b-2 AND a<b+2)
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1,3
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND a>b
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 2,3
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND c BETWEEN b-2 AND d+2
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query III rowsort x176
SELECT b-c,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,3
;
-- -3
-- 180
-- 0
-- -4
-- 132
-- 0

-- query IIIII rowsort x177
SELECT c-d,
       abs(b-c),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 75 values hashing to 1ad85c88d1fdbc2acc6b8554c4efc1b9

-- query IIIII rowsort x177
SELECT c-d,
       abs(b-c),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 3,1,4,2,5
;
-- 75 values hashing to 1ad85c88d1fdbc2acc6b8554c4efc1b9

-- query II rowsort x178
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 58 values hashing to bb4dab7fc28f43ac36df70091e062673

-- query II rowsort x178
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 58 values hashing to bb4dab7fc28f43ac36df70091e062673

-- query II rowsort x178
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
;
-- 58 values hashing to bb4dab7fc28f43ac36df70091e062673

-- query II rowsort x178
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 58 values hashing to bb4dab7fc28f43ac36df70091e062673

-- query I rowsort x179
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
;
-- 21 values hashing to 558d17aef1b84bc5cb6d000f08146d80

-- query I rowsort x179
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 1
;
-- 21 values hashing to 558d17aef1b84bc5cb6d000f08146d80

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE c>d
   AND b>c
   AND (e>c OR e<d)
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE c>d
   AND b>c
   AND (e>c OR e<d)
 ORDER BY 1,2,4
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND b>c
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND b>c
 ORDER BY 1,2
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND b>c
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND b>c
 ORDER BY 1,3,2,4
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c>d
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query IIII rowsort x180
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c>d
 ORDER BY 2,3,1,4
;
-- 1390
-- 5
-- 0
-- 136
-- 1430
-- 6
-- 0
-- 140

-- query III rowsort x181
SELECT a+b*2+c*3+d*4+e*5,
       b,
       e
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 36 values hashing to 04fbc8747ced76bd5e39372d36c6cd56

-- query III rowsort x181
SELECT a+b*2+c*3+d*4+e*5,
       b,
       e
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 36 values hashing to 04fbc8747ced76bd5e39372d36c6cd56

-- query III rowsort x181
SELECT a+b*2+c*3+d*4+e*5,
       b,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 36 values hashing to 04fbc8747ced76bd5e39372d36c6cd56

-- query III rowsort x181
SELECT a+b*2+c*3+d*4+e*5,
       b,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 1,2,3
;
-- 36 values hashing to 04fbc8747ced76bd5e39372d36c6cd56

-- query IIIII rowsort x182
SELECT abs(a),
       c,
       c-d,
       a-b,
       abs(b-c)
  FROM t1
;
-- 150 values hashing to c7973f84ec584b5205e6e5bde1b29849

-- query IIIII rowsort x182
SELECT abs(a),
       c,
       c-d,
       a-b,
       abs(b-c)
  FROM t1
 ORDER BY 3,2,4
;
-- 150 values hashing to c7973f84ec584b5205e6e5bde1b29849

-- query IIII rowsort x183
SELECT a+b*2+c*3,
       e,
       a+b*2,
       b-c
  FROM t1
;
-- 120 values hashing to f21f802495ad9e86d9467f0a8a89233a

-- query IIII rowsort x183
SELECT a+b*2+c*3,
       e,
       a+b*2,
       b-c
  FROM t1
 ORDER BY 2,4,3
;
-- 120 values hashing to f21f802495ad9e86d9467f0a8a89233a

-- query IIII rowsort x184
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
;
-- 56 values hashing to eb34893f0f45a3fe06872613f6814573

-- query IIII rowsort x184
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
 ORDER BY 3,1,2,4
;
-- 56 values hashing to eb34893f0f45a3fe06872613f6814573

-- query IIII rowsort x184
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
;
-- 56 values hashing to eb34893f0f45a3fe06872613f6814573

-- query IIII rowsort x184
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
 ORDER BY 2,3,1,4
;
-- 56 values hashing to eb34893f0f45a3fe06872613f6814573

-- query IIIIIII rowsort x185
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       d,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       e,
       a-b
  FROM t1
;
-- 210 values hashing to 744e1c7818764ebcfc4e5f91cbc2c798

-- query IIIIIII rowsort x185
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       d,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       e,
       a-b
  FROM t1
 ORDER BY 1,5,6,7
;
-- 210 values hashing to 744e1c7818764ebcfc4e5f91cbc2c798

-- query II rowsort x186
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 30 values hashing to 8fc25640059ac6e22325dc1d3441cf1f

-- query II rowsort x186
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 30 values hashing to 8fc25640059ac6e22325dc1d3441cf1f

-- query IIIIIII rowsort x187
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       e,
       abs(b-c),
       c,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
;
-- 70 values hashing to 1c2143bbb23c135b0863948fe892809c

-- query IIIIIII rowsort x187
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       e,
       abs(b-c),
       c,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 7,5
;
-- 70 values hashing to 1c2143bbb23c135b0863948fe892809c

-- query IIIIIII rowsort x187
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       e,
       abs(b-c),
       c,
       a-b
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
;
-- 70 values hashing to 1c2143bbb23c135b0863948fe892809c

-- query IIIIIII rowsort x187
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       e,
       abs(b-c),
       c,
       a-b
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,6,2,7
;
-- 70 values hashing to 1c2143bbb23c135b0863948fe892809c

-- query IIIIIII rowsort x188
SELECT b,
       b-c,
       e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
;
-- 91 values hashing to f3fb9861505a2282b1406a8e7b28909c

-- query IIIIIII rowsort x188
SELECT b,
       b-c,
       e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
 ORDER BY 6,1,5
;
-- 91 values hashing to f3fb9861505a2282b1406a8e7b28909c

-- query IIIIIII rowsort x189
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
;
-- 28 values hashing to a817d5c4c618f4c42b4f3b805d114cf0

-- query IIIIIII rowsort x189
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,1,5,6,3
;
-- 28 values hashing to a817d5c4c618f4c42b4f3b805d114cf0

-- query IIII rowsort x190
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 52 values hashing to 173e4994cd6ab5b27f4f842e3cb32936

-- query IIII rowsort x190
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,1,2
;
-- 52 values hashing to 173e4994cd6ab5b27f4f842e3cb32936

-- query IIII rowsort x190
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
;
-- 52 values hashing to 173e4994cd6ab5b27f4f842e3cb32936

-- query IIII rowsort x190
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
 ORDER BY 2,1
;
-- 52 values hashing to 173e4994cd6ab5b27f4f842e3cb32936

-- query IIIIIII rowsort x191
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 119 values hashing to 5c163ac63543e0ecea6b845410a9b56c

-- query IIIIIII rowsort x191
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 2,5
;
-- 119 values hashing to 5c163ac63543e0ecea6b845410a9b56c

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1,3
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query III rowsort x192
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,3
;
-- 87 values hashing to 1ec49f6791dd184fda345e1c050a3e0a

-- query IIIIIII rowsort x193
SELECT a+b*2+c*3+d*4,
       b-c,
       d-e,
       (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 182 values hashing to b7435dc417aa7b9b48c92564eadaf539

-- query IIIIIII rowsort x193
SELECT a+b*2+c*3+d*4,
       b-c,
       d-e,
       (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,7,5,2,3,6
;
-- 182 values hashing to b7435dc417aa7b9b48c92564eadaf539

-- query III rowsort x194
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
;
-- 48 values hashing to b017eedf1b384582bc0f9ccea450c45b

-- query III rowsort x194
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
 ORDER BY 3,2,1
;
-- 48 values hashing to b017eedf1b384582bc0f9ccea450c45b

-- query III rowsort x194
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
;
-- 48 values hashing to b017eedf1b384582bc0f9ccea450c45b

-- query III rowsort x194
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 48 values hashing to b017eedf1b384582bc0f9ccea450c45b

-- query IIIII rowsort x195
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       e
  FROM t1
;
-- 150 values hashing to 910280276c633b79b275a9d294a0dd7e

-- query IIIII rowsort x195
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       e
  FROM t1
 ORDER BY 4,5
;
-- 150 values hashing to 910280276c633b79b275a9d294a0dd7e

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR a>b
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR a>b
 ORDER BY 4,2,1,3,5
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR b>c
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 4,1,5,6,2,3
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE b>c
    OR a>b
    OR (a>b-2 AND a<b+2)
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIIII rowsort x196
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE b>c
    OR a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,6,5
;
-- 144 values hashing to b0cf50305beafb1e2ef15470d870665d

-- query IIIII rowsort x197
SELECT e,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
;
-- 15 values hashing to 10166a1287dc846bc381908f1cdd9942

-- query IIIII rowsort x197
SELECT e,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,5,4,1,3
;
-- 15 values hashing to 10166a1287dc846bc381908f1cdd9942

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3,4,2
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
 ORDER BY 4,1
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,6,4,2,5,3
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query IIIIII rowsort x198
SELECT a,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,1,2,6,4,3
;
-- 107
-- -1
-- 333
-- 333
-- 0
-- 109

-- query III rowsort x199
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
;
-- 1338
-- 444
-- 220
-- 1484
-- 444
-- 245

-- query III rowsort x199
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
 ORDER BY 3,2,1
;
-- 1338
-- 444
-- 220
-- 1484
-- 444
-- 245

-- query III rowsort x199
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
;
-- 1338
-- 444
-- 220
-- 1484
-- 444
-- 245

-- query III rowsort x199
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
 ORDER BY 3,1
;
-- 1338
-- 444
-- 220
-- 1484
-- 444
-- 245

-- query IIIII rowsort x200
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
;
-- 115 values hashing to 85423b23f56dc9d107c8a7f05e1ed69f

-- query IIIII rowsort x200
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 4,5,2
;
-- 115 values hashing to 85423b23f56dc9d107c8a7f05e1ed69f

-- query IIIII rowsort x200
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
;
-- 115 values hashing to 85423b23f56dc9d107c8a7f05e1ed69f

-- query IIIII rowsort x200
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
 ORDER BY 1,2
;
-- 115 values hashing to 85423b23f56dc9d107c8a7f05e1ed69f

-- query II rowsort x201
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
;
-- 26 values hashing to d9568f9745f48f39ac8f2365d73421e8

-- query II rowsort x201
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
 ORDER BY 1,2
;
-- 26 values hashing to d9568f9745f48f39ac8f2365d73421e8

-- query III rowsort x202
SELECT a,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
;
-- 51 values hashing to e11ff5467dcf535c8d18a66d2118b20f

-- query III rowsort x202
SELECT a,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
 ORDER BY 1,2,3
;
-- 51 values hashing to e11ff5467dcf535c8d18a66d2118b20f

-- query IIIIIII rowsort x203
SELECT a+b*2+c*3+d*4+e*5,
       a,
       abs(b-c),
       c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
;
-- 210 values hashing to 68f3c01251d7d0155ebc39d74552c468

-- query IIIIIII rowsort x203
SELECT a+b*2+c*3+d*4+e*5,
       a,
       abs(b-c),
       c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 3,6,4,7,1
;
-- 210 values hashing to 68f3c01251d7d0155ebc39d74552c468

-- query IIIII rowsort x204
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to b74d9b45d77541b380a040202bacdb7d

-- query IIIII rowsort x204
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 5,2
;
-- 130 values hashing to b74d9b45d77541b380a040202bacdb7d

-- query I rowsort x205
SELECT a+b*2+c*3
  FROM t1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query I rowsort x205
SELECT a+b*2+c*3
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query III rowsort x206
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
;
-- 90 values hashing to 8b14a16082dc488eda882a71c9d2446a

-- query III rowsort x206
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to 8b14a16082dc488eda882a71c9d2446a

-- query IIIIIII rowsort x207
SELECT d,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       d-e,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
;
-- 126 values hashing to 64d37da8e34e3aa76ea008b07eea3b9e

-- query IIIIIII rowsort x207
SELECT d,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       d-e,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
 ORDER BY 5,7
;
-- 126 values hashing to 64d37da8e34e3aa76ea008b07eea3b9e

-- query III rowsort x208
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
;
-- 90 values hashing to 1eb3650aee03b10519d530d9d2d32daa

-- query III rowsort x208
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 ORDER BY 2,3,1
;
-- 90 values hashing to 1eb3650aee03b10519d530d9d2d32daa

-- query I rowsort x209
SELECT d
  FROM t1
 WHERE (e>a AND e<b)
;
-- 190
-- 222
-- 248

-- query I rowsort x209
SELECT d
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1
;
-- 190
-- 222
-- 248

-- query II rowsort x210
SELECT a-b,
       d-e
  FROM t1
;
-- 60 values hashing to c60a057f1b0709ced3374a0ceb82507d

-- query II rowsort x210
SELECT a-b,
       d-e
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to c60a057f1b0709ced3374a0ceb82507d

-- query I rowsort x211
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x211
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x211
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query I rowsort x211
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 10 values hashing to b833e3a3ba082b2c0028b4cd08f0834d

-- query IIII rowsort x212
SELECT a+b*2,
       b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 104 values hashing to 1d50f4e0c1ed1032de3e7b775dd73868

-- query IIII rowsort x212
SELECT a+b*2,
       b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,4,1
;
-- 104 values hashing to 1d50f4e0c1ed1032de3e7b775dd73868

-- query IIII rowsort x213
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       e,
       abs(a)
  FROM t1
;
-- 120 values hashing to ba136db6ad43163a3ef34562f928c5f0

-- query IIII rowsort x213
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       e,
       abs(a)
  FROM t1
 ORDER BY 4,2
;
-- 120 values hashing to ba136db6ad43163a3ef34562f928c5f0

-- query IIIIII rowsort x214
SELECT c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a-b,
       a+b*2+c*3
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
;
-- 156 values hashing to 206d0bc80a26b970f06e318d7e9bd644

-- query IIIIII rowsort x214
SELECT c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a-b,
       a+b*2+c*3
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
 ORDER BY 1,2,6,5
;
-- 156 values hashing to 206d0bc80a26b970f06e318d7e9bd644

-- query IIIIII rowsort x214
SELECT c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a-b,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
;
-- 156 values hashing to 206d0bc80a26b970f06e318d7e9bd644

-- query IIIIII rowsort x214
SELECT c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a-b,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
 ORDER BY 5,3,6,1
;
-- 156 values hashing to 206d0bc80a26b970f06e318d7e9bd644

-- query I rowsort x215
SELECT d-e
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 19 values hashing to 7b54a5de170e892819f38d8939bfcdec

-- query I rowsort x215
SELECT d-e
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 19 values hashing to 7b54a5de170e892819f38d8939bfcdec

-- query I rowsort x215
SELECT d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 19 values hashing to 7b54a5de170e892819f38d8939bfcdec

-- query I rowsort x215
SELECT d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 1
;
-- 19 values hashing to 7b54a5de170e892819f38d8939bfcdec

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 4,3,6,5,2,1
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
 ORDER BY 3,4,5
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIIII rowsort x216
SELECT c-d,
       abs(a),
       b-c,
       b,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 6,1
;
-- 30 values hashing to ed58ee197e5adb321f7c6370392528e1

-- query IIIII rowsort x217
SELECT abs(b-c),
       d,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to bb84b24e592ceb4ae7edb4cfd9c05746

-- query IIIII rowsort x217
SELECT abs(b-c),
       d,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,5,1,4,3
;
-- 50 values hashing to bb84b24e592ceb4ae7edb4cfd9c05746

-- query IIIIIII rowsort x218
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       c,
       abs(b-c),
       e,
       d,
       d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
;
-- 196 values hashing to e48e30f893e08742181bb5a88cbe9a37

-- query IIIIIII rowsort x218
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       c,
       abs(b-c),
       e,
       d,
       d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
 ORDER BY 3,4,5,2
;
-- 196 values hashing to e48e30f893e08742181bb5a88cbe9a37

-- query IIIIII rowsort x219
SELECT (a+b+c+d+e)/5,
       d-e,
       a-b,
       abs(a),
       b,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to afa30011e6f2bf13350422b6fbcd727d

-- query IIIIII rowsort x219
SELECT (a+b+c+d+e)/5,
       d-e,
       a-b,
       abs(a),
       b,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 4,6,1,5,2
;
-- 90 values hashing to afa30011e6f2bf13350422b6fbcd727d

-- query I rowsort x220
SELECT (a+b+c+d+e)/5
  FROM t1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query I rowsort x220
SELECT (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query IIIIII rowsort x221
SELECT d,
       c-d,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
;
-- 180 values hashing to 3c2b8c60f9c069d2fec20be5436bcaef

-- query IIIIII rowsort x221
SELECT d,
       c-d,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
 ORDER BY 2,5,3,1,4
;
-- 180 values hashing to 3c2b8c60f9c069d2fec20be5436bcaef

-- query II rowsort x222
SELECT abs(a),
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
;
-- 30 values hashing to 22e9f0aee0362e751bbd3b8ee9e4132b

-- query II rowsort x222
SELECT abs(a),
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 2,1
;
-- 30 values hashing to 22e9f0aee0362e751bbd3b8ee9e4132b

-- query II rowsort x222
SELECT abs(a),
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
;
-- 30 values hashing to 22e9f0aee0362e751bbd3b8ee9e4132b

-- query II rowsort x222
SELECT abs(a),
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 30 values hashing to 22e9f0aee0362e751bbd3b8ee9e4132b

-- query IIIII rowsort x223
SELECT e,
       c,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to 6f2760ad04a095b47a38304a0ce7cdad

-- query IIIII rowsort x223
SELECT e,
       c,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,1
;
-- 50 values hashing to 6f2760ad04a095b47a38304a0ce7cdad

-- query III rowsort x224
SELECT c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to 9dd3f8305d9a0c3356085f5f4b3dce73

-- query III rowsort x224
SELECT c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,2
;
-- 30 values hashing to 9dd3f8305d9a0c3356085f5f4b3dce73

-- query IIII rowsort x225
SELECT c-d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
;
-- 52 values hashing to bb512ea3d271ac62b90c40752e35f14b

-- query IIII rowsort x225
SELECT c-d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
 ORDER BY 3,1,2
;
-- 52 values hashing to bb512ea3d271ac62b90c40752e35f14b

-- query IIIIIII rowsort x226
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       abs(a),
       d-e
  FROM t1
;
-- 210 values hashing to b5cbf607833bf9a5fdc632fb91e9ff71

-- query IIIIIII rowsort x226
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       abs(a),
       d-e
  FROM t1
 ORDER BY 5,4,2,7,3
;
-- 210 values hashing to b5cbf607833bf9a5fdc632fb91e9ff71

-- query I rowsort x227
SELECT a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 7e883b178d4e5791c14e6a7e2bac0d0d

-- query I rowsort x227
SELECT a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 10 values hashing to 7e883b178d4e5791c14e6a7e2bac0d0d

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query II rowsort x228
SELECT abs(b-c),
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 54 values hashing to d4ce8ba735d9acaa3b10b7b1a10f6953

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 3,4
;

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3,4
;

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x229
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4
;

-- query IIIII rowsort x230
SELECT abs(a),
       a-b,
       d,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
;
-- 105 values hashing to 7812b85b0f50b75dbd9e607e311dab66

-- query IIIII rowsort x230
SELECT abs(a),
       a-b,
       d,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 1,3,2,4
;
-- 105 values hashing to 7812b85b0f50b75dbd9e607e311dab66

-- query III rowsort x231
SELECT d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE b>c
;
-- 39 values hashing to c87739d1c8a83e2c24c60f3aa8b27352

-- query III rowsort x231
SELECT d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE b>c
 ORDER BY 3,2
;
-- 39 values hashing to c87739d1c8a83e2c24c60f3aa8b27352

-- query IIIII rowsort x232
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 25 values hashing to f97cdad01f826c602da43c95709d7b37

-- query IIIII rowsort x232
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 4,1,3,2,5
;
-- 25 values hashing to f97cdad01f826c602da43c95709d7b37

-- query IIIIIII rowsort x233
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 56 values hashing to 2a206e5f4a306122d828045c0545b0e9

-- query IIIIIII rowsort x233
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,2,5,1
;
-- 56 values hashing to 2a206e5f4a306122d828045c0545b0e9

-- query IIIIIII rowsort x234
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       a-b,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 182 values hashing to bb6a2dc836dbe87b1f1614c7b5cbc31f

-- query IIIIIII rowsort x234
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       a-b,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,7
;
-- 182 values hashing to bb6a2dc836dbe87b1f1614c7b5cbc31f

-- query II rowsort x235
SELECT b,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
;

-- query II rowsort x235
SELECT b,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
 ORDER BY 1,2
;

-- query II rowsort x235
SELECT b,
       a+b*2
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query II rowsort x235
SELECT b,
       a+b*2
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;

-- query IIII rowsort x236
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 60 values hashing to d644984b6f9054a9563f45bc047ccb8e

-- query IIII rowsort x236
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 3,1,4,2
;
-- 60 values hashing to d644984b6f9054a9563f45bc047ccb8e

-- query IIIIII rowsort x237
SELECT b-c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
;
-- 42 values hashing to 330177bd106f9db2a147541d0a83c95d

-- query IIIIII rowsort x237
SELECT b-c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 5,3,4,1
;
-- 42 values hashing to 330177bd106f9db2a147541d0a83c95d

-- query IIIIII rowsort x237
SELECT b-c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 42 values hashing to 330177bd106f9db2a147541d0a83c95d

-- query IIIIII rowsort x237
SELECT b-c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 6,4,1
;
-- 42 values hashing to 330177bd106f9db2a147541d0a83c95d

-- query II rowsort x238
SELECT a,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
;
-- 54 values hashing to a09cfc6ea15c7f2923bb3bf3c08114d5

-- query II rowsort x238
SELECT a,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
 ORDER BY 2,1
;
-- 54 values hashing to a09cfc6ea15c7f2923bb3bf3c08114d5

-- query II rowsort x238
SELECT a,
       b
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to a09cfc6ea15c7f2923bb3bf3c08114d5

-- query II rowsort x238
SELECT a,
       b
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 54 values hashing to a09cfc6ea15c7f2923bb3bf3c08114d5

-- query III rowsort x239
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 9 values hashing to f044135d5ec9fca538836730e824fee6

-- query III rowsort x239
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2,1
;
-- 9 values hashing to f044135d5ec9fca538836730e824fee6

-- query III rowsort x239
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 9 values hashing to f044135d5ec9fca538836730e824fee6

-- query III rowsort x239
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 3,1
;
-- 9 values hashing to f044135d5ec9fca538836730e824fee6

-- query II rowsort x240
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 16 values hashing to cd57c9637cf1dd8a14c62b351d7876c7

-- query II rowsort x240
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 16 values hashing to cd57c9637cf1dd8a14c62b351d7876c7

-- query II rowsort x240
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
;
-- 16 values hashing to cd57c9637cf1dd8a14c62b351d7876c7

-- query II rowsort x240
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 16 values hashing to cd57c9637cf1dd8a14c62b351d7876c7

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND d>e
   AND c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,3
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND a>b
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 2,3,1
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d>e
   AND a>b
   AND c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query III rowsort x241
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d>e
   AND a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2
;
-- 15 values hashing to 549ef6c7a2e8518af80a4c5c167ccb57

-- query I rowsort x242
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
;
-- 222

-- query I rowsort x242
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 222

-- query I rowsort x242
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;
-- 222

-- query I rowsort x242
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 222

-- query IIII rowsort x243
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       e,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 32 values hashing to be5aab25bb7e0a33c20cbc34de57ed18

-- query IIII rowsort x243
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       e,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 4,1
;
-- 32 values hashing to be5aab25bb7e0a33c20cbc34de57ed18

-- query III rowsort x244
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
;
-- 9 values hashing to d721035cc6a214f9dff82f700c27f98f

-- query III rowsort x244
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,1
;
-- 9 values hashing to d721035cc6a214f9dff82f700c27f98f

-- query IIIIIII rowsort x245
SELECT abs(a),
       c,
       a+b*2+c*3,
       d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
;
-- 77 values hashing to 0d8574644a00abf2c52da416b02ea014

-- query IIIIIII rowsort x245
SELECT abs(a),
       c,
       a+b*2+c*3,
       d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
 ORDER BY 6,2,7,3,5,1
;
-- 77 values hashing to 0d8574644a00abf2c52da416b02ea014

-- query I rowsort x246
SELECT c-d
  FROM t1
;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query I rowsort x246
SELECT c-d
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query IIII rowsort x247
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 60 values hashing to f3728015d880344e7da187798a04d6fe

-- query IIII rowsort x247
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 2,3,4,1
;
-- 60 values hashing to f3728015d880344e7da187798a04d6fe

-- query II rowsort x248
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 10 values hashing to 993ada4aa33fed5a3c3cc14c7f0355a2

-- query II rowsort x248
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 1,2
;
-- 10 values hashing to 993ada4aa33fed5a3c3cc14c7f0355a2

-- query II rowsort x248
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 993ada4aa33fed5a3c3cc14c7f0355a2

-- query II rowsort x248
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 10 values hashing to 993ada4aa33fed5a3c3cc14c7f0355a2

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND d NOT BETWEEN 110 AND 150
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
 ORDER BY 2,1,3
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (e>c OR e<d)
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query III rowsort x249
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (e>c OR e<d)
 ORDER BY 3,1,2
;
-- 15 values hashing to efd797723366531db1bebf903a6d7592

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,1,4,5
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
 ORDER BY 5,1,2,3
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIII rowsort x250
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
 ORDER BY 5,3,1
;
-- 110 values hashing to 2f522c62ea77218ed529d169e6ba970b

-- query IIIIII rowsort x251
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       c-d
  FROM t1
 WHERE b>c
;
-- 78 values hashing to 029db106a359201924a20c5e7ff377e2

-- query IIIIII rowsort x251
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       c-d
  FROM t1
 WHERE b>c
 ORDER BY 1,3,5,6,4
;
-- 78 values hashing to 029db106a359201924a20c5e7ff377e2

-- query IIIIII rowsort x252
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       e,
       d-e,
       c-d,
       a
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d>e
;

-- query IIIIII rowsort x252
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       e,
       d-e,
       c-d,
       a
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d>e
 ORDER BY 6,3
;

-- query IIIIII rowsort x252
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       e,
       d-e,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND d>e
   AND (e>a AND e<b)
;

-- query IIIIII rowsort x252
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       e,
       d-e,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND d>e
   AND (e>a AND e<b)
 ORDER BY 6,5
;

-- query IIII rowsort x253
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       c,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
;
-- 16
-- 2878
-- 193
-- 579
-- 26
-- 3706
-- 247
-- 743

-- query IIII rowsort x253
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       c,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
 ORDER BY 2,4
;
-- 16
-- 2878
-- 193
-- 579
-- 26
-- 3706
-- 247
-- 743

-- query IIIII rowsort x254
SELECT abs(a),
       a+b*2+c*3,
       a+b*2,
       e,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 40 values hashing to e5463f71a41e13dccc88ded91f689791

-- query IIIII rowsort x254
SELECT abs(a),
       a+b*2+c*3,
       a+b*2,
       e,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 5,4,1,2,3
;
-- 40 values hashing to e5463f71a41e13dccc88ded91f689791

-- query IIIII rowsort x255
SELECT a-b,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 75 values hashing to 35978cebd4adb543c68cf09793e3a08d

-- query IIIII rowsort x255
SELECT a-b,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 5,2,4
;
-- 75 values hashing to 35978cebd4adb543c68cf09793e3a08d

-- query I rowsort x256
SELECT a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 0462df69a372162bd2326b32559acd24

-- query I rowsort x256
SELECT a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to 0462df69a372162bd2326b32559acd24

-- query IIII rowsort x257
SELECT a+b*2,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
;
-- 92 values hashing to 10918894cdc2e2486b0c6db84bc930f2

-- query IIII rowsort x257
SELECT a+b*2,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2,3,4
;
-- 92 values hashing to 10918894cdc2e2486b0c6db84bc930f2

-- query IIII rowsort x257
SELECT a+b*2,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
;
-- 92 values hashing to 10918894cdc2e2486b0c6db84bc930f2

-- query IIII rowsort x257
SELECT a+b*2,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
 ORDER BY 3,2,4
;
-- 92 values hashing to 10918894cdc2e2486b0c6db84bc930f2

-- query I rowsort x258
SELECT b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 14 values hashing to a7e5c80b121ef6ebed205e0e293a70bb

-- query I rowsort x258
SELECT b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 14 values hashing to a7e5c80b121ef6ebed205e0e293a70bb

-- query I rowsort x258
SELECT b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
;
-- 14 values hashing to a7e5c80b121ef6ebed205e0e293a70bb

-- query I rowsort x258
SELECT b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 14 values hashing to a7e5c80b121ef6ebed205e0e293a70bb

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR d>e
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR d>e
 ORDER BY 1,2
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR c>d
    OR (e>c OR e<d)
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR c>d
    OR (e>c OR e<d)
 ORDER BY 2,1
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR c>d
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query II rowsort x259
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR c>d
 ORDER BY 1,2
;
-- 52 values hashing to 8016ab331d3de23b9d9d86ef15ff6188

-- query IIIII rowsort x260
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       abs(b-c),
       b
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 55 values hashing to 48231c3bc55f491fbef643fb9e0ff0dd

-- query IIIII rowsort x260
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       abs(b-c),
       b
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,1,5,2,3
;
-- 55 values hashing to 48231c3bc55f491fbef643fb9e0ff0dd

-- query IIIII rowsort x260
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       abs(b-c),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
;
-- 55 values hashing to 48231c3bc55f491fbef643fb9e0ff0dd

-- query IIIII rowsort x260
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       abs(b-c),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
 ORDER BY 5,4,3,1,2
;
-- 55 values hashing to 48231c3bc55f491fbef643fb9e0ff0dd

-- query IIII rowsort x261
SELECT a+b*2+c*3,
       d,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 60 values hashing to ae37d31c8ce412a5a1d53fff2eadd283

-- query IIII rowsort x261
SELECT a+b*2+c*3,
       d,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 4,3,1,2
;
-- 60 values hashing to ae37d31c8ce412a5a1d53fff2eadd283

-- query IIIIIII rowsort x262
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       abs(b-c),
       c-d
  FROM t1
 WHERE a>b
;
-- 119 values hashing to d681beba9c51dcdbdb73c28c06816f1a

-- query IIIIIII rowsort x262
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       abs(b-c),
       c-d
  FROM t1
 WHERE a>b
 ORDER BY 3,4,7,5,2,1,6
;
-- 119 values hashing to d681beba9c51dcdbdb73c28c06816f1a

-- query IIII rowsort x263
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
;
-- 68 values hashing to 4df88795d28642e3011ed7c43bbfacb3

-- query IIII rowsort x263
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
 ORDER BY 1,2
;
-- 68 values hashing to 4df88795d28642e3011ed7c43bbfacb3

-- query IIIII rowsort x264
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 110 values hashing to 368aabb83756ec743ef7e87d428181f7

-- query IIIII rowsort x264
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,4
;
-- 110 values hashing to 368aabb83756ec743ef7e87d428181f7

-- query IIIII rowsort x264
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 110 values hashing to 368aabb83756ec743ef7e87d428181f7

-- query IIIII rowsort x264
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,5,4,2,3
;
-- 110 values hashing to 368aabb83756ec743ef7e87d428181f7

-- query IIIIII rowsort x265
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       c,
       abs(a),
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 180 values hashing to 569cfd1e5f992d360c1409a72c51313e

-- query IIIIII rowsort x265
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       c,
       abs(a),
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 3,2,5,4,1,6
;
-- 180 values hashing to 569cfd1e5f992d360c1409a72c51313e

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4,3
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
 ORDER BY 4,2
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,1
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x266
SELECT e,
       a+b*2+c*3,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4,1
;

-- query IIIII rowsort x267
SELECT e,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x267
SELECT e,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1,4,2
;

-- query IIIII rowsort x267
SELECT e,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x267
SELECT e,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,4,3,1,2
;

-- query IIIII rowsort x268
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to 811663651ce5d74b26e6f8a0ab084a54

-- query IIIII rowsort x268
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 4,1,5,3
;
-- 50 values hashing to 811663651ce5d74b26e6f8a0ab084a54

-- query I rowsort x269
SELECT d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;
-- 190
-- 222
-- 248

-- query I rowsort x269
SELECT d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 1
;
-- 190
-- 222
-- 248

-- query I rowsort x269
SELECT d
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 190
-- 222
-- 248

-- query I rowsort x269
SELECT d
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 190
-- 222
-- 248

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND c>d
   AND (e>a AND e<b)
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND c>d
   AND (e>a AND e<b)
 ORDER BY 3,4,6,7,1
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c>d
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c>d
 ORDER BY 6,3,4
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
   AND d>e
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
   AND d>e
 ORDER BY 2,1
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
   AND c>d
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query IIIIIII rowsort x270
SELECT c,
       (a+b+c+d+e)/5,
       e,
       d-e,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
   AND c>d
 ORDER BY 5,1,6,2,3
;
-- 224
-- 222
-- 221
-- 1
-- 666
-- -1
-- 0

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query I rowsort x271
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 28 values hashing to 199eb36995ce9cc025eb667a27b774d5

-- query II rowsort x272
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 60 values hashing to beed70047ae1fe6e957f8b195a17c63d

-- query II rowsort x272
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to beed70047ae1fe6e957f8b195a17c63d

-- query IIII rowsort x273
SELECT a,
       b-c,
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 40 values hashing to 38f9a6f093c1ee7b2fc4271c752ed1cc

-- query IIII rowsort x273
SELECT a,
       b-c,
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1,4,2
;
-- 40 values hashing to 38f9a6f093c1ee7b2fc4271c752ed1cc

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
 ORDER BY 1,2,5
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 2,3
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x274
SELECT a,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,4
;
-- 220
-- 2
-- 1
-- 1338
-- 3331

-- query IIIII rowsort x275
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       b,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to cc044b3e1bb23780c4122968965b9354

-- query IIIII rowsort x275
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       b,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 5,2
;
-- 50 values hashing to cc044b3e1bb23780c4122968965b9354

-- query I rowsort x276
SELECT a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to efa8813bb3fe4fd95c76a8b4cec1fef1

-- query I rowsort x276
SELECT a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 10 values hashing to efa8813bb3fe4fd95c76a8b4cec1fef1

-- query IIIIIII rowsort x277
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       d,
       a-b
  FROM t1
;
-- 210 values hashing to 7486fd307b51a7be6044ad6f75724921

-- query IIIIIII rowsort x277
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       d,
       a-b
  FROM t1
 ORDER BY 3,7,4,2,1
;
-- 210 values hashing to 7486fd307b51a7be6044ad6f75724921

-- query III rowsort x278
SELECT c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE a>b
;
-- 51 values hashing to ce8fbf8484882a4861b010d1bdd692a0

-- query III rowsort x278
SELECT c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE a>b
 ORDER BY 1,3
;
-- 51 values hashing to ce8fbf8484882a4861b010d1bdd692a0

-- query IIII rowsort x279
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2,
       d-e
  FROM t1
;
-- 120 values hashing to c8342c8e4bd0281d6cc939310a43f2bd

-- query IIII rowsort x279
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2,
       d-e
  FROM t1
 ORDER BY 1,2,3,4
;
-- 120 values hashing to c8342c8e4bd0281d6cc939310a43f2bd

-- query IIIII rowsort x280
SELECT c-d,
       d,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
;
-- 150 values hashing to 3bc7718481a0e80714bf6d63ff54dbba

-- query IIIII rowsort x280
SELECT c-d,
       d,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 5,1,4
;
-- 150 values hashing to 3bc7718481a0e80714bf6d63ff54dbba

-- query IIIIIII rowsort x281
SELECT d,
       (a+b+c+d+e)/5,
       d-e,
       b-c,
       b,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
;
-- 196 values hashing to fe3b7834bf1f16af9a218035e03b116c

-- query IIIIIII rowsort x281
SELECT d,
       (a+b+c+d+e)/5,
       d-e,
       b-c,
       b,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
 ORDER BY 1,5,2,3,4,6,7
;
-- 196 values hashing to fe3b7834bf1f16af9a218035e03b116c

-- query IIIIIII rowsort x281
SELECT d,
       (a+b+c+d+e)/5,
       d-e,
       b-c,
       b,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 196 values hashing to fe3b7834bf1f16af9a218035e03b116c

-- query IIIIIII rowsort x281
SELECT d,
       (a+b+c+d+e)/5,
       d-e,
       b-c,
       b,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,7,5,1,4,6,3
;
-- 196 values hashing to fe3b7834bf1f16af9a218035e03b116c

-- query IIIIII rowsort x282
SELECT a+b*2,
       b,
       abs(b-c),
       d-e,
       a,
       c-d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 108 values hashing to 9d92cdd25b06773d672e7c3859697c55

-- query IIIIII rowsort x282
SELECT a+b*2,
       b,
       abs(b-c),
       d-e,
       a,
       c-d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,5
;
-- 108 values hashing to 9d92cdd25b06773d672e7c3859697c55

-- query IIIIII rowsort x282
SELECT a+b*2,
       b,
       abs(b-c),
       d-e,
       a,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 108 values hashing to 9d92cdd25b06773d672e7c3859697c55

-- query IIIIII rowsort x282
SELECT a+b*2,
       b,
       abs(b-c),
       d-e,
       a,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 2,6,5,1,3,4
;
-- 108 values hashing to 9d92cdd25b06773d672e7c3859697c55

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query I rowsort x283
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 27 values hashing to 2c390d67360189455801dde3eabc94c1

-- query IIIIII rowsort x284
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c
  FROM t1
;
-- 180 values hashing to 1d0de9d24d8118b60018a11121f08077

-- query IIIIII rowsort x284
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c
  FROM t1
 ORDER BY 5,1,4,3,6
;
-- 180 values hashing to 1d0de9d24d8118b60018a11121f08077

-- query IIIII rowsort x285
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
;
-- 150 values hashing to b971905f32afdbb3012ccf36d9988e58

-- query IIIII rowsort x285
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 ORDER BY 3,5
;
-- 150 values hashing to b971905f32afdbb3012ccf36d9988e58

-- query IIIIIII rowsort x286
SELECT abs(a),
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
;
-- 140 values hashing to 6d150ac098b3050af6b926cad6652fc3

-- query IIIIIII rowsort x286
SELECT abs(a),
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
 ORDER BY 7,2
;
-- 140 values hashing to 6d150ac098b3050af6b926cad6652fc3

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND (a>b-2 AND a<b+2)
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,5,6
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 6,4,7,5
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
   AND a>b
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query IIIIIII rowsort x287
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3,
       b-c,
       (a+b+c+d+e)/5,
       abs(b-c),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 1,3,4,5,6,2,7
;
-- 21 values hashing to 7913e005ffff21245fdcea9c3d34fb63

-- query III rowsort x288
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a)
  FROM t1
;
-- 90 values hashing to 67248c2918ebe4af9523fec7d59cd50b

-- query III rowsort x288
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a)
  FROM t1
 ORDER BY 2,1
;
-- 90 values hashing to 67248c2918ebe4af9523fec7d59cd50b

-- query IIIIIII rowsort x289
SELECT b-c,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
;
-- 210 values hashing to 1308bb5483e2e2ff52b8f8054a9ac5cd

-- query IIIIIII rowsort x289
SELECT b-c,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 ORDER BY 2,7,3,4,1,5,6
;
-- 210 values hashing to 1308bb5483e2e2ff52b8f8054a9ac5cd

-- query IIIII rowsort x290
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       b
  FROM t1
;
-- 150 values hashing to 0385c2db473c4ec4eff9c5f169932b89

-- query IIIII rowsort x290
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       b
  FROM t1
 ORDER BY 4,1,3,2,5
;
-- 150 values hashing to 0385c2db473c4ec4eff9c5f169932b89

-- query IIIII rowsort x291
SELECT b,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 150 values hashing to 2671d7e440d49bb15bba2d068a6fb56e

-- query IIIII rowsort x291
SELECT b,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,5,4,1,3
;
-- 150 values hashing to 2671d7e440d49bb15bba2d068a6fb56e

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
   AND d>e
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
   AND d>e
 ORDER BY 1,2
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND c>d
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND c>d
 ORDER BY 1,2
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND d>e
   AND (a>b-2 AND a<b+2)
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query II rowsort x292
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND d>e
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 131
-- 333
-- 138
-- 222
-- 182
-- 333

-- query IIIII rowsort x293
SELECT e,
       (a+b+c+d+e)/5,
       abs(a),
       c-d,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
;
-- 145 values hashing to 646dabfcf63de71a2cd0241f3c5c354c

-- query IIIII rowsort x293
SELECT e,
       (a+b+c+d+e)/5,
       abs(a),
       c-d,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,4,2,5,1
;
-- 145 values hashing to 646dabfcf63de71a2cd0241f3c5c354c

-- query IIIII rowsort x294
SELECT d,
       a+b*2+c*3,
       c,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 150 values hashing to df59bd3344f3e0573446957b26e8b00f

-- query IIIII rowsort x294
SELECT d,
       a+b*2+c*3,
       c,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 3,2,5,4
;
-- 150 values hashing to df59bd3344f3e0573446957b26e8b00f

-- query II rowsort x295
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 313e2f24fcde36abf536de1a90a3fd55

-- query II rowsort x295
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 20 values hashing to 313e2f24fcde36abf536de1a90a3fd55

-- query IIIIIII rowsort x296
SELECT d,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       e,
       (a+b+c+d+e)/5
  FROM t1
;
-- 210 values hashing to b8a38ab3b031ad91464b62c5c9d9cf52

-- query IIIIIII rowsort x296
SELECT d,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       e,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 7,5,4,6,1
;
-- 210 values hashing to b8a38ab3b031ad91464b62c5c9d9cf52

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
    OR b>c
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
    OR b>c
 ORDER BY 4,2,3,1
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
 ORDER BY 2,1
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR b>c
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR b>c
 ORDER BY 2,1
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR d NOT BETWEEN 110 AND 150
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query IIII rowsort x297
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,3
;
-- 108 values hashing to f17c6b3e60c3a1d7881ff9c7defa63c5

-- query II rowsort x298
SELECT e,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
;
-- 30 values hashing to f86eeb8a5ace713028dbbf2ca99dbad7

-- query II rowsort x298
SELECT e,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 2,1
;
-- 30 values hashing to f86eeb8a5ace713028dbbf2ca99dbad7

-- query II rowsort x298
SELECT e,
       a-b
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
;
-- 30 values hashing to f86eeb8a5ace713028dbbf2ca99dbad7

-- query II rowsort x298
SELECT e,
       a-b
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 30 values hashing to f86eeb8a5ace713028dbbf2ca99dbad7

-- query IIII rowsort x299
SELECT c,
       d-e,
       abs(a),
       e
  FROM t1
;
-- 120 values hashing to e83bb402da7a08db39698ddc6894bc80

-- query IIII rowsort x299
SELECT c,
       d-e,
       abs(a),
       e
  FROM t1
 ORDER BY 1,2
;
-- 120 values hashing to e83bb402da7a08db39698ddc6894bc80

-- query IIII rowsort x300
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
;
-- 52 values hashing to 78e7b83e6942df2d1bfd868316d31335

-- query IIII rowsort x300
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
 ORDER BY 4,3
;
-- 52 values hashing to 78e7b83e6942df2d1bfd868316d31335

-- query IIIIII rowsort x301
SELECT a-b,
       abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 102 values hashing to a6af0d67f11b2d67f0274effd3a7886c

-- query IIIIII rowsort x301
SELECT a-b,
       abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 4,3,1,2,6
;
-- 102 values hashing to a6af0d67f11b2d67f0274effd3a7886c

-- query I rowsort x302
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
;
-- 17 values hashing to baeb6fdb5d575870fddf7d11fa9e02f3

-- query I rowsort x302
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
 ORDER BY 1
;
-- 17 values hashing to baeb6fdb5d575870fddf7d11fa9e02f3

-- query IIII rowsort x303
SELECT c-d,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
;
-- 120 values hashing to 0249d9b05d5c103df774e762f761cffb

-- query IIII rowsort x303
SELECT c-d,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 ORDER BY 4,2,1
;
-- 120 values hashing to 0249d9b05d5c103df774e762f761cffb

-- query IIIII rowsort x304
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
   AND (e>c OR e<d)
;
-- 10 values hashing to 65e67c89f0b9eac3aebadb469d499244

-- query IIIII rowsort x304
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>a AND e<b)
   AND (e>c OR e<d)
 ORDER BY 5,1,4
;
-- 10 values hashing to 65e67c89f0b9eac3aebadb469d499244

-- query IIIII rowsort x304
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND (e>a AND e<b)
;
-- 10 values hashing to 65e67c89f0b9eac3aebadb469d499244

-- query IIIII rowsort x304
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND (e>a AND e<b)
 ORDER BY 2,5,1,3
;
-- 10 values hashing to 65e67c89f0b9eac3aebadb469d499244

-- query IIII rowsort x305
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
;
-- 120 values hashing to cbafe694dc36f6d5a77ed21b9171865a

-- query IIII rowsort x305
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 ORDER BY 1,2,4,3
;
-- 120 values hashing to cbafe694dc36f6d5a77ed21b9171865a

-- query IIIIII rowsort x306
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       d-e,
       a+b*2
  FROM t1
 WHERE c>d
;
-- 78 values hashing to f5801c819d7fc8338357d6aeedca106d

-- query IIIIII rowsort x306
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       d-e,
       a+b*2
  FROM t1
 WHERE c>d
 ORDER BY 4,5,6,3,2,1
;
-- 78 values hashing to f5801c819d7fc8338357d6aeedca106d

-- query IIII rowsort x307
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 120 values hashing to 727f16ef8bf4aaf1061c0602fa722757

-- query IIII rowsort x307
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 4,2,3
;
-- 120 values hashing to 727f16ef8bf4aaf1061c0602fa722757

-- query IIIIII rowsort x308
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       a+b*2+c*3
  FROM t1
;
-- 180 values hashing to e13410f526aa235c1220c611a43aeab1

-- query IIIIII rowsort x308
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       a+b*2+c*3
  FROM t1
 ORDER BY 6,1
;
-- 180 values hashing to e13410f526aa235c1220c611a43aeab1

-- query III rowsort x309
SELECT a-b,
       a+b*2,
       c
  FROM t1
;
-- 90 values hashing to c6af1ce8e7751994c9acfbf36e97f991

-- query III rowsort x309
SELECT a-b,
       a+b*2,
       c
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to c6af1ce8e7751994c9acfbf36e97f991

-- query III rowsort x310
SELECT d-e,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
;
-- 24 values hashing to 5d0a46c407293e78a2ca3cf0c3cd5c49

-- query III rowsort x310
SELECT d-e,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 3,2
;
-- 24 values hashing to 5d0a46c407293e78a2ca3cf0c3cd5c49

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE b>c
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE b>c
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
   AND b>c
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
   AND b>c
 ORDER BY 3,2,1
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query III rowsort x311
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 3,1
;
-- 23
-- 0
-- 233
-- 26
-- 0
-- 248

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query II rowsort x312
SELECT a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 38 values hashing to 8c7d032b253042442e7800e69dca3de8

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
 ORDER BY 5,3,4,1
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE b>c
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE b>c
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,6,5,1,3,4
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIIIII rowsort x313
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       a-b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,6,1
;
-- 144 values hashing to 5d554a6a785e45be7fb99898e93d8d94

-- query IIII rowsort x314
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c>d
;
-- 16 values hashing to d67cabf96d0b47633cd08730637b2048

-- query IIII rowsort x314
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c>d
 ORDER BY 3,2,1
;
-- 16 values hashing to d67cabf96d0b47633cd08730637b2048

-- query IIII rowsort x314
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
;
-- 16 values hashing to d67cabf96d0b47633cd08730637b2048

-- query IIII rowsort x314
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,4
;
-- 16 values hashing to d67cabf96d0b47633cd08730637b2048

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>a AND e<b)
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>a AND e<b)
 ORDER BY 2,1
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
 ORDER BY 2,1
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 2,1
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;
-- 0
-- 444
-- 0
-- 444

-- query II rowsort x315
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 0
-- 444
-- 0
-- 444

-- query IIIII rowsort x316
SELECT abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 85 values hashing to 39ae65b13a8871e595955fe9fc9b2e5d

-- query IIIII rowsort x316
SELECT abs(b-c),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 5,3,2,4,1
;
-- 85 values hashing to 39ae65b13a8871e595955fe9fc9b2e5d

-- query III rowsort x317
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND b>c
;
-- 0
-- 127
-- 4

-- query III rowsort x317
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND b>c
 ORDER BY 3,1
;
-- 0
-- 127
-- 4

-- query II rowsort x318
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to a883dad8b02e10bdbbfcd41a959944b3

-- query II rowsort x318
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 20 values hashing to a883dad8b02e10bdbbfcd41a959944b3

-- query IIII rowsort x319
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR c>d
;
-- 104 values hashing to 39510fb3ed1150a561a8d542151b4a24

-- query IIII rowsort x319
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR c>d
 ORDER BY 3,4
;
-- 104 values hashing to 39510fb3ed1150a561a8d542151b4a24

-- query IIII rowsort x319
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
;
-- 104 values hashing to 39510fb3ed1150a561a8d542151b4a24

-- query IIII rowsort x319
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 3,1,2
;
-- 104 values hashing to 39510fb3ed1150a561a8d542151b4a24

-- query I rowsort x320
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
;
-- 17 values hashing to dd282b8dd7664ec4babf6af25299c8f4

-- query I rowsort x320
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
 ORDER BY 1
;
-- 17 values hashing to dd282b8dd7664ec4babf6af25299c8f4

-- query II rowsort x321
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 60 values hashing to d1c1f508b401a056a7d00268e472c4dd

-- query II rowsort x321
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to d1c1f508b401a056a7d00268e472c4dd

-- query IIIIIII rowsort x322
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
;
-- 91 values hashing to 11d5fc8b50cf11747fb09838a6179a62

-- query IIIIIII rowsort x322
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
 ORDER BY 5,1,3
;
-- 91 values hashing to 11d5fc8b50cf11747fb09838a6179a62

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
    OR (e>a AND e<b)
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
    OR (e>a AND e<b)
 ORDER BY 4,2,3,1
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR c BETWEEN b-2 AND d+2
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,1,4,3
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 3,4
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
    OR c>d
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIII rowsort x323
SELECT d,
       a+b*2+c*3,
       a,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
    OR c>d
 ORDER BY 1,3,2
;
-- 72 values hashing to e48615ff8ca5cfc049146260f31d5352

-- query IIIII rowsort x324
SELECT b-c,
       b,
       d-e,
       (a+b+c+d+e)/5,
       c
  FROM t1
;
-- 150 values hashing to 8c15f4a29de572fba8a576d3bee6210d

-- query IIIII rowsort x324
SELECT b-c,
       b,
       d-e,
       (a+b+c+d+e)/5,
       c
  FROM t1
 ORDER BY 5,1,2
;
-- 150 values hashing to 8c15f4a29de572fba8a576d3bee6210d

-- query I rowsort x325
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query I rowsort x325
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query I rowsort x326
SELECT a+b*2
  FROM t1
 WHERE d>e
;
-- 11 values hashing to 894d1073493aea169dfee5237f6088b5

-- query I rowsort x326
SELECT a+b*2
  FROM t1
 WHERE d>e
 ORDER BY 1
;
-- 11 values hashing to 894d1073493aea169dfee5237f6088b5

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,6,3,2,5
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,3,6,4,2,5
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR c BETWEEN b-2 AND d+2
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,5,3
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query IIIIII rowsort x327
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,5,2,3,4,1
;
-- 138 values hashing to 2be016aa8b0de3153009a558d58e6e7a

-- query II rowsort x328
SELECT d-e,
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
;
-- 20 values hashing to 9213ee0b196f8c55b9b2a0d3784eb5ba

-- query II rowsort x328
SELECT d-e,
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 20 values hashing to 9213ee0b196f8c55b9b2a0d3784eb5ba

-- query II rowsort x328
SELECT d-e,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 20 values hashing to 9213ee0b196f8c55b9b2a0d3784eb5ba

-- query II rowsort x328
SELECT d-e,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- 20 values hashing to 9213ee0b196f8c55b9b2a0d3784eb5ba

-- query II rowsort x329
SELECT a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE (e>c OR e<d)
;
-- 42 values hashing to 458b4bfdfa720cc7465cc2064215cca0

-- query II rowsort x329
SELECT a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 2,1
;
-- 42 values hashing to 458b4bfdfa720cc7465cc2064215cca0

-- query III rowsort x330
SELECT e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 90 values hashing to 4dc17ac0fe53b0d075f577808068bada

-- query III rowsort x330
SELECT e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 1,3
;
-- 90 values hashing to 4dc17ac0fe53b0d075f577808068bada

-- query I rowsort x331
SELECT a-b
  FROM t1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query I rowsort x331
SELECT a-b
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query IIIII rowsort x332
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
;
-- 15 values hashing to 746ab6528656cd4013330c3a8960d199

-- query IIIII rowsort x332
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1,5,3
;
-- 15 values hashing to 746ab6528656cd4013330c3a8960d199

-- query IIIIII rowsort x333
SELECT a,
       a+b*2+c*3+d*4,
       e,
       a-b,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 48 values hashing to 41333036c33ca1020ecdf3ad5b3fca26

-- query IIIIII rowsort x333
SELECT a,
       a+b*2+c*3+d*4,
       e,
       a-b,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 5,2
;
-- 48 values hashing to 41333036c33ca1020ecdf3ad5b3fca26

-- query II rowsort x334
SELECT c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
;
-- 52 values hashing to 46cb487ee40100f4b5738b678e5ca30d

-- query II rowsort x334
SELECT c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
 ORDER BY 2,1
;
-- 52 values hashing to 46cb487ee40100f4b5738b678e5ca30d

-- query II rowsort x334
SELECT c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to 46cb487ee40100f4b5738b678e5ca30d

-- query II rowsort x334
SELECT c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 52 values hashing to 46cb487ee40100f4b5738b678e5ca30d

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
    OR a>b
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
    OR a>b
 ORDER BY 1,3
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
 ORDER BY 2,3
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query III rowsort x335
SELECT (a+b+c+d+e)/5,
       d,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 84 values hashing to 4ed78bf4242fcd95e3948b18cc96105c

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
    OR b>c
    OR (a>b-2 AND a<b+2)
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
    OR b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 4,2,5,1,6,3
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
    OR a>b
    OR (a>b-2 AND a<b+2)
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
    OR a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 4,6,5,3,2
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR b>c
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query IIIIII rowsort x336
SELECT abs(a),
       d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR b>c
 ORDER BY 5,1,2,6,3
;
-- 144 values hashing to b29aa2f0959d342b1fe6a5111224dc65

-- query II rowsort x337
SELECT abs(a),
       a+b*2+c*3
  FROM t1
 WHERE d>e
;
-- 22 values hashing to 5473c9f8d1216beb4e678b45e690a858

-- query II rowsort x337
SELECT abs(a),
       a+b*2+c*3
  FROM t1
 WHERE d>e
 ORDER BY 1,2
;
-- 22 values hashing to 5473c9f8d1216beb4e678b45e690a858

-- query IIIIII rowsort x338
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
;
-- 78 values hashing to 2456c9c4aabea692d43cdaba4f819e77

-- query IIIIII rowsort x338
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
 ORDER BY 1,6,4
;
-- 78 values hashing to 2456c9c4aabea692d43cdaba4f819e77

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,5
;

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,2,5,3
;

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
;

-- query IIIII rowsort x339
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
 ORDER BY 4,1,3,5
;

-- query IIIIII rowsort x340
SELECT a+b*2,
       abs(b-c),
       abs(a),
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
;
-- 144 values hashing to e2b60e10831969a097fab3dcf057ee30

-- query IIIIII rowsort x340
SELECT a+b*2,
       abs(b-c),
       abs(a),
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,4,3
;
-- 144 values hashing to e2b60e10831969a097fab3dcf057ee30

-- query IIIIII rowsort x341
SELECT d-e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
;
-- 180 values hashing to 8d07de1b9e6e330e3cf09ad37a1cb8f1

-- query IIIIII rowsort x341
SELECT d-e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 3,4,1,6
;
-- 180 values hashing to 8d07de1b9e6e330e3cf09ad37a1cb8f1

-- query II rowsort x342
SELECT b,
       c
  FROM t1
;
-- 60 values hashing to c3e922e391723c5ae3816d0fb151a039

-- query II rowsort x342
SELECT b,
       c
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to c3e922e391723c5ae3816d0fb151a039

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND (a>b-2 AND a<b+2)
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND d>e
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND d>e
 ORDER BY 2,1
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND c BETWEEN b-2 AND d+2
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query II rowsort x343
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 1096
-- 0
-- 793
-- 0
-- 827
-- 0

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
 ORDER BY 1,3,2
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR (e>c OR e<d)
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query III rowsort x344
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 2,1
;
-- 84 values hashing to 3a9f6e152480259b9690f902ec9b7fd9

-- query IIII rowsort x345
SELECT c-d,
       d-e,
       d,
       a+b*2+c*3
  FROM t1
;
-- 120 values hashing to a1ada57754462997e07971cda3305528

-- query IIII rowsort x345
SELECT c-d,
       d-e,
       d,
       a+b*2+c*3
  FROM t1
 ORDER BY 2,1,3,4
;
-- 120 values hashing to a1ada57754462997e07971cda3305528

-- query I rowsort x346
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
;
-- 1
-- 1
-- 1
-- 1
-- 1
-- 3

-- query I rowsort x346
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 1
-- 1
-- 1
-- 1
-- 1
-- 3

-- query IIII rowsort x347
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
;
-- 64 values hashing to a2a925c021960551d590b7672c6f3d05

-- query IIII rowsort x347
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,4,3
;
-- 64 values hashing to a2a925c021960551d590b7672c6f3d05

-- query IIII rowsort x347
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
    OR (e>a AND e<b)
;
-- 64 values hashing to a2a925c021960551d590b7672c6f3d05

-- query IIII rowsort x347
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 3,4,1
;
-- 64 values hashing to a2a925c021960551d590b7672c6f3d05

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
    OR c>d
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
    OR c>d
 ORDER BY 2,3
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR d>e
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR d>e
 ORDER BY 1,2
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE d>e
    OR c>d
    OR (a>b-2 AND a<b+2)
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x348
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE d>e
    OR c>d
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,4,1
;
-- 92 values hashing to c87852d64a0a0f7ad0c1cdde418d2c5b

-- query IIII rowsort x349
SELECT abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIII rowsort x349
SELECT abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,3,2,1
;

-- query IIII rowsort x349
SELECT abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x349
SELECT abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,2,3
;

-- query I rowsort x350
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 1067
-- 1272

-- query I rowsort x350
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 1067
-- 1272

-- query I rowsort x350
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
;
-- 1067
-- 1272

-- query I rowsort x350
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
 ORDER BY 1
;
-- 1067
-- 1272

-- query I rowsort x351
SELECT b-c
  FROM t1
 WHERE c>d
;
-- 13 values hashing to 7744fc7874118e6abe7e080d62e702a2

-- query I rowsort x351
SELECT b-c
  FROM t1
 WHERE c>d
 ORDER BY 1
;
-- 13 values hashing to 7744fc7874118e6abe7e080d62e702a2

-- query II rowsort x352
SELECT a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE b>c
;
-- 26 values hashing to 150f26c4261044e7d668047611de3015

-- query II rowsort x352
SELECT a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE b>c
 ORDER BY 1,2
;
-- 26 values hashing to 150f26c4261044e7d668047611de3015

-- query IIIIIII rowsort x353
SELECT a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3,
       d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
;
-- 210 values hashing to a762c4d51c7b81f25dc3488c5eb437d0

-- query IIIIIII rowsort x353
SELECT a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3,
       d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
 ORDER BY 5,4,7,6,1,2,3
;
-- 210 values hashing to a762c4d51c7b81f25dc3488c5eb437d0

-- query IIII rowsort x354
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR b>c
;
-- 80 values hashing to 31be87cb325fc0c5d4fadb3f90b0212f

-- query IIII rowsort x354
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR b>c
 ORDER BY 3,2
;
-- 80 values hashing to 31be87cb325fc0c5d4fadb3f90b0212f

-- query IIII rowsort x354
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR d>e
;
-- 80 values hashing to 31be87cb325fc0c5d4fadb3f90b0212f

-- query IIII rowsort x354
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
    OR d>e
 ORDER BY 1,4,2
;
-- 80 values hashing to 31be87cb325fc0c5d4fadb3f90b0212f

-- query II rowsort x355
SELECT a+b*2+c*3,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 26 values hashing to e67a059f451c8f90e1551f297d5424b1

-- query II rowsort x355
SELECT a+b*2+c*3,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 2,1
;
-- 26 values hashing to e67a059f451c8f90e1551f297d5424b1

-- query II rowsort x355
SELECT a+b*2+c*3,
       c-d
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 26 values hashing to e67a059f451c8f90e1551f297d5424b1

-- query II rowsort x355
SELECT a+b*2+c*3,
       c-d
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 26 values hashing to e67a059f451c8f90e1551f297d5424b1

-- query IIIIII rowsort x356
SELECT c,
       a+b*2+c*3+d*4,
       b,
       abs(b-c),
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
;
-- 180 values hashing to f54645bfc786b7ace563665760407aba

-- query IIIIII rowsort x356
SELECT c,
       a+b*2+c*3+d*4,
       b,
       abs(b-c),
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 ORDER BY 3,4,5
;
-- 180 values hashing to f54645bfc786b7ace563665760407aba

-- query II rowsort x357
SELECT a,
       c-d
  FROM t1
;
-- 60 values hashing to 2b2b05bb4ff5a2ae82df74f85bb4afa9

-- query II rowsort x357
SELECT a,
       c-d
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 2b2b05bb4ff5a2ae82df74f85bb4afa9

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 3,4,6
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR (e>a AND e<b)
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 1,6,5
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
    OR d>e
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query IIIIII rowsort x358
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
    OR d>e
 ORDER BY 6,2,3,5,4,1
;
-- 78 values hashing to 6ed7f32c0f6fca261a27bd3012c9991d

-- query III rowsort x359
SELECT b,
       a-b,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 78 values hashing to f69d50fd4da72efa577fd7b5b57a218c

-- query III rowsort x359
SELECT b,
       a-b,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 78 values hashing to f69d50fd4da72efa577fd7b5b57a218c

-- query III rowsort x359
SELECT b,
       a-b,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 78 values hashing to f69d50fd4da72efa577fd7b5b57a218c

-- query III rowsort x359
SELECT b,
       a-b,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 78 values hashing to f69d50fd4da72efa577fd7b5b57a218c

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
    OR a>b
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
    OR a>b
 ORDER BY 3,5,6,2,1,4
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
    OR a>b
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
    OR a>b
 ORDER BY 4,1,3
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query IIIIII rowsort x360
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 5,6,2,3
;
-- 156 values hashing to dc0420665219b1dbdb6c215345b1e791

-- query III rowsort x361
SELECT a+b*2+c*3,
       d-e,
       abs(a)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
;
-- 15 values hashing to eb595e9f255d651bde844105fc08fb57

-- query III rowsort x361
SELECT a+b*2+c*3,
       d-e,
       abs(a)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,3,1
;
-- 15 values hashing to eb595e9f255d651bde844105fc08fb57

-- query III rowsort x361
SELECT a+b*2+c*3,
       d-e,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
;
-- 15 values hashing to eb595e9f255d651bde844105fc08fb57

-- query III rowsort x361
SELECT a+b*2+c*3,
       d-e,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 3,1,2
;
-- 15 values hashing to eb595e9f255d651bde844105fc08fb57

-- query IIIIIII rowsort x362
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE d>e
;
-- 77 values hashing to 590bb43a66b49eaea7d40168ab95b87b

-- query IIIIIII rowsort x362
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE d>e
 ORDER BY 3,7,1,6,2,4,5
;
-- 77 values hashing to 590bb43a66b49eaea7d40168ab95b87b

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR b>c
    OR (e>c OR e<d)
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE a>b
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 2,4,7
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
 ORDER BY 4,5,3,7,6,1
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR a>b
    OR b>c
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIIIIII rowsort x363
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR a>b
    OR b>c
 ORDER BY 4,7,1,5,6,2,3
;
-- 189 values hashing to 3b74f944eef581369645e0018a91984a

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
 ORDER BY 3,2,1
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,4,3,2
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,2,4,3
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR (e>a AND e<b)
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x364
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR (e>a AND e<b)
 ORDER BY 2,3
;
-- 92 values hashing to f1d5c3beb375b47a05c92982d6c6752e

-- query IIII rowsort x365
SELECT abs(a),
       d-e,
       a,
       a+b*2+c*3
  FROM t1
;
-- 120 values hashing to 76e09a24f5a3dd61bfe1bde7114f6b63

-- query IIII rowsort x365
SELECT abs(a),
       d-e,
       a,
       a+b*2+c*3
  FROM t1
 ORDER BY 4,1
;
-- 120 values hashing to 76e09a24f5a3dd61bfe1bde7114f6b63

-- query I rowsort x366
SELECT a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- -2
-- 2

-- query I rowsort x366
SELECT a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- -2
-- 2

-- query IIII rowsort x367
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       b-c,
       a+b*2+c*3+d*4
  FROM t1
;
-- 120 values hashing to e2f79a7a193b84cd7f70cf4f40403a28

-- query IIII rowsort x367
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 4,1
;
-- 120 values hashing to e2f79a7a193b84cd7f70cf4f40403a28

-- query IIIII rowsort x368
SELECT a+b*2,
       b-c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to d28f6b944184a7946ea3cb47cd5f761f

-- query IIIII rowsort x368
SELECT a+b*2,
       b-c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,5,3,4,1
;
-- 30 values hashing to d28f6b944184a7946ea3cb47cd5f761f

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND b>c
;
-- 3
-- 191

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND b>c
 ORDER BY 1,2
;
-- 3
-- 191

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE c>d
   AND b>c
   AND (c<=d-2 OR c>=d+2)
;
-- 3
-- 191

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE c>d
   AND b>c
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 3
-- 191

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE b>c
   AND c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 3
-- 191

-- query II rowsort x369
SELECT c-d,
       abs(a)
  FROM t1
 WHERE b>c
   AND c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 3
-- 191

-- query IIIIII rowsort x370
SELECT a+b*2+c*3,
       a+b*2,
       c,
       abs(b-c),
       e,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 24 values hashing to 1612c366f1cbda32215c903e5addbbc5

-- query IIIIII rowsort x370
SELECT a+b*2+c*3,
       a+b*2,
       c,
       abs(b-c),
       e,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,5,1,3
;
-- 24 values hashing to 1612c366f1cbda32215c903e5addbbc5

-- query IIIII rowsort x371
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 140 values hashing to 4f4916853f2ccf272746741810ae125e

-- query IIIII rowsort x371
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 5,2,4,3,1
;
-- 140 values hashing to 4f4916853f2ccf272746741810ae125e

-- query IIIII rowsort x371
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
;
-- 140 values hashing to 4f4916853f2ccf272746741810ae125e

-- query IIIII rowsort x371
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
 ORDER BY 5,4,3
;
-- 140 values hashing to 4f4916853f2ccf272746741810ae125e

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND (a>b-2 AND a<b+2)
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 4,2,1,5
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIIII rowsort x372
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       e,
       c-d,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,6,3,5,2,1
;
-- 12 values hashing to fc68cd4e373c05bcb81c6c05f548e955

-- query IIIII rowsort x373
SELECT b-c,
       a+b*2+c*3,
       d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
;
-- 105 values hashing to 26923bd58b309b9593803e3d473e74a5

-- query IIIII rowsort x373
SELECT b-c,
       a+b*2+c*3,
       d,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 1,2,5
;
-- 105 values hashing to 26923bd58b309b9593803e3d473e74a5

-- query I rowsort x374
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 19 values hashing to 95973221897dd8239e748cb04834188e

-- query I rowsort x374
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 19 values hashing to 95973221897dd8239e748cb04834188e

-- query I rowsort x374
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 19 values hashing to 95973221897dd8239e748cb04834188e

-- query I rowsort x374
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 1
;
-- 19 values hashing to 95973221897dd8239e748cb04834188e

-- query III rowsort x375
SELECT abs(b-c),
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
    OR a>b
;
-- 75 values hashing to c4c0451bbe21c32530175a6b4771b20d

-- query III rowsort x375
SELECT abs(b-c),
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
    OR a>b
 ORDER BY 2,1
;
-- 75 values hashing to c4c0451bbe21c32530175a6b4771b20d

-- query III rowsort x375
SELECT abs(b-c),
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
    OR c>d
;
-- 75 values hashing to c4c0451bbe21c32530175a6b4771b20d

-- query III rowsort x375
SELECT abs(b-c),
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
    OR c>d
 ORDER BY 2,3,1
;
-- 75 values hashing to c4c0451bbe21c32530175a6b4771b20d

-- query II rowsort x376
SELECT b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
;
-- 22 values hashing to 1b1a4ed3e2cc298486d6232c92ea123d

-- query II rowsort x376
SELECT b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
 ORDER BY 1,2
;
-- 22 values hashing to 1b1a4ed3e2cc298486d6232c92ea123d

-- query II rowsort x376
SELECT b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 22 values hashing to 1b1a4ed3e2cc298486d6232c92ea123d

-- query II rowsort x376
SELECT b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 22 values hashing to 1b1a4ed3e2cc298486d6232c92ea123d

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
 ORDER BY 1,2,3
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
 ORDER BY 2,3,1
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query III rowsort x377
SELECT d-e,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,1
;
-- 72 values hashing to 0b3a185ef7f379374dde8c3e8619d4fb

-- query IIII rowsort x378
SELECT a+b*2+c*3+d*4+e*5,
       d,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
;
-- 36 values hashing to 5da6112e69defbda6b432d8087c0cef0

-- query IIII rowsort x378
SELECT a+b*2+c*3+d*4+e*5,
       d,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
 ORDER BY 2,4,3
;
-- 36 values hashing to 5da6112e69defbda6b432d8087c0cef0

-- query IIIIII rowsort x379
SELECT a+b*2,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 60 values hashing to f54c5084014bab5297db4be7e349c915

-- query IIIIII rowsort x379
SELECT a+b*2,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,2,5,1,6
;
-- 60 values hashing to f54c5084014bab5297db4be7e349c915

-- query IIIIIII rowsort x380
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
;
-- 210 values hashing to dd0bd35d9d46d1a4b77a23f4b4f553e7

-- query IIIIIII rowsort x380
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       b,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 ORDER BY 4,5,2,7,1,3,6
;
-- 210 values hashing to dd0bd35d9d46d1a4b77a23f4b4f553e7

-- query IIIIII rowsort x381
SELECT e,
       d-e,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to e07de53c370dbbe83225474f68b6d765

-- query IIIIII rowsort x381
SELECT e,
       d-e,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,4
;
-- 90 values hashing to e07de53c370dbbe83225474f68b6d765

-- query IIII rowsort x382
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
;
-- 56 values hashing to 2a2498d36b28f4415eda99f4d3aba546

-- query IIII rowsort x382
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1,3,4
;
-- 56 values hashing to 2a2498d36b28f4415eda99f4d3aba546

-- query IIII rowsort x382
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 56 values hashing to 2a2498d36b28f4415eda99f4d3aba546

-- query IIII rowsort x382
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,2,3,1
;
-- 56 values hashing to 2a2498d36b28f4415eda99f4d3aba546

-- query IIIII rowsort x383
SELECT a+b*2+c*3,
       abs(b-c),
       a+b*2,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to 4c5bc77c87d1b87f4b3630560ed8940c

-- query IIIII rowsort x383
SELECT a+b*2+c*3,
       abs(b-c),
       a+b*2,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,3,2,4
;
-- 130 values hashing to 4c5bc77c87d1b87f4b3630560ed8940c

-- query IIII rowsort x384
SELECT e,
       a-b,
       c,
       d-e
  FROM t1
;
-- 120 values hashing to 62d2c32a18d7b3ef44acb44f3c4dfa02

-- query IIII rowsort x384
SELECT e,
       a-b,
       c,
       d-e
  FROM t1
 ORDER BY 1,3
;
-- 120 values hashing to 62d2c32a18d7b3ef44acb44f3c4dfa02

-- query I rowsort x385
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
;
-- 19 values hashing to d54b17a6eb2efa3b7ec99d7719153c1e

-- query I rowsort x385
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 19 values hashing to d54b17a6eb2efa3b7ec99d7719153c1e

-- query I rowsort x385
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
;
-- 19 values hashing to d54b17a6eb2efa3b7ec99d7719153c1e

-- query I rowsort x385
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 19 values hashing to d54b17a6eb2efa3b7ec99d7719153c1e

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 3,2
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1,2,4
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIII rowsort x386
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,2
;
-- 92 values hashing to 7eeafa7a3807fccc9b73e72a4b93bc31

-- query IIIIIII rowsort x387
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5,
       c-d,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
;
-- 147 values hashing to 6e9a1be65ce2b6500b8b730732a2d405

-- query IIIIIII rowsort x387
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5,
       c-d,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 4,5,6
;
-- 147 values hashing to 6e9a1be65ce2b6500b8b730732a2d405

-- query I rowsort x388
SELECT c
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
;
-- 16 values hashing to 22c25adf7bd218113a71af4a3991a638

-- query I rowsort x388
SELECT c
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 16 values hashing to 22c25adf7bd218113a71af4a3991a638

-- query I rowsort x388
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
;
-- 16 values hashing to 22c25adf7bd218113a71af4a3991a638

-- query I rowsort x388
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
 ORDER BY 1
;
-- 16 values hashing to 22c25adf7bd218113a71af4a3991a638

-- query I rowsort x389
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 132
-- 135
-- 144
-- 157
-- 165
-- 180
-- 197
-- 227

-- query I rowsort x389
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 132
-- 135
-- 144
-- 157
-- 165
-- 180
-- 197
-- 227

-- query II rowsort x390
SELECT a+b*2+c*3,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
;
-- 22 values hashing to 7771e6d165f91614cbc1d5b976de4da8

-- query II rowsort x390
SELECT a+b*2+c*3,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 22 values hashing to 7771e6d165f91614cbc1d5b976de4da8

-- query II rowsort x390
SELECT a+b*2+c*3,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
;
-- 22 values hashing to 7771e6d165f91614cbc1d5b976de4da8

-- query II rowsort x390
SELECT a+b*2+c*3,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
 ORDER BY 2,1
;
-- 22 values hashing to 7771e6d165f91614cbc1d5b976de4da8

-- query IIII rowsort x391
SELECT a,
       e,
       a+b*2+c*3,
       a+b*2
  FROM t1
;
-- 120 values hashing to 6cfbc80b995d3658554afdd21a51582f

-- query IIII rowsort x391
SELECT a,
       e,
       a+b*2+c*3,
       a+b*2
  FROM t1
 ORDER BY 3,1
;
-- 120 values hashing to 6cfbc80b995d3658554afdd21a51582f

-- query III rowsort x392
SELECT d,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c>d
;
-- 66 values hashing to 0e5e006f2b6d0a931c6bba059b6d2c67

-- query III rowsort x392
SELECT d,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c>d
 ORDER BY 1,2,3
;
-- 66 values hashing to 0e5e006f2b6d0a931c6bba059b6d2c67

-- query III rowsort x392
SELECT d,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 66 values hashing to 0e5e006f2b6d0a931c6bba059b6d2c67

-- query III rowsort x392
SELECT d,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,3,1
;
-- 66 values hashing to 0e5e006f2b6d0a931c6bba059b6d2c67

-- query I rowsort x393
SELECT (a+b+c+d+e)/5
  FROM t1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query I rowsort x393
SELECT (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
;
-- 222
-- -1
-- 222
-- 1

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 222
-- -1
-- 222
-- 1

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;
-- 222
-- -1
-- 222
-- 1

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 222
-- -1
-- 222
-- 1

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 222
-- -1
-- 222
-- 1

-- query II rowsort x394
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 2,1
;
-- 222
-- -1
-- 222
-- 1

-- query III rowsort x395
SELECT a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
;
-- 30 values hashing to 8daf8f23f6242f7a667bd5780632de9a

-- query III rowsort x395
SELECT a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 30 values hashing to 8daf8f23f6242f7a667bd5780632de9a

-- query III rowsort x395
SELECT a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 30 values hashing to 8daf8f23f6242f7a667bd5780632de9a

-- query III rowsort x395
SELECT a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3
;
-- 30 values hashing to 8daf8f23f6242f7a667bd5780632de9a

-- query III rowsort x396
SELECT c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 24 values hashing to 9216376f4a9807e2185398d8d74076b0

-- query III rowsort x396
SELECT c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2
;
-- 24 values hashing to 9216376f4a9807e2185398d8d74076b0

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR (a>b-2 AND a<b+2)
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,5,1,7,4
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR (a>b-2 AND a<b+2)
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR (a>b-2 AND a<b+2)
 ORDER BY 7,1,5,3,6
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,1,4,5,2,7
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR a>b
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x397
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c,
       b-c,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR a>b
 ORDER BY 7,1
;
-- 168 values hashing to f3642d300b7a87ccfe2cd4bf73a7004d

-- query IIIIIII rowsort x398
SELECT c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
;
-- 42 values hashing to f283e84994d04c83261c13fad2061bd1

-- query IIIIIII rowsort x398
SELECT c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,5,7,3,4,6
;
-- 42 values hashing to f283e84994d04c83261c13fad2061bd1

-- query IIIIIII rowsort x398
SELECT c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
;
-- 42 values hashing to f283e84994d04c83261c13fad2061bd1

-- query IIIIIII rowsort x398
SELECT c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
 ORDER BY 2,3,7,4,1
;
-- 42 values hashing to f283e84994d04c83261c13fad2061bd1

-- query II rowsort x399
SELECT abs(a),
       b
  FROM t1
 WHERE b>c
;
-- 26 values hashing to 82a4fb50dd6aa553926a6d4ec2774a55

-- query II rowsort x399
SELECT abs(a),
       b
  FROM t1
 WHERE b>c
 ORDER BY 2,1
;
-- 26 values hashing to 82a4fb50dd6aa553926a6d4ec2774a55

-- query II rowsort x400
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 444
-- 192
-- 444
-- 222
-- 444
-- 247

-- query II rowsort x400
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 444
-- 192
-- 444
-- 222
-- 444
-- 247

-- query II rowsort x400
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 444
-- 192
-- 444
-- 222
-- 444
-- 247

-- query II rowsort x400
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 444
-- 192
-- 444
-- 222
-- 444
-- 247

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR b>c
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query II rowsort x401
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR b>c
 ORDER BY 2,1
;
-- 48 values hashing to 64376dd8151d8a271afd6fbfd3904ec9

-- query I rowsort x402
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query I rowsort x402
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;

-- query I rowsort x402
SELECT c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query I rowsort x402
SELECT c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 1
;

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 6,3,1
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,6,4,3,1,5
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x403
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 2,4,5,3,6
;
-- 126 values hashing to a02687520314ff075ab8bb20ad78dc8b

-- query IIIIII rowsort x404
SELECT a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a+b*2,
       a
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
;

-- query IIIIII rowsort x404
SELECT a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a+b*2,
       a
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
 ORDER BY 3,4,6,5
;

-- query III rowsort x405
SELECT a+b*2,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
;
-- 90 values hashing to 05ef2af4add7c81aa2cacd3340f3a48f

-- query III rowsort x405
SELECT a+b*2,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 ORDER BY 1,2
;
-- 90 values hashing to 05ef2af4add7c81aa2cacd3340f3a48f

-- query IIIII rowsort x406
SELECT a+b*2+c*3+d*4,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 145 values hashing to 4ccd19d5b9634a7757b9b2a1b9c70b0b

-- query IIIII rowsort x406
SELECT a+b*2+c*3+d*4,
       d-e,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,3,5
;
-- 145 values hashing to 4ccd19d5b9634a7757b9b2a1b9c70b0b

-- query IIIIIII rowsort x407
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       a,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
;

-- query IIIIIII rowsort x407
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       a,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 5,7,6,2,4,3
;

-- query IIII rowsort x408
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1050
-- 105
-- 2
-- 333
-- 1290
-- 129
-- -2
-- 222

-- query IIII rowsort x408
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4,3,1
;
-- 1050
-- 105
-- 2
-- 333
-- 1290
-- 129
-- -2
-- 222

-- query IIIIII rowsort x409
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 180 values hashing to 778c4d36b14ad59603d500ebe53124a8

-- query IIIIII rowsort x409
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 2,3,4,6,1
;
-- 180 values hashing to 778c4d36b14ad59603d500ebe53124a8

-- query IIIIIII rowsort x410
SELECT c,
       d-e,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       a,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x410
SELECT c,
       d-e,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       a,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,6,7,3
;

-- query IIIII rowsort x411
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a
  FROM t1
;
-- 150 values hashing to fb86dbed4e4876a4d8730df61548deb9

-- query IIIII rowsort x411
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a
  FROM t1
 ORDER BY 2,1,3,5
;
-- 150 values hashing to fb86dbed4e4876a4d8730df61548deb9

-- query IIIII rowsort x412
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;
-- 15 values hashing to 9f69d9b1ca7496c55e8e9d5a34c2b422

-- query IIIII rowsort x412
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 2,1
;
-- 15 values hashing to 9f69d9b1ca7496c55e8e9d5a34c2b422

-- query IIIII rowsort x412
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 15 values hashing to 9f69d9b1ca7496c55e8e9d5a34c2b422

-- query IIIII rowsort x412
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,5
;
-- 15 values hashing to 9f69d9b1ca7496c55e8e9d5a34c2b422

-- query IIII rowsort x413
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 108 values hashing to 052bee12f2a7a847ddd0a7089ac8cfbb

-- query IIII rowsort x413
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4,1
;
-- 108 values hashing to 052bee12f2a7a847ddd0a7089ac8cfbb

-- query IIII rowsort x413
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 108 values hashing to 052bee12f2a7a847ddd0a7089ac8cfbb

-- query IIII rowsort x413
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,4
;
-- 108 values hashing to 052bee12f2a7a847ddd0a7089ac8cfbb

-- query IIIII rowsort x414
SELECT abs(b-c),
       b-c,
       c-d,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 150 values hashing to 597fcab4085e4e5afa17f258fc54a550

-- query IIIII rowsort x414
SELECT abs(b-c),
       b-c,
       c-d,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,4,2,5
;
-- 150 values hashing to 597fcab4085e4e5afa17f258fc54a550

-- query III rowsort x415
SELECT b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
;
-- 66 values hashing to 03e7e92bd1e9e2b95658c34509df6798

-- query III rowsort x415
SELECT b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
 ORDER BY 3,1,2
;
-- 66 values hashing to 03e7e92bd1e9e2b95658c34509df6798

-- query III rowsort x415
SELECT b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 66 values hashing to 03e7e92bd1e9e2b95658c34509df6798

-- query III rowsort x415
SELECT b-c,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,3
;
-- 66 values hashing to 03e7e92bd1e9e2b95658c34509df6798

-- query IIIIIII rowsort x416
SELECT d,
       c,
       a+b*2,
       abs(b-c),
       abs(a),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 56 values hashing to 5805d136e910773107c290a90b9c97ef

-- query IIIIIII rowsort x416
SELECT d,
       c,
       a+b*2,
       abs(b-c),
       abs(a),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 4,2
;
-- 56 values hashing to 5805d136e910773107c290a90b9c97ef

-- query III rowsort x417
SELECT d-e,
       a,
       b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;
-- 9 values hashing to 128d329bc7a3ace9bfe759017667f1fa

-- query III rowsort x417
SELECT d-e,
       a,
       b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 3,1,2
;
-- 9 values hashing to 128d329bc7a3ace9bfe759017667f1fa

-- query III rowsort x417
SELECT d-e,
       a,
       b
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 9 values hashing to 128d329bc7a3ace9bfe759017667f1fa

-- query III rowsort x417
SELECT d-e,
       a,
       b
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,3,1
;
-- 9 values hashing to 128d329bc7a3ace9bfe759017667f1fa

-- query IIIII rowsort x418
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       d-e,
       d
  FROM t1
 WHERE b>c
;
-- 65 values hashing to ff90a655b6029f653cd5895fca7421dd

-- query IIIII rowsort x418
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       d-e,
       d
  FROM t1
 WHERE b>c
 ORDER BY 4,2,5
;
-- 65 values hashing to ff90a655b6029f653cd5895fca7421dd

-- query IIIIIII rowsort x419
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
;
-- 21 values hashing to 96375f3f872f57b2e90be141d7b751ac

-- query IIIIIII rowsort x419
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 5,7,4,3,1,6,2
;
-- 21 values hashing to 96375f3f872f57b2e90be141d7b751ac

-- query I rowsort x420
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
;
-- 19 values hashing to b9dfd9f7189c9f709aacb42c2b916f5a

-- query I rowsort x420
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
 ORDER BY 1
;
-- 19 values hashing to b9dfd9f7189c9f709aacb42c2b916f5a

-- query I rowsort x420
SELECT e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
;
-- 19 values hashing to b9dfd9f7189c9f709aacb42c2b916f5a

-- query I rowsort x420
SELECT e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 19 values hashing to b9dfd9f7189c9f709aacb42c2b916f5a

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE a>b
    OR d>e
    OR c BETWEEN b-2 AND d+2
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE a>b
    OR d>e
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR a>b
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR a>b
 ORDER BY 1
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE a>b
    OR c BETWEEN b-2 AND d+2
    OR d>e
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x421
SELECT c-d
  FROM t1
 WHERE a>b
    OR c BETWEEN b-2 AND d+2
    OR d>e
 ORDER BY 1
;
-- 25 values hashing to 7f750fc69a9dd4473b56b4b994a5bea5

-- query I rowsort x422
SELECT a+b*2+c*3+d*4
  FROM t1
;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query I rowsort x422
SELECT a+b*2+c*3+d*4
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query IIIII rowsort x423
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 75 values hashing to 6f480d3aa47a95f41a13232ad2630f97

-- query IIIII rowsort x423
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 2,1,4,5
;
-- 75 values hashing to 6f480d3aa47a95f41a13232ad2630f97

-- query IIIIII rowsort x424
SELECT abs(a),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
;
-- 66 values hashing to 5d035933803dd1c0ade45030c603f484

-- query IIIIII rowsort x424
SELECT abs(a),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
 ORDER BY 2,4,5,1,3
;
-- 66 values hashing to 5d035933803dd1c0ade45030c603f484

-- query IIIIIII rowsort x425
SELECT abs(b-c),
       b-c,
       a+b*2+c*3,
       a-b,
       e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 147 values hashing to c881e24abce01247b00f910db61ea7db

-- query IIIIIII rowsort x425
SELECT abs(b-c),
       b-c,
       a+b*2+c*3,
       a-b,
       e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 7,6,4,3,1,5
;
-- 147 values hashing to c881e24abce01247b00f910db61ea7db

-- query IIIIIII rowsort x425
SELECT abs(b-c),
       b-c,
       a+b*2+c*3,
       a-b,
       e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 147 values hashing to c881e24abce01247b00f910db61ea7db

-- query IIIIIII rowsort x425
SELECT abs(b-c),
       b-c,
       a+b*2+c*3,
       a-b,
       e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 7,5,6,1,4,3,2
;
-- 147 values hashing to c881e24abce01247b00f910db61ea7db

-- query IIII rowsort x426
SELECT (a+b+c+d+e)/5,
       d,
       e,
       a+b*2
  FROM t1
;
-- 120 values hashing to aae26346ea8b77e21281f2abe63c0266

-- query IIII rowsort x426
SELECT (a+b+c+d+e)/5,
       d,
       e,
       a+b*2
  FROM t1
 ORDER BY 1,2
;
-- 120 values hashing to aae26346ea8b77e21281f2abe63c0266

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND (e>c OR e<d)
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND (e>c OR e<d)
 ORDER BY 1,2
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND b>c
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND b>c
 ORDER BY 1,2
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query II rowsort x427
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 1,2
;
-- 18 values hashing to e18fbd84f978f4686ff46e6767805336

-- query IIIIII rowsort x428
SELECT abs(a),
       b-c,
       a,
       d-e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 102 values hashing to 3be3307b0e0eb44f8b0f04f87f4143a1

-- query IIIIII rowsort x428
SELECT abs(a),
       b-c,
       a,
       d-e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 5,4,3,6,2,1
;
-- 102 values hashing to 3be3307b0e0eb44f8b0f04f87f4143a1

-- query II rowsort x429
SELECT e,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
;
-- 30 values hashing to cb35c15d7e6b47bea3efc0c18a1204e9

-- query II rowsort x429
SELECT e,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 1,2
;
-- 30 values hashing to cb35c15d7e6b47bea3efc0c18a1204e9

-- query II rowsort x429
SELECT e,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
;
-- 30 values hashing to cb35c15d7e6b47bea3efc0c18a1204e9

-- query II rowsort x429
SELECT e,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 30 values hashing to cb35c15d7e6b47bea3efc0c18a1204e9

-- query IIII rowsort x430
SELECT b-c,
       c,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
;
-- 120 values hashing to 07862090d27a9db9ab7090ebaaa7406a

-- query IIII rowsort x430
SELECT b-c,
       c,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1,2,4
;
-- 120 values hashing to 07862090d27a9db9ab7090ebaaa7406a

-- query II rowsort x431
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE b>c
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 28 values hashing to dacd5810c0d7ccff31f735ce660f8e90

-- query II rowsort x431
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE b>c
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- 28 values hashing to dacd5810c0d7ccff31f735ce660f8e90

-- query II rowsort x431
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
;
-- 28 values hashing to dacd5810c0d7ccff31f735ce660f8e90

-- query II rowsort x431
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
 ORDER BY 1,2
;
-- 28 values hashing to dacd5810c0d7ccff31f735ce660f8e90

-- query IIIIIII rowsort x432
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
;
-- 21 values hashing to 36ec28df630c9710c5661a1aa87cb486

-- query IIIIIII rowsort x432
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,6,1,7,4,5
;
-- 21 values hashing to 36ec28df630c9710c5661a1aa87cb486

-- query II rowsort x433
SELECT d,
       c
  FROM t1
 WHERE a>b
;
-- 34 values hashing to a1b967905b56cc832158ad15962a643c

-- query II rowsort x433
SELECT d,
       c
  FROM t1
 WHERE a>b
 ORDER BY 2,1
;
-- 34 values hashing to a1b967905b56cc832158ad15962a643c

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR a>b
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR a>b
 ORDER BY 3,2
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR c>d
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR c>d
 ORDER BY 2,1
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR c>d
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query III rowsort x434
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR c>d
 ORDER BY 2,1,3
;
-- 75 values hashing to 241dcbe326d0c1903875caff29d3f486

-- query II rowsort x435
SELECT e,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
;
-- 46 values hashing to cabfa8d4539ca6b4f80fa6163c666cce

-- query II rowsort x435
SELECT e,
       abs(b-c)
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- 46 values hashing to cabfa8d4539ca6b4f80fa6163c666cce

-- query II rowsort x436
SELECT b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
;
-- -1
-- 1067

-- query II rowsort x436
SELECT b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- -1
-- 1067

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c BETWEEN b-2 AND d+2
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2,4,1
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND d>e
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND d>e
 ORDER BY 4,2,3
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
   AND d>e
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIII rowsort x437
SELECT c,
       a-b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 3,2,1,4
;
-- 224
-- -3
-- -1
-- 0
-- 247
-- -4
-- 2
-- 0

-- query IIIIII rowsort x438
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (c<=d-2 OR c>=d+2)
;
-- 168 values hashing to e31984607cdf6ff4640d14d3d9473720

-- query IIIIII rowsort x438
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,5,6,1,3,4
;
-- 168 values hashing to e31984607cdf6ff4640d14d3d9473720

-- query IIII rowsort x439
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR d>e
;
-- 84 values hashing to 7b429b731ffc2d6828c13b5243bbfe2d

-- query IIII rowsort x439
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR d>e
 ORDER BY 1,4,2,3
;
-- 84 values hashing to 7b429b731ffc2d6828c13b5243bbfe2d

-- query IIII rowsort x439
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR c>d
    OR (c<=d-2 OR c>=d+2)
;
-- 84 values hashing to 7b429b731ffc2d6828c13b5243bbfe2d

-- query IIII rowsort x439
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR c>d
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,3
;
-- 84 values hashing to 7b429b731ffc2d6828c13b5243bbfe2d

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND a>b
   AND c>d
;

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND a>b
   AND c>d
 ORDER BY 1,4,2
;

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND c>d
   AND a>b
;

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND c>d
   AND a>b
 ORDER BY 2,1,5
;

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE c>d
   AND a>b
   AND b>c
;

-- query IIIII rowsort x440
SELECT d,
       c-d,
       c,
       abs(a),
       a-b
  FROM t1
 WHERE c>d
   AND a>b
   AND b>c
 ORDER BY 4,5,1,2,3
;

-- query II rowsort x441
SELECT a-b,
       c
  FROM t1
;
-- 60 values hashing to 6e429924a0921c1dece0ca0dbe37acdf

-- query II rowsort x441
SELECT a-b,
       c
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 6e429924a0921c1dece0ca0dbe37acdf

-- query I rowsort x442
SELECT e
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 197
-- 227
-- 230

-- query I rowsort x442
SELECT e
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 1
;
-- 197
-- 227
-- 230

-- query I rowsort x442
SELECT e
  FROM t1
 WHERE b>c
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;
-- 197
-- 227
-- 230

-- query I rowsort x442
SELECT e
  FROM t1
 WHERE b>c
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 197
-- 227
-- 230

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 1,3
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND c BETWEEN b-2 AND d+2
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2,1
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
   AND a>b
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query III rowsort x443
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 1,2,3
;
-- 21 values hashing to 46fba0cfd195e857073f018503f70144

-- query IIIII rowsort x444
SELECT abs(a),
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
;
-- 30 values hashing to ff7a47e2effec928f49caa98e41fbf53

-- query IIIII rowsort x444
SELECT abs(a),
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 5,3,2,4,1
;
-- 30 values hashing to ff7a47e2effec928f49caa98e41fbf53

-- query IIIII rowsort x444
SELECT abs(a),
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
;
-- 30 values hashing to ff7a47e2effec928f49caa98e41fbf53

-- query IIIII rowsort x444
SELECT abs(a),
       a+b*2,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,3,4,5,2
;
-- 30 values hashing to ff7a47e2effec928f49caa98e41fbf53

-- query IIIIII rowsort x445
SELECT a+b*2,
       a-b,
       b,
       c-d,
       e,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 156 values hashing to c20ce57d3bbde4501483ab2ea2d853c5

-- query IIIIII rowsort x445
SELECT a+b*2,
       a-b,
       b,
       c-d,
       e,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2,6,4,5,3
;
-- 156 values hashing to c20ce57d3bbde4501483ab2ea2d853c5

-- query IIIIII rowsort x445
SELECT a+b*2,
       a-b,
       b,
       c-d,
       e,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
;
-- 156 values hashing to c20ce57d3bbde4501483ab2ea2d853c5

-- query IIIIII rowsort x445
SELECT a+b*2,
       a-b,
       b,
       c-d,
       e,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
 ORDER BY 3,1,5,6,4
;
-- 156 values hashing to c20ce57d3bbde4501483ab2ea2d853c5

-- query III rowsort x446
SELECT c,
       a+b*2+c*3,
       d
  FROM t1
 WHERE b>c
;
-- 39 values hashing to 96d628587b05021711e636831fb1226e

-- query III rowsort x446
SELECT c,
       a+b*2+c*3,
       d
  FROM t1
 WHERE b>c
 ORDER BY 1,2
;
-- 39 values hashing to 96d628587b05021711e636831fb1226e

-- query III rowsort x447
SELECT a+b*2+c*3+d*4,
       e,
       c-d
  FROM t1
;
-- 90 values hashing to ff40c38c1c2a4e69dc1ecb22894659f8

-- query III rowsort x447
SELECT a+b*2+c*3+d*4,
       e,
       c-d
  FROM t1
 ORDER BY 3,2
;
-- 90 values hashing to ff40c38c1c2a4e69dc1ecb22894659f8

-- query II rowsort x448
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
;
-- 60 values hashing to d6f5a04eabc50e3b8da80548b48f264c

-- query II rowsort x448
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to d6f5a04eabc50e3b8da80548b48f264c

-- query I rowsort x449
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL
-- NULL

-- query I rowsort x449
SELECT d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL
-- NULL

-- query I rowsort x449
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL
-- NULL

-- query I rowsort x449
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- -1
-- -1
-- -4
-- 1
-- 1
-- 3
-- NULL
-- NULL

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE c>d
   AND a>b
   AND d>e
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE c>d
   AND a>b
   AND d>e
 ORDER BY 4,6,1
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE a>b
   AND d>e
   AND c>d
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE a>b
   AND d>e
   AND c>d
 ORDER BY 5,1,4,6,3,2
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE c>d
   AND d>e
   AND a>b
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIIIII rowsort x450
SELECT a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE c>d
   AND d>e
   AND a>b
 ORDER BY 1,4,5
;
-- 18 values hashing to 17c53007ab36ea380c2c286e078e5d87

-- query IIII rowsort x451
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
;
-- 120 values hashing to 746b09ad2a19b1fac2c714bca47edd80

-- query IIII rowsort x451
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 ORDER BY 2,1
;
-- 120 values hashing to 746b09ad2a19b1fac2c714bca47edd80

-- query II rowsort x452
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 92db286438e1a83f0e6c91f86f4c49fd

-- query II rowsort x452
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 20 values hashing to 92db286438e1a83f0e6c91f86f4c49fd

-- query II rowsort x452
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 20 values hashing to 92db286438e1a83f0e6c91f86f4c49fd

-- query II rowsort x452
SELECT a-b,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 20 values hashing to 92db286438e1a83f0e6c91f86f4c49fd

-- query II rowsort x453
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 WHERE d>e
;
-- 22 values hashing to 5a69bb44147ee819d934f1d387083d8a

-- query II rowsort x453
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 WHERE d>e
 ORDER BY 1,2
;
-- 22 values hashing to 5a69bb44147ee819d934f1d387083d8a

-- query I rowsort x454
SELECT d
  FROM t1
;
-- 30 values hashing to 169a721efb38857a8de46fcd1500025a

-- query I rowsort x454
SELECT d
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 169a721efb38857a8de46fcd1500025a

-- query II rowsort x455
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to f9fe40544c61e79e6ae419400d5989f2

-- query II rowsort x455
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 52 values hashing to f9fe40544c61e79e6ae419400d5989f2

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 3,5,4,7,6
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 5,6,3,1,4,7,2
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 6,4
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;

-- query IIIIIII rowsort x456
SELECT a,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,4,3,7,5
;

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c>d
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c>d
 ORDER BY 1
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE d>e
    OR c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE d>e
    OR c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE c>d
    OR d>e
    OR d NOT BETWEEN 110 AND 150
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query I rowsort x457
SELECT abs(a)
  FROM t1
 WHERE c>d
    OR d>e
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 24 values hashing to 23f1fc77fb5b86515652f9873b16e3d5

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
 ORDER BY 1,2
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query II rowsort x458
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 50 values hashing to dcd5b5784df088d48900687d4319f5c1

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
 ORDER BY 5,4,3
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND b>c
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND b>c
 ORDER BY 1,2
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2,5
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query IIIII rowsort x459
SELECT d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,3,1
;
-- 2
-- 743
-- 111
-- 246
-- 26

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,3
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
   AND (e>c OR e<d)
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
   AND (e>c OR e<d)
 ORDER BY 3,2,1
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND a>b
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND a>b
 ORDER BY 2,1
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND a>b
   AND (c<=d-2 OR c>=d+2)
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query III rowsort x460
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND a>b
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 15 values hashing to 20cea9b1e26190fa19ea3589c0dee2ba

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
;

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
 ORDER BY 1,6,5
;

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,6
;

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x461
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d-e,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,7,2,5
;

-- query IIIIII rowsort x462
SELECT a+b*2,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
;
-- 168 values hashing to b8f4c948f04ae95904a54c7ecf8f1441

-- query IIIIII rowsort x462
SELECT a+b*2,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>c OR e<d)
 ORDER BY 2,6
;
-- 168 values hashing to b8f4c948f04ae95904a54c7ecf8f1441

-- query IIII rowsort x463
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 20 values hashing to e5b274399969a4489a0918946194021c

-- query IIII rowsort x463
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 4,2,3,1
;
-- 20 values hashing to e5b274399969a4489a0918946194021c

-- query IIII rowsort x463
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to e5b274399969a4489a0918946194021c

-- query IIII rowsort x463
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,2,1
;
-- 20 values hashing to e5b274399969a4489a0918946194021c

-- query IIIIII rowsort x464
SELECT a,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
;
-- 48 values hashing to ca3c93506e17359073b5710039fd37ae

-- query IIIIII rowsort x464
SELECT a,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
 ORDER BY 2,6,1,4,5
;
-- 48 values hashing to ca3c93506e17359073b5710039fd37ae

-- query IIIIII rowsort x464
SELECT a,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
;
-- 48 values hashing to ca3c93506e17359073b5710039fd37ae

-- query IIIIII rowsort x464
SELECT a,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
 ORDER BY 6,1,2,5,3,4
;
-- 48 values hashing to ca3c93506e17359073b5710039fd37ae

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (a>b-2 AND a<b+2)
;

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
;

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
;

-- query III rowsort x465
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,1,2
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,2
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
   AND b>c
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
   AND b>c
 ORDER BY 3,5
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x466
SELECT abs(a),
       abs(b-c),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,3,1,2
;

-- query IIIII rowsort x467
SELECT a-b,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a)
  FROM t1
;
-- 150 values hashing to 1b1550ce6f1c4cf9076f497c85f31201

-- query IIIII rowsort x467
SELECT a-b,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a)
  FROM t1
 ORDER BY 3,2,4,1,5
;
-- 150 values hashing to 1b1550ce6f1c4cf9076f497c85f31201

-- query III rowsort x468
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to 0c53eb204e07cf74f548683dc0ab4656

-- query III rowsort x468
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1,2,3
;
-- 24 values hashing to 0c53eb204e07cf74f548683dc0ab4656

-- query II rowsort x469
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE a>b
;
-- 34 values hashing to 5d338a9ebf9ddb3c72dc89eb65b687c6

-- query II rowsort x469
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE a>b
 ORDER BY 2,1
;
-- 34 values hashing to 5d338a9ebf9ddb3c72dc89eb65b687c6

-- query IIIIIII rowsort x470
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       abs(b-c),
       b-c,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 119 values hashing to 8753a74c6c3016be41f58f809c138c99

-- query IIIIIII rowsort x470
SELECT a+b*2,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       abs(b-c),
       b-c,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 3,7,6,1
;
-- 119 values hashing to 8753a74c6c3016be41f58f809c138c99

-- query IIIIIII rowsort x471
SELECT b-c,
       (a+b+c+d+e)/5,
       abs(a),
       abs(b-c),
       d,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
;
-- 77 values hashing to f74a17597a51a27cb8d52e6d651824a8

-- query IIIIIII rowsort x471
SELECT b-c,
       (a+b+c+d+e)/5,
       abs(a),
       abs(b-c),
       d,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
 ORDER BY 1,4,5
;
-- 77 values hashing to f74a17597a51a27cb8d52e6d651824a8

-- query I rowsort x472
SELECT b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- -1
-- 4

-- query I rowsort x472
SELECT b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- -1
-- 4

-- query IIIIIII rowsort x473
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
;
-- 70 values hashing to bf6372bfaa44f73c0f583a0700e6020f

-- query IIIIIII rowsort x473
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 5,6,1,7,3,2
;
-- 70 values hashing to bf6372bfaa44f73c0f583a0700e6020f

-- query IIIIIII rowsort x473
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 70 values hashing to bf6372bfaa44f73c0f583a0700e6020f

-- query IIIIIII rowsort x473
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,4,7,3,1,6,5
;
-- 70 values hashing to bf6372bfaa44f73c0f583a0700e6020f

-- query IIIIII rowsort x474
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 12 values hashing to 6fa4ae3ff283b4f7d9825b4b2d067415

-- query IIIIII rowsort x474
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,1,4,3
;
-- 12 values hashing to 6fa4ae3ff283b4f7d9825b4b2d067415

-- query IIIII rowsort x475
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
;
-- 150 values hashing to 313bbc0b791d1bb0d9b26be4e9e696f8

-- query IIIII rowsort x475
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
 ORDER BY 2,3,1,5
;
-- 150 values hashing to 313bbc0b791d1bb0d9b26be4e9e696f8

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,6,4,1,5,3
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND a>b
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND a>b
 ORDER BY 1,2,5,3,6
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;

-- query IIIIII rowsort x476
SELECT a+b*2,
       a+b*2+c*3+d*4,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a
  FROM t1
 WHERE a>b
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4
;

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,1,5
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query IIIIII rowsort x477
SELECT a+b*2,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 6,1
;
-- 162 values hashing to cc30df9c14f53527405a1c239bb87c59

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE c>d
    OR d>e
    OR (e>a AND e<b)
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE c>d
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 3,1
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR d>e
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR d>e
 ORDER BY 2,1
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR c>d
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR c>d
 ORDER BY 1,2
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
    OR d>e
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query III rowsort x478
SELECT b-c,
       c-d,
       a+b*2
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
    OR d>e
 ORDER BY 2,1,3
;
-- 57 values hashing to 7ece664b68f1d5dd5df20c38b45bf700

-- query IIIIII rowsort x479
SELECT c,
       a+b*2+c*3,
       a,
       d,
       a+b*2,
       b
  FROM t1
 WHERE (e>c OR e<d)
;
-- 126 values hashing to e39bc4de3557e78f0c6cef58f371354c

-- query IIIIII rowsort x479
SELECT c,
       a+b*2+c*3,
       a,
       d,
       a+b*2,
       b
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 3,5,6,1,2
;
-- 126 values hashing to e39bc4de3557e78f0c6cef58f371354c

-- query IIIII rowsort x480
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       d,
       a
  FROM t1
;
-- 150 values hashing to 9ee680f1a55fdef2116dcd0ea18d205a

-- query IIIII rowsort x480
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       d,
       a
  FROM t1
 ORDER BY 5,1
;
-- 150 values hashing to 9ee680f1a55fdef2116dcd0ea18d205a

-- query IIIII rowsort x481
SELECT abs(a),
       b-c,
       a-b,
       a,
       d-e
  FROM t1
;
-- 150 values hashing to e7378b047d883082b38d789060e0ef95

-- query IIIII rowsort x481
SELECT abs(a),
       b-c,
       a-b,
       a,
       d-e
  FROM t1
 ORDER BY 4,5,3
;
-- 150 values hashing to e7378b047d883082b38d789060e0ef95

-- query IIIIIII rowsort x482
SELECT b,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
;
-- 210 values hashing to 28f5a6cd0114ba9eae51109f58e52f03

-- query IIIIIII rowsort x482
SELECT b,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 ORDER BY 6,4,2,7,5,1
;
-- 210 values hashing to 28f5a6cd0114ba9eae51109f58e52f03

-- query IIIIIII rowsort x483
SELECT abs(b-c),
       d-e,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
;
-- 77 values hashing to 16093e77f72d0aa3214799803026d32d

-- query IIIIIII rowsort x483
SELECT abs(b-c),
       d-e,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
 ORDER BY 6,4,5,1,7,2,3
;
-- 77 values hashing to 16093e77f72d0aa3214799803026d32d

-- query IIIIII rowsort x484
SELECT b-c,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
;
-- 126 values hashing to 2fc84e3374819064bf08ed664bb0332f

-- query IIIIII rowsort x484
SELECT b-c,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 6,1,5
;
-- 126 values hashing to 2fc84e3374819064bf08ed664bb0332f

-- query IIIIIII rowsort x485
SELECT d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
    OR (c<=d-2 OR c>=d+2)
;
-- 161 values hashing to 44ac998ab65c19bee4410d6d64048302

-- query IIIIIII rowsort x485
SELECT d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 5,6,4,3,1,7
;
-- 161 values hashing to 44ac998ab65c19bee4410d6d64048302

-- query IIIIIII rowsort x485
SELECT d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR a>b
;
-- 161 values hashing to 44ac998ab65c19bee4410d6d64048302

-- query IIIIIII rowsort x485
SELECT d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR a>b
 ORDER BY 5,6,1,2,7,3,4
;
-- 161 values hashing to 44ac998ab65c19bee4410d6d64048302

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND (e>a AND e<b)
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND (e>a AND e<b)
 ORDER BY 1,5
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
 ORDER BY 5,4
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c BETWEEN b-2 AND d+2
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,3
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND d>e
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query IIIIII rowsort x486
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
   AND d>e
 ORDER BY 5,2,3
;
-- 12 values hashing to f2c764c5c74ab5249e4c5d2a30b60401

-- query I rowsort x487
SELECT a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 0462df69a372162bd2326b32559acd24

-- query I rowsort x487
SELECT a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to 0462df69a372162bd2326b32559acd24

-- query IIIIIII rowsort x488
SELECT a-b,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 56 values hashing to cb68d9d22476a7b85975e7ab215073a1

-- query IIIIIII rowsort x488
SELECT a-b,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 4,3,6,1
;
-- 56 values hashing to cb68d9d22476a7b85975e7ab215073a1

-- query IIII rowsort x489
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       c,
       b
  FROM t1
;
-- 120 values hashing to 9352a0c5f12faae85f27dc178913cf2d

-- query IIII rowsort x489
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       c,
       b
  FROM t1
 ORDER BY 3,2
;
-- 120 values hashing to 9352a0c5f12faae85f27dc178913cf2d

-- query IIIII rowsort x490
SELECT d-e,
       abs(a),
       a,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
;
-- 140 values hashing to 16f5a6bc5dd998e2e3b84b3a5f72fefe

-- query IIIII rowsort x490
SELECT d-e,
       abs(a),
       a,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
 ORDER BY 5,2
;
-- 140 values hashing to 16f5a6bc5dd998e2e3b84b3a5f72fefe

-- query I rowsort x491
SELECT abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
;
-- 107
-- 163
-- 188
-- 191
-- 213
-- 216
-- 220
-- 234

-- query I rowsort x491
SELECT abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 107
-- 163
-- 188
-- 191
-- 213
-- 216
-- 220
-- 234

-- query I rowsort x491
SELECT abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 107
-- 163
-- 188
-- 191
-- 213
-- 216
-- 220
-- 234

-- query I rowsort x491
SELECT abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 107
-- 163
-- 188
-- 191
-- 213
-- 216
-- 220
-- 234

-- query IIIIIII rowsort x492
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
;
-- 147 values hashing to 5c2d165e1dbe999b1759525ee339ca9a

-- query IIIIIII rowsort x492
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 5,7,1
;
-- 147 values hashing to 5c2d165e1dbe999b1759525ee339ca9a

-- query IIIIII rowsort x493
SELECT abs(a),
       e,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE (e>a AND e<b)
;
-- 18 values hashing to f7c0d5db3e9a4969e0527ffedf9b4d70

-- query IIIIII rowsort x493
SELECT abs(a),
       e,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1,5,6,4
;
-- 18 values hashing to f7c0d5db3e9a4969e0527ffedf9b4d70

-- query IIIIII rowsort x494
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
;

-- query IIIIII rowsort x494
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
 ORDER BY 3,2
;

-- query IIIIII rowsort x494
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
;

-- query IIIIII rowsort x494
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
 ORDER BY 3,6
;

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR a>b
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR a>b
 ORDER BY 3,2,5,1
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 1,4
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR a>b
    OR (c<=d-2 OR c>=d+2)
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x495
SELECT abs(b-c),
       a+b*2,
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
    OR a>b
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,1
;
-- 130 values hashing to 0011ef36e28a0677318e32f0b4bb6169

-- query IIIII rowsort x496
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5
  FROM t1
;
-- 150 values hashing to 0ef2610e58bc4c197e69ef4e4790dcbf

-- query IIIII rowsort x496
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 3,1,4,2
;
-- 150 values hashing to 0ef2610e58bc4c197e69ef4e4790dcbf

-- query IIIIII rowsort x497
SELECT a,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
;
-- 180 values hashing to 55ee5a9612b99a875a399d1da5d8426b

-- query IIIIII rowsort x497
SELECT a,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 3,2,6,1,5
;
-- 180 values hashing to 55ee5a9612b99a875a399d1da5d8426b

-- query II rowsort x498
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 7d54f2060f72872c2e80edaef61163c1

-- query II rowsort x498
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 10 values hashing to 7d54f2060f72872c2e80edaef61163c1

-- query II rowsort x498
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
;
-- 10 values hashing to 7d54f2060f72872c2e80edaef61163c1

-- query II rowsort x498
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
 ORDER BY 2,1
;
-- 10 values hashing to 7d54f2060f72872c2e80edaef61163c1

-- query IIIIII rowsort x499
SELECT a+b*2,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       b-c,
       b
  FROM t1
;
-- 180 values hashing to 0a21fdcf930166b057f92d8f196eeda8

-- query IIIIII rowsort x499
SELECT a+b*2,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       b-c,
       b
  FROM t1
 ORDER BY 6,3,5,2,1
;
-- 180 values hashing to 0a21fdcf930166b057f92d8f196eeda8

-- query IIIIII rowsort x500
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (e>c OR e<d)
;
-- 30 values hashing to 00e154afdc515fe6805c2adeead80dc8

-- query IIIIII rowsort x500
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (e>c OR e<d)
 ORDER BY 6,3,2,1,5
;
-- 30 values hashing to 00e154afdc515fe6805c2adeead80dc8

-- query IIIIII rowsort x500
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND d>e
;
-- 30 values hashing to 00e154afdc515fe6805c2adeead80dc8

-- query IIIIII rowsort x500
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND d>e
 ORDER BY 4,1,2,6
;
-- 30 values hashing to 00e154afdc515fe6805c2adeead80dc8

-- query IIIII rowsort x501
SELECT b-c,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
;
-- 55 values hashing to 9ee42810091de9e456cdf451707dfb19

-- query IIIII rowsort x501
SELECT b-c,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
 ORDER BY 4,1
;
-- 55 values hashing to 9ee42810091de9e456cdf451707dfb19

-- query IIIIII rowsort x502
SELECT abs(a),
       a+b*2,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE b>c
;
-- 78 values hashing to 05c3a0c169dae692b136ec4da7900710

-- query IIIIII rowsort x502
SELECT abs(a),
       a+b*2,
       c-d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE b>c
 ORDER BY 3,2
;
-- 78 values hashing to 05c3a0c169dae692b136ec4da7900710

-- query III rowsort x503
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
;
-- 51 values hashing to c4e39a7aad61c903c874fbef1b9cbd6d

-- query III rowsort x503
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,1
;
-- 51 values hashing to c4e39a7aad61c903c874fbef1b9cbd6d

-- query III rowsort x503
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
;
-- 51 values hashing to c4e39a7aad61c903c874fbef1b9cbd6d

-- query III rowsort x503
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
 ORDER BY 1,2,3
;
-- 51 values hashing to c4e39a7aad61c903c874fbef1b9cbd6d

-- query I rowsort x504
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 6af3ceebf0777a1fdf502d4b4007fb96

-- query I rowsort x504
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to 6af3ceebf0777a1fdf502d4b4007fb96

-- query IIIIII rowsort x505
SELECT a+b*2+c*3,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
;

-- query IIIIII rowsort x505
SELECT a+b*2+c*3,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,1,6,3,5,2
;

-- query IIIIII rowsort x505
SELECT a+b*2+c*3,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
;

-- query IIIIII rowsort x505
SELECT a+b*2+c*3,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
 ORDER BY 4,3,1,2
;

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR b>c
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR b>c
 ORDER BY 1
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query I rowsort x506
SELECT a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 25 values hashing to 64a52fdf762f93fa572da96c506b2fe2

-- query II rowsort x507
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 60 values hashing to 062c0e56752ce88d0167d9e0fd0770d7

-- query II rowsort x507
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 062c0e56752ce88d0167d9e0fd0770d7

-- query IIIII rowsort x508
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 40 values hashing to fae5120fb39277696b35aa3553bfd248

-- query IIIII rowsort x508
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1,3,4,5
;
-- 40 values hashing to fae5120fb39277696b35aa3553bfd248

-- query IIIII rowsort x508
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
;
-- 40 values hashing to fae5120fb39277696b35aa3553bfd248

-- query IIIII rowsort x508
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
 ORDER BY 4,3,2,5,1
;
-- 40 values hashing to fae5120fb39277696b35aa3553bfd248

-- query IIIIIII rowsort x509
SELECT c,
       (a+b+c+d+e)/5,
       c-d,
       a-b,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
;
-- 210 values hashing to a8320bf92935acc06873c02a2ef70728

-- query IIIIIII rowsort x509
SELECT c,
       (a+b+c+d+e)/5,
       c-d,
       a-b,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
 ORDER BY 2,4,6,1
;
-- 210 values hashing to a8320bf92935acc06873c02a2ef70728

-- query IIII rowsort x510
SELECT a-b,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3
  FROM t1
;
-- 120 values hashing to eba5cda4cc13d96f727c559c41db8919

-- query IIII rowsort x510
SELECT a-b,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3
  FROM t1
 ORDER BY 4,1,3
;
-- 120 values hashing to eba5cda4cc13d96f727c559c41db8919

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,3
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 4,1
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,5
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIIII rowsort x511
SELECT (a+b+c+d+e)/5,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,1,3
;
-- 145 values hashing to eca95b112211ab95103202c15c975890

-- query IIII rowsort x512
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       c-d,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
   AND a>b
;
-- 12 values hashing to a55c98f195d20b15999740a67127a991

-- query IIII rowsort x512
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       c-d,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 3,2,1,4
;
-- 12 values hashing to a55c98f195d20b15999740a67127a991

-- query IIII rowsort x512
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       c-d,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;
-- 12 values hashing to a55c98f195d20b15999740a67127a991

-- query IIII rowsort x512
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       c-d,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,4,3
;
-- 12 values hashing to a55c98f195d20b15999740a67127a991

-- query IIIIIII rowsort x513
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       b,
       abs(a),
       d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 182 values hashing to db856adb50d6b2c59247ce864ee0b0f7

-- query IIIIIII rowsort x513
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       b,
       abs(a),
       d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,5,4,2
;
-- 182 values hashing to db856adb50d6b2c59247ce864ee0b0f7

-- query IIIII rowsort x514
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 65 values hashing to 3008ddf6b506ac06a02ab54f4a4dbab7

-- query IIIII rowsort x514
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4,
       abs(a),
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 3,2,1,5,4
;
-- 65 values hashing to 3008ddf6b506ac06a02ab54f4a4dbab7

-- query IIIII rowsort x514
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 65 values hashing to 3008ddf6b506ac06a02ab54f4a4dbab7

-- query IIIII rowsort x514
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4,
       abs(a),
       a-b
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,5
;
-- 65 values hashing to 3008ddf6b506ac06a02ab54f4a4dbab7

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR b>c
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR b>c
 ORDER BY 5,4,3,6,2,1,7
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (e>a AND e<b)
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (e>a AND e<b)
 ORDER BY 1,4,6,2,3,5
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (e>a AND e<b)
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (e>a AND e<b)
 ORDER BY 4,3,6,5,7,1
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR b>c
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIIIIII rowsort x515
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR b>c
 ORDER BY 5,3
;
-- 175 values hashing to e99a4f7e39ea9b3735fc5ef9e055f336

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,2,1
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,3
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
 ORDER BY 3,2
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR (e>c OR e<d)
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query IIII rowsort x516
SELECT a+b*2+c*3+d*4,
       b-c,
       c-d,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 4,1,3
;
-- 104 values hashing to 33946dd780d80a44b8a5a40324ac28c1

-- query III rowsort x517
SELECT abs(a),
       a,
       b-c
  FROM t1
;
-- 90 values hashing to 5265c15239d446b5dc315f3e79dd842d

-- query III rowsort x517
SELECT abs(a),
       a,
       b-c
  FROM t1
 ORDER BY 1,3
;
-- 90 values hashing to 5265c15239d446b5dc315f3e79dd842d

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 5,1,4,2
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 5,1,3
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIII rowsort x518
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c,
       d,
       e
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,2
;
-- 0
-- 698
-- 231
-- 233
-- 230

-- query IIIIII rowsort x519
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       e,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
;
-- 180 values hashing to ea162126b301a546664c33ff053c4566

-- query IIIIII rowsort x519
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       e,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
 ORDER BY 4,2,1,6
;
-- 180 values hashing to ea162126b301a546664c33ff053c4566

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE d>e
    OR a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE d>e
    OR a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,3
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR d>e
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR d>e
 ORDER BY 5,4
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE a>b
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIIIIII rowsort x520
SELECT b-c,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE a>b
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,1,3,5,7,4
;
-- 154 values hashing to ed3dbfdce513c2b78ba7fd5300dd487d

-- query IIII rowsort x521
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 72 values hashing to 4d667e79e731c3952e5378b96fd2a448

-- query IIII rowsort x521
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4,1,3
;
-- 72 values hashing to 4d667e79e731c3952e5378b96fd2a448

-- query IIII rowsort x521
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 72 values hashing to 4d667e79e731c3952e5378b96fd2a448

-- query IIII rowsort x521
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,2,1,4
;
-- 72 values hashing to 4d667e79e731c3952e5378b96fd2a448

-- query II rowsort x522
SELECT e,
       b
  FROM t1
;
-- 60 values hashing to aea68eb2207c713683774d94afe4f14d

-- query II rowsort x522
SELECT e,
       b
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to aea68eb2207c713683774d94afe4f14d

-- query IIIIII rowsort x523
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
;
-- 180 values hashing to bddfab6a73f43e1b4ffe964de7db62eb

-- query IIIIII rowsort x523
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 ORDER BY 5,1,2,3
;
-- 180 values hashing to bddfab6a73f43e1b4ffe964de7db62eb

-- query IIIIII rowsort x524
SELECT c-d,
       c,
       d,
       a-b,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
;
-- 180 values hashing to 0bdc6744bb66a70d9d1edc0844bb5d82

-- query IIIIII rowsort x524
SELECT c-d,
       c,
       d,
       a-b,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 ORDER BY 5,2,4,1
;
-- 180 values hashing to 0bdc6744bb66a70d9d1edc0844bb5d82

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 1,2
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query II rowsort x525
SELECT a,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 42 values hashing to 84d2510a39db3f4308120d8b0ab47b9d

-- query III rowsort x526
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 57 values hashing to b393e5b09a6c3fcbe99c4db72e5040c0

-- query III rowsort x526
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1,3
;
-- 57 values hashing to b393e5b09a6c3fcbe99c4db72e5040c0

-- query III rowsort x527
SELECT a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query III rowsort x527
SELECT a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3,2
;

-- query IIIIII rowsort x528
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       c-d,
       d,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
;

-- query IIIIII rowsort x528
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       c-d,
       d,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,3
;

-- query IIIIII rowsort x528
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       c-d,
       d,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
;

-- query IIIIII rowsort x528
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       c-d,
       d,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,6,1
;

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
 ORDER BY 2,4,3,1
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,3,2
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
 ORDER BY 2,3,4,1
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query IIII rowsort x529
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,1
;
-- 96 values hashing to b29a4f53653c0e1a8bc6300aaa07f9de

-- query I rowsort x530
SELECT b
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
;
-- 21 values hashing to b84ff2c254f6ba4bcd8942c4ceb7e064

-- query I rowsort x530
SELECT b
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 21 values hashing to b84ff2c254f6ba4bcd8942c4ceb7e064

-- query I rowsort x530
SELECT b
  FROM t1
 WHERE (e>c OR e<d)
    OR d>e
;
-- 21 values hashing to b84ff2c254f6ba4bcd8942c4ceb7e064

-- query I rowsort x530
SELECT b
  FROM t1
 WHERE (e>c OR e<d)
    OR d>e
 ORDER BY 1
;
-- 21 values hashing to b84ff2c254f6ba4bcd8942c4ceb7e064

-- query III rowsort x531
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 90 values hashing to 774ffc972efa8f12fb5270b9a2811464

-- query III rowsort x531
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,2,3
;
-- 90 values hashing to 774ffc972efa8f12fb5270b9a2811464

-- query IIII rowsort x532
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a
  FROM t1
 WHERE a>b
    OR c>d
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 104 values hashing to 9d70636a8311231198a150a2ac8bb8f9

-- query IIII rowsort x532
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a
  FROM t1
 WHERE a>b
    OR c>d
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,3
;
-- 104 values hashing to 9d70636a8311231198a150a2ac8bb8f9

-- query IIII rowsort x532
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR c>d
;
-- 104 values hashing to 9d70636a8311231198a150a2ac8bb8f9

-- query IIII rowsort x532
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR c>d
 ORDER BY 3,1,4
;
-- 104 values hashing to 9d70636a8311231198a150a2ac8bb8f9

-- query IIII rowsort x533
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
;
-- 24 values hashing to 4eefd8751c9e5d963858bd7c3e44d8de

-- query IIII rowsort x533
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,4
;
-- 24 values hashing to 4eefd8751c9e5d963858bd7c3e44d8de

-- query IIII rowsort x533
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
;
-- 24 values hashing to 4eefd8751c9e5d963858bd7c3e44d8de

-- query IIII rowsort x533
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
 ORDER BY 2,1,4,3
;
-- 24 values hashing to 4eefd8751c9e5d963858bd7c3e44d8de

-- query II rowsort x534
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to 76d6c381b206468784f3ebd5580f5604

-- query II rowsort x534
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 52 values hashing to 76d6c381b206468784f3ebd5580f5604

-- query IIIII rowsort x535
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       b
  FROM t1
;
-- 150 values hashing to 5cb0c05a7c53a276c11f188783d0ad8b

-- query IIIII rowsort x535
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       b
  FROM t1
 ORDER BY 3,5,4,2,1
;
-- 150 values hashing to 5cb0c05a7c53a276c11f188783d0ad8b

-- query II rowsort x536
SELECT d-e,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
;
-- 28 values hashing to a0c29878c36a8a23511f201b3f7b1800

-- query II rowsort x536
SELECT d-e,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 28 values hashing to a0c29878c36a8a23511f201b3f7b1800

-- query II rowsort x536
SELECT d-e,
       c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
;
-- 28 values hashing to a0c29878c36a8a23511f201b3f7b1800

-- query II rowsort x536
SELECT d-e,
       c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
 ORDER BY 2,1
;
-- 28 values hashing to a0c29878c36a8a23511f201b3f7b1800

-- query IIII rowsort x537
SELECT c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
;
-- 64 values hashing to e06b774130bc687e564232bbcf51a91e

-- query IIII rowsort x537
SELECT c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,1,2
;
-- 64 values hashing to e06b774130bc687e564232bbcf51a91e

-- query IIII rowsort x537
SELECT c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
;
-- 64 values hashing to e06b774130bc687e564232bbcf51a91e

-- query IIII rowsort x537
SELECT c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
 ORDER BY 3,1
;
-- 64 values hashing to e06b774130bc687e564232bbcf51a91e

-- query IIIIII rowsort x538
SELECT d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 72 values hashing to 9eb6d54a1620a7b85e6d7b7044fcaef0

-- query IIIIII rowsort x538
SELECT d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 5,6,3,4,1
;
-- 72 values hashing to 9eb6d54a1620a7b85e6d7b7044fcaef0

-- query IIIIII rowsort x538
SELECT d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 72 values hashing to 9eb6d54a1620a7b85e6d7b7044fcaef0

-- query IIIIII rowsort x538
SELECT d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,5,4,3
;
-- 72 values hashing to 9eb6d54a1620a7b85e6d7b7044fcaef0

-- query IIIIIII rowsort x539
SELECT e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(a),
       d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
;

-- query IIIIIII rowsort x539
SELECT e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(a),
       d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
 ORDER BY 5,1,7,6,4,3,2
;

-- query IIIIIII rowsort x539
SELECT e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(a),
       d,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
;

-- query IIIIIII rowsort x539
SELECT e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(a),
       d,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,3,1,5,4,6,7
;

-- query IIII rowsort x540
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
;
-- 84 values hashing to a925a6ed3eaeb65d2def43aa60e4ba0a

-- query IIII rowsort x540
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 1,4,3
;
-- 84 values hashing to a925a6ed3eaeb65d2def43aa60e4ba0a

-- query III rowsort x541
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 90 values hashing to af2f5c460dcbe5d859625a848b452ff9

-- query III rowsort x541
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 3,2
;
-- 90 values hashing to af2f5c460dcbe5d859625a848b452ff9

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND (e>c OR e<d)
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND (e>c OR e<d)
 ORDER BY 2,4,3
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND a>b
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND a>b
 ORDER BY 2,3,1
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x542
SELECT b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,3,4
;
-- 32 values hashing to 9240066ab585efc3f0b28794f435c20b

-- query IIII rowsort x543
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 32 values hashing to 761c1d3eca857c88bfbc6357ef1d4bb9

-- query IIII rowsort x543
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 32 values hashing to 761c1d3eca857c88bfbc6357ef1d4bb9

-- query IIIII rowsort x544
SELECT c,
       c-d,
       a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
;
-- 150 values hashing to 17b6a2380f484c02289aad797fddc52c

-- query IIIII rowsort x544
SELECT c,
       c-d,
       a-b,
       a+b*2+c*3,
       abs(a)
  FROM t1
 ORDER BY 5,3,2,4,1
;
-- 150 values hashing to 17b6a2380f484c02289aad797fddc52c

-- query IIIIIII rowsort x545
SELECT b,
       abs(a),
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       a,
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
;
-- 147 values hashing to ddce6438f6ded8f787d7c7c9142766c8

-- query IIIIIII rowsort x545
SELECT b,
       abs(a),
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       a,
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
 ORDER BY 5,2,1,7,3,4
;
-- 147 values hashing to ddce6438f6ded8f787d7c7c9142766c8

-- query IIIIIII rowsort x545
SELECT b,
       abs(a),
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       a,
       c
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
;
-- 147 values hashing to ddce6438f6ded8f787d7c7c9142766c8

-- query IIIIIII rowsort x545
SELECT b,
       abs(a),
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       a,
       c
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 5,4
;
-- 147 values hashing to ddce6438f6ded8f787d7c7c9142766c8

-- query I rowsort x546
SELECT c-d
  FROM t1
;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query I rowsort x546
SELECT c-d
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query IIIIIII rowsort x547
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a+b*2,
       a,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
;
-- 91 values hashing to b18e90ba041643b851f2789fb293e177

-- query IIIIIII rowsort x547
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a+b*2,
       a,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
 ORDER BY 1,4,2,6,7,3,5
;
-- 91 values hashing to b18e90ba041643b851f2789fb293e177

-- query II rowsort x548
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE d>e
;
-- 22 values hashing to 72d2ab4ad233ab33010bd2c5d1749440

-- query II rowsort x548
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE d>e
 ORDER BY 1,2
;
-- 22 values hashing to 72d2ab4ad233ab33010bd2c5d1749440

-- query II rowsort x549
SELECT (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to bbd8f5be08e13456f3bfc16a88013529

-- query II rowsort x549
SELECT (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 52 values hashing to bbd8f5be08e13456f3bfc16a88013529

-- query IIII rowsort x550
SELECT abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
;
-- 120 values hashing to aa5182b024988c706aea974de8e9c476

-- query IIII rowsort x550
SELECT abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 ORDER BY 3,1,4
;
-- 120 values hashing to aa5182b024988c706aea974de8e9c476

-- query IIIII rowsort x551
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
;
-- 115 values hashing to bd1ad3e6a227b77b65945fd596e52c3d

-- query IIIII rowsort x551
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 4,2,1,3
;
-- 115 values hashing to bd1ad3e6a227b77b65945fd596e52c3d

-- query IIIII rowsort x551
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
;
-- 115 values hashing to bd1ad3e6a227b77b65945fd596e52c3d

-- query IIIII rowsort x551
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
 ORDER BY 4,1,2,3,5
;
-- 115 values hashing to bd1ad3e6a227b77b65945fd596e52c3d

-- query IIIIII rowsort x552
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 156 values hashing to d3db380510f107abcd9c2a05962f73f7

-- query IIIIII rowsort x552
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,6,1
;
-- 156 values hashing to d3db380510f107abcd9c2a05962f73f7

-- query IIIIII rowsort x552
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR c>d
;
-- 156 values hashing to d3db380510f107abcd9c2a05962f73f7

-- query IIIIII rowsort x552
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR c>d
 ORDER BY 1,4,6,5,3,2
;
-- 156 values hashing to d3db380510f107abcd9c2a05962f73f7

-- query IIIIII rowsort x553
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       d,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
;
-- 126 values hashing to a224d388369a7a8762e00a350ed763cf

-- query IIIIII rowsort x553
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       d,
       a+b*2,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 6,4,1,5,3
;
-- 126 values hashing to a224d388369a7a8762e00a350ed763cf

-- query III rowsort x554
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1050
-- 333
-- 106
-- 1290
-- 222
-- 125

-- query III rowsort x554
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,2
;
-- 1050
-- 333
-- 106
-- 1290
-- 222
-- 125

-- query I rowsort x555
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
;
-- 13 values hashing to 6e6a0a6e4c35b3bbdf0c9dcc6d9ee805

-- query I rowsort x555
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
 ORDER BY 1
;
-- 13 values hashing to 6e6a0a6e4c35b3bbdf0c9dcc6d9ee805

-- query I rowsort x556
SELECT d-e
  FROM t1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query I rowsort x556
SELECT d-e
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query IIIIIII rowsort x557
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       d,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
;
-- 210 values hashing to f30cba68ce30be44d3c41534b606390b

-- query IIIIIII rowsort x557
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       d,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 ORDER BY 1,3,2
;
-- 210 values hashing to f30cba68ce30be44d3c41534b606390b

-- query IIIII rowsort x558
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 150 values hashing to 9e0e10ca0afcd1880c61c538aa2b92c4

-- query IIIII rowsort x558
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 5,2,1,3,4
;
-- 150 values hashing to 9e0e10ca0afcd1880c61c538aa2b92c4

-- query IIIIIII rowsort x559
SELECT b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       (a+b+c+d+e)/5,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
;
-- 210 values hashing to 33ed025860d993d5123dff93b1bb0b4c

-- query IIIIIII rowsort x559
SELECT b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       (a+b+c+d+e)/5,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 ORDER BY 4,5,2
;
-- 210 values hashing to 33ed025860d993d5123dff93b1bb0b4c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query I rowsort x560
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 23 values hashing to aa1f40b06f76ca4564c5f92ac6387d9c

-- query II rowsort x561
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to 05003b5eabd6b2f7219b7c465b3e72fa

-- query II rowsort x561
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 54 values hashing to 05003b5eabd6b2f7219b7c465b3e72fa

-- query II rowsort x561
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
;
-- 54 values hashing to 05003b5eabd6b2f7219b7c465b3e72fa

-- query II rowsort x561
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
 ORDER BY 2,1
;
-- 54 values hashing to 05003b5eabd6b2f7219b7c465b3e72fa

-- query IIIII rowsort x562
SELECT c-d,
       abs(a),
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
;
-- 120 values hashing to 9deb969b4c89e7dd30619358d4f7c3e1

-- query IIIII rowsort x562
SELECT c-d,
       abs(a),
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,2,1
;
-- 120 values hashing to 9deb969b4c89e7dd30619358d4f7c3e1

-- query IIIII rowsort x562
SELECT c-d,
       abs(a),
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR (e>c OR e<d)
;
-- 120 values hashing to 9deb969b4c89e7dd30619358d4f7c3e1

-- query IIIII rowsort x562
SELECT c-d,
       abs(a),
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR (e>c OR e<d)
 ORDER BY 3,1
;
-- 120 values hashing to 9deb969b4c89e7dd30619358d4f7c3e1

-- query IIIIIII rowsort x563
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       a+b*2+c*3,
       a-b,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 154 values hashing to 638a0b12ab089da4bdab26fa4a86d2a4

-- query IIIIIII rowsort x563
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       a+b*2+c*3,
       a-b,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 5,7,2,6,1
;
-- 154 values hashing to 638a0b12ab089da4bdab26fa4a86d2a4

-- query IIIIIII rowsort x563
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       a+b*2+c*3,
       a-b,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 154 values hashing to 638a0b12ab089da4bdab26fa4a86d2a4

-- query IIIIIII rowsort x563
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       a+b*2+c*3,
       a-b,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 6,2,1,7
;
-- 154 values hashing to 638a0b12ab089da4bdab26fa4a86d2a4

-- query IIII rowsort x564
SELECT d,
       (a+b+c+d+e)/5,
       e,
       a+b*2+c*3
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
;
-- 190
-- 192
-- 192
-- 1158
-- 222
-- 222
-- 221
-- 1338

-- query IIII rowsort x564
SELECT d,
       (a+b+c+d+e)/5,
       e,
       a+b*2+c*3
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
 ORDER BY 3,1,4
;
-- 190
-- 192
-- 192
-- 1158
-- 222
-- 222
-- 221
-- 1338

-- query IIIIIII rowsort x565
SELECT e,
       c-d,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 210 values hashing to 8db0848d7a26b7f11f3c119d26e7ab9b

-- query IIIIIII rowsort x565
SELECT e,
       c-d,
       (a+b+c+d+e)/5,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 2,5,3,6,7,4,1
;
-- 210 values hashing to 8db0848d7a26b7f11f3c119d26e7ab9b

-- query IIIII rowsort x566
SELECT c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
;
-- 150 values hashing to b1e6017bcd974b8b6dfea93e886e7860

-- query IIIII rowsort x566
SELECT c-d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 ORDER BY 5,3,2,4
;
-- 150 values hashing to b1e6017bcd974b8b6dfea93e886e7860

-- query III rowsort x567
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       b-c
  FROM t1
;
-- 90 values hashing to 26cd92291109a2b8b185dc4cf12c1eb0

-- query III rowsort x567
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       b-c
  FROM t1
 ORDER BY 3,1,2
;
-- 90 values hashing to 26cd92291109a2b8b185dc4cf12c1eb0

-- query IIIII rowsort x568
SELECT c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 60 values hashing to 787fde79bb821591a7414b43c68a481a

-- query IIIII rowsort x568
SELECT c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,5,3
;
-- 60 values hashing to 787fde79bb821591a7414b43c68a481a

-- query IIIII rowsort x568
SELECT c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 60 values hashing to 787fde79bb821591a7414b43c68a481a

-- query IIIII rowsort x568
SELECT c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 1,4,3,2
;
-- 60 values hashing to 787fde79bb821591a7414b43c68a481a

-- query III rowsort x569
SELECT c,
       abs(b-c),
       c-d
  FROM t1
;
-- 90 values hashing to 41eddffbb1026fde489f8ddf1b8edefe

-- query III rowsort x569
SELECT c,
       abs(b-c),
       c-d
  FROM t1
 ORDER BY 3,2,1
;
-- 90 values hashing to 41eddffbb1026fde489f8ddf1b8edefe

-- query IIII rowsort x570
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c>d
;
-- 52 values hashing to 3d0071aa52b76cfd5320ac97977aa574

-- query IIII rowsort x570
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       a+b*2,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c>d
 ORDER BY 2,1,4,3
;
-- 52 values hashing to 3d0071aa52b76cfd5320ac97977aa574

-- query III rowsort x571
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       (a+b+c+d+e)/5
  FROM t1
;
-- 90 values hashing to 30a2cb0a98d6a10177a711a683f98ddf

-- query III rowsort x571
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to 30a2cb0a98d6a10177a711a683f98ddf

-- query I rowsort x572
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 184
-- 195
-- 225

-- query I rowsort x572
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 184
-- 195
-- 225

-- query I rowsort x572
SELECT c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
;
-- 184
-- 195
-- 225

-- query I rowsort x572
SELECT c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 184
-- 195
-- 225

-- query IIII rowsort x573
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 12 values hashing to 20519844c8541213771f3169975a81c7

-- query IIII rowsort x573
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 4,2,1
;
-- 12 values hashing to 20519844c8541213771f3169975a81c7

-- query IIII rowsort x573
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
;
-- 12 values hashing to 20519844c8541213771f3169975a81c7

-- query IIII rowsort x573
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,3
;
-- 12 values hashing to 20519844c8541213771f3169975a81c7

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,1
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,3,2,5
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x574
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,5,4
;
-- 35 values hashing to 831bf1ee380966afc5246d9d7f22ddcc

-- query IIIII rowsort x575
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b-c,
       a
  FROM t1
;
-- 150 values hashing to b08d384a8ae66fff46482ed9d1f3539a

-- query IIIII rowsort x575
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       b-c,
       a
  FROM t1
 ORDER BY 1,2,4,3,5
;
-- 150 values hashing to b08d384a8ae66fff46482ed9d1f3539a

-- query III rowsort x576
SELECT e,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
;
-- 9 values hashing to f47afebd970f10c8665b0f3887055c1e

-- query III rowsort x576
SELECT e,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1,2,3
;
-- 9 values hashing to f47afebd970f10c8665b0f3887055c1e

-- query IIIIII rowsort x577
SELECT a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 60 values hashing to e35119f8f9d05653a965303acf684221

-- query IIIIII rowsort x577
SELECT a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 6,2,1
;
-- 60 values hashing to e35119f8f9d05653a965303acf684221

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 2,3,1
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR a>b
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR a>b
 ORDER BY 1,2,3
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR d>e
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x578
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR d>e
 ORDER BY 2,3
;
-- 66 values hashing to 42d7ccf4a35710e53f6fc55ab6fe39b2

-- query III rowsort x579
SELECT a+b*2+c*3,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to 0737ede50d772682aae2bc5274742144

-- query III rowsort x579
SELECT a+b*2+c*3,
       b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1,2,3
;
-- 30 values hashing to 0737ede50d772682aae2bc5274742144

-- query IIIII rowsort x580
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2,
       b-c
  FROM t1
;
-- 150 values hashing to 39ac092c2826387388852a972eee0fd0

-- query IIIII rowsort x580
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2,
       b-c
  FROM t1
 ORDER BY 3,1,4
;
-- 150 values hashing to 39ac092c2826387388852a972eee0fd0

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE d>e
   AND b>c
   AND (a>b-2 AND a<b+2)
;
-- 137
-- 2

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE d>e
   AND b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 137
-- 2

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND d>e
;
-- 137
-- 2

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND d>e
 ORDER BY 1,2
;
-- 137
-- 2

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND b>c
;
-- 137
-- 2

-- query II rowsort x581
SELECT (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 1,2
;
-- 137
-- 2

-- query IIII rowsort x582
SELECT abs(a),
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- 1612
-- 107
-- 2
-- 127
-- 1902
-- 127
-- -2

-- query IIII rowsort x582
SELECT abs(a),
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4,3
;
-- 107
-- 1612
-- 107
-- 2
-- 127
-- 1902
-- 127
-- -2

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND (e>c OR e<d)
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND (e>c OR e<d)
 ORDER BY 1
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND d>e
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 1
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query I rowsort x583
SELECT d
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
 ORDER BY 1
;
-- 11 values hashing to 5fb1f7f101ae97ec369e8865b2f70e95

-- query IIII rowsort x584
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 84 values hashing to c1e82635b3d7facb5d9b45719f40b4cd

-- query IIII rowsort x584
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 1,4,2
;
-- 84 values hashing to c1e82635b3d7facb5d9b45719f40b4cd

-- query IIII rowsort x584
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 84 values hashing to c1e82635b3d7facb5d9b45719f40b4cd

-- query IIII rowsort x584
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4
;
-- 84 values hashing to c1e82635b3d7facb5d9b45719f40b4cd

-- query II rowsort x585
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND a>b
;
-- 12 values hashing to 2c0f6ec6275ba6c5272610a42842bac0

-- query II rowsort x585
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND a>b
 ORDER BY 1,2
;
-- 12 values hashing to 2c0f6ec6275ba6c5272610a42842bac0

-- query II rowsort x585
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND b>c
;
-- 12 values hashing to 2c0f6ec6275ba6c5272610a42842bac0

-- query II rowsort x585
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND b>c
 ORDER BY 2,1
;
-- 12 values hashing to 2c0f6ec6275ba6c5272610a42842bac0

-- query II rowsort x586
SELECT d,
       abs(b-c)
  FROM t1
;
-- 60 values hashing to 00d4ab74410d8ac671760d7198435203

-- query II rowsort x586
SELECT d,
       abs(b-c)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 00d4ab74410d8ac671760d7198435203

-- query IIIIIII rowsort x587
SELECT abs(b-c),
       c-d,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a-b,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 105 values hashing to 3e83008eb896a69947fcb2f5c00261ba

-- query IIIIIII rowsort x587
SELECT abs(b-c),
       c-d,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a-b,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 7,6,5,3
;
-- 105 values hashing to 3e83008eb896a69947fcb2f5c00261ba

-- query IIIII rowsort x588
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       d-e,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 40 values hashing to b20721d73ba3f6a923266e8b71e69295

-- query IIIII rowsort x588
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       d-e,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,5,2,4
;
-- 40 values hashing to b20721d73ba3f6a923266e8b71e69295

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND c>d
;
-- 222
-- 333
-- 444
-- 555

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND c>d
 ORDER BY 1
;
-- 222
-- 333
-- 444
-- 555

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND c>d
;
-- 222
-- 333
-- 444
-- 555

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND c>d
 ORDER BY 1
;
-- 222
-- 333
-- 444
-- 555

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 222
-- 333
-- 444
-- 555

-- query I rowsort x589
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 1
;
-- 222
-- 333
-- 444
-- 555

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR c>d
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
    OR c>d
 ORDER BY 3,6,5,1
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE c>d
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE c>d
    OR (a>b-2 AND a<b+2)
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,3,4,6,5,2
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (a>b-2 AND a<b+2)
    OR c>d
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIIIII rowsort x590
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (a>b-2 AND a<b+2)
    OR c>d
 ORDER BY 5,1
;
-- 132 values hashing to d647e0271e7dcd20be4b01806dc9049c

-- query IIII rowsort x591
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 120 values hashing to 16464527e24811f4febac77ea834135d

-- query IIII rowsort x591
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 2,4,1,3
;
-- 120 values hashing to 16464527e24811f4febac77ea834135d

-- query II rowsort x592
SELECT b-c,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 6fd9b50aa7457890a85c270b8a4f1525

-- query II rowsort x592
SELECT b-c,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 20 values hashing to 6fd9b50aa7457890a85c270b8a4f1525

-- query IIIIII rowsort x593
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       abs(b-c),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 72 values hashing to ead099d9e1a14c3c5109d016773391b0

-- query IIIIII rowsort x593
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       abs(b-c),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 5,2,1,3
;
-- 72 values hashing to ead099d9e1a14c3c5109d016773391b0

-- query IIIIII rowsort x593
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       abs(b-c),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 72 values hashing to ead099d9e1a14c3c5109d016773391b0

-- query IIIIII rowsort x593
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       abs(b-c),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,3
;
-- 72 values hashing to ead099d9e1a14c3c5109d016773391b0

-- query III rowsort x594
SELECT a,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- 635
-- 107
-- 127
-- 760
-- 127

-- query III rowsort x594
SELECT a,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1,2
;
-- 107
-- 635
-- 107
-- 127
-- 760
-- 127

-- query IIIIII rowsort x595
SELECT a+b*2+c*3+d*4,
       a,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR d>e
;
-- 120 values hashing to 49200402fefc8a32ee212ece11bbc9b2

-- query IIIIII rowsort x595
SELECT a+b*2+c*3+d*4,
       a,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR d>e
 ORDER BY 2,1,3,5,6,4
;
-- 120 values hashing to 49200402fefc8a32ee212ece11bbc9b2

-- query III rowsort x596
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       abs(a)
  FROM t1
;
-- 90 values hashing to ee68c9fb4d87c760d5e873f2e913c5a4

-- query III rowsort x596
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       abs(a)
  FROM t1
 ORDER BY 2,1,3
;
-- 90 values hashing to ee68c9fb4d87c760d5e873f2e913c5a4

-- query I rowsort x597
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 11
-- 14
-- 17
-- 22
-- 4
-- 5
-- 6
-- 9

-- query I rowsort x597
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 11
-- 14
-- 17
-- 22
-- 4
-- 5
-- 6
-- 9

-- query IIIIII rowsort x598
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to 29aa5114ddb75cbea4d8cc45fa4afd54

-- query IIIIII rowsort x598
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 5,2,3,6,4,1
;
-- 90 values hashing to 29aa5114ddb75cbea4d8cc45fa4afd54

-- query IIIII rowsort x599
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
;
-- 150 values hashing to 354baf9bf652faec3b23d9dd96f3dcd7

-- query IIIII rowsort x599
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 4,1,5
;
-- 150 values hashing to 354baf9bf652faec3b23d9dd96f3dcd7

-- query IIIII rowsort x600
SELECT a+b*2+c*3+d*4,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to aaa3b65ee00e530554fa3a2333bbc4ee

-- query IIIII rowsort x600
SELECT a+b*2+c*3+d*4,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 5,3,2,4,1
;
-- 130 values hashing to aaa3b65ee00e530554fa3a2333bbc4ee

-- query IIIII rowsort x601
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
;
-- 25 values hashing to f67c91cee8cbcab4101b0c4e9ea42a8b

-- query IIIII rowsort x601
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 3,2,4,5,1
;
-- 25 values hashing to f67c91cee8cbcab4101b0c4e9ea42a8b

-- query IIIII rowsort x601
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
;
-- 25 values hashing to f67c91cee8cbcab4101b0c4e9ea42a8b

-- query IIIII rowsort x601
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,1,2,5
;
-- 25 values hashing to f67c91cee8cbcab4101b0c4e9ea42a8b

-- query IIIIII rowsort x602
SELECT a+b*2+c*3,
       abs(a),
       a+b*2,
       b,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 156 values hashing to 4d0ab061ded856d78530159d920fafd1

-- query IIIIII rowsort x602
SELECT a+b*2+c*3,
       abs(a),
       a+b*2,
       b,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,3,5
;
-- 156 values hashing to 4d0ab061ded856d78530159d920fafd1

-- query III rowsort x603
SELECT c-d,
       a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
;
-- 57 values hashing to 8f966a2a20167d48616300e9b21f073e

-- query III rowsort x603
SELECT c-d,
       a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
 ORDER BY 1,3
;
-- 57 values hashing to 8f966a2a20167d48616300e9b21f073e

-- query III rowsort x603
SELECT c-d,
       a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 57 values hashing to 8f966a2a20167d48616300e9b21f073e

-- query III rowsort x603
SELECT c-d,
       a+b*2+c*3+d*4,
       b
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,1,2
;
-- 57 values hashing to 8f966a2a20167d48616300e9b21f073e

-- query III rowsort x604
SELECT a-b,
       a+b*2,
       a
  FROM t1
 WHERE d>e
    OR b>c
;
-- 60 values hashing to 59d499d10435c069fa6a84e2d995bf33

-- query III rowsort x604
SELECT a-b,
       a+b*2,
       a
  FROM t1
 WHERE d>e
    OR b>c
 ORDER BY 3,1
;
-- 60 values hashing to 59d499d10435c069fa6a84e2d995bf33

-- query III rowsort x604
SELECT a-b,
       a+b*2,
       a
  FROM t1
 WHERE b>c
    OR d>e
;
-- 60 values hashing to 59d499d10435c069fa6a84e2d995bf33

-- query III rowsort x604
SELECT a-b,
       a+b*2,
       a
  FROM t1
 WHERE b>c
    OR d>e
 ORDER BY 2,3,1
;
-- 60 values hashing to 59d499d10435c069fa6a84e2d995bf33

-- query IIIIII rowsort x605
SELECT e,
       b,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
;
-- 60 values hashing to c211130e730d38e13bad6ff26cee19a9

-- query IIIIII rowsort x605
SELECT e,
       b,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 5,4,3,6,2
;
-- 60 values hashing to c211130e730d38e13bad6ff26cee19a9

-- query IIIIII rowsort x605
SELECT e,
       b,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
;
-- 60 values hashing to c211130e730d38e13bad6ff26cee19a9

-- query IIIIII rowsort x605
SELECT e,
       b,
       a+b*2+c*3,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 60 values hashing to c211130e730d38e13bad6ff26cee19a9

-- query I rowsort x606
SELECT a
  FROM t1
;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query I rowsort x606
SELECT a
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query IIII rowsort x607
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 44 values hashing to 2a90f8140851a46adb39b25b04957845

-- query IIII rowsort x607
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 44 values hashing to 2a90f8140851a46adb39b25b04957845

-- query IIII rowsort x607
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
;
-- 44 values hashing to 2a90f8140851a46adb39b25b04957845

-- query IIII rowsort x607
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
 ORDER BY 4,2,3,1
;
-- 44 values hashing to 2a90f8140851a46adb39b25b04957845

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR a>b
    OR (e>c OR e<d)
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR a>b
    OR (e>c OR e<d)
 ORDER BY 2,1,6,3
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
 ORDER BY 4,7,1,2,6
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
    OR a>b
    OR b>c
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIIII rowsort x608
SELECT d-e,
       e,
       b,
       c,
       abs(b-c),
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
    OR a>b
    OR b>c
 ORDER BY 7,2,6,1,5,4,3
;
-- 189 values hashing to 9f4ad7fd9a7988f4345043e6a470f0eb

-- query IIIIII rowsort x609
SELECT c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d-e
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query IIIIII rowsort x609
SELECT c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d-e
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 4,5,6
;

-- query IIIIII rowsort x609
SELECT c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x609
SELECT c,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,6,2,1,5,3
;

-- query IIII rowsort x610
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
;
-- 44 values hashing to b0e581470db2e8b2cc006ff316140cf7

-- query IIII rowsort x610
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
 ORDER BY 4,2,1
;
-- 44 values hashing to b0e581470db2e8b2cc006ff316140cf7

-- query I rowsort x611
SELECT b
  FROM t1
;
-- 30 values hashing to 9697cb5cadc4331af70386531f7792a9

-- query I rowsort x611
SELECT b
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9697cb5cadc4331af70386531f7792a9

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d>e
   AND c BETWEEN b-2 AND d+2
;

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND d>e
;

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 2,1
;

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND d>e
;

-- query II rowsort x612
SELECT d,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND d>e
 ORDER BY 2,1
;

-- query II rowsort x613
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
    OR b>c
;
-- 46 values hashing to 4e3336bea5bf7984bcab041050e540ec

-- query II rowsort x613
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
    OR b>c
 ORDER BY 2,1
;
-- 46 values hashing to 4e3336bea5bf7984bcab041050e540ec

-- query II rowsort x613
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR (e>a AND e<b)
;
-- 46 values hashing to 4e3336bea5bf7984bcab041050e540ec

-- query II rowsort x613
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR (e>a AND e<b)
 ORDER BY 2,1
;
-- 46 values hashing to 4e3336bea5bf7984bcab041050e540ec

-- query II rowsort x614
SELECT a+b*2,
       abs(b-c)
  FROM t1
;
-- 60 values hashing to 1bf213ae7ba406909284a56a0a055f68

-- query II rowsort x614
SELECT a+b*2,
       abs(b-c)
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 1bf213ae7ba406909284a56a0a055f68

-- query IIIII rowsort x615
SELECT a+b*2+c*3+d*4,
       e,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE c>d
;
-- 65 values hashing to d0755f06ce4481afa6b7f87a5410f7ae

-- query IIIII rowsort x615
SELECT a+b*2+c*3+d*4,
       e,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE c>d
 ORDER BY 1,2,3,5,4
;
-- 65 values hashing to d0755f06ce4481afa6b7f87a5410f7ae

-- query IIII rowsort x616
SELECT abs(b-c),
       d-e,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to 2106e5a753ac202c6064546142a3578f

-- query IIII rowsort x616
SELECT abs(b-c),
       d-e,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,3,4,2
;
-- 20 values hashing to 2106e5a753ac202c6064546142a3578f

-- query IIIIII rowsort x617
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c,
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
;
-- 126 values hashing to 92b9ad83b8c6fc2f68ce4915d40e2834

-- query IIIIII rowsort x617
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a-b,
       b-c,
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 6,1,5,4
;
-- 126 values hashing to 92b9ad83b8c6fc2f68ce4915d40e2834

-- query I rowsort x618
SELECT abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
;
-- 16 values hashing to 5cbad2abd3a002a9adb35870fd42e9fa

-- query I rowsort x618
SELECT abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 16 values hashing to 5cbad2abd3a002a9adb35870fd42e9fa

-- query I rowsort x618
SELECT abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
;
-- 16 values hashing to 5cbad2abd3a002a9adb35870fd42e9fa

-- query I rowsort x618
SELECT abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
 ORDER BY 1
;
-- 16 values hashing to 5cbad2abd3a002a9adb35870fd42e9fa

-- query IIII rowsort x619
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 32 values hashing to 81c854081b1d86fd5d815aee775e79da

-- query IIII rowsort x619
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 32 values hashing to 81c854081b1d86fd5d815aee775e79da

-- query IIIII rowsort x620
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 95 values hashing to 7811b63159124b3a5f973e1d6733e15e

-- query IIIII rowsort x620
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1,5,3,4
;
-- 95 values hashing to 7811b63159124b3a5f973e1d6733e15e

-- query IIIII rowsort x620
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
;
-- 95 values hashing to 7811b63159124b3a5f973e1d6733e15e

-- query IIIII rowsort x620
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
 ORDER BY 4,2,5,3
;
-- 95 values hashing to 7811b63159124b3a5f973e1d6733e15e

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
 ORDER BY 4,3,2
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND (c<=d-2 OR c>=d+2)
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIII rowsort x621
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,1,4
;
-- 16 values hashing to 42d8187b851bde596da680e62bd20ad1

-- query IIIII rowsort x622
SELECT e,
       d-e,
       abs(a),
       b-c,
       (a+b+c+d+e)/5
  FROM t1
;
-- 150 values hashing to 27f32d662f3d6d294760141373c8ce9e

-- query IIIII rowsort x622
SELECT e,
       d-e,
       abs(a),
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 5,3,4
;
-- 150 values hashing to 27f32d662f3d6d294760141373c8ce9e

-- query I rowsort x623
SELECT a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 1000
-- 1096
-- 1180
-- 1360
-- 793
-- 827
-- 851
-- 940

-- query I rowsort x623
SELECT a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 1000
-- 1096
-- 1180
-- 1360
-- 793
-- 827
-- 851
-- 940

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
    OR d>e
    OR (c<=d-2 OR c>=d+2)
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
    OR d>e
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,4
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR d>e
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
    OR d>e
 ORDER BY 1,3,2,5,4
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
    OR a>b
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIIII rowsort x624
SELECT a+b*2,
       d,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
    OR a>b
 ORDER BY 1,2,5,4,3
;
-- 125 values hashing to 53f534fc08db58afb6497d397bd5bb95

-- query IIII rowsort x625
SELECT b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE (e>c OR e<d)
;
-- 84 values hashing to 6619e98949acd58a236485d6798b4082

-- query IIII rowsort x625
SELECT b,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 3,1
;
-- 84 values hashing to 6619e98949acd58a236485d6798b4082

-- query IIIII rowsort x626
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 99ad44057ef6c31bb7427cf8ad3c0d26

-- query IIIII rowsort x626
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1,3
;
-- 10 values hashing to 99ad44057ef6c31bb7427cf8ad3c0d26

-- query IIIII rowsort x626
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 99ad44057ef6c31bb7427cf8ad3c0d26

-- query IIIII rowsort x626
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4,1,5
;
-- 10 values hashing to 99ad44057ef6c31bb7427cf8ad3c0d26

-- query IIII rowsort x627
SELECT c-d,
       c,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
;
-- 52 values hashing to 043a1bf0ea90cf65a472357be8cbec27

-- query IIII rowsort x627
SELECT c-d,
       c,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
 ORDER BY 2,4,3,1
;
-- 52 values hashing to 043a1bf0ea90cf65a472357be8cbec27

-- query IIII rowsort x627
SELECT c-d,
       c,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 52 values hashing to 043a1bf0ea90cf65a472357be8cbec27

-- query IIII rowsort x627
SELECT c-d,
       c,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,1
;
-- 52 values hashing to 043a1bf0ea90cf65a472357be8cbec27

-- query IIIII rowsort x628
SELECT a+b*2+c*3+d*4,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
;
-- 150 values hashing to 865170780eff2a2d4fea71d70cee629f

-- query IIIII rowsort x628
SELECT a+b*2+c*3+d*4,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 ORDER BY 3,1,5,4
;
-- 150 values hashing to 865170780eff2a2d4fea71d70cee629f

-- query IIII rowsort x629
SELECT b-c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 32 values hashing to c75b58a5e64e9082eface00abf923bd4

-- query IIII rowsort x629
SELECT b-c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,4
;
-- 32 values hashing to c75b58a5e64e9082eface00abf923bd4

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
    OR c>d
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
    OR c>d
 ORDER BY 7,6,2
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE d>e
    OR c>d
    OR (a>b-2 AND a<b+2)
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE d>e
    OR c>d
    OR (a>b-2 AND a<b+2)
 ORDER BY 4,3,5
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE c>d
    OR d>e
    OR (a>b-2 AND a<b+2)
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIIII rowsort x630
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       a+b*2+c*3+d*4+e*5,
       a,
       b-c,
       c-d,
       abs(a)
  FROM t1
 WHERE c>d
    OR d>e
    OR (a>b-2 AND a<b+2)
 ORDER BY 7,1,3,2,6,5
;
-- 161 values hashing to 0075fc322441a6991573270f863c003e

-- query IIIIII rowsort x631
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       abs(a)
  FROM t1
;
-- 180 values hashing to b995fd3ed3a0e0bb771def6e5722bb0a

-- query IIIIII rowsort x631
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       abs(a)
  FROM t1
 ORDER BY 1,2,5,4,3
;
-- 180 values hashing to b995fd3ed3a0e0bb771def6e5722bb0a

-- query III rowsort x632
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to 6b5bb07ceb8e20f75fc46fed8f804e00

-- query III rowsort x632
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,2
;
-- 24 values hashing to 6b5bb07ceb8e20f75fc46fed8f804e00

-- query IIIIII rowsort x633
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE c>d
;
-- 78 values hashing to eac728c6ddb91ccd31a0d1128417639c

-- query IIIIII rowsort x633
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE c>d
 ORDER BY 2,4,5,6
;
-- 78 values hashing to eac728c6ddb91ccd31a0d1128417639c

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query I rowsort x634
SELECT a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 22 values hashing to 0bdc2e35193aab199c06b8b1e1fbe779

-- query IIIIIII rowsort x635
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 56 values hashing to ea44c18e5d7f35f44d27e96d1a548408

-- query IIIIIII rowsort x635
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 7,4,3,5,2,1
;
-- 56 values hashing to ea44c18e5d7f35f44d27e96d1a548408

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND c BETWEEN b-2 AND d+2
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1,3,4
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND a>b
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 2,4,3,1
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query IIII rowsort x636
SELECT a+b*2+c*3+d*4,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,4
;
-- 1325
-- 391
-- 444
-- 4
-- 1828
-- 544
-- 333
-- 14

-- query I rowsort x637
SELECT e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
;
-- 16 values hashing to 7d839bd833a63d8738f66b90ff985dab

-- query I rowsort x637
SELECT e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
 ORDER BY 1
;
-- 16 values hashing to 7d839bd833a63d8738f66b90ff985dab

-- query I rowsort x637
SELECT e
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 16 values hashing to 7d839bd833a63d8738f66b90ff985dab

-- query I rowsort x637
SELECT e
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 16 values hashing to 7d839bd833a63d8738f66b90ff985dab

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR b>c
 ORDER BY 4,1
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 5,2,1,4,3
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query IIIII rowsort x638
SELECT e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,5,3,4,2
;
-- 135 values hashing to e7aa3c5e3a24b65ef956b409a661d477

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
 ORDER BY 2,1
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
    OR (e>a AND e<b)
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query II rowsort x639
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 1,2
;
-- 52 values hashing to f1d3044a0e85a2767084245edcb2f4a6

-- query III rowsort x640
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 75 values hashing to cf041186510209396f2e00bd4f59e36f

-- query III rowsort x640
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,1
;
-- 75 values hashing to cf041186510209396f2e00bd4f59e36f

-- query III rowsort x640
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 75 values hashing to cf041186510209396f2e00bd4f59e36f

-- query III rowsort x640
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,3,2
;
-- 75 values hashing to cf041186510209396f2e00bd4f59e36f

-- query IIIIII rowsort x641
SELECT c,
       d,
       a+b*2+c*3+d*4+e*5,
       d-e,
       b-c,
       a+b*2
  FROM t1
;
-- 180 values hashing to efbf7446555a01f143d113eadb8baae3

-- query IIIIII rowsort x641
SELECT c,
       d,
       a+b*2+c*3+d*4+e*5,
       d-e,
       b-c,
       a+b*2
  FROM t1
 ORDER BY 5,4,3
;
-- 180 values hashing to efbf7446555a01f143d113eadb8baae3

-- query IIIIIII rowsort x642
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a+b*2+c*3+d*4+e*5,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
;
-- 210 values hashing to 7de752c4774915444d60e77708b2048c

-- query IIIIIII rowsort x642
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a+b*2+c*3+d*4+e*5,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 ORDER BY 1,6,5,4,7,2
;
-- 210 values hashing to 7de752c4774915444d60e77708b2048c

-- query IIIIII rowsort x643
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       c,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
;
-- 66 values hashing to 33243dacc3029b5e540ce9e560aac25f

-- query IIIIII rowsort x643
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       c,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,4,6,5,3
;
-- 66 values hashing to 33243dacc3029b5e540ce9e560aac25f

-- query III rowsort x644
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR (c<=d-2 OR c>=d+2)
;
-- 66 values hashing to 7cbbec5d5fa1bb9944f843aa4c37f973

-- query III rowsort x644
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,3
;
-- 66 values hashing to 7cbbec5d5fa1bb9944f843aa4c37f973

-- query III rowsort x644
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 66 values hashing to 7cbbec5d5fa1bb9944f843aa4c37f973

-- query III rowsort x644
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 1,3,2
;
-- 66 values hashing to 7cbbec5d5fa1bb9944f843aa4c37f973

-- query IIIIII rowsort x645
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 0
-- 760
-- 4
-- 3
-- 1902
-- 127

-- query IIIIII rowsort x645
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,6,4,3,5
;
-- 0
-- 760
-- 4
-- 3
-- 1902
-- 127

-- query IIIIII rowsort x645
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 0
-- 760
-- 4
-- 3
-- 1902
-- 127

-- query IIIIII rowsort x645
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,4,2,5,3
;
-- 0
-- 760
-- 4
-- 3
-- 1902
-- 127

-- query IIIII rowsort x646
SELECT (a+b+c+d+e)/5,
       abs(a),
       abs(b-c),
       a+b*2,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 40 values hashing to b9cade3e1ff5363496ae3fe0437b7238

-- query IIIII rowsort x646
SELECT (a+b+c+d+e)/5,
       abs(a),
       abs(b-c),
       a+b*2,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 3,2,1,4,5
;
-- 40 values hashing to b9cade3e1ff5363496ae3fe0437b7238

-- query I rowsort x647
SELECT e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
;
-- 9 values hashing to b54db3efe6d10d8d5c23d5b40a6e98f4

-- query I rowsort x647
SELECT e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 1
;
-- 9 values hashing to b54db3efe6d10d8d5c23d5b40a6e98f4

-- query I rowsort x647
SELECT e
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to b54db3efe6d10d8d5c23d5b40a6e98f4

-- query I rowsort x647
SELECT e
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 9 values hashing to b54db3efe6d10d8d5c23d5b40a6e98f4

-- query II rowsort x648
SELECT a+b*2,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 34 values hashing to 431dcbdecbfe1b6d6b282b2f49c172ac

-- query II rowsort x648
SELECT a+b*2,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 34 values hashing to 431dcbdecbfe1b6d6b282b2f49c172ac

-- query III rowsort x649
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
;
-- 21
-- 220
-- 1338
-- 26
-- 245
-- 1484

-- query III rowsort x649
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
 ORDER BY 2,3
;
-- 21
-- 220
-- 1338
-- 26
-- 245
-- 1484

-- query III rowsort x649
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
;
-- 21
-- 220
-- 1338
-- 26
-- 245
-- 1484

-- query III rowsort x649
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2
;
-- 21
-- 220
-- 1338
-- 26
-- 245
-- 1484

-- query IIIIIII rowsort x650
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 70 values hashing to 6e510133a22ce9d30f9d1179329b8878

-- query IIIIIII rowsort x650
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,7
;
-- 70 values hashing to 6e510133a22ce9d30f9d1179329b8878

-- query IIIIII rowsort x651
SELECT a+b*2+c*3,
       d,
       a+b*2,
       c-d,
       e,
       b-c
  FROM t1
;
-- 180 values hashing to bc4513b12162a93825e9bfea4fe97a1d

-- query IIIIII rowsort x651
SELECT a+b*2+c*3,
       d,
       a+b*2,
       c-d,
       e,
       b-c
  FROM t1
 ORDER BY 4,2,5
;
-- 180 values hashing to bc4513b12162a93825e9bfea4fe97a1d

-- query III rowsort x652
SELECT a+b*2+c*3+d*4,
       abs(a),
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND (e>c OR e<d)
;
-- 2226
-- 220
-- 1
-- 2476
-- 245
-- 2

-- query III rowsort x652
SELECT a+b*2+c*3+d*4,
       abs(a),
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND (e>c OR e<d)
 ORDER BY 1,3
;
-- 2226
-- 220
-- 1
-- 2476
-- 245
-- 2

-- query III rowsort x652
SELECT a+b*2+c*3+d*4,
       abs(a),
       d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (e>a AND e<b)
;
-- 2226
-- 220
-- 1
-- 2476
-- 245
-- 2

-- query III rowsort x652
SELECT a+b*2+c*3+d*4,
       abs(a),
       d-e
  FROM t1
 WHERE (e>c OR e<d)
   AND (e>a AND e<b)
 ORDER BY 2,1,3
;
-- 2226
-- 220
-- 1
-- 2476
-- 245
-- 2

-- query IIII rowsort x653
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e,
       c
  FROM t1
;
-- 120 values hashing to 6f7f6e9e0a1d7b8bf7c070d9ce0a22c0

-- query IIII rowsort x653
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       d-e,
       c
  FROM t1
 ORDER BY 3,2,1,4
;
-- 120 values hashing to 6f7f6e9e0a1d7b8bf7c070d9ce0a22c0

-- query I rowsort x654
SELECT d-e
  FROM t1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query I rowsort x654
SELECT d-e
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 333
-- 3
-- 129

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 2,3
;
-- 333
-- 3
-- 129

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND b>c
;
-- 333
-- 3
-- 129

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND b>c
 ORDER BY 1,3,2
;
-- 333
-- 3
-- 129

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 333
-- 3
-- 129

-- query III rowsort x655
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2,3
;
-- 333
-- 3
-- 129

-- query IIIII rowsort x656
SELECT c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 110 values hashing to 4323943c45e250340feb8d5708b8e62f

-- query IIIII rowsort x656
SELECT c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,1,5,2,4
;
-- 110 values hashing to 4323943c45e250340feb8d5708b8e62f

-- query IIIII rowsort x656
SELECT c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
;
-- 110 values hashing to 4323943c45e250340feb8d5708b8e62f

-- query IIIII rowsort x656
SELECT c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
 ORDER BY 3,4,5,1
;
-- 110 values hashing to 4323943c45e250340feb8d5708b8e62f

-- query II rowsort x657
SELECT d-e,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 16 values hashing to 5c9ea7d17d4d991b597a507c0c7402e0

-- query II rowsort x657
SELECT d-e,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 16 values hashing to 5c9ea7d17d4d991b597a507c0c7402e0

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (e>a AND e<b)
;
-- 0
-- 579
-- 0
-- 743

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 0
-- 579
-- 0
-- 743

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 0
-- 579
-- 0
-- 743

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 0
-- 579
-- 0
-- 743

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
;
-- 0
-- 579
-- 0
-- 743

-- query II rowsort x658
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
 ORDER BY 1,2
;
-- 0
-- 579
-- 0
-- 743

-- query I rowsort x659
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query I rowsort x659
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query I rowsort x660
SELECT c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
;
-- 10 values hashing to 298da0bf5f4a33425b406d45cfe7a02f

-- query I rowsort x660
SELECT c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 10 values hashing to 298da0bf5f4a33425b406d45cfe7a02f

-- query I rowsort x660
SELECT c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 10 values hashing to 298da0bf5f4a33425b406d45cfe7a02f

-- query I rowsort x660
SELECT c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 10 values hashing to 298da0bf5f4a33425b406d45cfe7a02f

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR c>d
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR c>d
 ORDER BY 1,2
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE b>c
    OR c>d
    OR c BETWEEN b-2 AND d+2
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE b>c
    OR c>d
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE c>d
    OR b>c
    OR c BETWEEN b-2 AND d+2
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query II rowsort x661
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE c>d
    OR b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 50 values hashing to 8b693107f5d03208df22ebd40471e4c5

-- query III rowsort x662
SELECT d-e,
       a,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to 6d73a828975e3289a657efba0304054c

-- query III rowsort x662
SELECT d-e,
       a,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,2,1
;
-- 30 values hashing to 6d73a828975e3289a657efba0304054c

-- query I rowsort x663
SELECT a+b*2
  FROM t1
;
-- 30 values hashing to fbca95e5a969d3d61cef1ebdfb618461

-- query I rowsort x663
SELECT a+b*2
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to fbca95e5a969d3d61cef1ebdfb618461

-- query III rowsort x664
SELECT d,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 12 values hashing to 4b4ca058935d839f72f52963e0da4925

-- query III rowsort x664
SELECT d,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,3
;
-- 12 values hashing to 4b4ca058935d839f72f52963e0da4925

-- query III rowsort x664
SELECT d,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 12 values hashing to 4b4ca058935d839f72f52963e0da4925

-- query III rowsort x664
SELECT d,
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 12 values hashing to 4b4ca058935d839f72f52963e0da4925

-- query IIIIIII rowsort x665
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a+b*2+c*3+d*4,
       a,
       a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
;
-- 91 values hashing to 18f349038c355a58d26ec68d72766f74

-- query IIIIIII rowsort x665
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a+b*2+c*3+d*4,
       a,
       a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
 ORDER BY 5,6,2,4
;
-- 91 values hashing to 18f349038c355a58d26ec68d72766f74

-- query IIII rowsort x666
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3+d*4,
       a
  FROM t1
;
-- 120 values hashing to 4a6e5a11c1b2cadbd2509edd4727fc36

-- query IIII rowsort x666
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3+d*4,
       a
  FROM t1
 ORDER BY 2,3
;
-- 120 values hashing to 4a6e5a11c1b2cadbd2509edd4727fc36

-- query IIII rowsort x667
SELECT a+b*2+c*3,
       a-b,
       e,
       d-e
  FROM t1
 WHERE b>c
;
-- 52 values hashing to b425d3cd6fe34fd738c34e0c2c726c94

-- query IIII rowsort x667
SELECT a+b*2+c*3,
       a-b,
       e,
       d-e
  FROM t1
 WHERE b>c
 ORDER BY 3,1
;
-- 52 values hashing to b425d3cd6fe34fd738c34e0c2c726c94

-- query IIIIIII rowsort x668
SELECT a+b*2+c*3,
       abs(b-c),
       e,
       (a+b+c+d+e)/5,
       b,
       d,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
;
-- 133 values hashing to 35456f0028870395a71bdffc4cf633ec

-- query IIIIIII rowsort x668
SELECT a+b*2+c*3,
       abs(b-c),
       e,
       (a+b+c+d+e)/5,
       b,
       d,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
 ORDER BY 2,6,3,1,5,4,7
;
-- 133 values hashing to 35456f0028870395a71bdffc4cf633ec

-- query IIIII rowsort x669
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       a+b*2+c*3+d*4,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 8831886a230ed0211a4e484d7642fe2e

-- query IIIII rowsort x669
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       a+b*2+c*3+d*4,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,5,1,3,2
;
-- 10 values hashing to 8831886a230ed0211a4e484d7642fe2e

-- query IIIIII rowsort x670
SELECT (a+b+c+d+e)/5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c-d,
       a+b*2
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 156 values hashing to 4432156680365971a3e4cbf671510d6d

-- query IIIIII rowsort x670
SELECT (a+b+c+d+e)/5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c-d,
       a+b*2
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,6
;
-- 156 values hashing to 4432156680365971a3e4cbf671510d6d

-- query IIIIII rowsort x670
SELECT (a+b+c+d+e)/5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c-d,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
;
-- 156 values hashing to 4432156680365971a3e4cbf671510d6d

-- query IIIIII rowsort x670
SELECT (a+b+c+d+e)/5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       c-d,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
 ORDER BY 3,4
;
-- 156 values hashing to 4432156680365971a3e4cbf671510d6d

-- query IIII rowsort x671
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
;
-- 52 values hashing to 65fa8f30fe3b38c1f63914b24dd0ae36

-- query IIII rowsort x671
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
 ORDER BY 1,3
;
-- 52 values hashing to 65fa8f30fe3b38c1f63914b24dd0ae36

-- query IIII rowsort x672
SELECT b-c,
       c-d,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 120 values hashing to ee5ebd71e2885766385292465c73b289

-- query IIII rowsort x672
SELECT b-c,
       c-d,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 1,3,4
;
-- 120 values hashing to ee5ebd71e2885766385292465c73b289

-- query IIII rowsort x673
SELECT a-b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 120 values hashing to 12556e5006f3a24e10df5da2cc282ae5

-- query IIII rowsort x673
SELECT a-b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 4,2
;
-- 120 values hashing to 12556e5006f3a24e10df5da2cc282ae5

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,3,1
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
 ORDER BY 1,3
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
   AND d>e
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query III rowsort x674
SELECT d,
       b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 1,2
;
-- 15 values hashing to 4935fb89cfb41e1c3e07004dd65f5c35

-- query IIIIII rowsort x675
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 48 values hashing to 9a1c2dfd2507a0a0eb699119d7e6fa15

-- query IIIIII rowsort x675
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,3
;
-- 48 values hashing to 9a1c2dfd2507a0a0eb699119d7e6fa15

-- query IIIIII rowsort x676
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
;
-- 54 values hashing to 70cd18685ab99a2b7c3fc0b4491b7cdb

-- query IIIIII rowsort x676
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 1,5,3,6,2
;
-- 54 values hashing to 70cd18685ab99a2b7c3fc0b4491b7cdb

-- query IIIIII rowsort x676
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
;
-- 54 values hashing to 70cd18685ab99a2b7c3fc0b4491b7cdb

-- query IIIIII rowsort x676
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 54 values hashing to 70cd18685ab99a2b7c3fc0b4491b7cdb

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
 ORDER BY 1
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND d>e
 ORDER BY 1
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query I rowsort x677
SELECT e
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 1
;
-- 162
-- 180
-- 210
-- 221
-- 230
-- 237
-- 246

-- query IIIIII rowsort x678
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
;
-- 102 values hashing to 99987b7ee71d19ed1c2374b9fafa7bf0

-- query IIIIII rowsort x678
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
 ORDER BY 1,5,4,3,6,2
;
-- 102 values hashing to 99987b7ee71d19ed1c2374b9fafa7bf0

-- query IIIIII rowsort x678
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
;
-- 102 values hashing to 99987b7ee71d19ed1c2374b9fafa7bf0

-- query IIIIII rowsort x678
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 6,1,5,2
;
-- 102 values hashing to 99987b7ee71d19ed1c2374b9fafa7bf0

-- query II rowsort x679
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1050
-- 107
-- 1290
-- 127

-- query II rowsort x679
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 1050
-- 107
-- 1290
-- 127

-- query IIIII rowsort x680
SELECT c,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(b-c),
       b
  FROM t1
;
-- 150 values hashing to 08650458538a7f599e07dc060bd0d5a8

-- query IIIII rowsort x680
SELECT c,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(b-c),
       b
  FROM t1
 ORDER BY 2,4,1,3,5
;
-- 150 values hashing to 08650458538a7f599e07dc060bd0d5a8

-- query IIII rowsort x681
SELECT a+b*2,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 120 values hashing to e4765bbd17a313f600b42a1fdae917ae

-- query IIII rowsort x681
SELECT a+b*2,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 2,3,4
;
-- 120 values hashing to e4765bbd17a313f600b42a1fdae917ae

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND a>b
;

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND a>b
 ORDER BY 3,1,2
;

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;

-- query III rowsort x682
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 3,2,1
;

-- query IIII rowsort x683
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 120 values hashing to 44fd7ec618532e84d2b224108a6efc76

-- query IIII rowsort x683
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 2,3,1,4
;
-- 120 values hashing to 44fd7ec618532e84d2b224108a6efc76

-- query IIIII rowsort x684
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
;
-- 150 values hashing to 1bd193a7d8faa78de64325339eff9e57

-- query IIIII rowsort x684
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 ORDER BY 3,5
;
-- 150 values hashing to 1bd193a7d8faa78de64325339eff9e57

-- query III rowsort x685
SELECT a+b*2+c*3+d*4+e*5,
       a-b,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1612
-- 2
-- 108
-- 1902
-- -2
-- 128

-- query III rowsort x685
SELECT a+b*2+c*3+d*4+e*5,
       a-b,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,1
;
-- 1612
-- 2
-- 108
-- 1902
-- -2
-- 128

-- query III rowsort x686
SELECT a,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 90 values hashing to e7f4afdfc7ec5420ff8bea9047b73d7e

-- query III rowsort x686
SELECT a,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 1,3
;
-- 90 values hashing to e7f4afdfc7ec5420ff8bea9047b73d7e

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR d>e
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR d>e
 ORDER BY 3,5,4,2
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR d>e
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR d>e
 ORDER BY 3,2,5,1,4
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
    OR c BETWEEN b-2 AND d+2
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x687
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
    OR c BETWEEN b-2 AND d+2
 ORDER BY 5,3
;
-- 105 values hashing to 6db0595048bb4b87385375c23fbb03e9

-- query IIIII rowsort x688
SELECT a,
       (a+b+c+d+e)/5,
       b-c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
;
-- 85 values hashing to 4805fd0e5a976f4378ba55c5494b747e

-- query IIIII rowsort x688
SELECT a,
       (a+b+c+d+e)/5,
       b-c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
 ORDER BY 1,2
;
-- 85 values hashing to 4805fd0e5a976f4378ba55c5494b747e

-- query I rowsort x689
SELECT a+b*2
  FROM t1
 WHERE b>c
    OR a>b
;
-- 24 values hashing to e71470a4cbcc21748346c6f62f1c096d

-- query I rowsort x689
SELECT a+b*2
  FROM t1
 WHERE b>c
    OR a>b
 ORDER BY 1
;
-- 24 values hashing to e71470a4cbcc21748346c6f62f1c096d

-- query I rowsort x689
SELECT a+b*2
  FROM t1
 WHERE a>b
    OR b>c
;
-- 24 values hashing to e71470a4cbcc21748346c6f62f1c096d

-- query I rowsort x689
SELECT a+b*2
  FROM t1
 WHERE a>b
    OR b>c
 ORDER BY 1
;
-- 24 values hashing to e71470a4cbcc21748346c6f62f1c096d

-- query IIII rowsort x690
SELECT b-c,
       a+b*2,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
;
-- 120 values hashing to 6e54ebf916f41ecf931f4532456d3be2

-- query IIII rowsort x690
SELECT b-c,
       a+b*2,
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 ORDER BY 4,3
;
-- 120 values hashing to 6e54ebf916f41ecf931f4532456d3be2

-- query IIII rowsort x691
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
;
-- 68 values hashing to 06c7ceeead894606cbb65850934466f4

-- query IIII rowsort x691
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
 ORDER BY 3,4
;
-- 68 values hashing to 06c7ceeead894606cbb65850934466f4

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND d>e
;
-- 2125
-- 2226

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND d>e
 ORDER BY 1
;
-- 2125
-- 2226

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
   AND c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 2125
-- 2226

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
   AND c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 2125
-- 2226

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND d>e
   AND (c<=d-2 OR c>=d+2)
;
-- 2125
-- 2226

-- query I rowsort x692
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND d>e
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 2125
-- 2226

-- query II rowsort x693
SELECT b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
;
-- 22 values hashing to 8555b014659201768f0fe7baf9967e06

-- query II rowsort x693
SELECT b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
 ORDER BY 1,2
;
-- 22 values hashing to 8555b014659201768f0fe7baf9967e06

-- query II rowsort x694
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 60 values hashing to 47be54c84370bf1c6eb0642f00978093

-- query II rowsort x694
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 47be54c84370bf1c6eb0642f00978093

-- query IIIII rowsort x695
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 2fa427a693b2bdbbb544b9392fe8952a

-- query IIIII rowsort x695
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,4,2
;
-- 10 values hashing to 2fa427a693b2bdbbb544b9392fe8952a

-- query IIIII rowsort x696
SELECT a-b,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
;
-- 150 values hashing to 5129a20d65fcd44a07408f5142b1cd09

-- query IIIII rowsort x696
SELECT a-b,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 ORDER BY 4,2
;
-- 150 values hashing to 5129a20d65fcd44a07408f5142b1cd09

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
;

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
 ORDER BY 5,3,1,4,2,6
;

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
   AND c>d
;

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
   AND c>d
 ORDER BY 6,5,4,7,1,3
;

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x697
SELECT abs(a),
       a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a-b,
       e
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2,3,6,7,4,5
;

-- query II rowsort x698
SELECT a-b,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 52 values hashing to a9641b59792fc08509de991d21cf1449

-- query II rowsort x698
SELECT a-b,
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 52 values hashing to a9641b59792fc08509de991d21cf1449

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 2,1
;

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query II rowsort x699
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;

-- query IIIII rowsort x700
SELECT (a+b+c+d+e)/5,
       b,
       abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 135 values hashing to 605ff1ace3fefbac5df841361cbdd14e

-- query IIIII rowsort x700
SELECT (a+b+c+d+e)/5,
       b,
       abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4,5,1,2
;
-- 135 values hashing to 605ff1ace3fefbac5df841361cbdd14e

-- query IIIII rowsort x700
SELECT (a+b+c+d+e)/5,
       b,
       abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
;
-- 135 values hashing to 605ff1ace3fefbac5df841361cbdd14e

-- query IIIII rowsort x700
SELECT (a+b+c+d+e)/5,
       b,
       abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 5,4,3
;
-- 135 values hashing to 605ff1ace3fefbac5df841361cbdd14e

-- query IIII rowsort x701
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
;
-- 96 values hashing to 2b9cb6d210d8977b701edd7cc1a21cd6

-- query IIII rowsort x701
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,4,3,1
;
-- 96 values hashing to 2b9cb6d210d8977b701edd7cc1a21cd6

-- query IIII rowsort x701
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
;
-- 96 values hashing to 2b9cb6d210d8977b701edd7cc1a21cd6

-- query IIII rowsort x701
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
 ORDER BY 1,4,2
;
-- 96 values hashing to 2b9cb6d210d8977b701edd7cc1a21cd6

-- query III rowsort x702
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
;
-- 60 values hashing to b670a82934f4611abfa49da6ac4c7700

-- query III rowsort x702
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
 ORDER BY 3,1
;
-- 60 values hashing to b670a82934f4611abfa49da6ac4c7700

-- query IIIIII rowsort x703
SELECT d,
       e,
       a+b*2+c*3+d*4+e*5,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 114 values hashing to 78365d176362a43babd7bf2b93ff7edd

-- query IIIIII rowsort x703
SELECT d,
       e,
       a+b*2+c*3+d*4+e*5,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 5,6,4
;
-- 114 values hashing to 78365d176362a43babd7bf2b93ff7edd

-- query IIII rowsort x704
SELECT (a+b+c+d+e)/5,
       d,
       c-d,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
;
-- 60 values hashing to 87c38a4989a95b372a49f40afe4b6ee7

-- query IIII rowsort x704
SELECT (a+b+c+d+e)/5,
       d,
       c-d,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
 ORDER BY 3,2,4,1
;
-- 60 values hashing to 87c38a4989a95b372a49f40afe4b6ee7

-- query IIII rowsort x704
SELECT (a+b+c+d+e)/5,
       d,
       c-d,
       abs(b-c)
  FROM t1
 WHERE c>d
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 60 values hashing to 87c38a4989a95b372a49f40afe4b6ee7

-- query IIII rowsort x704
SELECT (a+b+c+d+e)/5,
       d,
       c-d,
       abs(b-c)
  FROM t1
 WHERE c>d
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,2
;
-- 60 values hashing to 87c38a4989a95b372a49f40afe4b6ee7

-- query IIIIII rowsort x705
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
;
-- 24 values hashing to 96313609120ed6ed43f19282bb33448a

-- query IIIIII rowsort x705
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 5,4
;
-- 24 values hashing to 96313609120ed6ed43f19282bb33448a

-- query IIIIII rowsort x705
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND d>e
;
-- 24 values hashing to 96313609120ed6ed43f19282bb33448a

-- query IIIIII rowsort x705
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 6,3,4
;
-- 24 values hashing to 96313609120ed6ed43f19282bb33448a

-- query I rowsort x706
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
;
-- 111
-- 222
-- 222

-- query I rowsort x706
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1
;
-- 111
-- 222
-- 222

-- query II rowsort x707
SELECT abs(a),
       abs(b-c)
  FROM t1
;
-- 60 values hashing to ef628e93360c6418a161c8bc984fc005

-- query II rowsort x707
SELECT abs(a),
       abs(b-c)
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to ef628e93360c6418a161c8bc984fc005

-- query IIIII rowsort x708
SELECT abs(b-c),
       d,
       d-e,
       c-d,
       e
  FROM t1
 WHERE a>b
;
-- 85 values hashing to 936fa92f2a3e8f45419618b59f6a8858

-- query IIIII rowsort x708
SELECT abs(b-c),
       d,
       d-e,
       c-d,
       e
  FROM t1
 WHERE a>b
 ORDER BY 4,1,5,2
;
-- 85 values hashing to 936fa92f2a3e8f45419618b59f6a8858

-- query IIII rowsort x709
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 40 values hashing to 0bcf1508dc78bc1867e520ca3db7355d

-- query IIII rowsort x709
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,3,2
;
-- 40 values hashing to 0bcf1508dc78bc1867e520ca3db7355d

-- query IIII rowsort x709
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
;
-- 40 values hashing to 0bcf1508dc78bc1867e520ca3db7355d

-- query IIII rowsort x709
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 4,2,3
;
-- 40 values hashing to 0bcf1508dc78bc1867e520ca3db7355d

-- query III rowsort x710
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
;
-- 90 values hashing to 1c204adbdc05d0927b60e997937fe50a

-- query III rowsort x710
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 2,3,1
;
-- 90 values hashing to 1c204adbdc05d0927b60e997937fe50a

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR d NOT BETWEEN 110 AND 150
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR (e>c OR e<d)
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR b>c
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query I rowsort x711
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR b>c
 ORDER BY 1
;
-- 27 values hashing to ccb5588394c5680f5305fcb9ef5b3e2e

-- query III rowsort x712
SELECT a,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 78 values hashing to 9770cbf7ed4c923952579ab2f2657e25

-- query III rowsort x712
SELECT a,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 78 values hashing to 9770cbf7ed4c923952579ab2f2657e25

-- query IIIIII rowsort x713
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       a,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
;
-- 180 values hashing to e6dcf1f455e14598f16d8f906e8ef7e9

-- query IIIIII rowsort x713
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       d,
       a,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 ORDER BY 6,5,3,4,1,2
;
-- 180 values hashing to e6dcf1f455e14598f16d8f906e8ef7e9

-- query IIIII rowsort x714
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
;
-- 80 values hashing to 6ef54925015c9504f804e0fdb4d91037

-- query IIIII rowsort x714
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
 ORDER BY 4,5,1,2
;
-- 80 values hashing to 6ef54925015c9504f804e0fdb4d91037

-- query IIIII rowsort x714
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 80 values hashing to 6ef54925015c9504f804e0fdb4d91037

-- query IIIII rowsort x714
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4
;
-- 80 values hashing to 6ef54925015c9504f804e0fdb4d91037

-- query IIIII rowsort x715
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       abs(a)
  FROM t1
 WHERE c>d
    OR d>e
;
-- 95 values hashing to bed7235daff0f9f53011e8f710309332

-- query IIIII rowsort x715
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       abs(a)
  FROM t1
 WHERE c>d
    OR d>e
 ORDER BY 1,3,4
;
-- 95 values hashing to bed7235daff0f9f53011e8f710309332

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,2
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1,3,4
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query IIII rowsort x716
SELECT b-c,
       a+b*2,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 4,2,1,3
;
-- 36 values hashing to 9b60c80f1253128bfdf084e82443c834

-- query I rowsort x717
SELECT b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 130
-- 139
-- 143
-- 158
-- 167
-- 181
-- 198
-- 228

-- query I rowsort x717
SELECT b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 130
-- 139
-- 143
-- 158
-- 167
-- 181
-- 198
-- 228

-- query II rowsort x718
SELECT a+b*2,
       e
  FROM t1
;
-- 60 values hashing to e0271f8ba22474f4049d1c4117e25a26

-- query II rowsort x718
SELECT a+b*2,
       e
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to e0271f8ba22474f4049d1c4117e25a26

-- query IIIII rowsort x719
SELECT (a+b+c+d+e)/5,
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
;
-- 40 values hashing to c3933b6e8cb7e7bff2b8e6232d42043a

-- query IIIII rowsort x719
SELECT (a+b+c+d+e)/5,
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
 ORDER BY 3,2
;
-- 40 values hashing to c3933b6e8cb7e7bff2b8e6232d42043a

-- query IIIII rowsort x719
SELECT (a+b+c+d+e)/5,
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
;
-- 40 values hashing to c3933b6e8cb7e7bff2b8e6232d42043a

-- query IIIII rowsort x719
SELECT (a+b+c+d+e)/5,
       a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
 ORDER BY 3,2,4
;
-- 40 values hashing to c3933b6e8cb7e7bff2b8e6232d42043a

-- query I rowsort x720
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 15 values hashing to 24301db3251cc0181759db55e6ca955d

-- query I rowsort x720
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 15 values hashing to 24301db3251cc0181759db55e6ca955d

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE b>c
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE b>c
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,2,7,3,4
;

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE c>d
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE c>d
   AND b>c
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,4
;

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND b>c
   AND c>d
;

-- query IIIIIII rowsort x721
SELECT a-b,
       (a+b+c+d+e)/5,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND b>c
   AND c>d
 ORDER BY 4,6,3,1,7,2,5
;

-- query II rowsort x722
SELECT e,
       (a+b+c+d+e)/5
  FROM t1
;
-- 60 values hashing to d498732e2676d6a2598a7fc7eb42e20c

-- query II rowsort x722
SELECT e,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to d498732e2676d6a2598a7fc7eb42e20c

-- query IIIIIII rowsort x723
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       d-e,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2+c*3
  FROM t1
 WHERE c>d
;
-- 91 values hashing to 33c48df60edc29d417900f70ffaa09c1

-- query IIIIIII rowsort x723
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       d-e,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2+c*3
  FROM t1
 WHERE c>d
 ORDER BY 2,3,7,5,4,6
;
-- 91 values hashing to 33c48df60edc29d417900f70ffaa09c1

-- query IIIIIII rowsort x724
SELECT e,
       c,
       c-d,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3+d*4
  FROM t1
;
-- 210 values hashing to 65c04b0e28cbaad4c60a25ea653f926f

-- query IIIIIII rowsort x724
SELECT e,
       c,
       c-d,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 3,2
;
-- 210 values hashing to 65c04b0e28cbaad4c60a25ea653f926f

-- query IIIIII rowsort x725
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 180 values hashing to 84287fc53576cbb5bb4df2db89013970

-- query IIIIII rowsort x725
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 1,4,5,6
;
-- 180 values hashing to 84287fc53576cbb5bb4df2db89013970

-- query I rowsort x726
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 26 values hashing to bacf799fb7f910fb7d7a8d0e0ab6cc33

-- query I rowsort x726
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 26 values hashing to bacf799fb7f910fb7d7a8d0e0ab6cc33

-- query I rowsort x727
SELECT a-b
  FROM t1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query I rowsort x727
SELECT a-b
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,2,1
;

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND a>b
;

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND a>b
 ORDER BY 2,3,1
;

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;

-- query III rowsort x728
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 1,3,2
;

-- query IIIIIII rowsort x729
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       b,
       e,
       a+b*2,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
;
-- 21 values hashing to f6e9afbfb91f2c78712b7e371b0629ca

-- query IIIIIII rowsort x729
SELECT a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       b,
       e,
       a+b*2,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 7,3,5,2,4,1
;
-- 21 values hashing to f6e9afbfb91f2c78712b7e371b0629ca

-- query III rowsort x730
SELECT e,
       d,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 78 values hashing to b3cb3cb66bde843991043df72fec3f0c

-- query III rowsort x730
SELECT e,
       d,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,3,2
;
-- 78 values hashing to b3cb3cb66bde843991043df72fec3f0c

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR d>e
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
    OR d>e
 ORDER BY 3,1
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR d>e
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR d>e
 ORDER BY 3,2,4,5,1
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
    OR a>b
    OR (a>b-2 AND a<b+2)
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIII rowsort x731
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE d>e
    OR a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 4,2,3,1
;
-- 115 values hashing to bb21d817f25fca8477eb01b4fedb58c7

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 4,3
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (c<=d-2 OR c>=d+2)
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 4,1,2,7
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
 ORDER BY 4,1,5,6,2
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query IIIIIII rowsort x732
SELECT b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,5,3,7,4,6
;
-- 21 values hashing to 66cd7aeef4414a02b7f5507993fab335

-- query II rowsort x733
SELECT c-d,
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 30 values hashing to 5c44e220765931661a93eef7d781f382

-- query II rowsort x733
SELECT c-d,
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 30 values hashing to 5c44e220765931661a93eef7d781f382

-- query I rowsort x734
SELECT a+b*2
  FROM t1
;
-- 30 values hashing to fbca95e5a969d3d61cef1ebdfb618461

-- query I rowsort x734
SELECT a+b*2
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to fbca95e5a969d3d61cef1ebdfb618461

-- query III rowsort x735
SELECT e,
       b-c,
       a-b
  FROM t1
;
-- 90 values hashing to 54548edc6b7e3210f1a87b87028507eb

-- query III rowsort x735
SELECT e,
       b-c,
       a-b
  FROM t1
 ORDER BY 3,2
;
-- 90 values hashing to 54548edc6b7e3210f1a87b87028507eb

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4,1,2
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
 ORDER BY 4,3,2,1
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIII rowsort x736
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
 ORDER BY 2,3,1
;
-- 104 values hashing to 0fe9466f8bc2d8db37e18a838d56e649

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND c>d
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND c>d
 ORDER BY 3,2,1,4,5
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND a>b
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND a>b
 ORDER BY 3,5,1,2,4
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c>d
   AND a>b
   AND c BETWEEN b-2 AND d+2
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query IIIII rowsort x737
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE c>d
   AND a>b
   AND c BETWEEN b-2 AND d+2
 ORDER BY 5,1,2,4,3
;
-- 25 values hashing to a2167941ad5156924d8b2030b57290cc

-- query III rowsort x738
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
;
-- 9 values hashing to 0e75b49ae26f7f4b1a44ae9d353a0e7e

-- query III rowsort x738
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
 ORDER BY 3,1
;
-- 9 values hashing to 0e75b49ae26f7f4b1a44ae9d353a0e7e

-- query IIIIII rowsort x739
SELECT a+b*2+c*3+d*4,
       a,
       e,
       a+b*2+c*3+d*4+e*5,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
;
-- 78 values hashing to abb56a92bf0cb2eeb79cb083d30f4461

-- query IIIIII rowsort x739
SELECT a+b*2+c*3+d*4,
       a,
       e,
       a+b*2+c*3+d*4+e*5,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
 ORDER BY 4,3,6
;
-- 78 values hashing to abb56a92bf0cb2eeb79cb083d30f4461

-- query II rowsort x740
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 54 values hashing to 375bd17b041072c483e342b932f987d7

-- query II rowsort x740
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 54 values hashing to 375bd17b041072c483e342b932f987d7

-- query III rowsort x741
SELECT d,
       abs(b-c),
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
;
-- 63 values hashing to a77c78bd17779239f80e4add9247f9a3

-- query III rowsort x741
SELECT d,
       abs(b-c),
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 3,1
;
-- 63 values hashing to a77c78bd17779239f80e4add9247f9a3

-- query I rowsort x742
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
;
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0

-- query I rowsort x742
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0

-- query I rowsort x742
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0

-- query I rowsort x742
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0
-- 0

-- query III rowsort x743
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
;
-- 90 values hashing to 3c15699b628fcb0315fbe0c6eeda70e0

-- query III rowsort x743
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
 ORDER BY 1,3
;
-- 90 values hashing to 3c15699b628fcb0315fbe0c6eeda70e0

-- query IIII rowsort x744
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 84 values hashing to 4b1f41b8ffbace27ffd3a54792a622f5

-- query IIII rowsort x744
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,3
;
-- 84 values hashing to 4b1f41b8ffbace27ffd3a54792a622f5

-- query IIII rowsort x744
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 84 values hashing to 4b1f41b8ffbace27ffd3a54792a622f5

-- query IIII rowsort x744
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 1,3,4
;
-- 84 values hashing to 4b1f41b8ffbace27ffd3a54792a622f5

-- query IIII rowsort x745
SELECT b-c,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
;
-- 68 values hashing to e51724a26aa401a907517e31686c8aa8

-- query IIII rowsort x745
SELECT b-c,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
 ORDER BY 3,2,1,4
;
-- 68 values hashing to e51724a26aa401a907517e31686c8aa8

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (e>c OR e<d)
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query II rowsort x746
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
   AND (e>c OR e<d)
 ORDER BY 1,2
;
-- 10 values hashing to 46db9015ef52a10b49c8e03ba9ef9196

-- query I rowsort x747
SELECT a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 10 values hashing to efa8813bb3fe4fd95c76a8b4cec1fef1

-- query I rowsort x747
SELECT a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 10 values hashing to efa8813bb3fe4fd95c76a8b4cec1fef1

-- query II rowsort x748
SELECT (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 24 values hashing to 5c25c8944f53227053854fc9e1ad5d04

-- query II rowsort x748
SELECT (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 1,2
;
-- 24 values hashing to 5c25c8944f53227053854fc9e1ad5d04

-- query II rowsort x748
SELECT (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 24 values hashing to 5c25c8944f53227053854fc9e1ad5d04

-- query II rowsort x748
SELECT (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 24 values hashing to 5c25c8944f53227053854fc9e1ad5d04

-- query IIIII rowsort x749
SELECT abs(a),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 150 values hashing to ff1cec10198db2dc82176f49396dc74c

-- query IIIII rowsort x749
SELECT abs(a),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 4,2,3,5,1
;
-- 150 values hashing to ff1cec10198db2dc82176f49396dc74c

-- query IIIII rowsort x750
SELECT c-d,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 150 values hashing to 5d88f05c0ec013c69e7d2468ca196f39

-- query IIIII rowsort x750
SELECT c-d,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 4,2,3,5
;
-- 150 values hashing to 5d88f05c0ec013c69e7d2468ca196f39

-- query II rowsort x751
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
;
-- 16
-- 222
-- 26
-- 111

-- query II rowsort x751
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 16
-- 222
-- 26
-- 111

-- query II rowsort x751
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
;
-- 16
-- 222
-- 26
-- 111

-- query II rowsort x751
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
   AND b>c
 ORDER BY 2,1
;
-- 16
-- 222
-- 26
-- 111

-- query IIIIII rowsort x752
SELECT a,
       c,
       c-d,
       (a+b+c+d+e)/5,
       e,
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 60 values hashing to 40bddf4ca96e21e4b7d5a9be8dbf5c68

-- query IIIIII rowsort x752
SELECT a,
       c,
       c-d,
       (a+b+c+d+e)/5,
       e,
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,6,1,5,2,4
;
-- 60 values hashing to 40bddf4ca96e21e4b7d5a9be8dbf5c68

-- query IIII rowsort x753
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       abs(a),
       b
  FROM t1
 WHERE d>e
;
-- 44 values hashing to 7034369d38673d6b059070a0e839c554

-- query IIII rowsort x753
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       abs(a),
       b
  FROM t1
 WHERE d>e
 ORDER BY 3,1
;
-- 44 values hashing to 7034369d38673d6b059070a0e839c554

-- query IIIIIII rowsort x754
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 126 values hashing to 192f68d8690f0de01a1560966b1800e8

-- query IIIIIII rowsort x754
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4,7,6,5,1,2
;
-- 126 values hashing to 192f68d8690f0de01a1560966b1800e8

-- query IIIIIII rowsort x754
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 126 values hashing to 192f68d8690f0de01a1560966b1800e8

-- query IIIIIII rowsort x754
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       b-c,
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 7,6,4,3,2,5
;
-- 126 values hashing to 192f68d8690f0de01a1560966b1800e8

-- query IIIII rowsort x755
SELECT abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
;
-- 95 values hashing to 4a08be935c0a2bbfee088c7b78d8a22b

-- query IIIII rowsort x755
SELECT abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
 ORDER BY 2,1
;
-- 95 values hashing to 4a08be935c0a2bbfee088c7b78d8a22b

-- query IIIII rowsort x755
SELECT abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 95 values hashing to 4a08be935c0a2bbfee088c7b78d8a22b

-- query IIIII rowsort x755
SELECT abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,2,5
;
-- 95 values hashing to 4a08be935c0a2bbfee088c7b78d8a22b

-- query IIIIIII rowsort x756
SELECT b-c,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       d
  FROM t1
 WHERE b>c
;
-- 91 values hashing to 4d1ba48d653a04c1964aca0a76d2fa66

-- query IIIIIII rowsort x756
SELECT b-c,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       d
  FROM t1
 WHERE b>c
 ORDER BY 4,5,2
;
-- 91 values hashing to 4d1ba48d653a04c1964aca0a76d2fa66

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
 ORDER BY 3,2
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,5,2
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIII rowsort x757
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
 ORDER BY 4,5
;
-- 20 values hashing to df87df2d7282eb1327156fc49e9cd150

-- query IIIIIII rowsort x758
SELECT a+b*2+c*3,
       a,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       b
  FROM t1
 WHERE (e>a AND e<b)
;
-- 21 values hashing to 1c7d5e919afacfb1b1a0e4f7b11608eb

-- query IIIIIII rowsort x758
SELECT a+b*2+c*3,
       a,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       b
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 7,5,1
;
-- 21 values hashing to 1c7d5e919afacfb1b1a0e4f7b11608eb

-- query IIII rowsort x759
SELECT a+b*2,
       d,
       a+b*2+c*3+d*4+e*5,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 108 values hashing to 8d1dfc0a320648d492a00bf65d8e4d6a

-- query IIII rowsort x759
SELECT a+b*2,
       d,
       a+b*2+c*3+d*4+e*5,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,2
;
-- 108 values hashing to 8d1dfc0a320648d492a00bf65d8e4d6a

-- query IIIII rowsort x760
SELECT a+b*2+c*3+d*4,
       b-c,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x760
SELECT a+b*2+c*3+d*4,
       b-c,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,2
;

-- query IIIII rowsort x760
SELECT a+b*2+c*3+d*4,
       b-c,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIIII rowsort x760
SELECT a+b*2+c*3+d*4,
       b-c,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 5,1,2,4
;

-- query IIIII rowsort x761
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       d-e,
       e,
       d
  FROM t1
;
-- 150 values hashing to 8fc0fc1ae43b818568824e2e5b772c8b

-- query IIIII rowsort x761
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       d-e,
       e,
       d
  FROM t1
 ORDER BY 3,2,4
;
-- 150 values hashing to 8fc0fc1ae43b818568824e2e5b772c8b

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 2,5,3,4,1
;

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 5,4,3,1
;

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x762
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,3,4,1,2
;

-- query III rowsort x763
SELECT c,
       d,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
;
-- 24 values hashing to acc553f142405b2316a0d6f67b8c087f

-- query III rowsort x763
SELECT c,
       d,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2,3
;
-- 24 values hashing to acc553f142405b2316a0d6f67b8c087f

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE (e>a AND e<b)
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE (e>a AND e<b)
   AND (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,1,2
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE (e>c OR e<d)
   AND (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,3,2
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND (e>a AND e<b)
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query III rowsort x764
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 222
-- 0
-- 224
-- 248
-- 0
-- 247

-- query IIIIII rowsort x765
SELECT a+b*2+c*3+d*4+e*5,
       b,
       abs(b-c),
       abs(a),
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE b>c
;
-- 78 values hashing to 15f8a87acd557eff36b6b45cf6145a89

-- query IIIIII rowsort x765
SELECT a+b*2+c*3+d*4+e*5,
       b,
       abs(b-c),
       abs(a),
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE b>c
 ORDER BY 4,5,6,3,1,2
;
-- 78 values hashing to 15f8a87acd557eff36b6b45cf6145a89

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,2
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
;
-- 1067
-- 333
-- 107

-- query III rowsort x766
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2,3
;
-- 1067
-- 333
-- 107

-- query IIIIII rowsort x767
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       b,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
;
-- 180 values hashing to 1ecd732fc97614a29c190f64cedb21e6

-- query IIIIII rowsort x767
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       b,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 ORDER BY 5,4,3
;
-- 180 values hashing to 1ecd732fc97614a29c190f64cedb21e6

-- query I rowsort x768
SELECT c
  FROM t1
;
-- 30 values hashing to 177ddffdf372dd8b1cd1f4f32c609fc7

-- query I rowsort x768
SELECT c
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 177ddffdf372dd8b1cd1f4f32c609fc7

-- query I rowsort x769
SELECT a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 635
-- 760

-- query I rowsort x769
SELECT a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 635
-- 760

-- query II rowsort x770
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR b>c
;
-- 40 values hashing to a066bcf112057385006c3ee80251128d

-- query II rowsort x770
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR b>c
 ORDER BY 1,2
;
-- 40 values hashing to a066bcf112057385006c3ee80251128d

-- query II rowsort x770
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR d>e
;
-- 40 values hashing to a066bcf112057385006c3ee80251128d

-- query II rowsort x770
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR d>e
 ORDER BY 1,2
;
-- 40 values hashing to a066bcf112057385006c3ee80251128d

-- query IIIIIII rowsort x771
SELECT a+b*2+c*3,
       a,
       d,
       a+b*2,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
;
-- 210 values hashing to fbc9ec93b76c4fb6716609f161ed1737

-- query IIIIIII rowsort x771
SELECT a+b*2+c*3,
       a,
       d,
       a+b*2,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1,5,7
;
-- 210 values hashing to fbc9ec93b76c4fb6716609f161ed1737

-- query III rowsort x772
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 51 values hashing to 2ef29759ecbd012e176e97d752db71f4

-- query III rowsort x772
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 2,3
;
-- 51 values hashing to 2ef29759ecbd012e176e97d752db71f4

-- query IIIIIII rowsort x773
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       abs(b-c),
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
;
-- 210 values hashing to 924153fc00e68eaae184bcae05105db5

-- query IIIIIII rowsort x773
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       abs(b-c),
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 ORDER BY 7,4,6,2,3,1,5
;
-- 210 values hashing to 924153fc00e68eaae184bcae05105db5

-- query I rowsort x774
SELECT abs(b-c)
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
;
-- 26 values hashing to bbf5d06f9b3cf6ed2e0c96d97cb93393

-- query I rowsort x774
SELECT abs(b-c)
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 26 values hashing to bbf5d06f9b3cf6ed2e0c96d97cb93393

-- query I rowsort x774
SELECT abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
;
-- 26 values hashing to bbf5d06f9b3cf6ed2e0c96d97cb93393

-- query I rowsort x774
SELECT abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
 ORDER BY 1
;
-- 26 values hashing to bbf5d06f9b3cf6ed2e0c96d97cb93393

-- query I rowsort x775
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 30 values hashing to 0075716954dbc259c5e8ac65568a6fa7

-- query I rowsort x775
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 0075716954dbc259c5e8ac65568a6fa7

-- query IIIII rowsort x776
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       b-c,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 50 values hashing to c0abef7fc17bf093b41ad295ca250beb

-- query IIIII rowsort x776
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       b-c,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 5,1,4,3,2
;
-- 50 values hashing to c0abef7fc17bf093b41ad295ca250beb

-- query I rowsort x777
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
;
-- 13 values hashing to d271a615af2e7875654b988689524a23

-- query I rowsort x777
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
 ORDER BY 1
;
-- 13 values hashing to d271a615af2e7875654b988689524a23

-- query III rowsort x778
SELECT (a+b+c+d+e)/5,
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
;

-- query III rowsort x778
SELECT (a+b+c+d+e)/5,
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1,3
;

-- query III rowsort x778
SELECT (a+b+c+d+e)/5,
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
;

-- query III rowsort x778
SELECT (a+b+c+d+e)/5,
       b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,3
;

-- query IIIII rowsort x779
SELECT b,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 145 values hashing to adcbe2157e977aa5b3104d8336f850b9

-- query IIIII rowsort x779
SELECT b,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,5,1
;
-- 145 values hashing to adcbe2157e977aa5b3104d8336f850b9

-- query IIIIIII rowsort x780
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       c-d
  FROM t1
;
-- 210 values hashing to 12b6753aecb255f2092cbe394ac3e0b1

-- query IIIIIII rowsort x780
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       c-d
  FROM t1
 ORDER BY 5,7,3,1
;
-- 210 values hashing to 12b6753aecb255f2092cbe394ac3e0b1

-- query II rowsort x781
SELECT d-e,
       abs(a)
  FROM t1
;
-- 60 values hashing to eeff397028894e248156d61f81e4f6f0

-- query II rowsort x781
SELECT d-e,
       abs(a)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to eeff397028894e248156d61f81e4f6f0

-- query IIIII rowsort x782
SELECT b-c,
       abs(b-c),
       d-e,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
;
-- 90 values hashing to 626ef6252ef34893711614adade69fcc

-- query IIIII rowsort x782
SELECT b-c,
       abs(b-c),
       d-e,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
 ORDER BY 2,3,4
;
-- 90 values hashing to 626ef6252ef34893711614adade69fcc

-- query IIIII rowsort x782
SELECT b-c,
       abs(b-c),
       d-e,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 90 values hashing to 626ef6252ef34893711614adade69fcc

-- query IIIII rowsort x782
SELECT b-c,
       abs(b-c),
       d-e,
       d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4
;
-- 90 values hashing to 626ef6252ef34893711614adade69fcc

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d>e
   AND d NOT BETWEEN 110 AND 150
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,1,5,3,6
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND d>e
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND d>e
 ORDER BY 1,4,3,5,6
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d>e
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d>e
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,6,5,2,4
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x783
SELECT b-c,
       a+b*2+c*3,
       a+b*2,
       c-d,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,4,5,2,3,1
;

-- query III rowsort x784
SELECT b,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 90 values hashing to 1040bcfbc48b8da482563e6bf55c8020

-- query III rowsort x784
SELECT b,
       abs(a),
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,3
;
-- 90 values hashing to 1040bcfbc48b8da482563e6bf55c8020

-- query IIIII rowsort x785
SELECT a+b*2+c*3+d*4+e*5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a-b
  FROM t1
 WHERE c>d
   AND b>c
;
-- 20 values hashing to 4aa57bffd9ad259bf18a44fc63809db3

-- query IIIII rowsort x785
SELECT a+b*2+c*3+d*4+e*5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a-b
  FROM t1
 WHERE c>d
   AND b>c
 ORDER BY 1,4,3,2
;
-- 20 values hashing to 4aa57bffd9ad259bf18a44fc63809db3

-- query IIIII rowsort x785
SELECT a+b*2+c*3+d*4+e*5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a-b
  FROM t1
 WHERE b>c
   AND c>d
;
-- 20 values hashing to 4aa57bffd9ad259bf18a44fc63809db3

-- query IIIII rowsort x785
SELECT a+b*2+c*3+d*4+e*5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a-b
  FROM t1
 WHERE b>c
   AND c>d
 ORDER BY 1,3
;
-- 20 values hashing to 4aa57bffd9ad259bf18a44fc63809db3

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR c BETWEEN b-2 AND d+2
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR b>c
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR b>c
 ORDER BY 1,2
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR d NOT BETWEEN 110 AND 150
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR b>c
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query II rowsort x786
SELECT b,
       a+b*2
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR b>c
 ORDER BY 1,2
;
-- 52 values hashing to 6edf7153843e52137e6df1f9451808b2

-- query IIII rowsort x787
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
;
-- 56 values hashing to 79e43be9c8bc1b1482e9e3ec5055d625

-- query IIII rowsort x787
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2,4,1
;
-- 56 values hashing to 79e43be9c8bc1b1482e9e3ec5055d625

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 1
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query I rowsort x788
SELECT a-b
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 10 values hashing to f18663fb394835caeb11f30bbb756057

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,3,5,2,6
;

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,6
;

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;

-- query IIIIII rowsort x789
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       c,
       b,
       e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,2,1
;

-- query II rowsort x790
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND c>d
;
-- -4
-- 1430
-- 1
-- 1300
-- 1
-- 1390
-- 3
-- 364

-- query II rowsort x790
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND c>d
 ORDER BY 2,1
;
-- -4
-- 1430
-- 1
-- 1300
-- 1
-- 1390
-- 3
-- 364

-- query II rowsort x790
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND (a>b-2 AND a<b+2)
;
-- -4
-- 1430
-- 1
-- 1300
-- 1
-- 1390
-- 3
-- 364

-- query II rowsort x790
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- -4
-- 1430
-- 1
-- 1300
-- 1
-- 1390
-- 3
-- 364

-- query III rowsort x791
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
;
-- 90 values hashing to 3e9e8f67aeb7ef26568b78aaec231885

-- query III rowsort x791
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to 3e9e8f67aeb7ef26568b78aaec231885

-- query II rowsort x792
SELECT d-e,
       b
  FROM t1
;
-- 60 values hashing to 8cf8dd4e30fa1a0ba26c7c32e36c2ccd

-- query II rowsort x792
SELECT d-e,
       b
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 8cf8dd4e30fa1a0ba26c7c32e36c2ccd

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND c>d
   AND c BETWEEN b-2 AND d+2
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND c>d
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,1,5,2
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
   AND c>d
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 3,1,5,2
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND c>d
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
   AND c>d
 ORDER BY 5,1,4
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND a>b
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query IIIII rowsort x793
SELECT abs(b-c),
       abs(a),
       d-e,
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND a>b
 ORDER BY 4,1,3
;
-- 25 values hashing to d782d4b19976325c2cb7b97f99c702cb

-- query I rowsort x794
SELECT d-e
  FROM t1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query I rowsort x794
SELECT d-e
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query IIIII rowsort x795
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4,
       a,
       abs(b-c)
  FROM t1
;
-- 150 values hashing to d816f0f14e2bff044cd70aff15ac2d4b

-- query IIIII rowsort x795
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4,
       a,
       abs(b-c)
  FROM t1
 ORDER BY 2,4,1
;
-- 150 values hashing to d816f0f14e2bff044cd70aff15ac2d4b

-- query I rowsort x796
SELECT c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
;

-- query I rowsort x796
SELECT c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1
;

-- query I rowsort x796
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;

-- query I rowsort x796
SELECT c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 1
;

-- query II rowsort x797
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
;
-- 40 values hashing to 9102a4c60187cf2a5da79119275168f3

-- query II rowsort x797
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
 ORDER BY 2,1
;
-- 40 values hashing to 9102a4c60187cf2a5da79119275168f3

-- query II rowsort x797
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
;
-- 40 values hashing to 9102a4c60187cf2a5da79119275168f3

-- query II rowsort x797
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
    OR (e>a AND e<b)
 ORDER BY 1,2
;
-- 40 values hashing to 9102a4c60187cf2a5da79119275168f3

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c>d
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c>d
 ORDER BY 4,1,5
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE d>e
    OR c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE d>e
    OR c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,2,4
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR d>e
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIII rowsort x798
SELECT abs(a),
       d-e,
       a+b*2+c*3,
       abs(b-c),
       b
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR d>e
 ORDER BY 1,3
;
-- 120 values hashing to 7f568c528311be6ed6eec5ebe0e3ef6a

-- query IIIIIII rowsort x799
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 70 values hashing to d354893ad347c5d343981e64288646e8

-- query IIIIIII rowsort x799
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 4,1,5,2,6,3
;
-- 70 values hashing to d354893ad347c5d343981e64288646e8

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,2
;

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 5,6,2,3,1,4
;

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIIIII rowsort x800
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,6,5,1,3,2
;

-- query IIIIII rowsort x801
SELECT d,
       c-d,
       a+b*2+c*3,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 180 values hashing to 36e748eb3b5f1beac4d5c62c3fb4b854

-- query IIIIII rowsort x801
SELECT d,
       c-d,
       a+b*2+c*3,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,5,6,3,1
;
-- 180 values hashing to 36e748eb3b5f1beac4d5c62c3fb4b854

-- query IIIIIII rowsort x802
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a,
       b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 196 values hashing to 5403ef2d6951bd8fa174d4149c728d2c

-- query IIIIIII rowsort x802
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a,
       b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,6
;
-- 196 values hashing to 5403ef2d6951bd8fa174d4149c728d2c

-- query IIIIIII rowsort x802
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a,
       b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
;
-- 196 values hashing to 5403ef2d6951bd8fa174d4149c728d2c

-- query IIIIIII rowsort x802
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a,
       b,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
 ORDER BY 7,4,3,5,2,6,1
;
-- 196 values hashing to 5403ef2d6951bd8fa174d4149c728d2c

-- query IIIIIII rowsort x803
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       d,
       abs(b-c),
       c,
       d-e
  FROM t1
;
-- 210 values hashing to b047d56f74f0ab55f66fea22b4c3b64d

-- query IIIIIII rowsort x803
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       abs(a),
       d,
       abs(b-c),
       c,
       d-e
  FROM t1
 ORDER BY 4,3,5,2,6,7
;
-- 210 values hashing to b047d56f74f0ab55f66fea22b4c3b64d

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,5
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 5,2
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIII rowsort x804
SELECT a+b*2,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,3,5,4
;
-- 120 values hashing to 15eab5346226dca12c84b3717d672faf

-- query IIIIII rowsort x805
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       c-d,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 48 values hashing to daf2cdb908e35fa07f04d94c58909428

-- query IIIIII rowsort x805
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       c-d,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1,5,2,3,4
;
-- 48 values hashing to daf2cdb908e35fa07f04d94c58909428

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR b>c
    OR c BETWEEN b-2 AND d+2
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 3,2,4
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR d>e
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR d>e
 ORDER BY 1,4,2
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR b>c
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIII rowsort x806
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR b>c
 ORDER BY 3,2
;
-- 96 values hashing to 44da1927a8f7dc680350aa237e4bf11f

-- query IIIIIII rowsort x807
SELECT b,
       a+b*2+c*3+d*4,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 105 values hashing to 54c654e1e6431af9fd26b5eb45fdfe9b

-- query IIIIIII rowsort x807
SELECT b,
       a+b*2+c*3+d*4,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 5,6,1,3,7
;
-- 105 values hashing to 54c654e1e6431af9fd26b5eb45fdfe9b

-- query IIII rowsort x808
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
;
-- 84 values hashing to 87b28524c600c839717c27b7fb63bd50

-- query IIII rowsort x808
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 2,4
;
-- 84 values hashing to 87b28524c600c839717c27b7fb63bd50

-- query IIIIIII rowsort x809
SELECT abs(a),
       a+b*2,
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       c,
       d,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 105 values hashing to 077ef28ce7fb5bae0691476a025491fc

-- query IIIIIII rowsort x809
SELECT abs(a),
       a+b*2,
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       c,
       d,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,3,2,6,5,7,4
;
-- 105 values hashing to 077ef28ce7fb5bae0691476a025491fc

-- query I rowsort x810
SELECT a
  FROM t1
 WHERE (e>a AND e<b)
;
-- 191
-- 220
-- 245

-- query I rowsort x810
SELECT a
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 1
;
-- 191
-- 220
-- 245

-- query IIII rowsort x811
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       b-c
  FROM t1
;
-- 120 values hashing to 819c892fbc5c854738f5016649048d8f

-- query IIII rowsort x811
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       b-c
  FROM t1
 ORDER BY 3,1,4,2
;
-- 120 values hashing to 819c892fbc5c854738f5016649048d8f

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND a>b
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND a>b
 ORDER BY 1,2
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE a>b
   AND b>c
   AND (a>b-2 AND a<b+2)
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE a>b
   AND b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE b>c
   AND a>b
   AND (a>b-2 AND a<b+2)
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x812
SELECT abs(a),
       a+b*2
  FROM t1
 WHERE b>c
   AND a>b
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 159
-- 475
-- 168
-- 502
-- 199
-- 595
-- 229
-- 685

-- query II rowsort x813
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
;
-- 60 values hashing to a159b23fd53b433a22233bac12bfcbfd

-- query II rowsort x813
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to a159b23fd53b433a22233bac12bfcbfd

-- query IIII rowsort x814
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       b,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
;
-- 64 values hashing to 3566124dacd2c12176bfda780e1a9b96

-- query IIII rowsort x814
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       b,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
 ORDER BY 4,2
;
-- 64 values hashing to 3566124dacd2c12176bfda780e1a9b96

-- query IIII rowsort x814
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       b,
       d-e
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
;
-- 64 values hashing to 3566124dacd2c12176bfda780e1a9b96

-- query IIII rowsort x814
SELECT abs(b-c),
       a+b*2+c*3+d*4+e*5,
       b,
       d-e
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 4,1,3
;
-- 64 values hashing to 3566124dacd2c12176bfda780e1a9b96

-- query IIIII rowsort x815
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
;
-- 150 values hashing to 22246749bbaaa527ef55579a649f1f59

-- query IIIII rowsort x815
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 3,5,1
;
-- 150 values hashing to 22246749bbaaa527ef55579a649f1f59

-- query IIIII rowsort x816
SELECT e,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       a
  FROM t1
;
-- 150 values hashing to bbb491379c2c046a624e37471571dca3

-- query IIIII rowsort x816
SELECT e,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       a
  FROM t1
 ORDER BY 4,2,3,5
;
-- 150 values hashing to bbb491379c2c046a624e37471571dca3

-- query III rowsort x817
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
;
-- 57 values hashing to 881ebccd5da31eb464ebc33480b921bd

-- query III rowsort x817
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,3,2
;
-- 57 values hashing to 881ebccd5da31eb464ebc33480b921bd

-- query III rowsort x817
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
;
-- 57 values hashing to 881ebccd5da31eb464ebc33480b921bd

-- query III rowsort x817
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
 ORDER BY 1,2
;
-- 57 values hashing to 881ebccd5da31eb464ebc33480b921bd

-- query IIIIII rowsort x818
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d-e,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
;
-- 132 values hashing to 2fad9b201c26f61f51170e12cdacb20d

-- query IIIIII rowsort x818
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d-e,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
 ORDER BY 3,4,6
;
-- 132 values hashing to 2fad9b201c26f61f51170e12cdacb20d

-- query IIIIII rowsort x818
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d-e,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
;
-- 132 values hashing to 2fad9b201c26f61f51170e12cdacb20d

-- query IIIIII rowsort x818
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d-e,
       abs(b-c),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 6,4
;
-- 132 values hashing to 2fad9b201c26f61f51170e12cdacb20d

-- query IIIIIII rowsort x819
SELECT d-e,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
;
-- 210 values hashing to bad1bff3c68810098c882b1301d57d5b

-- query IIIIIII rowsort x819
SELECT d-e,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       a+b*2+c*3+d*4,
       abs(a)
  FROM t1
 ORDER BY 7,6,2,1,3,4
;
-- 210 values hashing to bad1bff3c68810098c882b1301d57d5b

-- query IIIII rowsort x820
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       abs(a),
       d
  FROM t1
;
-- 150 values hashing to a2c1f470369263777dccdd62b6cc58a3

-- query IIIII rowsort x820
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       abs(a),
       d
  FROM t1
 ORDER BY 1,2
;
-- 150 values hashing to a2c1f470369263777dccdd62b6cc58a3

-- query II rowsort x821
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 1050
-- 0
-- 1290
-- 3

-- query II rowsort x821
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 1050
-- 0
-- 1290
-- 3

-- query IIII rowsort x822
SELECT a,
       d-e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR c BETWEEN b-2 AND d+2
;
-- 96 values hashing to ec09cfec9014af043b24a1141a68712f

-- query IIII rowsort x822
SELECT a,
       d-e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b>c
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 96 values hashing to ec09cfec9014af043b24a1141a68712f

-- query IIII rowsort x822
SELECT a,
       d-e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR (c<=d-2 OR c>=d+2)
;
-- 96 values hashing to ec09cfec9014af043b24a1141a68712f

-- query IIII rowsort x822
SELECT a,
       d-e,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b>c
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,4
;
-- 96 values hashing to ec09cfec9014af043b24a1141a68712f

-- query IIIIII rowsort x823
SELECT e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
;
-- 180 values hashing to 2f7e45662cd1d11b127086683f18509a

-- query IIIIII rowsort x823
SELECT e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 ORDER BY 1,3,5,6,4,2
;
-- 180 values hashing to 2f7e45662cd1d11b127086683f18509a

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
 ORDER BY 1
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query I rowsort x824
SELECT a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 9 values hashing to 0f7c2e78d7bf193feb4afa3397bfc48b

-- query III rowsort x825
SELECT a+b*2+c*3,
       a+b*2,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to 44d9cfffe4b77b006619cdc7b5f56f76

-- query III rowsort x825
SELECT a+b*2+c*3,
       a+b*2,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 2,1,3
;
-- 24 values hashing to 44d9cfffe4b77b006619cdc7b5f56f76

-- query IIIIIII rowsort x826
SELECT d-e,
       d,
       a+b*2,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       e
  FROM t1
 WHERE a>b
;
-- 119 values hashing to b5a3a414af9dfc13a52235ebb2e2a5cd

-- query IIIIIII rowsort x826
SELECT d-e,
       d,
       a+b*2,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       e
  FROM t1
 WHERE a>b
 ORDER BY 1,5,7,6,4,3
;
-- 119 values hashing to b5a3a414af9dfc13a52235ebb2e2a5cd

-- query III rowsort x827
SELECT a,
       d-e,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 51 values hashing to da371f3bfca30ba9e03f2c8a0a03051d

-- query III rowsort x827
SELECT a,
       d-e,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 2,1,3
;
-- 51 values hashing to da371f3bfca30ba9e03f2c8a0a03051d

-- query I rowsort x828
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
;
-- 15 values hashing to 7b91d490207e5d46d4cdedd249b0649a

-- query I rowsort x828
SELECT e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
 ORDER BY 1
;
-- 15 values hashing to 7b91d490207e5d46d4cdedd249b0649a

-- query I rowsort x828
SELECT e
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
;
-- 15 values hashing to 7b91d490207e5d46d4cdedd249b0649a

-- query I rowsort x828
SELECT e
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
 ORDER BY 1
;
-- 15 values hashing to 7b91d490207e5d46d4cdedd249b0649a

-- query IIIII rowsort x829
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE d>e
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 1290
-- 3
-- 1272
-- 1902
-- -2

-- query IIIII rowsort x829
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE d>e
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,4
;
-- 1290
-- 3
-- 1272
-- 1902
-- -2

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,5,3,1,4,6
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 5,1,6,2
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR (e>a AND e<b)
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 2,3,4,1,5
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x830
SELECT d,
       a+b*2,
       abs(a),
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
 ORDER BY 3,4,1,5
;
-- 78 values hashing to 42734ac27e5bd09a22c811113ba2cd6e

-- query IIIIII rowsort x831
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       abs(b-c),
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 180 values hashing to 8bb12c7cd5b4f87c7f4c64ddde4f7633

-- query IIIIII rowsort x831
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       abs(b-c),
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 6,4,2,5
;
-- 180 values hashing to 8bb12c7cd5b4f87c7f4c64ddde4f7633

-- query IIIIIII rowsort x832
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3,
       abs(b-c),
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
;
-- 154 values hashing to 9ad59033307ede2ebfba5c59c8379741

-- query IIIIIII rowsort x832
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3,
       abs(b-c),
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 4,6,5,3
;
-- 154 values hashing to 9ad59033307ede2ebfba5c59c8379741

-- query IIIIII rowsort x833
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       a+b*2+c*3,
       a+b*2,
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 18 values hashing to 67d527ba69854a5db8f6f51bd5f14f91

-- query IIIIII rowsort x833
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       a+b*2+c*3,
       a+b*2,
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 1,5,4,6
;
-- 18 values hashing to 67d527ba69854a5db8f6f51bd5f14f91

-- query IIIIII rowsort x833
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       a+b*2+c*3,
       a+b*2,
       e
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 18 values hashing to 67d527ba69854a5db8f6f51bd5f14f91

-- query IIIIII rowsort x833
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       d-e,
       a+b*2+c*3,
       a+b*2,
       e
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 6,1,2
;
-- 18 values hashing to 67d527ba69854a5db8f6f51bd5f14f91

-- query IIIIIII rowsort x834
SELECT b-c,
       e,
       d,
       abs(a),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 210 values hashing to 177a4f862e7e470622e4e575024da470

-- query IIIIIII rowsort x834
SELECT b-c,
       e,
       d,
       abs(a),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,6,5,2,3,7
;
-- 210 values hashing to 177a4f862e7e470622e4e575024da470

-- query IIIII rowsort x835
SELECT a,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to 526f5f5d9210eea0fcec55deb9e8f8e0

-- query IIIII rowsort x835
SELECT a,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,5,1,4,3
;
-- 130 values hashing to 526f5f5d9210eea0fcec55deb9e8f8e0

-- query IIIIII rowsort x836
SELECT b-c,
       b,
       a-b,
       c-d,
       d-e,
       e
  FROM t1
 WHERE b>c
;
-- 78 values hashing to edbe7006d53a6726fff6226000ae6c1c

-- query IIIIII rowsort x836
SELECT b-c,
       b,
       a-b,
       c-d,
       d-e,
       e
  FROM t1
 WHERE b>c
 ORDER BY 3,1,4,2,6,5
;
-- 78 values hashing to edbe7006d53a6726fff6226000ae6c1c

-- query II rowsort x837
SELECT abs(a),
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
;
-- 12 values hashing to 66f5b8188cd6c0e53ad39ec35e860eb6

-- query II rowsort x837
SELECT abs(a),
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 1,2
;
-- 12 values hashing to 66f5b8188cd6c0e53ad39ec35e860eb6

-- query II rowsort x837
SELECT abs(a),
       d-e
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
;
-- 12 values hashing to 66f5b8188cd6c0e53ad39ec35e860eb6

-- query II rowsort x837
SELECT abs(a),
       d-e
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 12 values hashing to 66f5b8188cd6c0e53ad39ec35e860eb6

-- query II rowsort x838
SELECT a,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
;
-- 191
-- 1
-- 220
-- -1
-- 245
-- 2

-- query II rowsort x838
SELECT a,
       b-c
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,1
;
-- 191
-- 1
-- 220
-- -1
-- 245
-- 2

-- query IIIIIII rowsort x839
SELECT a+b*2+c*3+d*4,
       abs(a),
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 210 values hashing to 192cee60e1f03daaf68361cb90ded9ad

-- query IIIIIII rowsort x839
SELECT a+b*2+c*3+d*4,
       abs(a),
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 2,1,6
;
-- 210 values hashing to 192cee60e1f03daaf68361cb90ded9ad

-- query II rowsort x840
SELECT a+b*2+c*3+d*4,
       b-c
  FROM t1
;
-- 60 values hashing to a8239bce4eec88df9ceb22456031d216

-- query II rowsort x840
SELECT a+b*2+c*3+d*4,
       b-c
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to a8239bce4eec88df9ceb22456031d216

-- query III rowsort x841
SELECT a,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 48 values hashing to 20e788da0b60b5e1993a4e655c3315e0

-- query III rowsort x841
SELECT a,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 48 values hashing to 20e788da0b60b5e1993a4e655c3315e0

-- query IIIIIII rowsort x842
SELECT a,
       a+b*2+c*3+d*4+e*5,
       d-e,
       b-c,
       abs(a),
       a+b*2,
       b
  FROM t1
;
-- 210 values hashing to 3ad2c65f63be30349866521e8a7baaa8

-- query IIIIIII rowsort x842
SELECT a,
       a+b*2+c*3+d*4+e*5,
       d-e,
       b-c,
       abs(a),
       a+b*2,
       b
  FROM t1
 ORDER BY 4,2,3,6,1,5,7
;
-- 210 values hashing to 3ad2c65f63be30349866521e8a7baaa8

-- query IIIII rowsort x843
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 150 values hashing to f2a5512e772b96231a3fc7bedb283acf

-- query IIIII rowsort x843
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,1,3
;
-- 150 values hashing to f2a5512e772b96231a3fc7bedb283acf

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 2,3
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIII rowsort x844
SELECT a-b,
       e,
       c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,3,1,2
;
-- 76 values hashing to 74b9ca76cf42eeb436c8f3d99d5026a5

-- query IIIIII rowsort x845
SELECT d,
       a+b*2+c*3+d*4,
       e,
       (a+b+c+d+e)/5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 180 values hashing to 77659f5a8cded981ffc465c38deec76f

-- query IIIIII rowsort x845
SELECT d,
       a+b*2+c*3+d*4,
       e,
       (a+b+c+d+e)/5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 4,6,5,1,2,3
;
-- 180 values hashing to 77659f5a8cded981ffc465c38deec76f

-- query IIIII rowsort x846
SELECT abs(b-c),
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 WHERE b>c
;
-- 65 values hashing to 700b1ea08f8a70f8aca21e66948e013f

-- query IIIII rowsort x846
SELECT abs(b-c),
       abs(a),
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 WHERE b>c
 ORDER BY 4,1
;
-- 65 values hashing to 700b1ea08f8a70f8aca21e66948e013f

-- query IIIIIII rowsort x847
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       a-b,
       d,
       a+b*2+c*3
  FROM t1
;
-- 210 values hashing to abe084b1d76cf674445ef239229bbc0a

-- query IIIIIII rowsort x847
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       a-b,
       d,
       a+b*2+c*3
  FROM t1
 ORDER BY 4,3,5,6,2,7,1
;
-- 210 values hashing to abe084b1d76cf674445ef239229bbc0a

-- query IIIII rowsort x848
SELECT b-c,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
;
-- 150 values hashing to 5a6c64d4512cfeaa7e90ffd06d9955d0

-- query IIIII rowsort x848
SELECT b-c,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 ORDER BY 2,3,1,5
;
-- 150 values hashing to 5a6c64d4512cfeaa7e90ffd06d9955d0

-- query I rowsort x849
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 1272

-- query I rowsort x849
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 1272

-- query I rowsort x849
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;
-- 1272

-- query I rowsort x849
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 1272

-- query IIIIII rowsort x850
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
;
-- 18 values hashing to a1099ee03d2f261e66a0c7dfa6457b0d

-- query IIIIII rowsort x850
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 6,2
;
-- 18 values hashing to a1099ee03d2f261e66a0c7dfa6457b0d

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR d>e
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR d>e
 ORDER BY 2,3
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR (c<=d-2 OR c>=d+2)
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 3,4
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIIII rowsort x851
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
 ORDER BY 3,4,1
;
-- 96 values hashing to 9e505d055e1630da12139a6616c91e0f

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR d NOT BETWEEN 110 AND 150
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,3,2,5
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
 ORDER BY 4,3
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,3,1
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x852
SELECT b,
       d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4,5,1
;
-- 105 values hashing to 898b1396ba944fbd4d391be2eb9eceb9

-- query IIIII rowsort x853
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c>d
;
-- 65 values hashing to 55e12f994d85d5bb430f97aeb458f0ad

-- query IIIII rowsort x853
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c>d
 ORDER BY 3,2
;
-- 65 values hashing to 55e12f994d85d5bb430f97aeb458f0ad

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
 ORDER BY 1,5
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
 ORDER BY 4,3,2,5
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND d>e
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query IIIII rowsort x854
SELECT d,
       b-c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND d>e
 ORDER BY 5,3,4,1
;
-- 25 values hashing to efe072d229c48fafc64d6801a2353477

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR d>e
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR d>e
 ORDER BY 2,1
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR d NOT BETWEEN 110 AND 150
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query II rowsort x855
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d>e
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 46 values hashing to 3cc7fbe290b9c568f60dabcc1daa4652

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
;

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,4,3,5,2,7
;

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 2,1
;

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x856
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 6,3,4
;

-- query II rowsort x857
SELECT b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 34 values hashing to 96ff786483c1e8f5196446a2b1d422d9

-- query II rowsort x857
SELECT b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 2,1
;
-- 34 values hashing to 96ff786483c1e8f5196446a2b1d422d9

-- query IIII rowsort x858
SELECT abs(b-c),
       b-c,
       d,
       d-e
  FROM t1
;
-- 120 values hashing to 51c6d5875559232e01ec8492a13bf290

-- query IIII rowsort x858
SELECT abs(b-c),
       b-c,
       d,
       d-e
  FROM t1
 ORDER BY 2,1
;
-- 120 values hashing to 51c6d5875559232e01ec8492a13bf290

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND d>e
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND d>e
 ORDER BY 1,2
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query II rowsort x859
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 2,1
;
-- 127
-- 1290
-- 137
-- 1390
-- 232
-- 468
-- 247
-- 490

-- query I rowsort x860
SELECT a-b
  FROM t1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query I rowsort x860
SELECT a-b
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query II rowsort x861
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE c>d
    OR d>e
;
-- 38 values hashing to 2a2598769a3b3b10efdd6fbbbcdb5d91

-- query II rowsort x861
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE c>d
    OR d>e
 ORDER BY 1,2
;
-- 38 values hashing to 2a2598769a3b3b10efdd6fbbbcdb5d91

-- query II rowsort x861
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE d>e
    OR c>d
;
-- 38 values hashing to 2a2598769a3b3b10efdd6fbbbcdb5d91

-- query II rowsort x861
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE d>e
    OR c>d
 ORDER BY 2,1
;
-- 38 values hashing to 2a2598769a3b3b10efdd6fbbbcdb5d91

-- query II rowsort x862
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR (e>a AND e<b)
;
-- 46 values hashing to 9d04deef1dfca681b44e162ce4541cae

-- query II rowsort x862
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR (e>a AND e<b)
 ORDER BY 1,2
;
-- 46 values hashing to 9d04deef1dfca681b44e162ce4541cae

-- query II rowsort x862
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 46 values hashing to 9d04deef1dfca681b44e162ce4541cae

-- query II rowsort x862
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 46 values hashing to 9d04deef1dfca681b44e162ce4541cae

-- query II rowsort x863
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 60 values hashing to 062c0e56752ce88d0167d9e0fd0770d7

-- query II rowsort x863
SELECT abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 062c0e56752ce88d0167d9e0fd0770d7

-- query I rowsort x864
SELECT a-b
  FROM t1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query I rowsort x864
SELECT a-b
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query IIIIIII rowsort x865
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
;
-- 91 values hashing to 4cede8da66ea2861ef9c48cc1208662f

-- query IIIIIII rowsort x865
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 7,1,5
;
-- 91 values hashing to 4cede8da66ea2861ef9c48cc1208662f

-- query IIIIIII rowsort x865
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
;
-- 91 values hashing to 4cede8da66ea2861ef9c48cc1208662f

-- query IIIIIII rowsort x865
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
 ORDER BY 3,4,2,7,1,6
;
-- 91 values hashing to 4cede8da66ea2861ef9c48cc1208662f

-- query I rowsort x866
SELECT d-e
  FROM t1
 WHERE b>c
;
-- 13 values hashing to 37b4d73e441261c2486e2c599c1c89f1

-- query I rowsort x866
SELECT d-e
  FROM t1
 WHERE b>c
 ORDER BY 1
;
-- 13 values hashing to 37b4d73e441261c2486e2c599c1c89f1

-- query IIIII rowsort x867
SELECT abs(a),
       a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
;
-- 150 values hashing to 578a866d06ec2584773e3a7cd8378039

-- query IIIII rowsort x867
SELECT abs(a),
       a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 ORDER BY 1,3,2,4
;
-- 150 values hashing to 578a866d06ec2584773e3a7cd8378039

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,6,3
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND (e>c OR e<d)
 ORDER BY 2,6,3,1
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query IIIIIII rowsort x868
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       d-e,
       b,
       e
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 7,6,4,1
;
-- 21 values hashing to 3534198846c175bfee0fb8ea8a34b086

-- query II rowsort x869
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE c>d
    OR d>e
;
-- 38 values hashing to 38f3dc6640f3c6f990539ded2f42dd40

-- query II rowsort x869
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE c>d
    OR d>e
 ORDER BY 2,1
;
-- 38 values hashing to 38f3dc6640f3c6f990539ded2f42dd40

-- query II rowsort x869
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d>e
    OR c>d
;
-- 38 values hashing to 38f3dc6640f3c6f990539ded2f42dd40

-- query II rowsort x869
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d>e
    OR c>d
 ORDER BY 1,2
;
-- 38 values hashing to 38f3dc6640f3c6f990539ded2f42dd40

-- query III rowsort x870
SELECT b-c,
       abs(b-c),
       a+b*2
  FROM t1
;
-- 90 values hashing to daca262d1b7c5c84e7776454aeae28b6

-- query III rowsort x870
SELECT b-c,
       abs(b-c),
       a+b*2
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to daca262d1b7c5c84e7776454aeae28b6

-- query II rowsort x871
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 0
-- -1
-- 0
-- 2
-- 0
-- 3

-- query II rowsort x871
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,2
;
-- 0
-- -1
-- 0
-- 2
-- 0
-- 3

-- query II rowsort x871
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 0
-- -1
-- 0
-- 2
-- 0
-- 3

-- query II rowsort x871
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 1,2
;
-- 0
-- -1
-- 0
-- 2
-- 0
-- 3

-- query III rowsort x872
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       b
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 78 values hashing to f5793db3d840c263516ce377d0018549

-- query III rowsort x872
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       b
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1,3
;
-- 78 values hashing to f5793db3d840c263516ce377d0018549

-- query III rowsort x872
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
;
-- 78 values hashing to f5793db3d840c263516ce377d0018549

-- query III rowsort x872
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
 ORDER BY 2,1
;
-- 78 values hashing to f5793db3d840c263516ce377d0018549

-- query I rowsort x873
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
;
-- 14 values hashing to f97f357089334d125cef4f36f7735b7d

-- query I rowsort x873
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
 ORDER BY 1
;
-- 14 values hashing to f97f357089334d125cef4f36f7735b7d

-- query I rowsort x873
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
;
-- 14 values hashing to f97f357089334d125cef4f36f7735b7d

-- query I rowsort x873
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
    OR (e>a AND e<b)
 ORDER BY 1
;
-- 14 values hashing to f97f357089334d125cef4f36f7735b7d

-- query IIIIII rowsort x874
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       abs(b-c),
       c-d,
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 168 values hashing to 0e9151ef1fc0b9657f5d3f3cc3f6617d

-- query IIIIII rowsort x874
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       abs(b-c),
       c-d,
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 3,4,2,6,5
;
-- 168 values hashing to 0e9151ef1fc0b9657f5d3f3cc3f6617d

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>a AND e<b)
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>a AND e<b)
 ORDER BY 2,3,7,5,6,4
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 5,2
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x875
SELECT (a+b+c+d+e)/5,
       c-d,
       a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
 ORDER BY 4,5,1
;
-- 14 values hashing to 8b5e382e90ee04d96e67c5207bff60a3

-- query IIIIIII rowsort x876
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 210 values hashing to 50639da083e0dfcdd5c8e83a956b4426

-- query IIIIIII rowsort x876
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 4,5
;
-- 210 values hashing to 50639da083e0dfcdd5c8e83a956b4426

-- query IIIII rowsort x877
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
;
-- 35 values hashing to f68c064171813788a6cf94f0b90aff35

-- query IIIII rowsort x877
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
 ORDER BY 4,5,3,2
;
-- 35 values hashing to f68c064171813788a6cf94f0b90aff35

-- query IIIII rowsort x877
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 35 values hashing to f68c064171813788a6cf94f0b90aff35

-- query IIIII rowsort x877
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 5,2,4,1
;
-- 35 values hashing to f68c064171813788a6cf94f0b90aff35

-- query II rowsort x878
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
;
-- 60 values hashing to 786e944a9c358a8be09160a4fcdb486f

-- query II rowsort x878
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 786e944a9c358a8be09160a4fcdb486f

-- query II rowsort x879
SELECT abs(a),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 20 values hashing to 98d73ad45f8f620db8c8c9b4aeb68ec6

-- query II rowsort x879
SELECT abs(a),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 20 values hashing to 98d73ad45f8f620db8c8c9b4aeb68ec6

-- query II rowsort x879
SELECT abs(a),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
;
-- 20 values hashing to 98d73ad45f8f620db8c8c9b4aeb68ec6

-- query II rowsort x879
SELECT abs(a),
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 20 values hashing to 98d73ad45f8f620db8c8c9b4aeb68ec6

-- query III rowsort x880
SELECT e,
       a,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 109
-- 107
-- 2
-- 126
-- 127
-- -2

-- query III rowsort x880
SELECT e,
       a,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,2,1
;
-- 109
-- 107
-- 2
-- 126
-- 127
-- -2

-- query II rowsort x881
SELECT a-b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
;
-- -3
-- 666
-- -4
-- 743

-- query II rowsort x881
SELECT a-b,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
 ORDER BY 2,1
;
-- -3
-- 666
-- -4
-- 743

-- query II rowsort x881
SELECT a-b,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
;
-- -3
-- 666
-- -4
-- 743

-- query II rowsort x881
SELECT a-b,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- -3
-- 666
-- -4
-- 743

-- query I rowsort x882
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query I rowsort x882
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query IIIIII rowsort x883
SELECT a+b*2+c*3+d*4,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
;
-- 180 values hashing to 42336e6173780b5bf485e01d7ad7e2d6

-- query IIIIII rowsort x883
SELECT a+b*2+c*3+d*4,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 ORDER BY 2,1,4
;
-- 180 values hashing to 42336e6173780b5bf485e01d7ad7e2d6

-- query I rowsort x884
SELECT e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 26 values hashing to cfc94af2318f3af5d1c269b640dee05c

-- query I rowsort x884
SELECT e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 26 values hashing to cfc94af2318f3af5d1c269b640dee05c

-- query IIII rowsort x885
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a
  FROM t1
;
-- 120 values hashing to fe89e0694e565ddde146aae161a10d93

-- query IIII rowsort x885
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a
  FROM t1
 ORDER BY 2,1,3
;
-- 120 values hashing to fe89e0694e565ddde146aae161a10d93

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4,2,3
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
 ORDER BY 4,2,3
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query IIII rowsort x886
SELECT d,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
 ORDER BY 1,4,2,3
;
-- 52 values hashing to 6779ef1c86798a0a3109a0c1b0c8180a

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR c>d
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR c>d
 ORDER BY 1,2
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR (e>c OR e<d)
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
    OR (e>c OR e<d)
 ORDER BY 1,2
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,2,1
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR (a>b-2 AND a<b+2)
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x887
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
    OR (a>b-2 AND a<b+2)
 ORDER BY 2,1
;
-- 81 values hashing to c79f665e7971df459923fc66824c7e23

-- query III rowsort x888
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE d>e
;
-- 33 values hashing to 842ca7ca664eef175a333bdc30730d09

-- query III rowsort x888
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
 WHERE d>e
 ORDER BY 2,1
;
-- 33 values hashing to 842ca7ca664eef175a333bdc30730d09

-- query IIIII rowsort x889
SELECT a,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
;
-- 35 values hashing to 94dcb6f7f5a353dfa833f9d433031a2b

-- query IIIII rowsort x889
SELECT a,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
 ORDER BY 4,3
;
-- 35 values hashing to 94dcb6f7f5a353dfa833f9d433031a2b

-- query IIIII rowsort x889
SELECT a,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
;
-- 35 values hashing to 94dcb6f7f5a353dfa833f9d433031a2b

-- query IIIII rowsort x889
SELECT a,
       abs(b-c),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,4,5
;
-- 35 values hashing to 94dcb6f7f5a353dfa833f9d433031a2b

-- query IIIII rowsort x890
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       a,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 5e8123b381f22a7420674f7b7ec697f9

-- query IIIII rowsort x890
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       a,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3,4,5,2
;
-- 10 values hashing to 5e8123b381f22a7420674f7b7ec697f9

-- query II rowsort x891
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
;
-- 26 values hashing to 7fd49e95ee3c9c5ebd63030470d8b287

-- query II rowsort x891
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
 ORDER BY 1,2
;
-- 26 values hashing to 7fd49e95ee3c9c5ebd63030470d8b287

-- query IIIII rowsort x892
SELECT a-b,
       b-c,
       d,
       abs(b-c),
       e
  FROM t1
 WHERE (e>a AND e<b)
;
-- 15 values hashing to e39b01b20ef9540b9be9916e3b31112a

-- query IIIII rowsort x892
SELECT a-b,
       b-c,
       d,
       abs(b-c),
       e
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 5,1
;
-- 15 values hashing to e39b01b20ef9540b9be9916e3b31112a

-- query III rowsort x893
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       a+b*2+c*3
  FROM t1
;
-- 90 values hashing to 79a58ab06f4154a5fd7bd890a842407d

-- query III rowsort x893
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       a+b*2+c*3
  FROM t1
 ORDER BY 1,3,2
;
-- 90 values hashing to 79a58ab06f4154a5fd7bd890a842407d

-- query IIIIIII rowsort x894
SELECT d,
       b-c,
       abs(a),
       c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c
  FROM t1
;
-- 210 values hashing to 62f70022f80e2aa8043d7b5a66b9ef24

-- query IIIIIII rowsort x894
SELECT d,
       b-c,
       abs(a),
       c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c
  FROM t1
 ORDER BY 2,7,5,1,4
;
-- 210 values hashing to 62f70022f80e2aa8043d7b5a66b9ef24

-- query IIIIIII rowsort x895
SELECT b-c,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
;
-- 77 values hashing to 43cba760bf35fce24ea8939d5b17b80e

-- query IIIIIII rowsort x895
SELECT b-c,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
 ORDER BY 2,7,4,3,6
;
-- 77 values hashing to 43cba760bf35fce24ea8939d5b17b80e

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
 ORDER BY 1
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 1
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
;
-- 222
-- 222
-- 333
-- 333

-- query I rowsort x896
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 222
-- 222
-- 333
-- 333

-- query IIII rowsort x897
SELECT abs(b-c),
       c,
       e,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
;

-- query IIII rowsort x897
SELECT abs(b-c),
       c,
       e,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
 ORDER BY 3,4,1,2
;

-- query IIII rowsort x898
SELECT b-c,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c)
  FROM t1
;
-- 120 values hashing to 24ab9384165a923dfb2a68fff58af0ad

-- query IIII rowsort x898
SELECT b-c,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c)
  FROM t1
 ORDER BY 2,4,1,3
;
-- 120 values hashing to 24ab9384165a923dfb2a68fff58af0ad

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
 ORDER BY 3,2
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND b>c
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 1,3
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIII rowsort x899
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND b>c
 ORDER BY 2,4,1,3
;
-- 2
-- 111
-- 827
-- -1
-- 2
-- 111
-- 851
-- -1

-- query IIIII rowsort x900
SELECT a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 75 values hashing to 264015368b7e2d3ef40b19554f289c91

-- query IIIII rowsort x900
SELECT a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 4,3,5,1,2
;
-- 75 values hashing to 264015368b7e2d3ef40b19554f289c91

-- query I rowsort x901
SELECT d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query I rowsort x901
SELECT d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 1
;

-- query I rowsort x901
SELECT d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query I rowsort x901
SELECT d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;

-- query III rowsort x902
SELECT a,
       abs(b-c),
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 107
-- 1
-- 106
-- 127
-- 4
-- 125

-- query III rowsort x902
SELECT a,
       abs(b-c),
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,1
;
-- 107
-- 1
-- 106
-- 127
-- 4
-- 125

-- query I rowsort x903
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
;
-- 30 values hashing to 9589cc1f14474dd0aa42c579d2bfedb1

-- query I rowsort x903
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 9589cc1f14474dd0aa42c579d2bfedb1

-- query II rowsort x904
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
;
-- 44 values hashing to 1cd54d7fbd0a6f17f2992fab04d0df36

-- query II rowsort x904
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
 ORDER BY 2,1
;
-- 44 values hashing to 1cd54d7fbd0a6f17f2992fab04d0df36

-- query II rowsort x905
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 30 values hashing to 5951da2724242112ec0cd6e310f71fda

-- query II rowsort x905
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 1,2
;
-- 30 values hashing to 5951da2724242112ec0cd6e310f71fda

-- query I rowsort x906
SELECT a+b*2+c*3+d*4
  FROM t1
;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query I rowsort x906
SELECT a+b*2+c*3+d*4
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR a>b
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
    OR a>b
 ORDER BY 3,5,2
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR c>d
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR c>d
 ORDER BY 4,3,2,5,1
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 5,1
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR a>b
    OR d NOT BETWEEN 110 AND 150
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIII rowsort x907
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       d-e,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR a>b
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 3,1,2,5
;
-- 140 values hashing to 4e028439887eb00b53e88ff660e4f6df

-- query IIIIIII rowsort x908
SELECT b,
       b-c,
       a-b,
       e,
       c-d,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
;
-- 91 values hashing to 61af2b3e6246e6c0b52d25fa685fba31

-- query IIIIIII rowsort x908
SELECT b,
       b-c,
       a-b,
       e,
       c-d,
       a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
 ORDER BY 3,1,2,7,5,6
;
-- 91 values hashing to 61af2b3e6246e6c0b52d25fa685fba31

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 2,3
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND a>b
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,1
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
   AND a>b
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
   AND a>b
 ORDER BY 1,3,2
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND (e>a AND e<b)
;

-- query III rowsort x909
SELECT b-c,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND (e>a AND e<b)
 ORDER BY 2,3
;

-- query IIIII rowsort x910
SELECT a-b,
       a+b*2+c*3+d*4,
       a+b*2,
       b,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 130 values hashing to 2588c8de78321484611a50f063942e51

-- query IIIII rowsort x910
SELECT a-b,
       a+b*2+c*3+d*4,
       a+b*2,
       b,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 1,4,2,3
;
-- 130 values hashing to 2588c8de78321484611a50f063942e51

-- query IIIII rowsort x911
SELECT c,
       abs(b-c),
       b,
       (a+b+c+d+e)/5,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
;
-- 105 values hashing to 12d7571bf63f56fd60fc953c549c4576

-- query IIIII rowsort x911
SELECT c,
       abs(b-c),
       b,
       (a+b+c+d+e)/5,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
 ORDER BY 1,5
;
-- 105 values hashing to 12d7571bf63f56fd60fc953c549c4576

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
;
-- 579
-- 1
-- 666
-- 1

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
   AND c>d
 ORDER BY 2,1
;
-- 579
-- 1
-- 666
-- 1

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
;
-- 579
-- 1
-- 666
-- 1

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 579
-- 1
-- 666
-- 1

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
;
-- 579
-- 1
-- 666
-- 1

-- query II rowsort x912
SELECT a+b*2,
       abs(b-c)
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
 ORDER BY 2,1
;
-- 579
-- 1
-- 666
-- 1

-- query I rowsort x913
SELECT (a+b+c+d+e)/5
  FROM t1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query I rowsort x913
SELECT (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query IIIIIII rowsort x914
SELECT a+b*2+c*3+d*4,
       a-b,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
;
-- 42 values hashing to 9fc3445db9f74014fa1b0ad2c6bef7a0

-- query IIIIIII rowsort x914
SELECT a+b*2+c*3+d*4,
       a-b,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
 ORDER BY 6,7,1,3
;
-- 42 values hashing to 9fc3445db9f74014fa1b0ad2c6bef7a0

-- query I rowsort x915
SELECT a+b*2+c*3
  FROM t1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query I rowsort x915
SELECT a+b*2+c*3
  FROM t1
 ORDER BY 1
;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
    OR d>e
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
    OR d>e
 ORDER BY 1,2
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR c>d
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR c>d
 ORDER BY 2,1
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query II rowsort x916
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
    OR d>e
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,2
;
-- 40 values hashing to a4eb0104d41af22e42996fc476790ecb

-- query IIII rowsort x917
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 222
-- 127
-- 2
-- 1902
-- 333
-- 107
-- -1
-- 1612

-- query IIII rowsort x917
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,3
;
-- 222
-- 127
-- 2
-- 1902
-- 333
-- 107
-- -1
-- 1612

-- query III rowsort x918
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
;
-- 12 values hashing to 1035deb2c40a4b7e0f266141df5c98a3

-- query III rowsort x918
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
 ORDER BY 3,1,2
;
-- 12 values hashing to 1035deb2c40a4b7e0f266141df5c98a3

-- query III rowsort x918
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c>d
;
-- 12 values hashing to 1035deb2c40a4b7e0f266141df5c98a3

-- query III rowsort x918
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c>d
 ORDER BY 3,1
;
-- 12 values hashing to 1035deb2c40a4b7e0f266141df5c98a3

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND c>d
   AND (c<=d-2 OR c>=d+2)
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND c>d
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 3,4,2
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND c>d
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND c>d
 ORDER BY 2,4,3
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
   AND c>d
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
   AND c>d
 ORDER BY 4,2,1,3
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
   AND a>b
   AND (c<=d-2 OR c>=d+2)
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query IIII rowsort x919
SELECT b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
   AND a>b
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,4,3,2
;
-- 186
-- 2806
-- 0
-- 376
-- 211
-- 3175
-- 0
-- 426

-- query III rowsort x920
SELECT a-b,
       c,
       a+b*2
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
;
-- 27 values hashing to 70241e09ff2d5961d8dcfc8d2b3bfe57

-- query III rowsort x920
SELECT a-b,
       c,
       a+b*2
  FROM t1
 WHERE b>c
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>c OR e<d)
 ORDER BY 1,3,2
;
-- 27 values hashing to 70241e09ff2d5961d8dcfc8d2b3bfe57

-- query III rowsort x920
SELECT a-b,
       c,
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
;
-- 27 values hashing to 70241e09ff2d5961d8dcfc8d2b3bfe57

-- query III rowsort x920
SELECT a-b,
       c,
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
 ORDER BY 3,2
;
-- 27 values hashing to 70241e09ff2d5961d8dcfc8d2b3bfe57

-- query IIIIII rowsort x921
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 90 values hashing to 711c5520c1c6aed361fe5801ea593a6b

-- query IIIIII rowsort x921
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 5,3
;
-- 90 values hashing to 711c5520c1c6aed361fe5801ea593a6b

-- query IIIII rowsort x922
SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(b-c),
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 150 values hashing to ccd08e2cecb428df2a757b68bf4a0866

-- query IIIII rowsort x922
SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       abs(b-c),
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 2,5,1,3,4
;
-- 150 values hashing to ccd08e2cecb428df2a757b68bf4a0866

-- query III rowsort x923
SELECT (a+b+c+d+e)/5,
       e,
       c
  FROM t1
;
-- 90 values hashing to 9efd3afc3390d993ad116337cbd5ab05

-- query III rowsort x923
SELECT (a+b+c+d+e)/5,
       e,
       c
  FROM t1
 ORDER BY 2,3
;
-- 90 values hashing to 9efd3afc3390d993ad116337cbd5ab05

-- query IIII rowsort x924
SELECT d,
       abs(b-c),
       b,
       b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
;
-- 68 values hashing to 8050cded0b9f193897a5e53499364ff9

-- query IIII rowsort x924
SELECT d,
       abs(b-c),
       b,
       b-c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
 ORDER BY 2,4
;
-- 68 values hashing to 8050cded0b9f193897a5e53499364ff9

-- query IIIIII rowsort x925
SELECT b,
       a+b*2,
       a+b*2+c*3,
       e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
;
-- 54 values hashing to 5708005ac18e323809f647804000a6c1

-- query IIIIII rowsort x925
SELECT b,
       a+b*2,
       a+b*2+c*3,
       e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
 ORDER BY 5,6,3,1,2
;
-- 54 values hashing to 5708005ac18e323809f647804000a6c1

-- query IIIIII rowsort x925
SELECT b,
       a+b*2,
       a+b*2+c*3,
       e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
;
-- 54 values hashing to 5708005ac18e323809f647804000a6c1

-- query IIIIII rowsort x925
SELECT b,
       a+b*2,
       a+b*2+c*3,
       e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,6,1,2,4,5
;
-- 54 values hashing to 5708005ac18e323809f647804000a6c1

-- query IIIIIII rowsort x926
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIIIII rowsort x926
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,2,5,3,7,1,6
;

-- query IIIIIII rowsort x926
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
;

-- query IIIIIII rowsort x926
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       abs(b-c),
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2,7,6
;

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
   AND a>b
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
   AND a>b
 ORDER BY 2,1
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
 ORDER BY 2,1
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND (a>b-2 AND a<b+2)
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query III rowsort x927
SELECT abs(a),
       a+b*2,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 18 values hashing to 60b7c84682b5d4d47d5bebed31838dbe

-- query IIII rowsort x928
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
;
-- 72 values hashing to 1d3de673e0723bd762f36310f29d99af

-- query IIII rowsort x928
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
 ORDER BY 4,1
;
-- 72 values hashing to 1d3de673e0723bd762f36310f29d99af

-- query IIII rowsort x928
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
;
-- 72 values hashing to 1d3de673e0723bd762f36310f29d99af

-- query IIII rowsort x928
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
 ORDER BY 4,2,3
;
-- 72 values hashing to 1d3de673e0723bd762f36310f29d99af

-- query IIIIII rowsort x929
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 18 values hashing to 94fe2288f1f9c586bb533ea232753edd

-- query IIIIII rowsort x929
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>a AND e<b)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 6,4,3
;
-- 18 values hashing to 94fe2288f1f9c586bb533ea232753edd

-- query IIIIII rowsort x929
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
;
-- 18 values hashing to 94fe2288f1f9c586bb533ea232753edd

-- query IIIIII rowsort x929
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
 ORDER BY 3,2
;
-- 18 values hashing to 94fe2288f1f9c586bb533ea232753edd

-- query II rowsort x930
SELECT b,
       d-e
  FROM t1
;
-- 60 values hashing to 9f924d68846b18f44c1dd24867e65aa2

-- query II rowsort x930
SELECT b,
       d-e
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 9f924d68846b18f44c1dd24867e65aa2

-- query III rowsort x931
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 9 values hashing to 105a1fed23ff72661f4b6348cd2ce5a8

-- query III rowsort x931
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,2,1
;
-- 9 values hashing to 105a1fed23ff72661f4b6348cd2ce5a8

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE c>d
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 6,1,2
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>c OR e<d)
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND (e>c OR e<d)
 ORDER BY 6,4,3,5,7
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
   AND c>d
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIIII rowsort x932
SELECT (a+b+c+d+e)/5,
       e,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
   AND c>d
 ORDER BY 4,5,3,1
;
-- 21 values hashing to a8129edd377d312f8163e2f45600237e

-- query IIIIII rowsort x933
SELECT b-c,
       d-e,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 60 values hashing to 5ef0b993601e70b2f826cc8584a5d9fd

-- query IIIIII rowsort x933
SELECT b-c,
       d-e,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 3,5,6,4,2
;
-- 60 values hashing to 5ef0b993601e70b2f826cc8584a5d9fd

-- query II rowsort x934
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND a>b
;
-- 10 values hashing to 4696c13474a735611a80cd1ca030dd8c

-- query II rowsort x934
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND a>b
 ORDER BY 2,1
;
-- 10 values hashing to 4696c13474a735611a80cd1ca030dd8c

-- query II rowsort x934
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND c>d
;
-- 10 values hashing to 4696c13474a735611a80cd1ca030dd8c

-- query II rowsort x934
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
   AND c>d
 ORDER BY 1,2
;
-- 10 values hashing to 4696c13474a735611a80cd1ca030dd8c

-- query IIII rowsort x935
SELECT a+b*2+c*3+d*4+e*5,
       c,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
;
-- 20 values hashing to c5d849859f6eca128c22635ba6c3cb04

-- query IIII rowsort x935
SELECT a+b*2+c*3+d*4+e*5,
       c,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,2,1
;
-- 20 values hashing to c5d849859f6eca128c22635ba6c3cb04

-- query IIII rowsort x935
SELECT a+b*2+c*3+d*4+e*5,
       c,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
;
-- 20 values hashing to c5d849859f6eca128c22635ba6c3cb04

-- query IIII rowsort x935
SELECT a+b*2+c*3+d*4+e*5,
       c,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 4,3,1,2
;
-- 20 values hashing to c5d849859f6eca128c22635ba6c3cb04

-- query I rowsort x936
SELECT b-c
  FROM t1
 WHERE a>b
;
-- 17 values hashing to acc51927d4c550f3c05c306b7914158e

-- query I rowsort x936
SELECT b-c
  FROM t1
 WHERE a>b
 ORDER BY 1
;
-- 17 values hashing to acc51927d4c550f3c05c306b7914158e

-- query IIIIIII rowsort x937
SELECT abs(a),
       b,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
;
-- 49 values hashing to 77efab7a5ab568021241d73b49ff1a6b

-- query IIIIIII rowsort x937
SELECT abs(a),
       b,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 WHERE d>e
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 3,6,4,5,2,7
;
-- 49 values hashing to 77efab7a5ab568021241d73b49ff1a6b

-- query IIIII rowsort x938
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2,
       c-d
  FROM t1
 WHERE c>d
   AND b>c
;
-- 20 values hashing to 1939e130cceab074419ddaf68a054d49

-- query IIIII rowsort x938
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2,
       c-d
  FROM t1
 WHERE c>d
   AND b>c
 ORDER BY 1,4,5,3
;
-- 20 values hashing to 1939e130cceab074419ddaf68a054d49

-- query IIIII rowsort x938
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2,
       c-d
  FROM t1
 WHERE b>c
   AND c>d
;
-- 20 values hashing to 1939e130cceab074419ddaf68a054d49

-- query IIIII rowsort x938
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a,
       a+b*2,
       c-d
  FROM t1
 WHERE b>c
   AND c>d
 ORDER BY 1,2
;
-- 20 values hashing to 1939e130cceab074419ddaf68a054d49

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
;

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
 ORDER BY 1
;

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND c>d
;

-- query I rowsort x939
SELECT a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 1
;

-- query II rowsort x940
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
;
-- 60 values hashing to 1eff7d96438eb491cb4de14a09c1cccf

-- query II rowsort x940
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 1eff7d96438eb491cb4de14a09c1cccf

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND (e>c OR e<d)
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b>c
   AND (e>c OR e<d)
 ORDER BY 3,4
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
 ORDER BY 2,3
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIII rowsort x941
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND (c<=d-2 OR c>=d+2)
   AND b>c
 ORDER BY 4,3,1
;
-- 12 values hashing to 454c51d20bd07dcb7b5c6f56fb27e95e

-- query IIIII rowsort x942
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE b>c
;
-- 65 values hashing to d9a717bcbc137be38ba100402163ea40

-- query IIIII rowsort x942
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE b>c
 ORDER BY 3,2,4,5,1
;
-- 65 values hashing to d9a717bcbc137be38ba100402163ea40

-- query IIIIIII rowsort x943
SELECT abs(a),
       a+b*2,
       b,
       d,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
;
-- 133 values hashing to d3c64f57fd93d0c41302271d82a32244

-- query IIIIIII rowsort x943
SELECT abs(a),
       a+b*2,
       b,
       d,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a>b
 ORDER BY 1,4,7
;
-- 133 values hashing to d3c64f57fd93d0c41302271d82a32244

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE a>b
   AND c>d
   AND d NOT BETWEEN 110 AND 150
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE a>b
   AND c>d
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,3
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND c>d
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE a>b
   AND d NOT BETWEEN 110 AND 150
   AND c>d
 ORDER BY 2,4,3
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE c>d
   AND d NOT BETWEEN 110 AND 150
   AND a>b
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x944
SELECT a+b*2+c*3+d*4,
       a-b,
       e,
       abs(a),
       c
  FROM t1
 WHERE c>d
   AND d NOT BETWEEN 110 AND 150
   AND a>b
 ORDER BY 4,3
;
-- 20 values hashing to 52f547bc6b572a943b06156e2dc9c3a3

-- query IIIII rowsort x945
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to f38e7043ef57f1185447d10b1686710d

-- query IIIII rowsort x945
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1,4
;
-- 10 values hashing to f38e7043ef57f1185447d10b1686710d

-- query IIII rowsort x946
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a-b
  FROM t1
 WHERE b>c
    OR a>b
;
-- 96 values hashing to 7ac23eaaab8b15588342ee58c7bd324d

-- query IIII rowsort x946
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a-b
  FROM t1
 WHERE b>c
    OR a>b
 ORDER BY 1,3,2
;
-- 96 values hashing to 7ac23eaaab8b15588342ee58c7bd324d

-- query IIIIII rowsort x947
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       a-b
  FROM t1
;
-- 180 values hashing to cf199af6d194ce491525b6982e5b855b

-- query IIIIII rowsort x947
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       a-b
  FROM t1
 ORDER BY 4,1,2,5,6
;
-- 180 values hashing to cf199af6d194ce491525b6982e5b855b

-- query II rowsort x948
SELECT a,
       d
  FROM t1
 WHERE d>e
    OR b>c
;
-- 40 values hashing to 225faa916990f35159a64c72d7e3d503

-- query II rowsort x948
SELECT a,
       d
  FROM t1
 WHERE d>e
    OR b>c
 ORDER BY 2,1
;
-- 40 values hashing to 225faa916990f35159a64c72d7e3d503

-- query II rowsort x948
SELECT a,
       d
  FROM t1
 WHERE b>c
    OR d>e
;
-- 40 values hashing to 225faa916990f35159a64c72d7e3d503

-- query II rowsort x948
SELECT a,
       d
  FROM t1
 WHERE b>c
    OR d>e
 ORDER BY 2,1
;
-- 40 values hashing to 225faa916990f35159a64c72d7e3d503

-- query I rowsort x949
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
;
-- 13 values hashing to 29a95fdf6a51f4043cf4a3d5d20f5b95

-- query I rowsort x949
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
 ORDER BY 1
;
-- 13 values hashing to 29a95fdf6a51f4043cf4a3d5d20f5b95

-- query III rowsort x950
SELECT b,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND c>d
;
-- 9 values hashing to bb157abd6674aba4aa42b6355a973ede

-- query III rowsort x950
SELECT b,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND c BETWEEN b-2 AND d+2
   AND c>d
 ORDER BY 3,1
;
-- 9 values hashing to bb157abd6674aba4aa42b6355a973ede

-- query III rowsort x950
SELECT b,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to bb157abd6674aba4aa42b6355a973ede

-- query III rowsort x950
SELECT b,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,3
;
-- 9 values hashing to bb157abd6674aba4aa42b6355a973ede

-- query IIIII rowsort x951
SELECT a-b,
       a,
       b-c,
       b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c>d
;
-- 110 values hashing to 2f823f29deac7f8f8152cc3004e55137

-- query IIIII rowsort x951
SELECT a-b,
       a,
       b-c,
       b,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c>d
 ORDER BY 2,1,5,4
;
-- 110 values hashing to 2f823f29deac7f8f8152cc3004e55137

-- query IIIII rowsort x951
SELECT a-b,
       a,
       b-c,
       b,
       e
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
;
-- 110 values hashing to 2f823f29deac7f8f8152cc3004e55137

-- query IIIII rowsort x951
SELECT a-b,
       a,
       b-c,
       b,
       e
  FROM t1
 WHERE c>d
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1,2
;
-- 110 values hashing to 2f823f29deac7f8f8152cc3004e55137

-- query I rowsort x952
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 21 values hashing to 928f7d1962563aaad6047043e90ef523

-- query I rowsort x952
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 1
;
-- 21 values hashing to 928f7d1962563aaad6047043e90ef523

-- query I rowsort x952
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
;
-- 21 values hashing to 928f7d1962563aaad6047043e90ef523

-- query I rowsort x952
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 21 values hashing to 928f7d1962563aaad6047043e90ef523

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
 ORDER BY 1,7,5,4,2,3
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,7,4,1,5
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIIIII rowsort x953
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 5,7,6
;
-- 77 values hashing to aade56ce4d6e49c7d138c7d6d23f39f4

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 2,5,3,4
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
 ORDER BY 3,4
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x954
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 5,2,4
;
-- 145 values hashing to 2cb501fcb4f9f78b2d5beb65da09c0c3

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
;

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
 ORDER BY 1,4,3,5
;

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND (e>a AND e<b)
;

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND a>b
   AND (e>a AND e<b)
 ORDER BY 5,4
;

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
;

-- query IIIII rowsort x955
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
 ORDER BY 3,2
;

-- query IIIIII rowsort x956
SELECT abs(a),
       a-b,
       d-e,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
;
-- 12 values hashing to 4cd2ddb5a674658bafabf7975e8d0c27

-- query IIIIII rowsort x956
SELECT abs(a),
       a-b,
       d-e,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
 ORDER BY 4,1,5
;
-- 12 values hashing to 4cd2ddb5a674658bafabf7975e8d0c27

-- query IIIIII rowsort x956
SELECT abs(a),
       a-b,
       d-e,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
;
-- 12 values hashing to 4cd2ddb5a674658bafabf7975e8d0c27

-- query IIIIII rowsort x956
SELECT abs(a),
       a-b,
       d-e,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
   AND (e>a AND e<b)
 ORDER BY 2,3,6,1,5,4
;
-- 12 values hashing to 4cd2ddb5a674658bafabf7975e8d0c27

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
   AND d>e
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
   AND d>e
 ORDER BY 2,1,3,4,5
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND d>e
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
   AND d>e
 ORDER BY 5,6
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE d>e
   AND (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
 ORDER BY 2,1,3,5
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
;

-- query IIIIII rowsort x957
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       b-c
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
 ORDER BY 4,5,2
;

-- query IIII rowsort x958
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
   AND c>d
;

-- query IIII rowsort x958
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
   AND c>d
 ORDER BY 2,1,4
;

-- query IIII rowsort x958
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
;

-- query IIII rowsort x958
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE a>b
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
 ORDER BY 1,4,3,2
;

-- query IIIIIII rowsort x959
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 210 values hashing to 03234f0abbf892c9f6239a86bb6afa6e

-- query IIIIIII rowsort x959
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 5,1,2
;
-- 210 values hashing to 03234f0abbf892c9f6239a86bb6afa6e

-- query IIIII rowsort x960
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
;
-- 55 values hashing to fb7114013bb5208c809ef98576781919

-- query IIIII rowsort x960
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
 ORDER BY 4,2,3
;
-- 55 values hashing to fb7114013bb5208c809ef98576781919

-- query II rowsort x961
SELECT b,
       abs(b-c)
  FROM t1
;
-- 60 values hashing to 27981adf06e0e81d4fc66380389b2c0c

-- query II rowsort x961
SELECT b,
       abs(b-c)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 27981adf06e0e81d4fc66380389b2c0c

-- query II rowsort x962
SELECT e,
       abs(a)
  FROM t1
;
-- 60 values hashing to 0577a532186fd58ab51cdab496db421e

-- query II rowsort x962
SELECT e,
       abs(a)
  FROM t1
 ORDER BY 2,1
;
-- 60 values hashing to 0577a532186fd58ab51cdab496db421e

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
 ORDER BY 5,1,7,4,6,2,3
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
 ORDER BY 6,5
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
    OR b>c
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x963
SELECT c-d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a+b*2+c*3,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
    OR b>c
 ORDER BY 5,3,7,2,4
;
-- 112 values hashing to 3d5e535875e48959c28273401c1e4098

-- query IIIIIII rowsort x964
SELECT d,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 105 values hashing to e1afc82b2cf737dce31cee8d0f8c3fb8

-- query IIIIIII rowsort x964
SELECT d,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 7,1
;
-- 105 values hashing to e1afc82b2cf737dce31cee8d0f8c3fb8

-- query IIIIIII rowsort x965
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
;
-- 210 values hashing to 4851f91b878369586df547aa071fc35a

-- query IIIIIII rowsort x965
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 ORDER BY 2,7
;
-- 210 values hashing to 4851f91b878369586df547aa071fc35a

-- query IIII rowsort x966
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       b
  FROM t1
;
-- 120 values hashing to c151f79df713fca35883394246865fae

-- query IIII rowsort x966
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       b
  FROM t1
 ORDER BY 4,1,2,3
;
-- 120 values hashing to c151f79df713fca35883394246865fae

-- query IIII rowsort x967
SELECT abs(b-c),
       c,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
;
-- 72 values hashing to b8e0646cd0cd3c94d646b5476a3351c5

-- query IIII rowsort x967
SELECT abs(b-c),
       c,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,2
;
-- 72 values hashing to b8e0646cd0cd3c94d646b5476a3351c5

-- query IIII rowsort x968
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
;
-- 120 values hashing to 13a90992dc0556ac7ca52fed5f7ee3f1

-- query IIII rowsort x968
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 ORDER BY 4,1
;
-- 120 values hashing to 13a90992dc0556ac7ca52fed5f7ee3f1

-- query IIIII rowsort x969
SELECT a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 378bbf11f9628097312692a8b811f92e

-- query IIIII rowsort x969
SELECT a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,1,5
;
-- 10 values hashing to 378bbf11f9628097312692a8b811f92e

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR c BETWEEN b-2 AND d+2
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR c>d
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
    OR c>d
 ORDER BY 1
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR c>d
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR c>d
 ORDER BY 1
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query I rowsort x970
SELECT abs(b-c)
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
 ORDER BY 1
;
-- 20 values hashing to 0b90f8526d043c66fd0f06b10364119a

-- query IIIIII rowsort x971
SELECT c-d,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 174 values hashing to b8a669259035dcc1606844dc8925b72e

-- query IIIIII rowsort x971
SELECT c-d,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,5,4
;
-- 174 values hashing to b8a669259035dcc1606844dc8925b72e

-- query IIIIII rowsort x971
SELECT c-d,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
;
-- 174 values hashing to b8a669259035dcc1606844dc8925b72e

-- query IIIIII rowsort x971
SELECT c-d,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 6,2,5,4
;
-- 174 values hashing to b8a669259035dcc1606844dc8925b72e

-- query IIIIII rowsort x972
SELECT a,
       a+b*2+c*3+d*4+e*5,
       c,
       a+b*2+c*3+d*4,
       c-d,
       a-b
  FROM t1
 WHERE a>b
;
-- 102 values hashing to 462f4b654d6798393ae1a0895fa3fb2a

-- query IIIIII rowsort x972
SELECT a,
       a+b*2+c*3+d*4+e*5,
       c,
       a+b*2+c*3+d*4,
       c-d,
       a-b
  FROM t1
 WHERE a>b
 ORDER BY 5,1,6,4,3
;
-- 102 values hashing to 462f4b654d6798393ae1a0895fa3fb2a

-- query IIII rowsort x973
SELECT abs(a),
       b-c,
       a+b*2+c*3,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
;
-- 12 values hashing to 186dbec8f36825c23c7409f9e544ce7a

-- query IIII rowsort x973
SELECT abs(a),
       b-c,
       a+b*2+c*3,
       a+b*2
  FROM t1
 WHERE (e>a AND e<b)
 ORDER BY 2,3
;
-- 12 values hashing to 186dbec8f36825c23c7409f9e544ce7a

-- query IIIII rowsort x974
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a+b*2+c*3
  FROM t1
 WHERE c>d
    OR d>e
    OR (e>a AND e<b)
;
-- 95 values hashing to 1987d45b0b116ae6c825c03dd1326dc4

-- query IIIII rowsort x974
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a+b*2+c*3
  FROM t1
 WHERE c>d
    OR d>e
    OR (e>a AND e<b)
 ORDER BY 5,3,4,1,2
;
-- 95 values hashing to 1987d45b0b116ae6c825c03dd1326dc4

-- query IIIII rowsort x974
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a+b*2+c*3
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR d>e
;
-- 95 values hashing to 1987d45b0b116ae6c825c03dd1326dc4

-- query IIIII rowsort x974
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a+b*2+c*3
  FROM t1
 WHERE (e>a AND e<b)
    OR c>d
    OR d>e
 ORDER BY 1,5,3
;
-- 95 values hashing to 1987d45b0b116ae6c825c03dd1326dc4

-- query II rowsort x975
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 20 values hashing to f47b92b2f2855847b16fd69cccd8b5e9

-- query II rowsort x975
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 1,2
;
-- 20 values hashing to f47b92b2f2855847b16fd69cccd8b5e9

-- query IIIII rowsort x976
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
;
-- 150 values hashing to 4925274e122cd1d139a3b33f0edc8844

-- query IIIII rowsort x976
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 ORDER BY 3,2,1,5
;
-- 150 values hashing to 4925274e122cd1d139a3b33f0edc8844

-- query III rowsort x977
SELECT a-b,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
;
-- 24 values hashing to edc2725dcb44c9a570c873c2b3858c8a

-- query III rowsort x977
SELECT a-b,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
 ORDER BY 1,2
;
-- 24 values hashing to edc2725dcb44c9a570c873c2b3858c8a

-- query II rowsort x978
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
;
-- 60 values hashing to 2a0252ba1bd9c0a82b344822dc3ec2da

-- query II rowsort x978
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1,2
;
-- 60 values hashing to 2a0252ba1bd9c0a82b344822dc3ec2da

-- query IIIIII rowsort x979
SELECT abs(a),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b
  FROM t1
 WHERE b>c
;
-- 78 values hashing to 79d0c593dc32db6c341e6fdcf333042d

-- query IIIIII rowsort x979
SELECT abs(a),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b
  FROM t1
 WHERE b>c
 ORDER BY 5,2,1,4,3
;
-- 78 values hashing to 79d0c593dc32db6c341e6fdcf333042d

-- query IIIIIII rowsort x980
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       a+b*2+c*3+d*4,
       d,
       b-c,
       a-b,
       b
  FROM t1
 WHERE b>c
    OR c>d
    OR (e>c OR e<d)
;
-- 196 values hashing to dafeb817b27e64f0141bebd221c69fa5

-- query IIIIIII rowsort x980
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       a+b*2+c*3+d*4,
       d,
       b-c,
       a-b,
       b
  FROM t1
 WHERE b>c
    OR c>d
    OR (e>c OR e<d)
 ORDER BY 2,1,5,6,3,4,7
;
-- 196 values hashing to dafeb817b27e64f0141bebd221c69fa5

-- query IIIIIII rowsort x980
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       a+b*2+c*3+d*4,
       d,
       b-c,
       a-b,
       b
  FROM t1
 WHERE c>d
    OR b>c
    OR (e>c OR e<d)
;
-- 196 values hashing to dafeb817b27e64f0141bebd221c69fa5

-- query IIIIIII rowsort x980
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       a+b*2+c*3+d*4,
       d,
       b-c,
       a-b,
       b
  FROM t1
 WHERE c>d
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 7,1,4,5,3,6
;
-- 196 values hashing to dafeb817b27e64f0141bebd221c69fa5

-- query IIIII rowsort x981
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIIII rowsort x981
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       e
  FROM t1
 WHERE (e>a AND e<b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 2,3,5
;

-- query IIIII rowsort x981
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
;

-- query IIIII rowsort x981
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
 ORDER BY 5,3,2
;

-- query IIIIIII rowsort x982
SELECT a-b,
       b-c,
       (a+b+c+d+e)/5,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
;
-- 210 values hashing to 9128b6a4fd5c85d08765b0a26d39cc70

-- query IIIIIII rowsort x982
SELECT a-b,
       b-c,
       (a+b+c+d+e)/5,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 ORDER BY 3,4,5,1,2
;
-- 210 values hashing to 9128b6a4fd5c85d08765b0a26d39cc70

-- query III rowsort x983
SELECT c-d,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
;
-- 30 values hashing to 2c4df05a4ee2d9e4f97fb34b36dd6bea

-- query III rowsort x983
SELECT c-d,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
 ORDER BY 2,1
;
-- 30 values hashing to 2c4df05a4ee2d9e4f97fb34b36dd6bea

-- query IIIII rowsort x984
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
;
-- 150 values hashing to 5b5db6179b811b7ba9834927de2d7368

-- query IIIII rowsort x984
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 ORDER BY 2,4,5,3,1
;
-- 150 values hashing to 5b5db6179b811b7ba9834927de2d7368

-- query IIII rowsort x985
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
;
-- 40 values hashing to 4d66a0e29fc571de9d9cb365746d2462

-- query IIII rowsort x985
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,4,1,3
;
-- 40 values hashing to 4d66a0e29fc571de9d9cb365746d2462

-- query IIII rowsort x985
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
;
-- 40 values hashing to 4d66a0e29fc571de9d9cb365746d2462

-- query IIII rowsort x985
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c BETWEEN b-2 AND d+2
 ORDER BY 4,2,1,3
;
-- 40 values hashing to 4d66a0e29fc571de9d9cb365746d2462

-- query IIII rowsort x986
SELECT b,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
;
-- 120 values hashing to 6f78ddc0a5b5ad8ef4b1d08972887887

-- query IIII rowsort x986
SELECT b,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c
  FROM t1
 ORDER BY 4,3,2,1
;
-- 120 values hashing to 6f78ddc0a5b5ad8ef4b1d08972887887

-- query III rowsort x987
SELECT c,
       a+b*2,
       b-c
  FROM t1
;
-- 90 values hashing to 02e18efb5e8ae490e7b5137b79765bb9

-- query III rowsort x987
SELECT c,
       a+b*2,
       b-c
  FROM t1
 ORDER BY 3,1
;
-- 90 values hashing to 02e18efb5e8ae490e7b5137b79765bb9

-- query II rowsort x988
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
;
-- 30 values hashing to a512bc577af89b7ed951794c489cba1a

-- query II rowsort x988
SELECT a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
 ORDER BY 2,1
;
-- 30 values hashing to a512bc577af89b7ed951794c489cba1a

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,2
;

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
;

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
   AND c>d
 ORDER BY 4,3,1,2
;

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
;

-- query IIII rowsort x989
SELECT c-d,
       b-c,
       a,
       a+b*2+c*3
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND e+d BETWEEN a+b-10 AND c+130
 ORDER BY 3,4
;

-- query I rowsort x990
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
;
-- 18 values hashing to 9db1749e744db8ddaa29f825f2bbae00

-- query I rowsort x990
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
 ORDER BY 1
;
-- 18 values hashing to 9db1749e744db8ddaa29f825f2bbae00

-- query I rowsort x990
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
;
-- 18 values hashing to 9db1749e744db8ddaa29f825f2bbae00

-- query I rowsort x990
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
 ORDER BY 1
;
-- 18 values hashing to 9db1749e744db8ddaa29f825f2bbae00

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE b>c
    OR (e>c OR e<d)
    OR a>b
 ORDER BY 2,4
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR b>c
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR b>c
 ORDER BY 2,3
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR a>b
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR a>b
 ORDER BY 2,3,1,4
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE a>b
    OR b>c
    OR (e>c OR e<d)
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query IIII rowsort x991
SELECT abs(a),
       abs(b-c),
       d-e,
       e
  FROM t1
 WHERE a>b
    OR b>c
    OR (e>c OR e<d)
 ORDER BY 2,1,4,3
;
-- 108 values hashing to a072f79e2ee5caa924199a92f589ad4a

-- query II rowsort x992
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
;
-- 52 values hashing to befd4856a3c68ee6fecb6d1ee36161c0

-- query II rowsort x992
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 2,1
;
-- 52 values hashing to befd4856a3c68ee6fecb6d1ee36161c0

-- query IIIIIII rowsort x993
SELECT c-d,
       a-b,
       b,
       d-e,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
;
-- 91 values hashing to 056173676fceb0bfa309c7b316c21b41

-- query IIIIIII rowsort x993
SELECT c-d,
       a-b,
       b,
       d-e,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
 ORDER BY 2,7,6
;
-- 91 values hashing to 056173676fceb0bfa309c7b316c21b41

-- query III rowsort x994
SELECT b,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
;
-- 9 values hashing to 75b3df4bbfa7a41597197240b91d7583

-- query III rowsort x994
SELECT b,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
 ORDER BY 1,2,3
;
-- 9 values hashing to 75b3df4bbfa7a41597197240b91d7583

-- query III rowsort x994
SELECT b,
       abs(b-c),
       d
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
;
-- 9 values hashing to 75b3df4bbfa7a41597197240b91d7583

-- query III rowsort x994
SELECT b,
       abs(b-c),
       d
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
 ORDER BY 2,3,1
;
-- 9 values hashing to 75b3df4bbfa7a41597197240b91d7583

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND b>c
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
   AND b>c
 ORDER BY 2,1
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE b>c
   AND c>d
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE b>c
   AND c>d
   AND c BETWEEN b-2 AND d+2
 ORDER BY 3,1,2
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND b>c
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c>d
   AND c BETWEEN b-2 AND d+2
   AND b>c
 ORDER BY 2,1,3
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c>d
   AND b>c
   AND c BETWEEN b-2 AND d+2
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query III rowsort x995
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d,
       e
  FROM t1
 WHERE c>d
   AND b>c
   AND c BETWEEN b-2 AND d+2
 ORDER BY 1,2,3
;
-- 9 values hashing to 967a584b4e8e0422a6fc749b26d83269

-- query IIIIIII rowsort x996
SELECT abs(a),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
;
-- 210 values hashing to b7e3c0a48e7ba9bc7fa12a5007125dd7

-- query IIIIIII rowsort x996
SELECT abs(a),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3+d*4+e*5,
       c
  FROM t1
 ORDER BY 5,3
;
-- 210 values hashing to b7e3c0a48e7ba9bc7fa12a5007125dd7

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
    OR a>b
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
    OR a>b
 ORDER BY 1
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 1
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query I rowsort x997
SELECT abs(b-c)
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
 ORDER BY 1
;
-- 28 values hashing to b3a80aab6a3a581af6d0494bc775069f

-- query IIIII rowsort x998
SELECT d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
;
-- 10 values hashing to 320ede2fb2ea53711789ed5ffee03adc

-- query IIIII rowsort x998
SELECT d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
 ORDER BY 4,1,3,5,2
;
-- 10 values hashing to 320ede2fb2ea53711789ed5ffee03adc

-- query II rowsort x999
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
;
-- 26 values hashing to 3f88fe320ecc1f2abe76387af0badb07

-- query II rowsort x999
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
 ORDER BY 2,1
;
-- 26 values hashing to 3f88fe320ecc1f2abe76387af0badb07

-- cleanup created tables
DROP TABLE t1;
