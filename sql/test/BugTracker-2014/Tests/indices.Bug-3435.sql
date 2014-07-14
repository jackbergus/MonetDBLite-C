START TRANSACTION;

CREATE TABLE TEST1 (ONE int, TWO INT) ;
CREATE TABLE TEST2 (ONE int, TWO INT) ;
INSERT INTO TEST1 VALUES (1, 1) ;
INSERT INTO TEST2 VALUES (1, 1) ;

-- all is well
SELECT COUNT(*) FROM TEST1 JOIN TEST2 USING(ONE, TWO);

CREATE INDEX ONEDEX ON TEST1 (ONE, TWO);
-- no results?
SELECT COUNT(*) FROM TEST1 JOIN TEST2 USING(ONE, TWO);

DROP INDEX ONEDEX;
-- all is well again
SELECT COUNT(*) FROM TEST1 JOIN TEST2 USING(ONE, TWO);

ROLLBACK;
