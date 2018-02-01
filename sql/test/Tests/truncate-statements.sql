CREATE TABLE testing (ab INT);
INSERT INTO testing VALUES (1);
TRUNCATE testing;

CREATE TABLE testing2 (abc INT);

CREATE TRIGGER nanani2 AFTER TRUNCATE ON testing FOR EACH STATEMENT BEGIN ATOMIC INSERT INTO testing2 VALUES (1); END;

INSERT INTO testing VALUES (2), (3);
TRUNCATE testing;
SELECT COUNT(*) FROM testing2; --there should be 1 row

DROP TRIGGER nanani2;
TRUNCATE testing2;

CREATE TRIGGER nanani2 AFTER DELETE ON testing FOR EACH STATEMENT BEGIN ATOMIC INSERT INTO testing2 VALUES (2); END;

INSERT INTO testing VALUES (4);
TRUNCATE testing;
INSERT INTO testing VALUES (5);
DELETE FROM testing;

SELECT COUNT(*) FROM testing2; --there should be 1 row

DROP TRIGGER nanani2;
DROP TABLE testing;
DROP TABLE testing2;
