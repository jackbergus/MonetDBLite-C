CREATE TABLE een (a INTEGER, b INTEGER, C integer);
UPDATE een SET (A,B,C) = (SELECT 2,2,2);
SELECT * FROM een;

