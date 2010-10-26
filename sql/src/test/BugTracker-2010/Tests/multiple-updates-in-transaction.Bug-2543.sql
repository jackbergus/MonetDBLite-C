CREATE TABLE people (id TINYINT PRIMARY KEY, name VARCHAR(128) NOT NULL);
INSERT INTO people (id,name) SELECT 0,'Phil Ivey';
INSERT INTO people (id,name) SELECT 1,'Michael Jordan';
INSERT INTO people (id,name) SELECT 2,'Lionel Messi';
SELECT * FROM people ORDER BY id;
START TRANSACTION;
UPDATE people SET id = -1 WHERE name='Phil Ivey';
SELECT * FROM people ORDER BY id;
UPDATE people SET id = -2 WHERE name='Phil Ivey';
SELECT * FROM people ORDER BY id;
COMMIT;
SELECT * FROM people ORDER BY id;
DROP TABLE people;
