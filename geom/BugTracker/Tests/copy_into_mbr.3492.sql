CREATE TABLE geom (id INTEGER, g GEOMETRY, b MBR);
INSERT INTO geom values (1, 'POLYGON((1 2, 3 2, 3 4, 1 4, 1 2))', NULL);
INSERT INTO geom values (2, 'POLYGON((1 2, 3 2, 3 4, 1 4, 1 2))', 'BOX(1 2,3 4)');
INSERT INTO geom values (3, 'POLYGON((1 2, 3 2, 3 4, 1 4, 1 2))', 'BOX (1 2,3 4)');
INSERT INTO geom values (4, NULL, NULL);
SELECT * FROM geom ORDER BY id;
UPDATE geom SET b = MBR(g);
SELECT * FROM geom ORDER BY id;
CREATE TABLE newgeom (id INTEGER, g GEOMETRY, b MBR);
INSERT INTO newgeom SELECT * FROM geom ORDER BY id;
SELECT * FROM newgeom ORDER BY id;
DROP TABLE geom;
DROP TABLE newgeom;
