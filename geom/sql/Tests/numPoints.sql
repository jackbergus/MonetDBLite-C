SELECT ST_NumPoints(ST_GeomFromText('LINESTRING(77.29 29.07,77.42 29.26,77.27 29.31,77.29 29.07)'));
SELECT ST_NumPoints(ST_GeomFromText('polygon((77.29 29.07,77.42 29.26,77.27 29.31,77.29 29.07))'));
select st_numPoints(st_mpointFromText('multipoint(1 2 3, 4 5 6, 7 8 9, 10 11 12)'));
