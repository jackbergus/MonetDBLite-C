--PointZM
CREATE TABLE "pointzm" (
	gid SERIAL,
	geom GEOMETRY(POINTZM));

INSERT INTO "pointzm"(geom) VALUES('01010000800000000000000000000000000000F03F0000000000000040');
INSERT INTO "pointzm"(geom) VALUES('01010000800000000000002240000000000000F0BF00000000000000C0');
INSERT INTO "pointzm"(geom) VALUES('01010000800000000000002240000000000000F0BF00000000000034C0');
--PostGIS WKB: INSERT INTO "pointzm"(geom) VALUES('01010000C00000000000000000000000000000F03F00000000000000400000000000000840');
--PostGIS WKB: INSERT INTO "pointzm"(geom) VALUES('01010000C00000000000002240000000000000F0BF00000000000000C000000000000008C0');
--PostGIS WKB: INSERT INTO "pointzm"(geom) VALUES('01010000C00000000000002240000000000000F0BF00000000000034C00000000000C05EC0');
--WKT: INSERT INTO "pointzm"(geom) VALUES(ST_PointFromText('POINT(0.0 1.0 2.0 3.0)'));
--WKT: INSERT INTO "pointzm"(geom) VALUES(ST_PointFromText('POINT(9.0 -1.0 -2.0 -3.0)'));
--WKT: INSERT INTO "pointzm"(geom) VALUES(ST_PointFromText('POINT(9.0 -1.0 -20.0 -123.0)'));

--MultiPointZM
CREATE TABLE "multipointzm" (
	gid SERIAL,
	geom GEOMETRY(MULTIPOINTZM));

INSERT INTO "multipointzm"(geom) VALUES('01040000800300000001010000800000000000000000000000000000F03F000000000000004001010000800000000000002240000000000000F0BF00000000000000C001010000800000000000002240000000000000F0BF00000000000034C0');
--PostGIS WKB: INSERT INTO "multipointzm"(geom) VALUES('01040000400300000001010000400000000000000000000000000000F03F000000000000084001010000400000000000002240000000000000F0BF00000000000008C001010000400000000000002240000000000000F0BF0000000000C05EC0');
--WKT: INSERT INTO "multipointzm"(geom) VALUES(ST_MPointFromText('MULTIPOINT(0.0 1.0 2.0 3.0,9.0 -1.0 -2.0 -3.0,9.0 -1.0 -20.0 -123.0)'));

--ArcZM
CREATE TABLE "arczm" (
	gid SERIAL,
	geom GEOMETRY(MULTILINESTRINGZM));

INSERT INTO "arczm"(geom) VALUES('01050000800300000001020000800200000000000000000000000000000000000000000000000000F03F000000000000F03F000000000000F03F0000000000000040010200008002000000000000000000084000000000000008400000000000000840000000000000104000000000000010400000000000001040010200008003000000000000000000244000000000000024400000000000001440000000000000144000000000000014400000000000001840000000000000084000000000000008400000000000001C40');
--PostGIS WKB: INSERT INTO "arczm"(geom) VALUES('01050000C00300000001020000C00200000000000000000000000000000000000000000000000000F03F0000000000002240000000000000F03F000000000000F03F0000000000000040000000000000204001020000C0020000000000000000000840000000000000084000000000000008400000000000001C40000000000000104000000000000010400000000000001040000000000000184001020000C00300000000000000000024400000000000002440000000000000144000000000000014400000000000001440000000000000144000000000000018400000000000001040000000000000084000000000000008400000000000001C400000000000001040');
--WKT: INSERT INTO "arczm"(geom) VALUES(ST_MLineFromText('MULTILINESTRING((0.0 0.0 1.0 9.0,1.0 1.0 2.0 8.0),(3.0 3.0 3.0 7.0,4.0 4.0 4.0 6.0),(10.0 10.0 5.0 5.0,5.0 5.0 6.0 4.0,3.0 3.0 7.0 4.0))'));

--PolygonZM
CREATE TABLE "polygonzm" (
	gid SERIAL,
	geom GEOMETRY(MULTIPOLYGONZM));

INSERT INTO "polygonzm"(geom) VALUES('0106000080020000000103000080020000000500000000000000000000000000000000000000000000000000000000000000000000000000000000002440000000000000184000000000000024400000000000002440000000000000104000000000000024400000000000000000000000000000004000000000000000000000000000000000000000000000000005000000000000000000144000000000000014400000000000002040000000000000204000000000000014400000000000002C4000000000000020400000000000002040000000000000284000000000000014400000000000002040000000000000244000000000000014400000000000001440000000000000204001030000800200000005000000000000000000F0BF000000000000F0BF000000000000F0BF000000000000F0BF00000000000024C000000000000018C000000000000024C000000000000024C000000000000010C000000000000024C0000000000000F0BF00000000000000C0000000000000F0BF000000000000F0BF000000000000F0BF0500000000000000000014C000000000000014C000000000000020C000000000000020C000000000000014C00000000000002CC000000000000020C000000000000020C000000000000028C000000000000014C000000000000020C000000000000024C000000000000014C000000000000014C000000000000020C0');
--PostGIS WKB: INSERT INTO "polygonzm"(geom) VALUES('01060000C00200000001030000C00200000005000000000000000000000000000000000000000000000000000000000000000000F03F0000000000000000000000000000244000000000000018400000000000001C4000000000000024400000000000002440000000000000104000000000000014400000000000002440000000000000000000000000000000400000000000000840000000000000000000000000000000000000000000000000000000000000F03F050000000000000000001440000000000000144000000000000020400000000000002240000000000000204000000000000014400000000000002C400000000000002E400000000000002040000000000000204000000000000028400000000000002A400000000000001440000000000000204000000000000024400000000000002640000000000000144000000000000014400000000000002040000000000000224001030000C00200000005000000000000000000F0BF000000000000F0BF000000000000F0BF000000000000F0BF000000000000F0BF00000000000024C000000000000018C00000000000001CC000000000000024C000000000000024C000000000000010C000000000000014C000000000000024C0000000000000F0BF00000000000000C000000000000008C0000000000000F0BF000000000000F0BF000000000000F0BF000000000000F0BF0500000000000000000014C000000000000014C000000000000020C000000000000022C000000000000020C000000000000014C00000000000002CC00000000000002EC000000000000020C000000000000020C000000000000028C00000000000002AC000000000000014C000000000000020C000000000000024C000000000000026C000000000000014C000000000000014C000000000000020C000000000000022C0');
--WKT: INSERT INTO "polygonzm"(geom) VALUES(ST_MPolyFromText('MULTIPOLYGON(((0.0 0.0 0.0 1.0,0.0 10.0 6.0 7.0,10.0 10.0 4.0 5.0,10.0 0.0 2.0 3.0,0.0 0.0 0.0 1.0),(5.0 5.0 8.0 9.0,8.0 5.0 14.0 15.0,8.0 8.0 12.0 13.0,5.0 8.0 10.0 11.0,5.0 5.0 8.0 9.0)),((-1.0 -1.0 -1.0 -1.0,-1.0 -10.0 -6.0 -7.0,-10.0 -10.0 -4.0 -5.0,-10.0 -1.0 -2.0 -3.0,-1.0 -1.0 -1.0 -1.0),(-5.0 -5.0 -8.0 -9.0,-8.0 -5.0 -14.0 -15.0,-8.0 -8.0 -12.0 -13.0,-5.0 -8.0 -10.0 -11.0,-5.0 -5.0 -8.0 -9.0)))'));

