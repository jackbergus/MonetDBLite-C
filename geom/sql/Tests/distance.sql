SELECT ST_Distance(ST_GeomFromText('POINT(-72.1235 42.3521)',4326), ST_GeomFromText('LINESTRING(-72.1260 42.45, -72.123 42.1546)', 4326));
SELECT ST_Distance(ST_GeomFromText('POINT(-72.1235 42.3521)',4326), ST_GeomFromText('LINESTRING(-72.1260 42.45, -72.123 42.1546)', 2163));
SELECT ST_Distance(ST_GeomFromText('POINT(-72.1235 42.3521)',2163), ST_GeomFromText('LINESTRING(-72.1260 42.45, -72.123 42.1546)', 2163));


