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

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query IIIIIII rowsort
SELECT e,
       abs(a),
       b,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to 46c6841abfae8913a6759ec6f454ab0f

-- query III rowsort
SELECT abs(b-c),
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 0451564addcc49504e7dd88be40b3e69

-- query IIII rowsort
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4;
-- NULL
-- 1
-- NULL
-- 114
-- NULL
-- 18
-- NULL
-- 207

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 20 values hashing to 4107afddb1186b30a9105bf7bf09f540

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6;
-- 174 values hashing to 777dcbc0198356b9c12bf01fa545f68c

-- query I rowsort
SELECT abs(b-c)
  FROM t1
ORDER BY 1;
-- 30 values hashing to c289bcde2e1a495d6cc09dde069c6c87

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b IS NOT NULL
   AND a>b
ORDER BY 1;
-- 391
-- 475
-- 502
-- 544
-- 595
-- 685

-- query IIIIIII rowsort
SELECT c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND coalesce(a,b,c,d,e)<>0
   AND c>d
ORDER BY 1,2,3,4,5,6,7;
-- 35 values hashing to b523d6b6df543010b45626657adada9d

-- query IIIIIII rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       b-c
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
ORDER BY 1,2,3,4,5,6,7;
-- 63 values hashing to 80800d1e987b7049fa5d57c55815bf4c

-- query IIIIIII rowsort
SELECT e,
       b,
       a,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b IS NOT NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to e421c85cd0132772b0b7762c78066abb

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a-b,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 24 values hashing to 83cde3379decb55b28d3ac450c6f9881

-- query IIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 1612
-- 107
-- 108
-- 333
-- 1902
-- 127
-- 128
-- 222

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1;
-- 30 values hashing to ec9f02c46c399db521c47dd9cb6a40dd

-- query III rowsort
SELECT d-e,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR b>c
    OR b IS NOT NULL
ORDER BY 1,2,3;
-- 90 values hashing to 7be06d7255991a0b921d169b65e408c0

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 292b0a5b2821884ba5d11e217b76fbd7

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR b>c
    OR a>b
ORDER BY 1,2,3;
-- 90 values hashing to f2ff447495c871e67c605d2c0b5e70ec

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b IS NOT NULL
ORDER BY 1,2,3;
-- 42 values hashing to d2467d2f2cfae3b29ec7f4a5152f36c4

-- query IIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       e,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5;
-- 65 values hashing to 5ed50f9b86136acfad54696420ffa1f0

-- query IIIII rowsort
SELECT e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       d,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to a030f689f5a0035d4db42d5da9f4b7a7

-- query III rowsort
SELECT e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 42 values hashing to e0970228aa8a30d2050cfd3c11be9185

-- query IIIIII rowsort
SELECT a+b*2,
       abs(b-c),
       c,
       d-e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR (e>a AND e<b)
    OR a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 138 values hashing to bf08a6d9c0db20af06d88ca646cda804

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
ORDER BY 1,2,3;
-- 45 values hashing to a15fae7379de155bbaeb251f575a7db0

-- query IIII rowsort
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a IS NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 72 values hashing to 12fdbfddf3f67b7da4a8224b4e2798a6

-- query IIIII rowsort
SELECT a,
       c-d,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b IS NOT NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 135 values hashing to cb5eb3ba2131bf64c07defbe3cb6e3af

-- query IIIII rowsort
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(a),
       a
  FROM t1
 WHERE b>c
   AND coalesce(a,b,c,d,e)<>0
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 4457dbfe4ab387a5f8f9b308280689f6

-- query IIIIII rowsort
SELECT abs(b-c),
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to bb777feb11708e8bab6a2441bd11b89e

-- query IIIIIII rowsort
SELECT a-b,
       b-c,
       abs(a),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       d-e
  FROM t1
 WHERE b IS NOT NULL
   AND e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 2
-- -1
-- 107
-- 1
-- 333
-- 105
-- -1

-- query II rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 1272
-- 1290

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to c1e3a4310060dcd710dc9c750c881699

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       a,
       d-e,
       d
  FROM t1
 WHERE a IS NULL
   AND d>e
ORDER BY 1,2,3,4,5,6,7;
-- 1120
-- NULL
-- 555
-- NULL
-- NULL
-- 4
-- 114

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       c-d,
       e,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 88 values hashing to b22693af4f023122fff8a50a5e372bda

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2;
-- 54 values hashing to 1b7def90663182338e06a1cf6a69716c

-- query II rowsort
SELECT a+b*2+c*3,
       c-d
  FROM t1
 WHERE b IS NOT NULL
    OR coalesce(a,b,c,d,e)<>0
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 60 values hashing to 56503929d5f9ae519d6cd57dbc46fd31

-- query IIII rowsort
SELECT e,
       a+b*2,
       c,
       b-c
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4;
-- 68 values hashing to 002e43f0dae181922fce672d6b46bce4

-- query IIIIII rowsort
SELECT c,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 4f318c569764111039dcb8c952539766

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       abs(a),
       d-e,
       b-c
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 8c1cbf34fc589bfee72b88a68c603df9

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       a-b,
       a+b*2,
       c
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 0e9c742378241574ced59b33a5434334

-- query IIIII rowsort
SELECT c-d,
       b-c,
       a+b*2+c*3,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 7fe27233559679a19eeea3d0344a0a75

-- query I rowsort
SELECT d
  FROM t1
 WHERE c>d
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
ORDER BY 1;
-- 185
-- 212
-- 222

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
ORDER BY 1;
-- 13 values hashing to 26ce2a46fa9ea4ff61793fcfe9ac0168

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to 0075716954dbc259c5e8ac65568a6fa7

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 782245bb6ba30992ede7e5b5f0b3a770

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
ORDER BY 1,2,3;
-- 33 values hashing to 10ffdae48a4133e337ecdb4299e41e7f

-- query IIIII rowsort
SELECT b-c,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5;
-- 10 values hashing to f4e0215d63da3cf742c6994add1a57ab

-- query III rowsort
SELECT c,
       a+b*2+c*3+d*4+e*5,
       c-d
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 506e2afe06127463d88f196da2943a89

-- query IIII rowsort
SELECT a+b*2,
       d,
       abs(b-c),
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d>e
ORDER BY 1,2,3,4;
-- 20 values hashing to 43c185bc3c298eb1f985ac13c0bafe63

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE c>d
ORDER BY 1;
-- 13 values hashing to 4f440d60ba96ec329ca81db364624811

-- query II rowsort
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR (e>c OR e<d)
ORDER BY 1,2;
-- 52 values hashing to de7705618b1cddff30f17f3cfd1b86ab

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1;
-- 555
-- 555

-- query IIIIII rowsort
SELECT a+b*2,
       d-e,
       a-b,
       abs(a),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 36 values hashing to d2d3b4e04efb177f21490dcb8d52ada5

-- query III rowsort
SELECT a+b*2+c*3,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
ORDER BY 1,2,3;
-- 54 values hashing to b8c57644f5bc8e0f2140fe80814027d3

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 784d5bd4f8864db01ca28799e5ce3a3e

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>a AND e<b)
ORDER BY 1,2;

-- query II rowsort
SELECT b-c,
       c
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2;
-- -1
-- 224
-- 1
-- 193
-- 2
-- 247

-- query IIIII rowsort
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       a,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 70 values hashing to 3a03b803d90629615043650cb325b728

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
ORDER BY 1,2,3,4,5;
-- 75 values hashing to 0fad8b78ab2dd2f61c26a27190ce19c0

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 24924fe69d316f176b1550199a62a171

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE d>e
    OR a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 253872178c640da617545317023199c8

-- query I rowsort
SELECT e
  FROM t1
ORDER BY 1;
-- 30 values hashing to b9f09a0d6206ee3b897ed8a2dc580e1d

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE c>d
ORDER BY 1;
-- 13 values hashing to a9f003d45f26b5b6764ef22f16260fdf

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1;
-- 30 values hashing to ec9f02c46c399db521c47dd9cb6a40dd

-- query IIII rowsort
SELECT c-d,
       a+b*2,
       d-e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND b IS NOT NULL
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 24 values hashing to 5b6e8b80eab2cb3c976af840f2f32caa

-- query III rowsort
SELECT a-b,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE a>b
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
ORDER BY 1,2,3;
-- 81 values hashing to daf8222f368b8af911b2ea0205aff651

-- query II rowsort
SELECT d-e,
       abs(a)
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2;
-- 42 values hashing to a867ad5e8d461f8bc18f0f80ec81a821

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       b-c
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 00e72088d65823366f9b3a96d22b61e0

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 WHERE a>b
   AND b>c
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 333
-- 1391
-- 23
-- 2

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to d3cef94ca3dc1b45729489b9ffa60d3f

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
ORDER BY 1,2,3;
-- 24 values hashing to 66a81d76eae1ab608302f07cd95c35e2

-- query IIII rowsort
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       d-e
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 84 values hashing to 13da6431c56def32def8f22e9acb8f5a

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 17 values hashing to baeb6fdb5d575870fddf7d11fa9e02f3

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(b-c),
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 491acceccdee796c24e32a2d5f4d5ef4

-- query IIIIII rowsort
SELECT d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c)
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 3ae5d48da87beb5893f4efe7ae59aa41

-- query III rowsort
SELECT d,
       c-d,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
    OR a IS NULL
ORDER BY 1,2,3;
-- 54 values hashing to 31eed42b421ab6466a52c1a32f6c58cf

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to de6b536a747f0bd59101fa0a12d1b4e5

-- query IIIII rowsort
SELECT b,
       d,
       abs(a),
       abs(b-c),
       d-e
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 70b18d00c256c3e58282c1c741745e5e

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c
  FROM t1
 WHERE b>c
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3;

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 9b296f0c2d63eb2d8663ebbf98fe7462

-- query II rowsort
SELECT d-e,
       abs(b-c)
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2;
-- 54 values hashing to d476ace2c3b8cf05ff5893bf63e088e9

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3;
-- 63 values hashing to 65983a3e33b00a21250a41e26be2a27c

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       d,
       b-c,
       b,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 04619e8c0fb24f77d2243885117a1776

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
ORDER BY 1;
-- 11 values hashing to 8272d1dcfc3f235e9ce05b0d0be2cf0e

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 66 values hashing to d667c19a8db947e8d78da6f211a32b33

-- query II rowsort
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a>b
ORDER BY 1,2;
-- 36 values hashing to b3abed6fa7975f32cea35c1c82052613

-- query III rowsort
SELECT b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to eaf0882665f15d6358c9bc2beca55a0c

-- query IIIIIII rowsort
SELECT abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       d,
       e,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
   AND (c<=d-2 OR c>=d+2)
   AND a>b
ORDER BY 1,2,3,4,5,6,7;
-- 21 values hashing to ddf3c7563b358cce0af4f01125706ce0

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       d-e,
       (a+b+c+d+e)/5,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b IS NOT NULL
   AND c>d
ORDER BY 1,2,3,4,5;
-- 55 values hashing to 4d1e4b4b34120f5c6bb0c0e4fe30fdbd

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       d,
       c-d,
       a
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6,7;
-- 182 values hashing to d5715764b273222c0aa9385bf4a9781e

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d>e
ORDER BY 1,2,3,4,5,6;
-- 96 values hashing to 5d1b031c85c8e443a475c8bf4d3c62ac

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND coalesce(a,b,c,d,e)<>0
   AND c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 14 values hashing to eb0d3d5abd4ff4a559c13f43d12f55fc

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       abs(b-c)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to f687ab94c7a21d83732ee96a366aad41

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>a AND e<b)
   AND a>b
ORDER BY 1,2,3,4,5;

-- query IIII rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
ORDER BY 1,2,3,4;
-- 12 values hashing to 383eb65446347ea6e607173208759bd4

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       d-e,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 063f5e8d2c0f3169b9c191380f3d3322

-- query IIII rowsort
SELECT d,
       b-c,
       abs(b-c),
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 60 values hashing to 1d4f85009c12a1a99a445c4d2f49a07e

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 54 values hashing to d2b3fb0bad81f76d011537262cf82da3

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE a IS NULL
   AND (e>c OR e<d)
ORDER BY 1;
-- -1

-- query IIIIII rowsort
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       c-d,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 90fa34da0f47adbe685546e0538a64b5

-- query I rowsort
SELECT d
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to a901a0fa410534d01e357e4cd9c9c41c

-- query II rowsort
SELECT c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2;
-- -2
-- 333

-- query IIIII rowsort
SELECT a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       d,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5;
-- 120 values hashing to 92d3da4ee6152238af162ebb340d4995

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       d,
       a-b,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 7eb91ccb10e1f33802a145f37a09d3c0

-- query IIIIII rowsort
SELECT a+b*2,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a-b,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to a13289706342cf62df9d849372f0933b

-- query IIIIIII rowsort
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       c,
       e,
       d
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 196 values hashing to cf443efda2951657ba653ba7aff10172

-- query II rowsort
SELECT a+b*2,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 50 values hashing to 51d40a3dfe04e569ca324b58e54c2001

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE b>c
ORDER BY 1,2;
-- 26 values hashing to f9aa7b0682d2155a61d91f6c3e3aa0f6

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2,
       abs(a),
       c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 75 values hashing to 20ec583d2295fd5f84a509c8bb33045d

-- query III rowsort
SELECT b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c>d
   AND a>b
ORDER BY 1,2,3;
-- 15 values hashing to 4ae979f02ba8355cc00e1b6009f7f07c

-- query IIIIII rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 47d6e3c44547d5c5dcbd19d1dd9f15d5

-- query I rowsort
SELECT a
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 7243fa2f96df52cd4af85647b2be6a1b

-- query IIIII rowsort
SELECT a+b*2+c*3,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 15138e5915e2fe5ed2c0c820de7579ce

-- query III rowsort
SELECT a+b*2+c*3,
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>c OR e<d)
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3;
-- 635
-- -1
-- 107
-- 760
-- 2
-- 127

-- query III rowsort
SELECT abs(a),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 51 values hashing to 2c44ca73003271afa763cdb6e877fae4

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 9e262611553407ecce8e397969dd1bce

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE b IS NOT NULL
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 1
-- 4

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2,
       d,
       a+b*2+c*3+d*4,
       a-b,
       b-c,
       a
  FROM t1
 WHERE b>c
    OR a IS NULL
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to 53754235cfffd05233b4d3a2403881a5

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE a>b
ORDER BY 1;
-- 17 values hashing to e237372cbf981454a9240fd99e73b8e4

-- query IIIIIII rowsort
SELECT a+b*2,
       a,
       b,
       c,
       abs(b-c),
       abs(a),
       d
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to b34e0001ad4bdd914341ae317c613e1c

-- query II rowsort
SELECT b-c,
       abs(a)
  FROM t1
 WHERE b IS NOT NULL
    OR e+d BETWEEN a+b-10 AND c+130
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2;
-- 54 values hashing to 3755533386c14db52aa1ef57fb5c7dfe

-- query IIII rowsort
SELECT c-d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
   AND a>b
ORDER BY 1,2,3,4;
-- 12 values hashing to 9d90bcb98a18bc4f2c6c648b57d9a0b5

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       abs(b-c),
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
ORDER BY 1,2,3,4,5,6;
-- 132 values hashing to 1438bde5aab9a47b1027ed6cd08d3080

-- query IIIIIII rowsort
SELECT abs(a),
       d,
       e,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6,7;
-- 98 values hashing to c485dc4b6e4854ed2f176aa12518bebd

-- query IIIII rowsort
SELECT d-e,
       abs(b-c),
       a+b*2+c*3,
       a+b*2,
       a-b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 2187ecb4988b726899c40305e68659be

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR c>d
ORDER BY 1,2,3,4;
-- 104 values hashing to a14dd901528761d99a178f3831e86c6f

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       d-e
  FROM t1
 WHERE a>b
   AND (e>c OR e<d)
   AND a IS NULL
ORDER BY 1,2,3,4,5;

-- query IIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a IS NULL
   AND d>e
ORDER BY 1,2,3,4,5;
-- NULL
-- NULL
-- 114
-- 1120
-- 1

-- query IIIIIII rowsort
SELECT d,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       c,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to b0d4bbdac1bb95cff2c4e05adbb5da90

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       b-c,
       e
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to a0916b6a52dd9dbdcc5e8e5abbf13dc2

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 7513fd547e90170855946a451500730f

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       c-d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to cc55531fcbd70c80d6dd0a84e1b5dab1

-- query IIIIII rowsort
SELECT c,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 2afc0d951d1416824ab2e15f933b302d

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE c>d
ORDER BY 1,2,3;
-- 39 values hashing to 68c3d5e1a20acbe40e43b4cb004bd223

-- query III rowsort
SELECT abs(b-c),
       (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE (e>a AND e<b)
   AND a IS NULL
ORDER BY 1,2,3;

-- query I rowsort
SELECT b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1;
-- 10 values hashing to f4e6e43c2b8b813ce50d6662923d4fc0

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5,
       c-d,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to b84d1c2bd9287ce781ed7f218fa68282

-- query IIIII rowsort
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 45 values hashing to c9265d596fbcbad28442ec6b998fb740

-- query II rowsort
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
ORDER BY 1,2;
-- 18 values hashing to da91174780bb14b5dedff6e117705ee5

-- query IIIIII rowsort
SELECT abs(a),
       (a+b+c+d+e)/5,
       a+b*2,
       c,
       b,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to a84ed43f5c663d693a9c3bea9318231a

-- query II rowsort
SELECT d-e,
       a
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 10 values hashing to 404b928d376c352433661ed869305818

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d>e
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 42 values hashing to c39888e7e799f07421b58acd0c14b335

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       d,
       d-e,
       a-b
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to e6ae93a5fa82784933c5ae92e7a39c88

-- query II rowsort
SELECT d-e,
       a-b
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to f8086924cbfa151a37fc052de951fa95

-- query III rowsort
SELECT abs(a),
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b IS NOT NULL
   AND c>d
ORDER BY 1,2,3;
-- 12 values hashing to d1f97e065d3318f1c905ff5f404c259e

-- query III rowsort
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE a>b
ORDER BY 1,2,3;
-- 51 values hashing to c3ff7d2b20e04fd75f074ea1f41137bc

-- query IIIIIII rowsort
SELECT c-d,
       d-e,
       a-b,
       (a+b+c+d+e)/5,
       b,
       a,
       abs(b-c)
  FROM t1
 WHERE d>e
   AND b IS NOT NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6,7;
-- 77 values hashing to fcdd05c347f43f87c33b71e758491765

-- query IIII rowsort
SELECT a,
       d,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to edb25fbf497e7db5e074ec693f986484

-- query IIII rowsort
SELECT d,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to ed44bad18fcadef3387f16249b2c8188

-- query IIIIII rowsort
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 35b3e42da41d41da850ff27225d1add2

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE a>b
ORDER BY 1,2,3;
-- 51 values hashing to b86029f47418c16af4cf2b938795cf9d

-- query II rowsort
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 34 values hashing to b9f27e2692846c7cf82160112dc817a1

-- query III rowsort
SELECT a-b,
       b-c,
       abs(b-c)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to c67a9b35c13fbe0e2c787e8b298e0cc7

-- query I rowsort
SELECT c
  FROM t1
 WHERE (e>c OR e<d)
    OR a>b
ORDER BY 1;
-- 25 values hashing to 12ac2528d0176d140f899db83beeae4a

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       c
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 126 values hashing to 0d3de03b4e439157d4403c7995f77353

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND b>c
ORDER BY 1;
-- 5

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 1af0120a7bbd1e3cd998679b777f783d

-- query IIII rowsort
SELECT a+b*2+c*3,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4;
-- 44 values hashing to 6eb821a9c64425c2015710ca063f859d

-- query I rowsort
SELECT d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR c>d
ORDER BY 1;
-- 23 values hashing to 83c121f8dfa4054cd315db02a5a0da66

-- query IIIII rowsort
SELECT c,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5;
-- 85 values hashing to 6916e65d511015d6aa52a62b4a666ba3

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR a>b
ORDER BY 1,2,3;
-- 72 values hashing to 20a4b8aec8f3063b4950f5c7d01cf17c

-- query IIIIIII rowsort
SELECT b,
       d,
       a,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE d>e
    OR a IS NULL
ORDER BY 1,2,3,4,5,6,7;
-- 84 values hashing to 5bce68a9cb274f51217904d5c72a6671

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       c,
       c-d,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
    OR b IS NOT NULL
ORDER BY 1,2,3,4;
-- 108 values hashing to 2d4310983fffbe49ff8a05e91ff7336c

-- query IIIII rowsort
SELECT abs(b-c),
       b-c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 72261b5400c0b7dba214ac4eddcacb91

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to 08aca67746baa979d75bd8d3a8f212cf

-- query II rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2;
-- 42 values hashing to f05f1e4996491abb7652a9e8dac93edc

-- query III rowsort
SELECT abs(b-c),
       b,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 0ca44be4b036928221c634402be5da44

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
   AND c>d
ORDER BY 1;
-- 1
-- 1

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 362a2f78bba70bae1f727da6185db9e1

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE (e>c OR e<d)
    OR coalesce(a,b,c,d,e)<>0
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 120 values hashing to 32c073ed253379fc3c0fbde03f69af53

-- query IIIII rowsort
SELECT a-b,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       a+b*2
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 660436ce07762532fcc9a69293041a2b

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 196 values hashing to c1f202f0a51841e72a91e666b7129ad5

-- query I rowsort
SELECT c
  FROM t1
 WHERE b>c
    OR b IS NOT NULL
    OR (e>c OR e<d)
ORDER BY 1;
-- 28 values hashing to cdae70acb9fb03e155f862decbecce8e

-- query IIII rowsort
SELECT d-e,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to ab195b44b1a8ac08b9a3c76310753019

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 7cf42480d3b855179ce02c484cbe661f

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to efdbaa4d180e7867bec1c4d897bd25b9

-- query I rowsort
SELECT d-e
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query IIIIII rowsort
SELECT b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       e,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR a IS NULL
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 96 values hashing to e323ed5546d6d53a22e652df110c9a0a

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a+b*2,
       a
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 1a22ce28ef143293b9a3df25d9186b3d

-- query IIII rowsort
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
ORDER BY 1,2,3,4;
-- 36 values hashing to 942b2c182279b08bb67984c403d5f2e3

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to cbd91d5b8b7846c7bc6e8eeab7c0ac50

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d>e
ORDER BY 1;
-- 11 values hashing to 968b47b57dececa1c36ea07df5744ccb

-- query IIIIII rowsort
SELECT d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 2960873e6fcd668c017046579722e727

-- query IIIIIII rowsort
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5,
       b,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to d53a351ec6050ce23d1caa14c0f37975

-- query IIIIIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 95e81aefa1435b01ca795dd01fa37055

-- query III rowsort
SELECT c-d,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 4ee92dc4498bf0bde48f9fe510e0eefb

-- query IIIIIII rowsort
SELECT b,
       a+b*2+c*3+d*4,
       c-d,
       a,
       b-c,
       a+b*2,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
    OR b IS NOT NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to c5a503f5c0f1577e8fa78c52b97736fb

-- query IIII rowsort
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 89a3078351b48f3f0a02f66263c70fca

-- query IIIIII rowsort
SELECT abs(b-c),
       c-d,
       c,
       d-e,
       abs(a),
       b-c
  FROM t1
 WHERE b IS NOT NULL
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 174 values hashing to 5e517b9dfca72106d8a226a8513ad186

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
ORDER BY 1;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       b,
       a-b,
       e,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to 86497e82dae5464fd3ffbb6a17945399

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
    OR a>b
ORDER BY 1,2,3,4,5,6;
-- 150 values hashing to 352a74ab89b39257e03af042d19053ca

-- query II rowsort
SELECT d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to f898ac0e4bfdd5488091e2b7479fd259

-- query IIIIII rowsort
SELECT abs(b-c),
       e,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 150 values hashing to 8b990284f465e87fb0bacddac6be6b32

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 84 values hashing to 70fb8991b94738915d1b89be5807c89d

-- query IIII rowsort
SELECT c-d,
       d,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
ORDER BY 1,2,3,4;
-- 112 values hashing to 009272768053fb392328a37e37af1380

-- query I rowsort
SELECT a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 15 values hashing to 0462df69a372162bd2326b32559acd24

-- query IIIIII rowsort
SELECT d,
       a-b,
       c-d,
       a+b*2+c*3,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 30 values hashing to 0b840c9d2f6e0d2416bb58c87065049d

-- query I rowsort
SELECT a
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       d-e
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 42cc720bde1b5dde4d745c8c50576a2a

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       abs(b-c),
       abs(a),
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to 48d8b2d1a06eb8b3706d975f7d0a211b

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       c-d
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 3c2e29c1a62828371d108fc2db0e9637

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to f26f35b2777ee4f09e0e1e36a80f73df

-- query IIII rowsort
SELECT c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d
  FROM t1
 WHERE b>c
    OR c>d
    OR a>b
ORDER BY 1,2,3,4;
-- 112 values hashing to e7ee87f5a21f10c5ba46c5523a4e3fc1

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       e,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a IS NULL
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5,6,7;
-- 35 values hashing to a6d02be344f2dcba4a1ee9ec438ac535

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       b-c,
       abs(a),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 1d2c335944b2e1c4478b898ff81edaa1

-- query III rowsort
SELECT e,
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 7ca206e4f35fd078b7c80aa48e621cc6

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       b-c,
       d-e,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to 29806c31c20e32638f689ff9b0074bbc

-- query III rowsort
SELECT d,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a IS NULL
   AND a>b
ORDER BY 1,2,3;

-- query IIIIII rowsort
SELECT b-c,
       c-d,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 60 values hashing to 1d97218927132ea6eeb68998798765dd

-- query IIIII rowsort
SELECT a,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b
  FROM t1
 WHERE b IS NOT NULL
    OR d>e
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 951e266b40b8150f48baec623f0a686d

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND a IS NULL
ORDER BY 1,2,3,4,5;

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 1b021b42d846ed8372e5b8a64e4c4eae

-- query IIIIII rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       c,
       e,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to e2fe87d1ca13d2214cfb68ebeb285fcc

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 23d7b46770ede1fdc73ef30ac487ca75

-- query IIIIIII rowsort
SELECT c-d,
       abs(b-c),
       b,
       abs(a),
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 489a274fb7aeb39a8c02d774c5ae965b

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       c-d,
       abs(a)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 949a25aceb3132e83fa3405310372da7

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
ORDER BY 1;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query IIIII rowsort
SELECT a+b*2,
       c-d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 95 values hashing to 9c84288c31e030804a75653e160c1629

-- query II rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 5576a114b22ef7b73225f14861d7f4b0

-- query IIIII rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 7ee51b913f9e7c82957dd58131b1b053

-- query II rowsort
SELECT d,
       c-d
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 91395206c5a9ae2e3ba90eaaf9fbcad3

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a
  FROM t1
 WHERE b>c
   AND a>b
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2;
-- 12 values hashing to d8e53c3de9f066cbd7c55b75853ee395

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       e,
       a+b*2,
       c-d,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 61699457c79288b3b884493fcc1312c0

-- query IIIIIII rowsort
SELECT e,
       d-e,
       a+b*2+c*3+d*4,
       c,
       d,
       a-b,
       abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to 524440442f030d3deaeba575dcdfa474

-- query III rowsort
SELECT abs(b-c),
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3;
-- 30 values hashing to af433230b7fed89ab6f38404c00cf2a1

-- query IIII rowsort
SELECT c-d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e
  FROM t1
 WHERE c>d
    OR a IS NULL
    OR (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 104 values hashing to 0fd633d46f41356e377d904b1d7e08ae

-- query IIII rowsort
SELECT abs(b-c),
       (a+b+c+d+e)/5,
       b-c,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 1
-- 107
-- -1
-- 317

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       d,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 195edd4caee8c35ebcd1a306b026059b

-- query IIII rowsort
SELECT c,
       a+b*2+c*3,
       b-c,
       a-b
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to bbfd0916ec1ab98a214daa18adf03788

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
ORDER BY 1;
-- 11 values hashing to 91e1a4121a8a99224ec3880f8f82538f

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a-b,
       c-d
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 0048abc82bda6100f7d7ca07351af44a

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       d-e,
       abs(a),
       a,
       e,
       c-d
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to a35e63886c480ff2953ef9c44c877404

-- query I rowsort
SELECT c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
   AND (e>c OR e<d)
ORDER BY 1;
-- 125
-- 161
-- 187
-- 214
-- 215
-- 224
-- 231

-- query IIIIIII rowsort
SELECT a+b*2,
       (a+b+c+d+e)/5,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       e
  FROM t1
 WHERE a>b
    OR a IS NULL
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to 1a6eadef60af9a484ef356b4dbe18111

-- query IIII rowsort
SELECT a+b*2+c*3,
       d-e,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to d5410dc1707e456075f961d75c8373e3

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       abs(b-c),
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to f52714b3be854536a6021f8399270892

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 15 values hashing to c1ad7b5831d238db75f543578abe9acd

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- -2
-- 1
-- 2

-- query III rowsort
SELECT b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 51 values hashing to 3f10f53291c4c4332957f5fbb29105f3

-- query III rowsort
SELECT d-e,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (e>a AND e<b)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;

-- query IIIII rowsort
SELECT d-e,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
ORDER BY 1,2,3,4,5;
-- 20 values hashing to 3cde23794ae5812c647b191dce114ef9

-- query IIIII rowsort
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 15 values hashing to 0bae48d0d8201f75d405f24f2d341639

-- query IIIII rowsort
SELECT d,
       d-e,
       a,
       b-c,
       e
  FROM t1
 WHERE (e>c OR e<d)
    OR a IS NULL
ORDER BY 1,2,3,4,5;
-- 110 values hashing to 01e20b55ecbd46ade3cff5a56486c879

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to caf4160422e6c04f33f5dee76a5ee6ba

-- query IIII rowsort
SELECT d-e,
       d,
       c,
       b-c
  FROM t1
 WHERE a IS NULL
   AND b>c
ORDER BY 1,2,3,4;

-- query IIIII rowsort
SELECT abs(a),
       a+b*2,
       a+b*2+c*3,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 75 values hashing to 0e1d3f091ae7618b475700ba7f021e9a

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 90 values hashing to fe561dee28440461c7db2b4bbe966e6d

-- query I rowsort
SELECT c-d
  FROM t1
ORDER BY 1;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query IIIIIII rowsort
SELECT abs(a),
       a+b*2+c*3,
       a+b*2,
       c,
       d,
       a-b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to e3666393489dac8e3e03edb06718f10f

-- query IIIII rowsort
SELECT a,
       a-b,
       a+b*2,
       a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 2f3a15a8e97ebcf855a829bc06b4b32c

-- query II rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2;
-- 60 values hashing to b3bf42b26da3b06aa3b50178db6c5697

-- query III rowsort
SELECT a,
       a+b*2+c*3,
       d-e
  FROM t1
 WHERE d>e
   AND b IS NOT NULL
ORDER BY 1,2,3;
-- 33 values hashing to 3a32b8d5a3ecfe962caef1637978eb7e

-- query IIIII rowsort
SELECT b,
       d-e,
       (a+b+c+d+e)/5,
       d,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to de89b94580a889b31f615d74825bf75b

-- query IIIIII rowsort
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
    OR b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to 5387d6edebdd989ccaefbb09e17a4489

-- query IIIIII rowsort
SELECT d,
       b-c,
       a+b*2+c*3,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 96 values hashing to 00c6ced20f2eeff721db25271eae6fb3

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 317
-- 385

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 80 values hashing to 53ec7c69fa7066b8d13cba3190a01566

-- query IIII rowsort
SELECT d,
       a-b,
       b-c,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a>b
ORDER BY 1,2,3,4;
-- 32 values hashing to f82ab87aa91c92197efafacd537934bc

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to f0edfb3eeaf25d63fa068b4d1ee607fc

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       abs(a),
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
ORDER BY 1,2,3,4,5;
-- 130 values hashing to 32e82da0c738e8e4864716e5bce71c70

-- query II rowsort
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a>b
ORDER BY 1,2;
-- 34 values hashing to 17af39f9188adb8ce97fb72e6c8356ee

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9589cc1f14474dd0aa42c579d2bfedb1

-- query II rowsort
SELECT a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE c>d
ORDER BY 1,2;
-- 26 values hashing to 7423c13b5fcb65e9953181f0cea5a006

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 45 values hashing to 39128834abd158abf862c122ca26779b

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE b IS NOT NULL
    OR a>b
ORDER BY 1,2;
-- 54 values hashing to 24f085b29e652f1489e82b92cd2a3f18

-- query III rowsort
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE c>d
   AND b>c
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3;
-- -3
-- 2878
-- 579

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       a-b
  FROM t1
 WHERE d>e
   AND a>b
   AND b>c
ORDER BY 1,2,3,4,5,6;
-- 555
-- 333
-- 3
-- 2323
-- 1391
-- 2

-- query I rowsort
SELECT abs(b-c)
  FROM t1
ORDER BY 1;
-- 30 values hashing to c289bcde2e1a495d6cc09dde069c6c87

-- query III rowsort
SELECT abs(a),
       d-e,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
ORDER BY 1,2,3;
-- 21 values hashing to be9475424320a9b7ee7d2633300645a8

-- query IIIIII rowsort
SELECT b,
       a+b*2,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a)
  FROM t1
 WHERE b>c
    OR (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 150 values hashing to f046070b061166d9a9445ac1be175e05

-- query III rowsort
SELECT e,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR b>c
ORDER BY 1,2,3;
-- 42 values hashing to 4415e43a6216d494659df3c3af052083

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 132 values hashing to 6f0120b9468fa22b78b4075616d92a65

-- query IIIIIII rowsort
SELECT d-e,
       a-b,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b-c,
       d
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6,7;
-- 133 values hashing to ad299b1f694938a839c76d63aeea1f80

-- query IIIII rowsort
SELECT abs(a),
       abs(b-c),
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
   AND (a>b-2 AND a<b+2)
   AND b>c
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 5bdbcd20f9b8b742c3afd186710bd1ba

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to a4d0a38ede3fe0f188f7321970a8f4dd

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 8397a0903e15704ffd79e739a314f51b

-- query II rowsort
SELECT a,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a IS NULL
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2;

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
ORDER BY 1,2;
-- 26 values hashing to 663683e4f7954e2f02d662e397617a1a

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       b-c,
       b,
       a,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to d8d3fdc7da9f9940577c907ddc46ffce

-- query IIIII rowsort
SELECT abs(b-c),
       d,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 952ec46f635a8a1bfe40ea39b30f4ec8

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 18 values hashing to ed081fa5a86710d0e9371bd21e57b60e

-- query IIIII rowsort
SELECT b-c,
       c-d,
       d-e,
       (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 3c56becf91b5255ea828187ff5b098f4

-- query IIIIII rowsort
SELECT b,
       e,
       a+b*2+c*3+d*4+e*5,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to f72f9804cce2a5a1e0ec51599a154fe3

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       c,
       c-d,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND d>e
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6,7;
-- 49 values hashing to e5f10ba8d31c39afeed33abfce4615f4

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       a+b*2,
       abs(b-c),
       abs(a),
       b-c,
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to ea291a160f11695640cfade2795f38fd

-- query I rowsort
SELECT a
  FROM t1
 WHERE b IS NOT NULL
   AND d>e
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 127

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       b-c,
       a,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 86a4dc3efb363f1f9683ae2a20b3ee22

-- query IIII rowsort
SELECT d-e,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b IS NOT NULL
    OR a>b
ORDER BY 1,2,3,4;
-- 108 values hashing to aca58d046c3974c5452267788f36253d

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 90 values hashing to 831ec57d0eab9076adedbe5a7b29e5bf

-- query I rowsort
SELECT a-b
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- -3
-- -3
-- -4

-- query IIIII rowsort
SELECT a-b,
       (a+b+c+d+e)/5,
       a,
       a+b*2,
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 130 values hashing to 8de54a5c9493f4626950467d68cfefe2

-- query IIII rowsort
SELECT c,
       c-d,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 7cfb43e744f8e78165f7b2b7b9e4751a

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to c76015113477b90a604969958de72e28

-- query IIIII rowsort
SELECT e,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 0e9e96a0d093e7424d1a880b95bfdf56

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       a,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 126 values hashing to a9e3be887c4114d3580e4feb0f2d4fcc

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
   AND a>b
   AND a IS NULL
ORDER BY 1;

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       d
  FROM t1
 WHERE (e>a AND e<b)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
ORDER BY 1,2,3,4;
-- 108 values hashing to 978db612dff384a225a87254a55c893f

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       b-c,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to b3ccccf01d4d70c48a2ac5cedbde340a

-- query II rowsort
SELECT abs(b-c),
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND coalesce(a,b,c,d,e)<>0
   AND (e>c OR e<d)
ORDER BY 1,2;
-- 26 values hashing to 6155648a9fcd972b0fc067d251cc8e28

-- query II rowsort
SELECT b-c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2;
-- 30 values hashing to 9171c6c1e8116c8bbc186b02e5f5d53a

-- query IIIIII rowsort
SELECT a-b,
       d-e,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6;
-- 156 values hashing to 7e476544120b4f25bbc20d8a66a7ca25

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       d,
       abs(b-c),
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to cabb6bcf768ba77f886f0b24483199ff

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- 579
-- 666
-- 743

-- query IIII rowsort
SELECT a+b*2+c*3,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 20 values hashing to 8b8de03297a4e9b601746a08dccab3da

-- query IIII rowsort
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       c-d
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4;
-- 68 values hashing to 059bff8962702d7f8ec171a2b6710523

-- query IIIIII rowsort
SELECT c-d,
       a+b*2+c*3,
       d-e,
       a+b*2+c*3+d*4,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b IS NOT NULL
    OR (e>a AND e<b)
    OR (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 168 values hashing to dc3fa84cb08309cd0e59105bb6687bb2

-- query IIII rowsort
SELECT c-d,
       a,
       a+b*2+c*3,
       a-b
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to fc3ff1ff51c829b0bd8bcc949814b62f

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a IS NULL
    OR c BETWEEN b-2 AND d+2
    OR a>b
ORDER BY 1,2,3,4,5;
-- 120 values hashing to 3fb73a6642c453dc019d87cb69d8ce65

-- query I rowsort
SELECT e
  FROM t1
 WHERE c>d
   AND coalesce(a,b,c,d,e)<>0
   AND a>b
ORDER BY 1;
-- 132
-- 173
-- 180
-- 189
-- 210

-- query IIIIII rowsort
SELECT d-e,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       a+b*2+c*3,
       c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to 3a6088239fe8d4db13bd3789cf9ed7da

-- query IIII rowsort
SELECT abs(a),
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to f4530e16c6d59dfaeee60435bf008b02

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a>b
ORDER BY 1,2,3;
-- 66 values hashing to affa3f7c8cca946ae71f450ca6822fc1

-- query IIII rowsort
SELECT a,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
ORDER BY 1,2,3,4;
-- 104 values hashing to 0eed9ac4c30390c199e62f58365199eb

-- query IIIII rowsort
SELECT d-e,
       c,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 40 values hashing to a24ad9a2815293e785c73b1daaa0e8ad

-- query III rowsort
SELECT b,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to b4c390cf4b2cfb24ddd6e3f132c39aaa

-- query III rowsort
SELECT a,
       a+b*2,
       a-b
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 49d12b03e799cc0ee6e76a2a9f7c33a8

-- query IIIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c>d
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
ORDER BY 1,2,3,4,5;
-- 100 values hashing to df3961211ec3a646a12da616ad3fadc0

-- query IIIII rowsort
SELECT c-d,
       a-b,
       (a+b+c+d+e)/5,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to bf7cb204030abc772d574623b4b8cfbf

-- query III rowsort
SELECT d-e,
       b-c,
       c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
   AND a IS NULL
ORDER BY 1,2,3;

-- query I rowsort
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 2aaf5920e7c6cb16651a8794e8a1e31a

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 107
-- 317
-- 127
-- 385

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND a IS NULL
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- NULL

-- query IIII rowsort
SELECT b-c,
       e,
       c-d,
       a-b
  FROM t1
 WHERE b>c
    OR a IS NULL
    OR b IS NOT NULL
ORDER BY 1,2,3,4;
-- 108 values hashing to 7e30de55cc8c8fecffab160dec37f6cf

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       d
  FROM t1
 WHERE a>b
    OR a IS NULL
    OR b>c
ORDER BY 1,2,3;
-- 78 values hashing to 63edb99176cba2defed12c703539f05a

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       a-b,
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
 WHERE b IS NOT NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 145 values hashing to 63be192e3efa764f76ad645bbc0072f1

-- query IIII rowsort
SELECT d,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 92 values hashing to a5b6a8f716fa56ad6172f74a7ea0e544

-- query IIIIIII rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       abs(b-c)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to d4be2584de61345eb22f847ae3919f39

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c)
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2;
-- 555
-- 1
-- 555
-- 2

-- query IIIIII rowsort
SELECT a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3,
       b-c,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 144faf71d17f02b59e87b9d4f0f2d960

-- query IIIIII rowsort
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       abs(b-c),
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>c OR e<d)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 138 values hashing to 8d59f2064f6a4d8a9932bb0487115ad1

-- query III rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
ORDER BY 1,2,3;
-- 39 values hashing to 0a7270cbb622612fe7d21399b291ea34

-- query IIIIIII rowsort
SELECT c,
       b,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND coalesce(a,b,c,d,e)<>0
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 106
-- 105
-- 635
-- 1612
-- 333
-- 0
-- 333

-- query IIIIIII rowsort
SELECT c-d,
       a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 42 values hashing to 292d19ab365220a4c3e6c8d933cded12

-- query IIIIII rowsort
SELECT a-b,
       b,
       a+b*2,
       a+b*2+c*3+d*4+e*5,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
ORDER BY 1,2,3,4,5,6;
-- 72 values hashing to 3e177272e34b49de0d456303ee9c5a3e

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
ORDER BY 1,2;
-- 26 values hashing to bbcf40e5d9193aabcea50a283e717c13

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
    OR a>b
ORDER BY 1,2,3,4,5,6;
-- 138 values hashing to 36061e61f6fb65be552999cbc8a62109

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       d,
       a+b*2+c*3,
       c,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2,3,4,5,6,7;
-- 21 values hashing to c52bd0f2d82976eab5cfb785d671da7e

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 4a8f3f5cc7acabba999f282a682e4df3

-- query II rowsort
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2;
-- 42 values hashing to 9d378e63f24bd55daca7add102ebfade

-- query IIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 84 values hashing to fd9f16c948283e1fe91f2c77bad90bee

-- query IIIII rowsort
SELECT abs(b-c),
       abs(a),
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 2ebddea9b425cce206f5389f0b39fd13

-- query IIIIIII rowsort
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d,
       b-c,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b IS NOT NULL
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 21 values hashing to 6b47d7772558a73fe76fe3782ca48346

-- query IIIII rowsort
SELECT a+b*2,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
    OR a IS NULL
ORDER BY 1,2,3,4,5;
-- 25 values hashing to 4c45e9b97d8ff2b66704f4fbce35bb07

-- query IIIIII rowsort
SELECT a,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d>e
ORDER BY 1,2,3,4,5,6;
-- 72 values hashing to 880fbd81a41a9c85a5eae4cce9eb38a7

-- query I rowsort
SELECT d
  FROM t1
 WHERE c>d
    OR b>c
ORDER BY 1;
-- 22 values hashing to 37894839dede35f650b00286a84a36c1

-- query IIIIIII rowsort
SELECT d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       c,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to dc257c0ed350a49a5fc2d03ed4017bce

-- query IIIIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       d-e,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR a>b
ORDER BY 1,2,3,4,5,6;
-- 144 values hashing to 9bef3a2da8ca8adaf6ac27a55656e1d4

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5,
       b-c,
       e,
       abs(b-c),
       c-d,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (e>c OR e<d)
   AND b>c
ORDER BY 1,2,3,4,5,6,7;
-- 760
-- 127
-- 4
-- 126
-- 4
-- -3
-- 129

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       c,
       abs(a),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
ORDER BY 1,2,3,4,5;
-- 25 values hashing to a319c940b7c0dad8385a5d2d235e0ac9

-- query III rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 33 values hashing to cccc2fc956ba31f21063f4ed5504c7d5

-- query IIIIII rowsort
SELECT e,
       d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 108 values hashing to 43e44193d5e2e8bb305b0af16302e4eb

-- query III rowsort
SELECT a+b*2+c*3,
       a-b,
       d-e
  FROM t1
 WHERE a IS NULL
    OR b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 69 values hashing to 59bf333ae0b98d58bcae7a31cd5557cc

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 558d17aef1b84bc5cb6d000f08146d80

-- query III rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 90 values hashing to bf0b1691880199579089ce2f5732550a

-- query IIII rowsort
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       a-b
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 2e71f1d3ef553efa731e74493491b43e

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       d-e,
       c,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 40 values hashing to a5c45806a190a3761cd26e77f9d1b87d

-- query IIIIII rowsort
SELECT a-b,
       a+b*2+c*3+d*4,
       c-d,
       b-c,
       abs(a),
       e
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to c2341ef27ca149884884ab6c568fa923

-- query II rowsort
SELECT d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 24 values hashing to 39f21bf43fd60cb6f414344a0ebf8c6e

-- query III rowsort
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 7bc137f1d51fe79facd9ee45bf275bf8

-- query I rowsort
SELECT b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a IS NULL
ORDER BY 1;
-- 112
-- 206

-- query IIIII rowsort
SELECT c-d,
       abs(a),
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to f04293c115149822ce94d0701e876523

-- query IIIIII rowsort
SELECT abs(b-c),
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       b-c
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to d675a861445bf6449191f78a0be4d636

-- query III rowsort
SELECT d,
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 4032b38fe56b3a0b8c9306a891b2213d

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- 382
-- 440
-- 490

-- query III rowsort
SELECT a+b*2+c*3,
       abs(b-c),
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 45 values hashing to 3729b9a2cec19ed659ec404c99fef704

-- query I rowsort
SELECT d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1;
-- 133
-- 136
-- 140
-- 183
-- 196
-- 226
-- NULL
-- NULL

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       c-d,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 4b77b8e5b0c1604194e4a62a152c243b

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2,
       d-e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5;
-- 65 values hashing to 7d1010ffd2bac09eacbd2c9fba7ac5e3

-- query III rowsort
SELECT a-b,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 06f69cfca8d245108f238d4c1bc772da

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
ORDER BY 1;
-- 30 values hashing to 74b4b1d1e049d57b3610b70a67a1c32f

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR d>e
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 96 values hashing to 0a694e460dfc951a33a620b695902bd4

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       abs(a),
       c,
       a+b*2+c*3+d*4,
       e,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a IS NULL
   AND coalesce(a,b,c,d,e)<>0
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;

-- query IIIIII rowsort
SELECT c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND (a>b-2 AND a<b+2)
   AND d>e
ORDER BY 1,2,3,4,5,6;
-- 18 values hashing to 0863cee9de2d56270775813a3a17b7e5

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       a-b,
       a+b*2,
       b,
       c-d
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to 94f74078907e78ef572fa0e510484e77

-- query IIIIII rowsort
SELECT c-d,
       e,
       a+b*2+c*3+d*4,
       c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 624e1992ceabc09658eb0d5c4c493913

-- query IIIIIII rowsort
SELECT d,
       d-e,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR b>c
    OR a>b
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to c3a28a29943cda0b0369096bc4217587

-- query IIIIII rowsort
SELECT d,
       c,
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       e
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 5654e95b1947f195d63ec22ce973e453

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 140 values hashing to bd275a415055d7f30cd2fe981b1ba355

-- query IIIII rowsort
SELECT d,
       e,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       c-d
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to d2a802f554e72ad9dba374c727edf3f0

-- query IIII rowsort
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 68 values hashing to 6523173f866be3a379005fdf32d3c5fb

-- query IIIIIII rowsort
SELECT e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a-b,
       abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to c3150ef8bcd2ba7d6850a2e90e8429d2

-- query II rowsort
SELECT c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR a IS NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to d1831b90746819624b83ad192394b1a8

-- query IIIIII rowsort
SELECT e,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE b>c
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6;
-- 24 values hashing to b2cc54a61a6f44d8ab1e65618acaa745

-- query IIIIII rowsort
SELECT d,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND c>d
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to aea9f3b24ac690b7ca61dde6e38d4087

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       abs(a),
       d-e,
       b-c,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6,7;
-- 56 values hashing to dfa264954dc45c28601ad369754a1a9c

-- query III rowsort
SELECT b-c,
       abs(b-c),
       a-b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 90 values hashing to b695930cba779990506825371a4cb6f0

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       c,
       b,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND d>e
ORDER BY 1,2,3,4,5;
-- 20 values hashing to f36747a922a64a45b6021838f71a7404

-- query IIII rowsort
SELECT abs(b-c),
       a+b*2+c*3+d*4,
       e,
       b-c
  FROM t1
 WHERE a IS NULL
    OR coalesce(a,b,c,d,e)<>0
    OR b>c
ORDER BY 1,2,3,4;
-- 120 values hashing to a66e96aaa5e2333eada2f94e14e11d19

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 786e944a9c358a8be09160a4fcdb486f

-- query II rowsort
SELECT c-d,
       a-b
  FROM t1
 WHERE d>e
ORDER BY 1,2;
-- 22 values hashing to 6d5296bf2990e2c542cb932b111e58b0

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3,
       c-d,
       d-e,
       a+b*2
  FROM t1
 WHERE d>e
    OR (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 120 values hashing to cb847ba7dcd3eb1d2450a5b291047662

-- query IIIIIII rowsort
SELECT b,
       a+b*2+c*3+d*4,
       a+b*2,
       d-e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6,7;
-- 203 values hashing to b8f26217f6d969f987d08b680bcca617

-- query IIIIII rowsort
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
ORDER BY 1,2,3,4,5,6;
-- 66 values hashing to 29bf444784eb00e33aec085b59443fcf

-- query II rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 9dab3921e761fb6aeea4e154dd53814c

-- query II rowsort
SELECT e,
       c-d
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 52b55195fd2cbf5a5724611d48a47b4d

-- query I rowsort
SELECT d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
ORDER BY 1;
-- 18 values hashing to 10a54676f8fc9c6839ddbb6078163c29

-- query I rowsort
SELECT abs(a)
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
   AND d>e
ORDER BY 1,2,3,4,5;
-- 2728
-- 14
-- 184
-- 364
-- 182

-- query II rowsort
SELECT a,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to f6891d2a92880715cbd16ae236fa3074

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to eea0fe282625350bef7f9b7814de13dd

-- query IIIIII rowsort
SELECT d-e,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 98908ff5846d6cb9e3fe38fc05b19861

-- query IIIIII rowsort
SELECT abs(a),
       b,
       abs(b-c),
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to a25fc4aa4ed799e5420dff54e7cf50b8

-- query IIII rowsort
SELECT c-d,
       a+b*2+c*3+d*4,
       a,
       b-c
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to f8a8436cb97b5c9c4005e4a59e5a61b5

-- query IIIIII rowsort
SELECT a+b*2,
       abs(a),
       b,
       c,
       d,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c BETWEEN b-2 AND d+2
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6;
-- 36 values hashing to 94312feb4471e360fb2f52d49629c3c6

-- query III rowsort
SELECT d-e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to ab7bf827555e6d006830cf421fb78d5a

-- query IIIII rowsort
SELECT e,
       a-b,
       b-c,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5;
-- 85 values hashing to 80d90d98b5254af7ad522b74fdb17712

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       c-d,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 90 values hashing to f8fb8a9cc87855aa28b5a54deac3d079

-- query II rowsort
SELECT a+b*2,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 34 values hashing to 431dcbdecbfe1b6d6b282b2f49c172ac

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a)
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4;
-- 68 values hashing to abcb35b2a0d7934c081beb8189cf1b95

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5,
       d-e,
       a,
       a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 130 values hashing to a796fca93745e24a441c4418f099ada2

-- query IIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       a,
       d-e,
       e,
       c
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to 1b520683f74b5530a6d329a42c3b086c

-- query IIIIIII rowsort
SELECT b,
       c,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR b>c
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to 93621982a8d1f310b8a2c14097620bf2

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(a),
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a IS NULL
   AND (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- NULL
-- NULL
-- NULL
-- -1
-- 0

-- query IIIIII rowsort
SELECT a,
       c-d,
       b,
       a+b*2,
       b-c,
       a-b
  FROM t1
 WHERE b IS NOT NULL
   AND b>c
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to 1dcb8480bfa52a7ff3eeadb8e5f9d6b7

-- query IIIIII rowsort
SELECT b-c,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       a,
       abs(b-c)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 1ed5912b63460941c8c5a0292f0a7984

-- query II rowsort
SELECT a+b*2,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 38 values hashing to 87d92ebb256f91f8fcff006e1de357c6

-- query IIII rowsort
SELECT abs(a),
       a+b*2+c*3+d*4,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 81a8b928f88cd5217110bc243c3ab674

-- query II rowsort
SELECT e,
       abs(b-c)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 175eb8ebb1cb5751d4c04d8c8042c1ca

-- query IIII rowsort
SELECT d-e,
       a+b*2,
       c-d,
       e
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 41cf291c3e37328eea680976910a4f23

-- query IIIII rowsort
SELECT c-d,
       abs(b-c),
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d
  FROM t1
 WHERE b>c
    OR c>d
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 130 values hashing to 22615879d395d9f85a5d5410a52cbade

-- query II rowsort
SELECT a+b*2+c*3,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 10 values hashing to fc410b7d336a3f78d1e43861edfaec84

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 21 values hashing to 2f6f2dd8e351550e41f9c92450c72bc6

-- query IIIII rowsort
SELECT a+b*2,
       d-e,
       d,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 32f0873492afea01a2ec2f1c8ddb066c

-- query IIIIII rowsort
SELECT b-c,
       c,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to fd977adbddd651550a6e34a05459bb63

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       c-d,
       abs(b-c)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to e0bd6b84b335beafaddf3b8b290fdc32

-- query IIII rowsort
SELECT a,
       c-d,
       b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
   AND (c<=d-2 OR c>=d+2)
   AND b>c
ORDER BY 1,2,3,4;
-- 234
-- -2
-- 232
-- 3473

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       abs(a),
       abs(b-c),
       c-d
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 3c8f4a1535d3f43a24c81afe21c184e4

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to d1c1f508b401a056a7d00268e472c4dd

-- query I rowsort
SELECT b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND a>b
ORDER BY 1;
-- 105

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 901ba045211faeea092345b7ad51c0d5

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
 WHERE d>e
    OR a IS NULL
ORDER BY 1,2;
-- 24 values hashing to e2a022b7bd74795bc490bcc51a206498

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE b IS NOT NULL
    OR (c<=d-2 OR c>=d+2)
    OR d>e
ORDER BY 1;
-- 28 values hashing to 13f8270a8f89d6e944f5090daeadabd0

-- query III rowsort
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to b64e8dd4be2e6ece6f5a841be6390216

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to b73cc6e12fee837e4c39dc8c79ae8088

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 262db940c660e83757adc7278c5040a6

-- query III rowsort
SELECT d,
       c,
       a-b
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3;
-- 114
-- 113
-- NULL
-- 207
-- 208
-- NULL

-- query IIII rowsort
SELECT a,
       c,
       d-e,
       d
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to d55510812ed7546de990bac6f6e05f89

-- query IIIII rowsort
SELECT b,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a IS NULL
   AND (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;

-- query II rowsort
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 7d882c923da7dd6117ef8c8ef811d50f

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND b IS NOT NULL
   AND (e>a AND e<b)
ORDER BY 1,2,3;

-- query III rowsort
SELECT b-c,
       a-b,
       d-e
  FROM t1
 WHERE b IS NOT NULL
   AND (e>a AND e<b)
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3;
-- -1
-- -3
-- 1
-- 1
-- -3
-- -2

-- query IIIII rowsort
SELECT a,
       b-c,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
 WHERE d>e
   AND c BETWEEN b-2 AND d+2
   AND a>b
ORDER BY 1,2,3,4,5;
-- 25 values hashing to 419cd8bb5dda32eae9bca394f90dde33

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to cf05f8db217ea1e68c87aadfde913fec

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 85d4eec34c66b4290a8a76fd7e78cf23

-- query III rowsort
SELECT a+b*2,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
    OR b>c
ORDER BY 1,2,3;
-- 72 values hashing to f845b36d538bfc88079f0cb5eef060a2

-- query IIII rowsort
SELECT a-b,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 40 values hashing to 80e350db406b6c89ef984d914c33e892

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE a IS NULL
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       b
  FROM t1
 WHERE c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 55 values hashing to 4fb7cde1ffb36fa34c2f5dfd90654ada

-- query IIIIIII rowsort
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       b-c,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
   AND coalesce(a,b,c,d,e)<>0
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to e86dd9a09988eb25ea97879396caf6b1

-- query IIII rowsort
SELECT e,
       a+b*2+c*3,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 32 values hashing to 2cd396bd130309f87de5f36d2f475a80

-- query II rowsort
SELECT b-c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR (e>c OR e<d)
    OR a IS NULL
ORDER BY 1,2;
-- 60 values hashing to 45b5218e3b6ff1cf93bd2d8b65f62dbb

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 18f2933597761b47c2c692da942192f4

-- query II rowsort
SELECT a+b*2+c*3,
       b-c
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2;
-- 42 values hashing to 08496728df11f8eb676e1463ca29cd89

-- query IIII rowsort
SELECT e,
       a+b*2+c*3+d*4+e*5,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
   AND d NOT BETWEEN 110 AND 150
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 24 values hashing to 47e330569be3eb481186c0d6c28073c5

-- query I rowsort
SELECT a+b*2
  FROM t1
ORDER BY 1;
-- 30 values hashing to fbca95e5a969d3d61cef1ebdfb618461

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1;
-- 10 values hashing to 6e82ac65b16043b22b77cce5a6b54b85

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>a AND e<b)
   AND b IS NOT NULL
ORDER BY 1;
-- 192
-- 222
-- 247

-- query IIIII rowsort
SELECT abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       b-c
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 40 values hashing to 37f20a64c7fb356dece2c07d46d1ab67

-- query II rowsort
SELECT a+b*2,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b IS NOT NULL
   AND c>d
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2;
-- 20 values hashing to 5f495935b071bd704ed9f2508972775f

-- query IIIIII rowsort
SELECT c,
       a+b*2+c*3+d*4,
       b,
       abs(b-c),
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to f54645bfc786b7ace563665760407aba

-- query II rowsort
SELECT c-d,
       abs(a)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to fe78e4b1ff081fd27c3224d12fcc9ce5

-- query IIII rowsort
SELECT a-b,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
ORDER BY 1,2,3,4;
-- 20 values hashing to a6f5b07700b91337d455fc7b74670969

-- query IIIIIII rowsort
SELECT d-e,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 147 values hashing to 940512b6145ce091c8d1f82874510cfb

-- query III rowsort
SELECT c,
       b-c,
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 72 values hashing to 0f242e9e2f56c89d9c9be56b8e43ccd9

-- query II rowsort
SELECT b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 105
-- 107
-- 129
-- 127

-- query IIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to bff37502d1e7e46781572fa3856673bb

-- query II rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a IS NULL
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 20 values hashing to 82d982ab8667fb9211481119ba46e14a

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       e,
       c-d,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to a705f5bea82e4b8a8f28a191c6530660

-- query IIII rowsort
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 56 values hashing to cbb39a25d3afdfd29808c80cbbdced19

-- query I rowsort
SELECT d-e
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9e2d6381b04ea314cd79c5fc9325b30e

-- query II rowsort
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b IS NOT NULL
    OR coalesce(a,b,c,d,e)<>0
    OR a IS NULL
ORDER BY 1,2;
-- 60 values hashing to 7a1089974412491aad2bf8edc19d0344

-- query IIIIII rowsort
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       b-c,
       a,
       d,
       b
  FROM t1
 WHERE b IS NOT NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 174 values hashing to 03fe0d3bbd39567ee4199b3e3b15c9e0

-- query IIIIIII rowsort
SELECT a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       d
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 126317fd31fb97a1f067200b291595e8

-- query II rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 3a2b53501becfa0092d18388c1510147

-- query IIIIII rowsort
SELECT a+b*2,
       c,
       d-e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 60 values hashing to 85fd30e621d2979629fdff750ef890c6

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a IS NULL
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2;
-- 38 values hashing to 2cb9992dd2e1efb568d5c05c75270eae

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 333
-- 105
-- 333
-- 129

-- query III rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to b31f4824975e491f8148bfc8e1ee9f41

-- query IIII rowsort
SELECT e,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 68 values hashing to 85ffb6504ac3b87c0fb31d02076bb13e

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE a>b
ORDER BY 1;
-- 17 values hashing to 339d4bd65b5ceb69bc4f771072510b73

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a,
       abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
    OR d>e
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to c1050f64689e52b52a4fd459eef9efca

-- query IIIIIII rowsort
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 6c1db2552ee9e0507d6aee38b8feb8cc

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a
  FROM t1
 WHERE b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2;
-- 46 values hashing to 18f24ebfbe56b03b99e19ec7f35bee15

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       b-c,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 88 values hashing to 4f0d28dd42becf5dea31ce1ea40351b7

-- query II rowsort
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 44 values hashing to 436aec0b8f293a2a9e9f2d2d27d983e8

-- query IIII rowsort
SELECT a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE c>d
    OR (e>c OR e<d)
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 108 values hashing to 3ac458d1cc019b66a1f2985ef9e2fc30

-- query II rowsort
SELECT c,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 106
-- 109

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a-b,
       b
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
    OR d>e
ORDER BY 1,2,3,4,5,6,7;
-- 161 values hashing to f5decf8ff88f038062422376c736ce1e

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9589cc1f14474dd0aa42c579d2bfedb1

-- query II rowsort
SELECT d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2;
-- -1
-- 107
-- 2
-- 127

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 51 values hashing to fe6b57844f6bca2c80db86f273233b7f

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 12 values hashing to 3297975eebdf7bdaa556ca71560c6bad

-- query IIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       e,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to d64ae13ea13b09b451adffcce9f0d88e

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       c,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 36 values hashing to 4d84e7911b468f556cb05fb367bc2e1a

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b>c
   AND (e>c OR e<d)
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 9 values hashing to 8b75136b2b51c77345c03804ec1cda5c

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       c-d,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d NOT BETWEEN 110 AND 150
   AND b>c
ORDER BY 1,2,3,4,5,6;
-- 36 values hashing to 1dfab01a2a3cde1a0fb099a13ee8f260

-- query IIIIIII rowsort
SELECT e,
       a+b*2+c*3,
       a+b*2,
       a,
       abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 2510a4574e6b6031bf8b31706569fd18

-- query I rowsort
SELECT e
  FROM t1
 WHERE b>c
ORDER BY 1;
-- 13 values hashing to 4d4acfcd99942f84e7e344dc0cf97feb

-- query II rowsort
SELECT abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to df4d8b65a46a637f8e6623eeab84c0cd

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 7a10803f8ac1862746a5dfd7761068ec

-- query IIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to a0bd82430be70a6a69fa925b102b17a1

-- query IIIII rowsort
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to aac2b3e27334fce2b3fe88f608a6a7d2

-- query IIIIII rowsort
SELECT a+b*2,
       c-d,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 126 values hashing to 2727cf3f7baeb9cf180f6c3e47e7ac5c

-- query IIIIIII rowsort
SELECT b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to a30d10c6e226154b4f8a0a602394c523

-- query III rowsort
SELECT c,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 2dea08f9e5f055d0e54310b6521dcdf9

-- query IIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND b>c
ORDER BY 1,2,3,4;
-- 36 values hashing to 79335442c361dccabc252e74f3e843e2

-- query III rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE a>b
    OR e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
ORDER BY 1,2,3;
-- 75 values hashing to b7122692372cbdcb123689643515f27b

-- query III rowsort
SELECT a+b*2,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 68d0758e12aa7de3bf098c50b1020325

-- query II rowsort
SELECT b,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
   AND d>e
ORDER BY 1,2;
-- 10 values hashing to 3c965ff7e782f60c038c785b61f762ec

-- query I rowsort
SELECT b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 45166f9056e31d2a2c5a729b92a8069f

-- query III rowsort
SELECT abs(a),
       abs(b-c),
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3;
-- 107
-- 1
-- 107
-- 127
-- 4
-- 127

-- query IIIIIII rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 211250250d77b776c079d3ae1530f040

-- query IIII rowsort
SELECT a+b*2,
       a-b,
       b,
       d
  FROM t1
 WHERE d>e
    OR d NOT BETWEEN 110 AND 150
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 88 values hashing to 5cede43346ad9a3e7df350a2905a234e

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 30 values hashing to 5f68c99fb1307c4719cc8c8b21a13d5a

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d,
       e,
       d-e
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 6502655c587cc722407dab5bad5802b1

-- query IIIII rowsort
SELECT a+b*2,
       b-c,
       c,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c>d
   AND b>c
ORDER BY 1,2,3,4,5;

-- query IIIIII rowsort
SELECT c-d,
       a,
       a+b*2,
       abs(a),
       (a+b+c+d+e)/5,
       c
  FROM t1
 WHERE a IS NULL
    OR (c<=d-2 OR c>=d+2)
    OR b>c
ORDER BY 1,2,3,4,5,6;
-- 126 values hashing to a0c2526cbe79a2234e194925721595ac

-- query III rowsort
SELECT b-c,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR a IS NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 90 values hashing to e930affe853f103637032aeca0d8bbed

-- query I rowsort
SELECT e
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
ORDER BY 1;
-- 22 values hashing to bbd955f05cf2d985d96026cbe9fcbf95

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 1612
-- 2
-- 1902
-- -2

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b IS NOT NULL
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 30 values hashing to 269f4a3f34eee7d366575299c282bf0f

-- query I rowsort
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1;
-- 30 values hashing to f54b614acd4cb798dba29ba05152f26d

-- query IIIIII rowsort
SELECT a-b,
       c,
       (a+b+c+d+e)/5,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 168 values hashing to e1a831887ece1fd1a76178b4e62c96d3

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
    OR d>e
ORDER BY 1,2,3,4,5,6,7;
-- 154 values hashing to b3c2481d8ea84ad257e77907a46f4575

-- query IIIII rowsort
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 505171f6697927ddf587129b77ebb51b

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       a+b*2+c*3,
       c-d,
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to ab4b430395489726f0634900658ff227

-- query IIII rowsort
SELECT abs(a),
       c,
       abs(b-c),
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 116 values hashing to 4293bfad16fedc0e068f1eaba172f4b0

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       abs(a)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND c>d
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 20 values hashing to 8f4e8cad16d912e4afabac29308ba86b

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       b,
       a-b,
       a,
       a+b*2+c*3
  FROM t1
 WHERE a IS NULL
    OR b>c
ORDER BY 1,2,3,4,5,6;
-- 90 values hashing to aae88e03ac5ada995ab449e794fe5dbd

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       a-b,
       b-c,
       b,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 60 values hashing to fccfe38217c9336da83a72e1e38466e9

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       a+b*2+c*3+d*4,
       abs(b-c),
       d-e
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to f5ab411c4a38875c9fb9a8449288401b

-- query III rowsort
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 51 values hashing to 9f89c5db1a39fdf0128d784a415b7aec

-- query I rowsort
SELECT d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- 17 values hashing to 6753fb8eb6def51fd8dded76e76af57a

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 1268fe276d67a0ee132c2c5115c12cbe

-- query II rowsort
SELECT c-d,
       abs(a)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2;
-- 20 values hashing to aa007d94cb84743d77f13a517ac1c0a2

-- query II rowsort
SELECT abs(b-c),
       c-d
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2;
-- 54 values hashing to 0769f1f2c8be954b6c9fa17d55b37ee4

-- query IIIIII rowsort
SELECT b,
       c,
       e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 5a2492c56eb0a3902520dbdb321524ae

-- query IIIII rowsort
SELECT a-b,
       c,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 47c99b2a96a0b1135bfe580e677eeea1

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 48c8a67b9e81a901a1f13db6fda04911

-- query III rowsort
SELECT a-b,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b IS NOT NULL
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 44c8198ef1ff172dccb68377d71790c4

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 0
-- 107
-- 0
-- 127

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 6ad2d4d42b2ada0a52d53e56cca280d6

-- query II rowsort
SELECT a+b*2,
       a-b
  FROM t1
 WHERE a>b
   AND d>e
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 391
-- 1
-- 544
-- 1

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to 8ab46353ee866e071bf1b7af72db7e40

-- query IIIIII rowsort
SELECT d,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c>d
   AND b IS NOT NULL
   AND a>b
ORDER BY 1,2,3,4,5,6;
-- 30 values hashing to fdd011a2e0a18abb3227e4326df8ecdd

-- query IIIIIII rowsort
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       (a+b+c+d+e)/5,
       d-e
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 51eb4c6f118a3cd801249a8cd6d255c6

-- query IIII rowsort
SELECT a,
       abs(a),
       a+b*2+c*3+d*4+e*5,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
ORDER BY 1,2,3,4;
-- 72 values hashing to 082358e17e9e36e6e9d5b0c79eee1ea6

-- query II rowsort
SELECT c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 19f43f5d16381a382e6f42d423819d43

-- query IIIII rowsort
SELECT b-c,
       a+b*2+c*3+d*4,
       b,
       c-d,
       a+b*2+c*3
  FROM t1
 WHERE d>e
   AND c>d
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 25 values hashing to 299e3455af3896f73b4c030343e18557

-- query IIIIII rowsort
SELECT b,
       (a+b+c+d+e)/5,
       a-b,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4,5,6;
-- 66 values hashing to 63f9ad9303fb8a4a7b347b0e62fdff94

-- query IIIII rowsort
SELECT c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5;
-- 10 values hashing to bbe75ac144d98776fc6601ffd1e7f529

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- 17 values hashing to a4c7d8a991efd76cb5f546dad4050ef2

-- query III rowsort
SELECT a+b*2,
       b-c,
       c-d
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 682d77eb10e5a460ffaf779a07bf10b2

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 162c428c5bacc4383ffe635abbb4e5ba

-- query III rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d>e
ORDER BY 1,2,3;
-- 33 values hashing to ea6c8f3411332788326ec19211e7f3ca

-- query III rowsort
SELECT a,
       c-d,
       abs(a)
  FROM t1
 WHERE d>e
ORDER BY 1,2,3;
-- 33 values hashing to a1f305de18a165327a59c4b3250a373e

-- query IIIII rowsort
SELECT abs(b-c),
       a-b,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 2b4eff4fda2993558a9c12090b664627

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       d-e,
       a+b*2+c*3
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5;
-- 125 values hashing to 8200bbe242c05e370d1826d430378751

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- 17 values hashing to d495cc96671b8b56d893ab44a8baf564

-- query IIIIIII rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       c-d,
       d,
       a+b*2+c*3+d*4,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 39ed7676da3c420f7e9c83cce81d1a4f

-- query IIIIIII rowsort
SELECT a,
       d-e,
       e,
       a+b*2+c*3,
       abs(b-c),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to 7343926d6c48db22db873f7d5ee38428

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 15 values hashing to a879d0436172411bd1ff79ad23bcf6c5

-- query IIIIIII rowsort
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
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to bfe4d06f73a191d0b43685cefb316775

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE a IS NULL
ORDER BY 1;
-- NULL
-- NULL

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c-d
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 08da035b8a7fe742130cdb13e7ad6ff6

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2;
-- 60 values hashing to b339e36127a64202a49f498513dd40e3

-- query IIIII rowsort
SELECT b,
       d-e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a IS NULL
   AND d>e
ORDER BY 1,2,3,4,5;
-- 112
-- 4
-- NULL
-- 1
-- 444

-- query IIII rowsort
SELECT e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 6f21fb43e70dd16f186ac8d998c9a1ab

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       e,
       c-d,
       b-c,
       d
  FROM t1
 WHERE d>e
   AND a>b
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 35 values hashing to be86deef0c7e820d495982d5c6b880da

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5;
-- 130 values hashing to 6411992407fa5dc995f0fcde32cc1804

-- query II rowsort
SELECT c,
       a-b
  FROM t1
 WHERE a>b
ORDER BY 1,2;
-- 34 values hashing to d2068136b2985ee7c04a8c9b78209dad

-- query IIIIIII rowsort
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       b,
       abs(a)
  FROM t1
 WHERE c>d
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 126 values hashing to adb8714e6ea266fe29ae95aa6fd92d4d

-- query II rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2;
-- 1120
-- 112
-- NULL
-- 206

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
ORDER BY 1,2,3,4;

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2,
       a+b*2+c*3,
       d-e,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to bb3374aa095cf12d733b405f3a4b0f1e

-- query IIIIII rowsort
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       c-d,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a>b
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to a0366f44c0f21a5de9e307e2f3a2b965

-- query IIII rowsort
SELECT a-b,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 68 values hashing to 58a97ed4a9b494aafbd3a3c57da82078

-- query III rowsort
SELECT c-d,
       a+b*2,
       d-e
  FROM t1
 WHERE c>d
ORDER BY 1,2,3;
-- 39 values hashing to b3af61dbda8d2d8b5489597c7f233424

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to cca0428a4957294dfd510fc7266ea92d

-- query II rowsort
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
ORDER BY 1,2;
-- 22 values hashing to efc2b46a59d1aa24c732442ab6e2e534

-- query I rowsort
SELECT a-b
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to a8aec6acdf2c584e2f18d33820ef624e

-- query II rowsort
SELECT d-e,
       c-d
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to ef369eca6494d99a6196b047bc1be265

-- query IIIIII rowsort
SELECT c-d,
       d,
       abs(b-c),
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>c OR e<d)
ORDER BY 1,2,3,4,5,6;
-- 126 values hashing to a8aad71dc40b7ba2ba2e600b47021d38

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       b,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE b IS NOT NULL
    OR (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 0002cb7ca93935fefb9e888bd6ec0cda

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       e,
       d
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 3dcf5bdec772863d7b90fced4cc9baaa

-- query IIIIIII rowsort
SELECT c-d,
       abs(a),
       a+b*2,
       a+b*2+c*3+d*4,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to 25f32304c1bc47764dd68ff331ed7b3d

-- query III rowsort
SELECT a,
       a+b*2+c*3+d*4,
       d
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3;
-- 81 values hashing to 43ef865ccee93beaef9b0531bbe27ea1

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d>e
ORDER BY 1,2,3,4,5;
-- 55 values hashing to 629632d72a0b69e9ce52cf46e7961dc2

-- query IIIIIII rowsort
SELECT e,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 133 values hashing to 4c7875a7b6b7999ecba73c9123945b6f

-- query IIIIIII rowsort
SELECT abs(b-c),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       c,
       a
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to e7899c818ed75057d5abbe8b5f971bc6

-- query IIIIIII rowsort
SELECT abs(b-c),
       d-e,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a,
       b,
       abs(a)
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 1039be830093d12f37a63093d04e1547

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e,
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to b2e9cef39d103d581c325552c1fad51e

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       d-e,
       c-d,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 40 values hashing to 0a56263b4e542487aed6eda155f85f2a

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
    OR b>c
ORDER BY 1,2,3,4,5,6;
-- 132 values hashing to 677b478959906ed745c9582fe57c8429

-- query IIIIII rowsort
SELECT b,
       a+b*2,
       b-c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 60 values hashing to 43cc8289cc0d7aa27dd7ca100b418c79

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1;
-- 1325
-- 1371
-- 1411
-- 1828
-- 1964
-- 2264
-- NULL
-- NULL

-- query IIII rowsort
SELECT d-e,
       b-c,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 6ca1061e1b64773067b613285ddb7e57

-- query I rowsort
SELECT b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 9 values hashing to af18a98364ca4a37adc4ca16602c22da

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to 0f2004236b9faf5aa9fead02a7c49bb1

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1;
-- 391
-- 416
-- 428
-- 475
-- 502
-- 544
-- 595
-- 685

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE c>d
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- -2
-- -2
-- -4
-- 1
-- 2
-- 3
-- NULL
-- NULL

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2;
-- 16 values hashing to 2c838c66b1922cc5ef8d87bbd634c2e1

-- query I rowsort
SELECT a-b
  FROM t1
 WHERE b IS NOT NULL
   AND c>d
ORDER BY 1;
-- 11 values hashing to a727bc0a71dc5f6847d30cb017bdbf58

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR c>d
ORDER BY 1;
-- 25 values hashing to 41af91f684d2199c66e7c6d300ada96b

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       e,
       a+b*2+c*3,
       abs(b-c),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6,7;
-- 133 values hashing to 0b00640f4c88770b3c72896ca4614554

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d,
       c-d,
       a+b*2
  FROM t1
 WHERE a>b
    OR (c<=d-2 OR c>=d+2)
    OR a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 144 values hashing to ce0260b129a5febb9ede5c74aea550c5

-- query II rowsort
SELECT b-c,
       a+b*2
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to 8f8952986d01fffc8cebb109eb10e66c

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       a,
       b-c,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
 WHERE d>e
    OR c BETWEEN b-2 AND d+2
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 108 values hashing to 0c675dc8434be0a244b5e78e42d773f0

-- query IIII rowsort
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>a AND e<b)
    OR a>b
ORDER BY 1,2,3,4;
-- 80 values hashing to 782160babf2c361f1ed87683e525e840

-- query IIIIIII rowsort
SELECT b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       a-b,
       a+b*2,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to e530bba37e14c2e4bfeb984a31c25c26

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 18 values hashing to 41b00f78900bcaddd3a9faeef71701c9

-- query IIIII rowsort
SELECT c,
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       a-b,
       d
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 80 values hashing to ea31eb8eb327932f9dddcc6bc5c8c833

-- query IIII rowsort
SELECT abs(b-c),
       d-e,
       b,
       c
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to a9c76f87fd78b4d3ad82ce7bc8e64ac8

-- query IIIII rowsort
SELECT abs(b-c),
       c-d,
       d-e,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d>e
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 15 values hashing to 7c787a6339d303da1db7c981873e544b

-- query IIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND d NOT BETWEEN 110 AND 150
   AND b IS NOT NULL
ORDER BY 1,2,3,4;
-- 60 values hashing to 2007f05c0a6e062701e09fdfa0713122

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       (a+b+c+d+e)/5
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 9b776a59385a5b6e30c0e39547af4166

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a-b,
       abs(a)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to fef98e4832a2f229da033f1bc8cf44b0

-- query II rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2;
-- 52 values hashing to 5bcbb381f1d7a1f9ba896ddd0f948d71

-- query IIII rowsort
SELECT a-b,
       c,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 3dee096e2ff1cd4833ffb7474653edd0

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2,
       b,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to 9715224193fc9463e03ea8c6b1228d00

-- query IIII rowsort
SELECT b-c,
       abs(b-c),
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4;
-- 44 values hashing to 0a0d670d28969de28ede7d2e1e51ba1f

-- query III rowsort
SELECT d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE b>c
   AND d>e
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 12 values hashing to 09562012bae47f170d9275f0d6912571

-- query IIIIIII rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR a IS NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 140 values hashing to 7b013cbc35b21bdb59f96aff7f278d57

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to fb407de0e3aa5eba05dfac0f6c830cf0

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 12 values hashing to d321a3d27a70ead3b2dfaf5159362643

-- query IIII rowsort
SELECT d-e,
       e,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 104 values hashing to 5e9803a88163ef8053517360e08e9f55

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (e>c OR e<d)
    OR a IS NULL
ORDER BY 1;
-- 22 values hashing to c72292419115129326c6770fce033a0f

-- query II rowsort
SELECT a+b*2+c*3,
       abs(b-c)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 0b9ef161ef3a21dce30650b33c19bb5e

-- query I rowsort
SELECT d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- 17 values hashing to 6753fb8eb6def51fd8dded76e76af57a

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6;
-- 156 values hashing to 8cfb948d288bf26f787dbe54192f20c2

-- query IIIIII rowsort
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to e47956172c8fa5c59837e680b8bf0cc7

-- query IIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a+b*2,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 84 values hashing to 5ef7a7de359f55165792cdb3acfb2f37

-- query II rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3
  FROM t1
 WHERE a IS NULL
    OR (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
ORDER BY 1,2;
-- 26 values hashing to 693a207f237ae88b9986be9729de24a7

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to aa5d47b7ad8836779f5ac0baa36be8dd

-- query I rowsort
SELECT b
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9697cb5cadc4331af70386531f7792a9

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a+b*2+c*3+d*4
  FROM t1
 WHERE a IS NULL
   AND c>d
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5;

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE (e>c OR e<d)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1;
-- 14 values hashing to 182b05ac2b2f5031af55d5fc8e2ca678

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c
  FROM t1
 WHERE a>b
    OR a IS NULL
ORDER BY 1,2;
-- 38 values hashing to c780d393ba03d9efcbfb54dfb435ce6b

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       c-d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
ORDER BY 1,2,3;
-- 39 values hashing to 43e0495dd149fef637b37182902a70b0

-- query IIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4;
-- 44 values hashing to a0bbce0efbadffac94910fe5daccf705

-- query IIIIIII rowsort
SELECT a-b,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to 8537770ca2da14912a0a889f8a0332b5

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2,
       b,
       d-e
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 077ebe086c15dc2ff2cf7917fc5603ce

-- query IIIII rowsort
SELECT e,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       b-c,
       d-e
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to f7d2d5ba4d29dabed474bd11e679268f

-- query IIIII rowsort
SELECT c,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       a+b*2
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
    OR a IS NULL
ORDER BY 1,2,3,4,5;
-- 95 values hashing to 3e4cd208357eddf8ec1f9c0f4886f421

-- query II rowsort
SELECT b-c,
       abs(a)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to f81a96674d5188e29e9a2725a491cbee

-- query IIIII rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b,
       a
  FROM t1
 WHERE b>c
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 120 values hashing to a8ac31c7c91b1d87db3fcf5623afa85b

-- query II rowsort
SELECT a,
       c
  FROM t1
 WHERE d>e
   AND b>c
ORDER BY 1,2;
-- 127
-- 125
-- 138
-- 137
-- 234
-- 231
-- 245
-- 247

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1;
-- 28 values hashing to 1ff878f032c5cfd9be2e7d1739fd5bb1

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 15 values hashing to 3778773ed139bd0dde6579b2944d52c5

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       a-b,
       a+b*2+c*3,
       e
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 108 values hashing to c945f38fdfb7bcfe16a6e443641f2ff5

-- query IIIIIII rowsort
SELECT d-e,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
ORDER BY 1,2,3,4,5,6,7;
-- 168 values hashing to ec4cf3ef8e4c6c0576b3697f263ee288

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       d,
       c
  FROM t1
 WHERE b>c
ORDER BY 1,2,3;
-- 39 values hashing to 3a3a06de0e9583c7ab3290f3dec6e38f

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 268ffae5bbd280974bcf34ff00a53ce8

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4+e*5,
       d,
       e
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4;
-- 444
-- NULL
-- 114
-- 110
-- 444
-- NULL
-- 207
-- NULL

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR a IS NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE d>e
   AND a IS NULL
ORDER BY 1;
-- NULL

-- query IIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 34c3e27713566af5831216c8673ecec6

-- query IIIII rowsort
SELECT b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to ef543d2c1644996271362e9eb021b653

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
ORDER BY 1;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(a),
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       d
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 120 values hashing to 65ae29e27263411cbba61fe2685ffa23

-- query IIIIIII rowsort
SELECT d-e,
       (a+b+c+d+e)/5,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to a31aa071b70198721385ba5a7b7cba2c

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1;
-- 30 values hashing to 62634e04a17da0e006feac1d867155ac

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b-c,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to aa6f3fd5f298c6b3c08a6e592d89cb60

-- query III rowsort
SELECT c-d,
       c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 8ce0f8b414e39414e330e5d40720506a

-- query II rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
ORDER BY 1,2;
-- 26 values hashing to ac1ac27954b3ddbc82d232af3766a94b

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR coalesce(a,b,c,d,e)<>0
    OR (e>c OR e<d)
ORDER BY 1;
-- 30 values hashing to 445b0172de37f3ca0ed777000309cef8

-- query III rowsort
SELECT a+b*2,
       abs(b-c),
       a
  FROM t1
 WHERE a IS NULL
   AND (e>c OR e<d)
   AND c>d
ORDER BY 1,2,3;

-- query IIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a+b*2+c*3,
       d,
       d-e
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 15 values hashing to bc2ce01b3953de9946df4d58505c8398

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
ORDER BY 1;
-- -4
-- 1
-- 2
-- 3
-- NULL

-- query II rowsort
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2;
-- 107
-- 0

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       a,
       b,
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to 8af952a15dc09ac334e0d82042a24df9

-- query I rowsort
SELECT a
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b IS NOT NULL
    OR c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
ORDER BY 1;
-- 28 values hashing to 96913c6f63f3116bacfa71ff4a9f73e2

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND a>b
   AND b IS NOT NULL
ORDER BY 1,2,3;
-- 51 values hashing to fb13c2384756bc5e8255d1d7d244b5a8

-- query IIIIIII rowsort
SELECT a-b,
       a+b*2+c*3,
       c-d,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 70abb12df6491fcd04e18940ea4523b4

-- query I rowsort
SELECT c
  FROM t1
 WHERE a IS NULL
   AND (c<=d-2 OR c>=d+2)
   AND c>d
ORDER BY 1;

-- query IIIIII rowsort
SELECT e,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to 421c6610087a017188e5d506772d3234

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       d
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3;
-- 42 values hashing to c4ed1d4efe550de05e657bff5ca3e4f1

-- query IIII rowsort
SELECT c-d,
       a+b*2+c*3+d*4+e*5,
       b,
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND b IS NOT NULL
ORDER BY 1,2,3,4;
-- 36 values hashing to 06e77c39107ea08444e134ef0f89067a

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 15 values hashing to 24301db3251cc0181759db55e6ca955d

-- query III rowsort
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
ORDER BY 1,2,3;
-- 39 values hashing to 03a1cfda7ff971e7feec2aae616af091

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       a,
       abs(b-c),
       d-e,
       a+b*2
  FROM t1
 WHERE b IS NOT NULL
   AND a>b
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 40 values hashing to 367c01752379b26b48a5796d10d16ee8

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR d>e
ORDER BY 1;
-- 26 values hashing to 5c41d2c888f71bdfb301a5449bb2316d

-- query IIIIII rowsort
SELECT c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a+b*2,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 90084eaaa4371d329e7a2ac1a0ed1c5f

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE (e>a AND e<b)
    OR (a>b-2 AND a<b+2)
ORDER BY 1;
-- 11 values hashing to 9b90765be9d258ed2e6f4bafe855f8c8

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       e
  FROM t1
 WHERE (e>a AND e<b)
   AND (e>c OR e<d)
ORDER BY 1,2;
-- 3331
-- 221
-- 3706
-- 246

-- query II rowsort
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
    OR (c<=d-2 OR c>=d+2)
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2;
-- 36 values hashing to 1fa798dc51e11d6e3131bf0c82349e7d

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 1db270b129edfe2a9cbfb25cb5406519

-- query IIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4
  FROM t1
 WHERE a IS NULL
   AND b IS NOT NULL
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to e77c56203b9f140a2fbfd2b4ec315cb6

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       c-d,
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 15 values hashing to 53401db7d1bdba939ef5d0b1869fc87a

-- query IIIII rowsort
SELECT b-c,
       a+b*2,
       b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- 105 values hashing to 4d9c7a11cb1abb70ca128d4f25567c20

-- query II rowsort
SELECT c,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
   AND b IS NOT NULL
   AND (e>a AND e<b)
ORDER BY 1,2;
-- 224
-- 2226
-- 247
-- 2476

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
ORDER BY 1;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query II rowsort
SELECT d-e,
       b
  FROM t1
 WHERE a>b
ORDER BY 1,2;
-- 34 values hashing to 61ae510be58bcd19ca005e792d30db99

-- query IIIIII rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
    OR b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to d3bb54ee120d9244f04682c3992fe447

-- query I rowsort
SELECT a-b
  FROM t1
ORDER BY 1;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query IIII rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e,
       (a+b+c+d+e)/5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND a IS NULL
ORDER BY 1,2,3,4;

-- query III rowsort
SELECT abs(b-c),
       c,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 4a1cb86e3b2d0a16b93a4a43e4862ea7

-- query II rowsort
SELECT abs(a),
       d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND d NOT BETWEEN 110 AND 150
   AND c>d
ORDER BY 1,2;
-- 12 values hashing to 1db451b4f2b6f6a00ca68c20c8f5a10a

-- query IIIII rowsort
SELECT d-e,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 0f2bcf5dd0b4e7c0d86e4dea51b3669d

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       b-c,
       e,
       a-b
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 49dc85648e0395e2d12eac8679743c89

-- query II rowsort
SELECT c-d,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
ORDER BY 1,2;
-- 12 values hashing to 29cac38b69c814d477ac32eec447ae65

-- query II rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(a)
  FROM t1
 WHERE a>b
    OR (e>c OR e<d)
ORDER BY 1,2;
-- 50 values hashing to b70d30843a06f6e016d63b0d5fc5c5fc

-- query III rowsort
SELECT d,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 356b53bc2a5a060f3597859758312b6a

-- query III rowsort
SELECT abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 21 values hashing to 6e80f3e9a1c3da5eec90c6c2db4083c6

-- query IIIIII rowsort
SELECT d,
       b-c,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 90 values hashing to 1cb2eacc3e9cb1ce9a5cdd735e243c53

-- query IIIIIII rowsort
SELECT a+b*2,
       d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to aae9fe2b7aee06bb2c5a585ddf71ea79

-- query III rowsort
SELECT abs(a),
       a+b*2+c*3,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 24 values hashing to 603c6dd34471ed173cee5dc2935fcb64

-- query IIIIIII rowsort
SELECT a,
       a+b*2,
       a+b*2+c*3,
       b,
       abs(b-c),
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to fb3c6154be221c04b78b37e980225b61

-- query I rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>a AND e<b)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1;
-- 16 values hashing to 6245ac24acbce1345908146a2c06dd24

-- query IIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 13596ff760d2bd824d35c61351f80bb9

-- query II rowsort
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
    OR a>b
ORDER BY 1,2;
-- 40 values hashing to 4ff7b2fb85463226b58936d09fcc37e8

-- query IIIII rowsort
SELECT abs(a),
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 32a03da26d11e34294e2baaf4f91be64

-- query I rowsort
SELECT c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 30 values hashing to 5597b8fa34613aadc270053ea54637e5

-- query IIIII rowsort
SELECT b,
       b-c,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b IS NOT NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 75d9abddd431af42ba006b25f9f77c64

-- query I rowsort
SELECT e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR b IS NOT NULL
ORDER BY 1;
-- 28 values hashing to d2d7ee3c92135bb07a4e693017a465fa

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       a+b*2+c*3,
       c-d,
       e,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6,7;
-- 105 values hashing to a1b6d1f25e288ac504cdf45104e5bcea

-- query IIII rowsort
SELECT abs(a),
       a-b,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to cae2effd4f5bfa6d7cc193ec4fec967d

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       a-b
  FROM t1
 WHERE a>b
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 120 values hashing to 47ef020bd750bd779fc3a87e56ca1e40

-- query III rowsort
SELECT abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
 WHERE (e>a AND e<b)
    OR (e>c OR e<d)
ORDER BY 1,2,3;
-- 66 values hashing to f25bc21e77b0f80a903714dbc26594bf

-- query IIIIII rowsort
SELECT d,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
    OR d>e
ORDER BY 1,2,3,4,5,6;
-- 120 values hashing to 094387372652ced028edd125dc034efc

-- query IIIII rowsort
SELECT e,
       b-c,
       abs(b-c),
       c,
       c-d
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5;
-- 85 values hashing to cf909c6ca2632f334d02ace97fe65161

-- query IIIIIII rowsort
SELECT b,
       a-b,
       d,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       a+b*2+c*3
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to 46dcc426265c9c6d3e5a95476b486aea

-- query IIIIII rowsort
SELECT d-e,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       abs(b-c),
       c-d
  FROM t1
 WHERE (e>a AND e<b)
    OR a IS NULL
    OR c>d
ORDER BY 1,2,3,4,5,6;
-- 90 values hashing to 24562a4b1a2aff1a1a2f2cf5c4224a17

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE c>d
    OR a>b
    OR d>e
ORDER BY 1;
-- 28 values hashing to 2fcc0f3b5e0753a1f915168aa80928cb

-- query IIII rowsort
SELECT c-d,
       b-c,
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4;
-- 44 values hashing to 2a856cf96ef2c2ee896fde7ac15baf59

-- query I rowsort
SELECT e
  FROM t1
 WHERE a>b
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 30 values hashing to b9f09a0d6206ee3b897ed8a2dc580e1d

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a>b
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4;

-- query I rowsort
SELECT c
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1;
-- 29 values hashing to 725eda52ed4dea9e7b98db61d7453ca7

-- query IIIIII rowsort
SELECT e,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a,
       b-c
  FROM t1
 WHERE a>b
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
ORDER BY 1,2,3,4,5,6;
-- 36 values hashing to 36e5ee818c5f66d85faa44d5c242e3a3

-- query IIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(b-c),
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
   AND (e>a AND e<b)
ORDER BY 1,2,3,4;

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE a>b
    OR c>d
ORDER BY 1,2,3;
-- 75 values hashing to b9e8c83a8bc74e55aa613fb8bbae83b5

-- query IIIIII rowsort
SELECT c,
       b,
       abs(b-c),
       e,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 1d8546ea2c7b3aec706db25a0a5582a5

-- query III rowsort
SELECT c-d,
       d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 9 values hashing to 8426b640ba20050345c3bd7757382d40

-- query III rowsort
SELECT a-b,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR d NOT BETWEEN 110 AND 150
    OR (e>a AND e<b)
ORDER BY 1,2,3;
-- 72 values hashing to 6d2826ad5fa4926835fd3b121dde9c29

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       c,
       a+b*2
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 46952a3594167f104f7b2fc9d0667fcb

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 135 values hashing to 1e6ea1ffb48cdd83eb8219a2171309ae

-- query II rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2;
-- 54 values hashing to 944c3b21b23622f327b6f5023635db60

-- query IIIIIII rowsort
SELECT a,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 112 values hashing to 4b7e9fe3af074b9e61a12ca304736451

-- query IIIII rowsort
SELECT d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       abs(b-c),
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>c OR e<d)
    OR b>c
ORDER BY 1,2,3,4,5;
-- 125 values hashing to a4c2c5b599a12eb25e02a7a49e712b33

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       d,
       b-c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d>e
    OR b IS NOT NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 203 values hashing to 1c10d302b1c0ebea0ed1b3f458977b97

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3;
-- 1612
-- -2
-- 0
-- 1902
-- -3
-- 3

-- query IIII rowsort
SELECT (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR b IS NOT NULL
ORDER BY 1,2,3,4;
-- 120 values hashing to 1851d361af710203059df04bf29673a7

-- query IIII rowsort
SELECT c,
       a+b*2+c*3+d*4+e*5,
       b,
       a+b*2
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 10ce41f677d9d05127e3b704d98bc101

-- query IIIIII rowsort
SELECT b-c,
       b,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       d-e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 60 values hashing to acdf487118a15ea371915fc5f0f267ff

-- query IIIII rowsort
SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4,
       abs(b-c)
  FROM t1
 WHERE a IS NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 40d0564520ae2c3653e39dbaed07d225

-- query IIIIII rowsort
SELECT b,
       b-c,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a
  FROM t1
 WHERE a IS NULL
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6;
-- 72 values hashing to 2f4add22910ef08e36f4a9b91127d083

-- query II rowsort
SELECT a-b,
       d-e
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to c60a057f1b0709ced3374a0ceb82507d

-- query I rowsort
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1;
-- 1985
-- 2046
-- 2131
-- 2728
-- 2949
-- 3399
-- NULL
-- NULL

-- query IIIII rowsort
SELECT d-e,
       a,
       b-c,
       e,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 2937bb482629986f024c94114abb48d4

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2
  FROM t1
 WHERE d>e
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2;
-- 32 values hashing to 9e90687d2b7ec623140ca90b9f8aa467

-- query IIIIIII rowsort
SELECT a-b,
       a+b*2+c*3,
       abs(b-c),
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to ca41f560b82abfc4ff509877b9d62b5d

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
ORDER BY 1;
-- 1325
-- 1371
-- 1411
-- 1828
-- 1964
-- 2264
-- NULL

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       abs(b-c),
       a+b*2
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 4a7a447f6d5243f37593760f719d4ded

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND coalesce(a,b,c,d,e)<>0
   AND a IS NULL
ORDER BY 1;
-- NULL
-- NULL

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       b
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 8bc441725523cf82da0b2509fef56441

-- query IIII rowsort
SELECT a+b*2,
       a-b,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 72 values hashing to 3f86e6dcd60d73671fd42bf747b97ef2

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       a+b*2+c*3+d*4,
       d-e,
       a+b*2+c*3
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 40 values hashing to 514495abd297c1a057a65b95c2ad204c

-- query IIII rowsort
SELECT a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       b
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to ab4368667b081082064b8857255d4dfb

-- query III rowsort
SELECT c-d,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a>b
ORDER BY 1,2,3;
-- 30 values hashing to 7df01c794d7280c4cda156ce4cc15349

-- query II rowsort
SELECT b,
       a
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 16 values hashing to 468bd5a398285c1f8e2aa9340125c06b

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       d-e
  FROM t1
 WHERE b>c
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 84 values hashing to 961fc2f4c5ee210998a114c2652508ac

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       abs(a),
       d-e,
       e,
       b
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 16d7b4faefe1748ff669ad3787e9d6ed

-- query IIIII rowsort
SELECT d,
       abs(a),
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a>b
   AND (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- 25 values hashing to b86aacf967a3caef141c367a037d8b82

-- query IIIIIII rowsort
SELECT d-e,
       a+b*2,
       b-c,
       abs(b-c),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to f466adf4b72001a7e56f1288f645df0b

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE b IS NOT NULL
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 5c41d2c888f71bdfb301a5449bb2316d

-- query II rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to b2ba365f7b87dd73ac4f1c85175748ca

-- query IIIIIII rowsort
SELECT abs(a),
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       a-b,
       c,
       c-d
  FROM t1
 WHERE a>b
   AND (a>b-2 AND a<b+2)
   AND c>d
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to 060c8961d4cff53963cd257a6eee9284

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d-e
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to bbd77b718f2719f7454986877792ef5e

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e,
       a
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 3fa24bffa729a10cb7039b714b42e5d4

-- query III rowsort
SELECT b-c,
       e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c>d
ORDER BY 1,2,3;
-- 54 values hashing to 881857dc2c171a5b5629a1b02f5ace04

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3,
       a+b*2,
       a,
       a-b,
       b,
       e
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to 76706d6bfaa3ef72a37e5472f2087545

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       a+b*2+c*3+d*4,
       a+b*2,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 98 values hashing to 3c732f810d9ffae30a7349df09c761e4

-- query IIIIII rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c,
       a+b*2+c*3,
       b
  FROM t1
 WHERE b>c
    OR c>d
ORDER BY 1,2,3,4,5,6;
-- 132 values hashing to 11730d9f03d7ecbc708a87dc3640c235

-- query IIIIII rowsort
SELECT e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       d
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND b>c
   AND d>e
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 9f73d785e22ab32232fd62d9ad1f340d

-- query I rowsort
SELECT a+b*2
  FROM t1
 WHERE a>b
   AND coalesce(a,b,c,d,e)<>0
   AND a IS NULL
ORDER BY 1;

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       e,
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 32 values hashing to e068612da5055a85525a6525c7174a3f

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR coalesce(a,b,c,d,e)<>0
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5;
-- 150 values hashing to efe403e7b4ddc333a02fb214bc2a480e

-- query II rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to cad6ac29e9baa7160c13794239affff0

-- query II rowsort
SELECT c-d,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
ORDER BY 1,2;
-- 26 values hashing to 153104bccece0f4b8983f53c4fce4711

-- query IIIIIII rowsort
SELECT b,
       a+b*2+c*3,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2,
       c
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4,5,6,7;
-- 77 values hashing to 6e95b47bb3fde264a5703ac9d978a586

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR b IS NOT NULL
ORDER BY 1,2,3,4;
-- 108 values hashing to 8e4e18bd94b85bed75cf03d3a9aa0f0d

-- query IIIII rowsort
SELECT b-c,
       abs(b-c),
       d-e,
       a+b*2,
       c-d
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5;

-- query II rowsort
SELECT c-d,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a IS NULL
ORDER BY 1,2;
-- 52 values hashing to 768787064bded9f5179020bdd71a7ca4

-- query I rowsort
SELECT b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 45166f9056e31d2a2c5a729b92a8069f

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE b IS NOT NULL
    OR a>b
ORDER BY 1;
-- 27 values hashing to c6c480f662d91f78cd743fd4c1283663

-- query IIIIIII rowsort
SELECT c,
       b-c,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3,
       a,
       c-d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6,7;
-- 189 values hashing to 3b5e129e362e947f42addc2454cc9d00

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4,
       abs(b-c),
       b-c,
       d-e,
       a+b*2,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b>c
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5,6;
-- 138 values hashing to 99547f63b16be41e4b6d1ce1ecd6bbba

-- query IIIII rowsort
SELECT c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       c,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 0a190d0a39d0986d864cdafb35899dec

-- query IIIII rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       c-d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 75 values hashing to 6f1161b8b64ef7b0fc274f04938506ff

-- query IIIII rowsort
SELECT b,
       a+b*2+c*3+d*4,
       c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 480f85ae67f16e760cb55c4afc93a670

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE b IS NOT NULL
   AND b>c
ORDER BY 1;
-- 13 values hashing to bf5f4ef7a0280c43b79f03405b636d31

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- -2
-- 1
-- 2

-- query IIIII rowsort
SELECT a+b*2+c*3,
       c,
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5;

-- query IIIIIII rowsort
SELECT e,
       c-d,
       (a+b+c+d+e)/5,
       a+b*2,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6,7;
-- 21 values hashing to 81a337f03d1dc2d11b2f29cda3091722

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a>b
ORDER BY 1,2,3;
-- 72 values hashing to 82acf3b1c44d191e300317b99459564f

-- query I rowsort
SELECT a+b*2+c*3+d*4
  FROM t1
ORDER BY 1;
-- 30 values hashing to fd6d6825820cf653aceb2d72af4a5983

-- query IIIII rowsort
SELECT c-d,
       a,
       b,
       d,
       b-c
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 805631fbc56c324b76a9e5def0b20628

-- query IIIII rowsort
SELECT a,
       c,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 50 values hashing to 8b122e9905ab4554fac21a8adb7e15bb

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       (a+b+c+d+e)/5,
       abs(a)
  FROM t1
 WHERE b IS NOT NULL
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4;
-- 32 values hashing to 7df290349b27acbd369f33e1bfd8fe4a

-- query IIIII rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5;
-- 10 values hashing to f554e1ec3679835b79c7b5798663cdfd

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       abs(a),
       c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 549a029db9acfbfd3deb7f78189f3707

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       c,
       d,
       b
  FROM t1
 WHERE b IS NOT NULL
   AND c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 75 values hashing to b90bf883e6dde333753b1eb5b7b41d7b

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       d,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 515b61c8383a5d4b24b24d9b52ab5a43

-- query IIIIIII rowsort
SELECT a+b*2+c*3+d*4,
       a-b,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to 1ff69bb4e6898fa319a064037e2747bc

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a IS NULL
ORDER BY 1;
-- 15 values hashing to ee5e469b70e69479c72ba919407850bf

-- query IIII rowsort
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       e
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 120 values hashing to 37c38db934bd2d3c307dd2619bfb035a

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 50 values hashing to 1a25f2981afcfe3b90b78e5f46d408dd

-- query IIIII rowsort
SELECT abs(a),
       (a+b+c+d+e)/5,
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND c BETWEEN b-2 AND d+2
   AND b>c
ORDER BY 1,2,3,4,5;
-- 10 values hashing to 97311a820c01f81122bd9a43101bb2b3

-- query IIII rowsort
SELECT b-c,
       a+b*2,
       d,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND b>c
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4;
-- 16 values hashing to 955f14c539e3692f1b86ab3a24683a19

-- query IIIII rowsort
SELECT d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a+b*2+c*3+d*4+e*5,
       b-c
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5;
-- 65 values hashing to e3d9292d05db4167a92c6229e4caa760

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE c>d
    OR d>e
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 28 values hashing to d4cd424a829b1432ef86746a9204209d

-- query IIII rowsort
SELECT c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       a-b
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4;
-- 72 values hashing to 370fe299a3734448a7be6672f01c3a94

-- query IIIII rowsort
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       b,
       a
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5;
-- 50 values hashing to 07bc5bca23ad9ae8a819dfac639082fd

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE a IS NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 104 values hashing to 55a5e0422172b0c7a6b2067252cce354

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to 2f9a934526ac4a7f7c28016425042260

-- query IIIII rowsort
SELECT b,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       d-e
  FROM t1
 WHERE (e>a AND e<b)
    OR d>e
ORDER BY 1,2,3,4,5;
-- 60 values hashing to 82d16a26b3d57b3cc239c4f7a9593f7c

-- query IIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       e,
       abs(a),
       a+b*2+c*3,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 18 values hashing to 23bd2aa9005d7a79f92b46bfe852378d

-- query III rowsort
SELECT d-e,
       a+b*2+c*3+d*4+e*5,
       a
  FROM t1
 WHERE (e>c OR e<d)
   AND a IS NULL
   AND a>b
ORDER BY 1,2,3;

-- query IIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2,
       c-d,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 610f0faec87fe3b6c7fe13df512df7d8

-- query IIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2,
       a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5,
       d-e,
       abs(b-c)
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3,4,5,6;
-- 162 values hashing to e98414941114afc92bb0247f70af52da

-- query I rowsort
SELECT abs(b-c)
  FROM t1
ORDER BY 1;
-- 30 values hashing to c289bcde2e1a495d6cc09dde069c6c87

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- -1
-- 4

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR c>d
ORDER BY 1,2,3;
-- 90 values hashing to c5fa723aa4e2c42050943e4693f1e923

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       a,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND a IS NULL
ORDER BY 1,2,3,4,5;
-- 1
-- 113
-- NULL
-- NULL
-- 1120

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       b
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6;
-- 78 values hashing to eac728c6ddb91ccd31a0d1128417639c

-- query II rowsort
SELECT d-e,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>c OR e<d)
    OR b>c
ORDER BY 1,2;
-- 52 values hashing to 7315fb2782e02a62e78599ef812d5d8e

-- query IIIIIII rowsort
SELECT abs(b-c),
       a-b,
       d-e,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4,
       a
  FROM t1
 WHERE c>d
    OR b>c
ORDER BY 1,2,3,4,5,6,7;
-- 154 values hashing to 253db2ba2de764cddb828c61c33fa94b

-- query IIIIII rowsort
SELECT b,
       a-b,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       c,
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 61f4eb32e9f9cee66661e5545d3b1c99

-- query IIII rowsort
SELECT a,
       a+b*2,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR a IS NULL
    OR d>e
ORDER BY 1,2,3,4;
-- 68 values hashing to 17710e7f1160312d5f85b00b3baef24b

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2+c*3+d*4,
       b,
       b-c,
       d-e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to af66c8797cf0a18cf8964083d275dc3e

-- query IIIIIII rowsort
SELECT abs(a),
       (a+b+c+d+e)/5,
       c,
       d-e,
       a+b*2,
       e,
       b
  FROM t1
 WHERE a>b
ORDER BY 1,2,3,4,5,6,7;
-- 119 values hashing to a928e4c940a05e1636f24ad9d8d056c5

-- query III rowsort
SELECT a-b,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR (e>a AND e<b)
    OR c>d
ORDER BY 1,2,3;
-- 54 values hashing to 750a489b4c6cdcd65e8153612541edb4

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to a3cc5ce52e625e50e112a70b5afa9d9f

-- query IIIII rowsort
SELECT a+b*2,
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b,
       c-d
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 61e0ca2c4623a448c09ffea6be3bd5d0

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       b
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to b4010ae6b698a00474a73f648303f691

-- query II rowsort
SELECT d,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2;
-- 60 values hashing to 338667821f799dd406c1ce8fc2fcd75b

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to a092631ff16c49852d19bcde8bb84f97

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       b
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 33372d8e30d702bdbd9868d693fc2202

-- query I rowsort
SELECT d
  FROM t1
ORDER BY 1;
-- 30 values hashing to 169a721efb38857a8de46fcd1500025a

-- query IIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       a,
       b-c,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 515844256bb85001d2cb75ee98b5a8f8

-- query I rowsort
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE a>b
ORDER BY 1;
-- 17 values hashing to 4a6c075c0bc5ddff6a754adcddbe79f2

-- query III rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
ORDER BY 1,2,3;
-- 33 values hashing to 03629e50bc54a9c68b8e0642de1d4b7f

-- query III rowsort
SELECT c,
       b-c,
       a+b*2+c*3
  FROM t1
 WHERE b>c
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 39 values hashing to c01cb38d1477fb445451a60bccfb3148

-- query I rowsort
SELECT a
  FROM t1
 WHERE a IS NULL
    OR b IS NOT NULL
ORDER BY 1;
-- 27 values hashing to c6c480f662d91f78cd743fd4c1283663

-- query IIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       b-c,
       c-d,
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND a>b
ORDER BY 1,2,3,4,5,6;
-- 36 values hashing to 64c7b21a3631601a574791d879f549c1

-- query II rowsort
SELECT b,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
ORDER BY 1,2;
-- 34 values hashing to 69ba5ba7b54faa8998a04eb07686fe15

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 107
-- 127

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       c
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to bb756a7a0a00511145e15f30e94dc3ab

-- query I rowsort
SELECT a-b
  FROM t1
 WHERE a>b
   AND c BETWEEN b-2 AND d+2
   AND (e>c OR e<d)
ORDER BY 1;
-- 1
-- 1
-- 2
-- 2
-- 2
-- 2
-- 3
-- 4

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c-d,
       b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       a-b
  FROM t1
 WHERE d>e
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6,7;
-- 112 values hashing to 0f2897475eaf6ca131d1b9e12559fcec

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       e,
       a+b*2+c*3
  FROM t1
 WHERE a>b
ORDER BY 1,2,3;
-- 51 values hashing to c1b4d722bbccd5388ce36d4da5a272fe

-- query III rowsort
SELECT b,
       d,
       b-c
  FROM t1
 WHERE a IS NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3;
-- 78 values hashing to d17be0197a4dc9db4ecd65acbbf40536

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 70 values hashing to 9a7478a4b8f1a1d7ee51ac83087d9623

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
ORDER BY 1;
-- 1300
-- 1390
-- 1430
-- 1580
-- 364
-- 398
-- 458

-- query IIIIIII rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       c,
       a,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>a AND e<b)
    OR b>c
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 133 values hashing to eb09696995447bcf7629e722d6bce242

-- query I rowsort
SELECT d-e
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND e+d BETWEEN a+b-10 AND c+130
   AND a IS NULL
ORDER BY 1;

-- query IIIIIII rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       a,
       (a+b+c+d+e)/5,
       e,
       d
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 9b0beb9869ed0a96cfbcda0f59b83405

-- query I rowsort
SELECT a
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9a6afb6b859fc856aafb6a7af11a38e4

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (a>b-2 AND a<b+2)
ORDER BY 1;
-- 28 values hashing to 486fb8b2bb23aeab9339f10803b81228

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR b IS NOT NULL
ORDER BY 1,2,3,4;
-- 108 values hashing to f3cb3836a7de227290cce6b4a51594bb

-- query III rowsort
SELECT d,
       c-d,
       a+b*2
  FROM t1
 WHERE (e>c OR e<d)
    OR d>e
    OR a>b
ORDER BY 1,2,3;
-- 75 values hashing to a4ce622cd218c8c4279544e5142a5f17

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       abs(a),
       a+b*2+c*3+d*4,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a-b
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 1cde2c74be53c5dce96c25052e2e10ad

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       a-b,
       b-c,
       d
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 406047a5fba16f6298cc8865ceb16d6d

-- query IIIII rowsort
SELECT a+b*2,
       abs(b-c),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d,
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to a2a674cd1ccfa13f299403584124d24b

-- query II rowsort
SELECT a,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2;
-- 14 values hashing to 42b7e1c03bf06145255a8f16dad4070e

-- query IIIIIII rowsort
SELECT e,
       b-c,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
   AND e+d BETWEEN a+b-10 AND c+130
   AND d>e
ORDER BY 1,2,3,4,5,6,7;

-- query II rowsort
SELECT d,
       b-c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
ORDER BY 1,2;
-- 22 values hashing to 59fc2a0cb9d6eb15500b2a01873c9267

-- query IIIIIII rowsort
SELECT b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c,
       a+b*2,
       d-e,
       a+b*2+c*3+d*4,
       c-d
  FROM t1
 WHERE a IS NULL
   AND c>d
ORDER BY 1,2,3,4,5,6,7;
-- -2
-- 18
-- 208
-- NULL
-- NULL
-- NULL
-- 1

-- query III rowsort
SELECT b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a+b*2
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 2a911ac2155259959d16fcce2279272b

-- query IIIIII rowsort
SELECT e,
       b-c,
       abs(b-c),
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 30 values hashing to b79d26d49660927b80fca503f834f14f

-- query IIIII rowsort
SELECT d,
       c-d,
       abs(b-c),
       b-c,
       a+b*2+c*3
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5;
-- 65 values hashing to 3e557fbf49bddf5af6346144a1ae8837

-- query IIIIII rowsort
SELECT a-b,
       a,
       a+b*2+c*3,
       abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE b IS NOT NULL
   AND (e>c OR e<d)
   AND c>d
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to 0e34bea3ef5254baecdfc598a768bad7

-- query IIIIIII rowsort
SELECT abs(b-c),
       e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 5a6fed1060cbe05c56269ecc68bf4a0a

-- query IIIIIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       e,
       c-d,
       a,
       abs(a),
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 0eaa58bc4fb56af423e73d84dbc298c7

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       (a+b+c+d+e)/5
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 6def4225a77ed61ec70dfdfab8f4294a

-- query IIII rowsort
SELECT b,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       a+b*2+c*3
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to aa50fc18d4fe0a775060a5289c7df0f1

-- query IIII rowsort
SELECT abs(a),
       c,
       (a+b+c+d+e)/5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a IS NULL
ORDER BY 1,2,3,4;
-- NULL
-- 113
-- NULL
-- 444
-- NULL
-- 208
-- NULL
-- 444

-- query IIIIIII rowsort
SELECT abs(b-c),
       d,
       a+b*2+c*3+d*4+e*5,
       a-b,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE d>e
ORDER BY 1,2,3,4,5,6,7;
-- 77 values hashing to c2770ceec6cb227337e0706504a617e0

-- query IIIII rowsort
SELECT c,
       a-b,
       a+b*2+c*3+d*4+e*5,
       e,
       abs(a)
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to a14b7f2ccb8b1fae67646b4fb3b5113b

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       c,
       a+b*2
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 02413ad3886e868d10e60923c66d937b

-- query IIII rowsort
SELECT a-b,
       b-c,
       a+b*2,
       c-d
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4;
-- 88 values hashing to 812e25e42aa220948974f1eec8a1ddf1

-- query IIII rowsort
SELECT a+b*2+c*3,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       d-e
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4;
-- 84 values hashing to d1c417e25ee0ab9d11e97402e0f5084e

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       c-d
  FROM t1
 WHERE d>e
   AND c>d
   AND a IS NULL
ORDER BY 1,2;

-- query IIII rowsort
SELECT b,
       a-b,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 60 values hashing to 537d3f9d63f0f7718ecf18cfd06d654a

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       b,
       a,
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR b>c
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 1e4b4b28a8b6a2e471e50ea659610358

-- query IIIIIII rowsort
SELECT b-c,
       a,
       (a+b+c+d+e)/5,
       c-d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR d NOT BETWEEN 110 AND 150
    OR (e>c OR e<d)
ORDER BY 1,2,3,4,5,6,7;
-- 175 values hashing to cfcb51efe7d807a4c1df7e63499e1f7e

-- query IIIIII rowsort
SELECT a-b,
       c-d,
       (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 910f2c92d56f1b0d38588697acb0b1b8

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       a+b*2+c*3+d*4
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to ac4a1d203ab70c5087569113ced7147f

-- query I rowsort
SELECT c
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR c>d
    OR a>b
ORDER BY 1;
-- 29 values hashing to 725eda52ed4dea9e7b98db61d7453ca7

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       b,
       abs(a)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to dfaa311be6dc8e4d21f0120e3a099cf0

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
   AND c>d
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 111
-- 111
-- 333
-- 444

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4;
-- 52 values hashing to 8a4f59d60224b0bb54df3d8b9940b67f

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       d-e,
       a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d>e
    OR b>c
ORDER BY 1,2,3,4,5;
-- 100 values hashing to 8037b1bcfe636f3ff495bfd825d53e0d

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       a+b*2
  FROM t1
 WHERE b>c
ORDER BY 1,2,3;
-- 39 values hashing to 841a895d7644c667c2fad00c7f68e8e5

-- query I rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
    OR b>c
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1;
-- 25 values hashing to 152789c2cc255e73e1326c66cc7fb1e3

-- query III rowsort
SELECT d-e,
       a,
       d
  FROM t1
 WHERE (e>c OR e<d)
   AND a IS NULL
ORDER BY 1,2,3;
-- 4
-- NULL
-- 114

-- query IIIII rowsort
SELECT a,
       (a+b+c+d+e)/5,
       b-c,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- 105 values hashing to 8561ffccf2f0932bb1c2a63c34257383

-- query III rowsort
SELECT abs(a),
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       e
  FROM t1
 WHERE b IS NOT NULL
ORDER BY 1,2,3;
-- 81 values hashing to 0640407785b3503fdb251a182b6d57ab

-- query IIIII rowsort
SELECT d-e,
       a-b,
       c,
       c-d,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 632b4850194bf60509de90f1feabfb2a

-- query IIIIII rowsort
SELECT abs(b-c),
       a+b*2+c*3,
       a+b*2+c*3+d*4,
       abs(a),
       a,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 5b25ff1c58c12b1f100ac28b4685433d

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 8e7a27827336c83e4b452eda1e64be51

-- query IIII rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 108 values hashing to ca801d7b57914978b4b6e8332ae88f58

-- query IIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND c>d
ORDER BY 1,2,3,4,5;
-- 50 values hashing to ac4b616ec0c322bb2be9a742fbc3e1b4

-- query IIIII rowsort
SELECT d-e,
       a,
       a+b*2+c*3+d*4+e*5,
       abs(a),
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND c>d
   AND d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 20 values hashing to 02253cc820958e19bdcdc9135a965d7c

-- query III rowsort
SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
ORDER BY 1,2,3;
-- 24 values hashing to 82a9f46f2908306f2348047b589eeac0

-- query II rowsort
SELECT c-d,
       e
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2;
-- 60 values hashing to 588535d9ebc6d149a7057b9468ce599d

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       d-e,
       abs(a),
       a+b*2,
       c
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 6e1d4a7fb7f2779d84fb3030fdecb95a

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1;
-- 30 values hashing to ec9f02c46c399db521c47dd9cb6a40dd

-- query IIIIII rowsort
SELECT a-b,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       b-c
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to d7acf8cfbd68a26fe1476b64dd164ef2

-- query IIII rowsort
SELECT abs(a),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
   AND a IS NULL
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4;

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
ORDER BY 1;
-- 30 values hashing to 9589cc1f14474dd0aa42c579d2bfedb1

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       c-d,
       a+b*2+c*3+d*4+e*5,
       a+b*2,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       e
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 9756db9aac4e087c276ae4c671e83fdc

-- query III rowsort
SELECT abs(a),
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (e>c OR e<d)
    OR c>d
ORDER BY 1,2,3;
-- 78 values hashing to 601783bc6cee105e35b85bffdefdabf0

-- query IIIII rowsort
SELECT d,
       b-c,
       c-d,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- 105 values hashing to 7e4e0609be3b34884ac960d168df1d08

-- query IIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b,
       abs(a),
       a+b*2+c*3+d*4
  FROM t1
 WHERE b>c
   AND (e>a AND e<b)
   AND b IS NOT NULL
ORDER BY 1,2,3,4;
-- 111
-- 249
-- 245
-- 2476
-- 222
-- 194
-- 191
-- 1918

-- query II rowsort
SELECT a+b*2,
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND a IS NULL
ORDER BY 1,2;
-- NULL
-- NULL

-- query IIII rowsort
SELECT c-d,
       abs(b-c),
       a-b,
       a
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 6449326185cfb2c4b591e22f1d0b9c43

-- query IIIIII rowsort
SELECT a,
       a+b*2+c*3+d*4+e*5,
       e,
       a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to d18f2b7889b1931bf2ad6e5c5b5d4434

-- query IIIIIII rowsort
SELECT abs(b-c),
       d,
       abs(a),
       a-b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c-d,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE b>c
    OR c>d
ORDER BY 1,2,3,4,5,6,7;
-- 154 values hashing to f2c0443c634f22d927709c9df7248cb4

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       e,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to e180b57b4723cf0cf9dbac7b9bf7036a

-- query IIII rowsort
SELECT a,
       a+b*2+c*3+d*4,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND c>d
   AND b IS NOT NULL
ORDER BY 1,2,3,4;
-- 20 values hashing to bd0a4f265ee4fa29a213395d83a0776d

-- query I rowsort
SELECT c
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1;
-- 193
-- 224
-- 247

-- query II rowsort
SELECT (a+b+c+d+e)/5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
   AND c>d
ORDER BY 1,2;
-- 10 values hashing to 2832b4b5ac653f653d22d7f12a93cf9e

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND d NOT BETWEEN 110 AND 150
   AND a>b
ORDER BY 1;
-- -1
-- -1
-- -1
-- -3
-- 1

-- query IIIII rowsort
SELECT e,
       a-b,
       b-c,
       d-e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a IS NULL
    OR (e>a AND e<b)
ORDER BY 1,2,3,4,5;
-- 25 values hashing to dc878db9fa79ddf65d2d494dd4e6f88c

-- query IIIII rowsort
SELECT a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       c-d,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4,5;
-- 95 values hashing to 451208c9117faf9f6575928cd5fcbcf3

-- query III rowsort
SELECT d-e,
       a-b,
       b-c
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 864c4406e97c2f59c84ce3ca396d1ab8

-- query I rowsort
SELECT c
  FROM t1
 WHERE b>c
    OR b IS NOT NULL
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 27 values hashing to 8aefe123549b9829fb99271a217cb9a2

-- query IIIIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       e,
       d-e,
       a-b,
       a+b*2+c*3,
       a
  FROM t1
 WHERE c>d
    OR d>e
ORDER BY 1,2,3,4,5,6;
-- 114 values hashing to e60614d0810e9d20d1ba7d5ec76faae4

-- query III rowsort
SELECT a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR c>d
ORDER BY 1,2,3;
-- 51 values hashing to 6257dc95c2d19fe398936dcf19cc0fd7

-- query IIIIIII rowsort
SELECT c,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       d
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 133 values hashing to 17d275371a37f40f92cc7a00385ceef1

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c),
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1,2,3,4,5;
-- 105 values hashing to eff52972830501f3a2595f830cc27718

-- query III rowsort
SELECT (a+b+c+d+e)/5,
       d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR c BETWEEN b-2 AND d+2
    OR a>b
ORDER BY 1,2,3;
-- 84 values hashing to dddaa7a5327df8e332800a2692c9fd3c

-- query IIII rowsort
SELECT a+b*2+c*3+d*4,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       e
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND b>c
ORDER BY 1,2,3,4;
-- 24 values hashing to 4322e1fd1ebd79c0adcf73292b568d18

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       a+b*2,
       e,
       c,
       abs(a),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE (e>c OR e<d)
   AND c>d
ORDER BY 1,2,3,4,5,6;
-- 48 values hashing to e123674e3f83b126ddc91ddfb4ec283e

-- query IIIIII rowsort
SELECT d,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       e,
       a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6;
-- 12 values hashing to 586bb8dc59a82a2d1a8dd742453b7009

-- query II rowsort
SELECT a+b*2+c*3+d*4,
       a-b
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (e>c OR e<d)
    OR c>d
ORDER BY 1,2;
-- 52 values hashing to 953d2bddf44b39d6a8131c7e0d8527ab

-- query I rowsort
SELECT (a+b+c+d+e)/5
  FROM t1
 WHERE (e>c OR e<d)
ORDER BY 1;
-- 21 values hashing to 3a5c51b5d871430790d3e62143a2ca9c

-- query IIII rowsort
SELECT a+b*2,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       abs(b-c),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 07bd2709604b3d638589a37e24a6142c

-- query IIIIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       c,
       a,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE c>d
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 45e6f78c344e1febadcfb399ccdb77d0

-- query IIIIII rowsort
SELECT a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b,
       a+b*2+c*3+d*4+e*5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       b
  FROM t1
 WHERE d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4,5,6;
-- 66 values hashing to 2bd8a28e2c3a998bd3b34756f07b98de

-- query IIIIIII rowsort
SELECT a+b*2+c*3,
       b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       (a+b+c+d+e)/5,
       a,
       d
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to 719552a6d050bc0883d65efb01ca392c

-- query IIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2,
       (a+b+c+d+e)/5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE a>b
    OR c BETWEEN b-2 AND d+2
    OR e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4,5,6;
-- 150 values hashing to 5db6c9ec6926b5c79fc5e8a4c523abc4

-- query I rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND d>e
ORDER BY 1;
-- 11 values hashing to be1fb32359cadf053dc7743dd3945178

-- query III rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a+b*2+c*3,
       d
  FROM t1
 WHERE b>c
   AND (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3;
-- 12 values hashing to e170e72ed3c6c65f197d2de7a3c22834

-- query I rowsort
SELECT a-b
  FROM t1
ORDER BY 1;
-- 30 values hashing to a8508bcdf86e494dd5feccb5ca8d9768

-- query IIIII rowsort
SELECT c-d,
       abs(a),
       a,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR c>d
ORDER BY 1,2,3,4,5;
-- 140 values hashing to d4f3b53d6c183b6326b0c2564db94ea0

-- query IIII rowsort
SELECT c-d,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
ORDER BY 1,2,3,4;
-- 104 values hashing to cd111f29f5f7f36e2a77b27e33dbd004

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       b-c,
       abs(b-c),
       e,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (a+b+c+d+e)/5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR a IS NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6,7;
-- 161 values hashing to ad90c576a238ab887d1339af826fbae7

-- query III rowsort
SELECT a+b*2+c*3+d*4,
       (a+b+c+d+e)/5,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR (e>a AND e<b)
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3;
-- 87 values hashing to 54008cb7c43c992b88512ae92630f7d2

-- query III rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       abs(a),
       c-d
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR (c<=d-2 OR c>=d+2)
    OR b>c
ORDER BY 1,2,3;
-- 57 values hashing to 886592d9da106aa25f38a55801e8ac69

-- query IIIIII rowsort
SELECT a-b,
       d-e,
       abs(b-c),
       e,
       a+b*2,
       b-c
  FROM t1
 WHERE a IS NULL
   AND b>c
   AND (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5,6;

-- query III rowsort
SELECT b-c,
       a+b*2+c*3,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE b>c
    OR e+d BETWEEN a+b-10 AND c+130
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3;
-- 48 values hashing to 6307101e8338aba164354bdb1282d73d

-- query IIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       c-d,
       e
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
ORDER BY 1,2,3,4;
-- 60 values hashing to 8f74be728e555a10648e2137a01e3bc0

-- query III rowsort
SELECT d,
       a,
       b
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 8dfc55883d23fac968db336e7eb05819

-- query IIII rowsort
SELECT b,
       a,
       a+b*2+c*3+d*4,
       (a+b+c+d+e)/5
  FROM t1
 WHERE b>c
   AND (a>b-2 AND a<b+2)
   AND e+d BETWEEN a+b-10 AND c+130
ORDER BY 1,2,3,4;

-- query IIIIII rowsort
SELECT a,
       a+b*2,
       b-c,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE (e>a AND e<b)
ORDER BY 1,2,3,4,5,6;
-- 18 values hashing to 506ea6fa327350f3bc05be2325c7037e

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       b-c,
       c-d,
       a+b*2+c*3,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE d>e
    OR a IS NULL
    OR d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5;
-- 105 values hashing to ab84430c78ddb8d0d0d19474da34643f

-- query IIIII rowsort
SELECT abs(a),
       d,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       c
  FROM t1
 WHERE a IS NULL
   AND c>d
   AND a>b
ORDER BY 1,2,3,4,5;

-- query IIIIIII rowsort
SELECT abs(b-c),
       (a+b+c+d+e)/5,
       a-b,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       b-c,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END
  FROM t1
 WHERE a IS NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4,5,6,7;
-- 14 values hashing to 618c86d29c136607a70868aa0904aa06

-- query II rowsort
SELECT b-c,
       abs(a)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR (e>a AND e<b)
ORDER BY 1,2;
-- 60 values hashing to f81a96674d5188e29e9a2725a491cbee

-- query I rowsort
SELECT b-c
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR (e>a AND e<b)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- 30 values hashing to c5a2b847c6c21100b32db39349809b0e

-- query IIII rowsort
SELECT a+b*2+c*3+d*4+e*5,
       a,
       a+b*2+c*3+d*4,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1,2,3,4;
-- 112 values hashing to 906803dad947847164e3a1bd7856a35c

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
   AND a IS NULL
   AND coalesce(a,b,c,d,e)<>0
ORDER BY 1;
-- NULL
-- NULL

-- query IIIII rowsort
SELECT e,
       a+b*2,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 9657f08c27dcf035d9e0c2e95cc4d75f

-- query IIIIIII rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       a+b*2,
       a-b,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       d-e
  FROM t1
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to b4a7869dee46edfc2130eb57eeddd3e2

-- query IIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       a-b,
       abs(b-c)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
   AND c>d
ORDER BY 1,2,3,4,5;
-- 40 values hashing to 37a6d88bfb16420fe6ffcfb0389bb483

-- query I rowsort
SELECT abs(a)
  FROM t1
 WHERE c>d
ORDER BY 1;
-- 13 values hashing to 7d6be458c1183d1520b654a8117570fe

-- query IIII rowsort
SELECT e,
       a+b*2,
       c,
       d-e
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 8229fc62414ac478d35fc865e46beba5

-- query IIII rowsort
SELECT d-e,
       d,
       a,
       a+b*2
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 75f1c2193cc02c75e60ae3b6c925a916

-- query I rowsort
SELECT a
  FROM t1
 WHERE c>d
ORDER BY 1;
-- 13 values hashing to 7d6be458c1183d1520b654a8117570fe

-- query IIIIII rowsort
SELECT c-d,
       a+b*2+c*3,
       a+b*2+c*3+d*4+e*5,
       a,
       b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
ORDER BY 1,2,3,4,5,6;
-- 102 values hashing to 12665cbcc870eefa3f4cc0d11a9991d5

-- query III rowsort
SELECT CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(a),
       a+b*2+c*3
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3;
-- 90 values hashing to 23c4156570b0b850e857e907cadd7306

-- query IIIII rowsort
SELECT (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       abs(a),
       b,
       a-b,
       a+b*2+c*3+d*4
  FROM t1
 WHERE (a>b-2 AND a<b+2)
   AND (e>c OR e<d)
   AND a>b
ORDER BY 1,2,3,4,5;
-- 25 values hashing to 2378cc3c476ffe4a8e946543b42a9d9d

-- query IIIII rowsort
SELECT a+b*2+c*3+d*4,
       a+b*2+c*3+d*4+e*5,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       (SELECT count(*) FROM t1 AS x WHERE x.c>t1.c AND x.d<t1.d),
       (a+b+c+d+e)/5
  FROM t1
 WHERE a>b
    OR (a>b-2 AND a<b+2)
ORDER BY 1,2,3,4,5;
-- 95 values hashing to 194147ebc0159ce5e6de96a285359361

-- query IIIII rowsort
SELECT d,
       abs(b-c),
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       b
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND a IS NULL
   AND c>d
ORDER BY 1,2,3,4,5;

-- query IIII rowsort
SELECT b,
       d-e,
       a+b*2,
       b-c
  FROM t1
ORDER BY 1,2,3,4;
-- 120 values hashing to 373df092a93b28b07e7af72a6365b90e

-- query IIIIII rowsort
SELECT c,
       e,
       a+b*2,
       abs(b-c),
       b-c,
       a
  FROM t1
 WHERE a IS NULL
   AND (e>a AND e<b)
   AND b IS NOT NULL
ORDER BY 1,2,3,4,5,6;

-- query IIIIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2,
       a+b*2+c*3+d*4+e*5,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3,
       a-b,
       a
  FROM t1
 WHERE b>c
ORDER BY 1,2,3,4,5,6,7;
-- 91 values hashing to 0ad92c52d72f7b62755150d1cc34a4ef

-- query IIIIIII rowsort
SELECT e,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       a-b,
       abs(b-c),
       abs(a)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR b>c
ORDER BY 1,2,3,4,5,6,7;
-- 168 values hashing to 8781330a228647b4efdfd2abbccd3f93

-- query IIIIIII rowsort
SELECT a-b,
       c,
       b,
       b-c,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       (a+b+c+d+e)/5,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR (c<=d-2 OR c>=d+2)
ORDER BY 1,2,3,4,5,6,7;
-- 210 values hashing to e7395b6a397534eb6c79b00a6cbf5faf

-- query IIIII rowsort
SELECT abs(b-c),
       d-e,
       c-d,
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
    OR c>d
    OR d>e
ORDER BY 1,2,3,4,5;
-- 150 values hashing to 56327e383a710587cd5f4205603ee4bc

-- query IIIIIII rowsort
SELECT a-b,
       (a+b+c+d+e)/5,
       abs(b-c),
       c,
       abs(a),
       e,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR a IS NULL
ORDER BY 1,2,3,4,5,6,7;
-- 203 values hashing to 5115916b701ad1d957ff0342cf9ed9b3

-- query IIII rowsort
SELECT a+b*2,
       c,
       e,
       b
  FROM t1
 WHERE (e>a AND e<b)
    OR coalesce(a,b,c,d,e)<>0
ORDER BY 1,2,3,4;
-- 120 values hashing to 978da2a4ac397e44e638d685b7e1de7d

-- query IIII rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       d,
       (a+b+c+d+e)/5,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b)
  FROM t1
 WHERE a>b
   AND (e>a AND e<b)
ORDER BY 1,2,3,4;

-- query I rowsort
SELECT a+b*2+c*3+d*4+e*5
  FROM t1
 WHERE (a>b-2 AND a<b+2)
    OR d NOT BETWEEN 110 AND 150
    OR EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 29 values hashing to 67079c1a773f2fc4382618135f2e0719

-- query II rowsort
SELECT b-c,
       a+b*2+c*3+d*4+e*5
  FROM t1
ORDER BY 1,2;
-- 60 values hashing to edc74796a9c28c4af36d6fb5faa5d0e2

-- query I rowsort
SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
ORDER BY 1;
-- 26 values hashing to 04805712f856ee99414b33bd106ed0c5

-- query III rowsort
SELECT a-b,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a
  FROM t1
ORDER BY 1,2,3;
-- 90 values hashing to 2e7d76b188bec6999ed83e1f2d4f6383

-- query I rowsort
SELECT abs(b-c)
  FROM t1
 WHERE coalesce(a,b,c,d,e)<>0
   AND b IS NOT NULL
ORDER BY 1;
-- 27 values hashing to 726c5ed379e4b774e40e82e6dbdde380

-- query II rowsort
SELECT c-d,
       abs(b-c)
  FROM t1
 WHERE (c<=d-2 OR c>=d+2)
   AND e+d BETWEEN a+b-10 AND c+130
   AND b IS NOT NULL
ORDER BY 1,2;
-- -2
-- 1
-- -3
-- 4

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       e,
       c-d,
       a+b*2+c*3,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a-b
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
    OR coalesce(a,b,c,d,e)<>0
    OR a IS NULL
ORDER BY 1,2,3,4,5,6;
-- 180 values hashing to 4a09d612e6ee25eb68bd8c0060901f36

-- query II rowsort
SELECT a-b,
       a
  FROM t1
 WHERE c>d
ORDER BY 1,2;
-- 26 values hashing to 9de411d9f4f9b07040f9b8f63b6e432c

-- query IIIIII rowsort
SELECT (a+b+c+d+e)/5,
       a+b*2+c*3+d*4+e*5,
       d-e,
       a+b*2,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       c
  FROM t1
 WHERE c BETWEEN b-2 AND d+2
   AND b>c
   AND a>b
ORDER BY 1,2,3,4,5,6;
-- 232
-- 3473
-- 3
-- 698
-- 555
-- 231

-- query I rowsort
SELECT a+b*2+c*3
  FROM t1
 WHERE e+d BETWEEN a+b-10 AND c+130
    OR c>d
    OR a IS NULL
ORDER BY 1;
-- 16 values hashing to 393ec0319f60a4bcad062e8ed256490f

-- cleanup created tables
DROP TABLE t1;
