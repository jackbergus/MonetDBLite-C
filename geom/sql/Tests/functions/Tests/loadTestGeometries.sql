CREATE TABLE geometries(id serial, geom geometry);

--simple geometries
--1 closed
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('POINT(10 20)'));
--2 
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('LINESTRING(10 20, 30 40, 50 60)'));
--3 closed
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('POLYGON((10 10, 10 20, 20 20, 20 10, 10 10))'));
--4 closed
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('MULTIPOINT(10 20, 30 40)'));
--5
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('MULTILINESTRING((30 40, 40 50), (50 60, 60 70))'));
--6
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('MULTILINESTRING((30 40, 40 50, 30 40), (50 60, 60 70))'));
--7 closed
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('MULTILINESTRING((30 40, 40 50, 30 40), (50 60, 40 50, 20 30, 50 60))'));
--8
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('MULTIPOLYGON(((10 10, 10 20, 20 20, 20 10, 10 10),(30 30, 30 40, 40 40, 40 30, 30 30)))'));
--9
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('GEOMETRYCOLLECTION(POINT(10 20),LINESTRING(10 20, 30 40),POLYGON((10 10, 10 20, 20 20, 20 10, 10 10)))'));
--10 closed
INSERT INTO geometries(geom) VALUES(ST_WKTToSQL('GEOMETRYCOLLECTION(POINT(10 20),LINESTRING(10 20, 30 40, 10 20),POLYGON((10 10, 10 20, 20 20, 20 10, 10 10)))'));
