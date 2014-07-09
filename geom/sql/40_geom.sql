-- The contents of this file are subject to the MonetDB Public License
-- Version 1.1 (the "License"); you may not use this file except in
-- compliance with the License. You may obtain a copy of the License at
-- http://www.monetdb.org/Legal/MonetDBLicense
--
-- Software distributed under the License is distributed on an "AS IS"
-- basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
-- License for the specific language governing rights and limitations
-- under the License.
--
-- The Original Code is the MonetDB Database System.
--
-- The Initial Developer of the Original Code is CWI.
-- Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
-- Copyright August 2008-2014 MonetDB B.V.
-- All Rights Reserved.

-- make sure you load the geom module before loading this sql module
-- create spatial_ref_sys metadata table

CREATE FUNCTION Has_Z(info integer) RETURNS integer EXTERNAL NAME geom."hasZ";
CREATE FUNCTION Has_M(info integer) RETURNS integer EXTERNAL NAME geom."hasM";
CREATE FUNCTION get_type(info integer, format integer) RETURNS string EXTERNAL NAME geom."getType";



CREATE TABLE spatial_ref_sys (
	srid INTEGER NOT NULL PRIMARY KEY,
	auth_name VARCHAR (256),
	auth_srid INTEGER,
	srtext VARCHAR (2048),
	proj4text VARCHAR (2048)
);

-- create geometry_columns metadata view
create view geometry_columns as
	select e.value as f_table_catalog,
		s.name as f_table_schema,
		y.f_table_name, y.f_geometry_column, y.coord_dimension, y.srid, y.type
	from schemas s, environment e, (
		select t.schema_id,
			t.name as f_table_name,
			x.name as f_geometry_column,
			has_z(info)+has_m(info)+2 as coord_dimension,
			srid, get_type(info, 0) as type
		from tables t, (
			select name, table_id, type_digits AS info, type_scale AS srid
			from columns
			where type in ( select distinct sqlname from types where systemname='wkb')
			) as x
		where t.id=x.table_id
		) y
	where y.schema_id=s.id and e.name='gdk_dbname';


copy into spatial_ref_sys from '/export/scratch1/alvanaki/DEV/MonetDB/geom/sql/postgis_spatial_ref_sys.csv' using delimiters ',';


CREATE TYPE mbr EXTERNAL NAME mbr;


-- currently we only use mbr instead of
-- Envelope():Geometry
-- as that returns Geometry objects, and we prefer the explicit mbr's
-- minimum bounding rectangle (mbr)
CREATE FUNCTION mbr(geom Geometry) RETURNS mbr external name geom."mbr";
CREATE FUNCTION mbrOverlap(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrOverlap";
CREATE FUNCTION mbrOverlapOrLeft(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrOverlapOrLeft";
CREATE FUNCTION mbrOverlapOrBelow(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrOverlapOrBelow";
CREATE FUNCTION mbrOverlapOrRight(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrOverlapOrRight";
CREATE FUNCTION mbrLeft(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrLeft";
CREATE FUNCTION mbrBelow(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrBelow";
CREATE FUNCTION mbrEqual(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrEqual";
CREATE FUNCTION mbrRight(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrRight";
CREATE FUNCTION mbrContained(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrContained";
CREATE FUNCTION mbrOverlapOrAbove(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrOverlapOrAbove";
CREATE FUNCTION mbrAbove(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrAbove";
CREATE FUNCTION mbrContains(box1 mbr, box2 mbr) RETURNS boolean external name geom."mbrContains";
CREATE FUNCTION mbrDistance(box1 mbr, box2 mbr) RETURNS double external name geom."mbrDistance";


-------------------------------------------------------------------------
------------------------- Management Functions- -------------------------
-------------------------------------------------------------------------
--CREATE PROCEDURE AddGeometryColumn(table_name string, column_name string, srid integer, geometryType string, dimension integer) 
--BEGIN
	--DECLARE column_type string;
	--SET column_type = concat('geometry( ', geometryType);
	--SET column_type = concat(column_type, ', ');
	--SET column_type = concat(column_type, srid);
	--SET column_type = concat(column_type, ')'); 
	--ALTER TABLE table_name ADD column_name
--END;

--CREATE PROCEDURE t(table_name string, column_name string, column_type string)
--BEGIN
--	ALTER TABLE table_name ADD column_name;
--END;

--CREATE FUNCTION t(table_name string, column_name string, srid integer, type string, dimension integer) RETURNS string 
--BEGIN
--	EXECUTE PROCEDURE AddGeometryColumn(table_name, column_name, srid, type, dimension);
--	RETURN '';
--END;

-------------------------------------------------------------------------
------------------------- Geometry Constructors -------------------------
-------------------------------------------------------------------------
-- Create Geometry from text (wkt)
CREATE FUNCTION ST_GeomFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."GeomFromText";
CREATE FUNCTION ST_GeometryFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."GeomFromText";
CREATE FUNCTION ST_PointFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."PointFromText"; 
CREATE FUNCTION ST_LineFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."LineFromText";
CREATE FUNCTION ST_PolygonFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."PolygonFromText";
CREATE FUNCTION ST_MPointFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."MPointFromText";
CREATE FUNCTION ST_MLineFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."MLineFromText";
CREATE FUNCTION ST_MPolyFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."MPolyFromText";
CREATE FUNCTION ST_GeomCollFromText(wkt string, srid integer) RETURNS Geometry EXTERNAL NAME geom."GeomCollFromText";
--CREATE FUNCTION ST_BdPolyFromText(wkt string, srid SMALLINT) RETURNS Geometry external name geom."BdPolyFromText"; 
--CREATE FUNCTION ST_BdMPolyFromText(wkt string, srid SMALLINT) RETURNS Geometry external name geom."BdMPolyFromText";

CREATE FUNCTION ST_GeomFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."GeomFromText";
CREATE FUNCTION ST_GeometryFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."GeomFromText";
CREATE FUNCTION ST_WKTToSQL(wkt string) RETURNS Geometry external name geom."GeomFromText";
CREATE FUNCTION ST_PointFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."PointFromText"; 
CREATE FUNCTION ST_LineFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."LineFromText";
CREATE FUNCTION ST_PolygonFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."PolygonFromText";
CREATE FUNCTION ST_MPointFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."MPointFromText";
CREATE FUNCTION ST_MLineFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."MLineFromText";
CREATE FUNCTION ST_MPolyFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."MPolyFromText";
CREATE FUNCTION ST_GeomCollFromText(wkt string) RETURNS Geometry EXTERNAL NAME geom."GeomCollFromText";
--CREATE FUNCTION ST_GeogFromText(wkt string) RETURNS Geography external name geom."GeographyFromText";
--CREATE FUNCTION ST_GeographyFromText(wkt string) RETURNS Geography external name geom."GeographyFromText";


-- Create Geometry from raw representation (byte array)
--CREATE FUNCTION ST_GeomFromWKB(wkb_raw WHATEVER_IS_STORED_IN_DB, srid smallint) RETURNS Geometry EXTERNAL NAME geom."GeomFromWKB";
--CREATE FUNCTION ST_PointFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB, srid smallint) RETURNS Geometry EXTERNAL NAME geom."PointFromWKB";
--CREATE FUNCTION ST_LineFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB, srid smallint) RETURNS Geometry EXTERNAL NAME geom."LineFromWKB";
--CREATE FUNCTION ST_LinestringFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB, srid smallint) RETURNS Geometry EXTERNAL NAME geom."LineFromWKB";

--CREATE FUNCTION ST_GeomFromWKB(wkb_raw WHATEVER_IS_STORED_IN_DB) RETURNS Geometry EXTERNAL NAME geom."GeomFromWKB";
--CREATE FUNCTION ST_WKBToSQL(wkb_arr WHATEVER_IS_STORED_IN_DB) RETURNS Geometry EXTERNAL NAME geom."GeomFromWKB";
--CREATE FUNCTION ST_PointFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB) RETURNS Geometry EXTERNAL NAME geom."PointFromWKB";
--CREATE FUNCTION ST_LineFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB) RETURNS Geometry EXTERNAL NAME geom."LineFromWKB";
--CREATE FUNCTION ST_LinestringFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB) RETURNS Geometry EXTERNAL NAME geom."LineFromWKB";
--CREATE FUNCTION ST_GeogFromWKB(wkb_arr WHATEVER_IS_STORED_IN_DB) RETURNS Geography EXTERNAL NAME geom."GeogFromWKB";

-- Create Geometry from simpler geometries
CREATE FUNCTION ST_MakePoint(x double, y double) RETURNS Geometry EXTERNAL NAME geom."MakePoint"; 
CREATE FUNCTION ST_Point(x double, y double) RETURNS Geometry EXTERNAL NAME geom."MakePoint";
CREATE FUNCTION ST_MakePoint(x double, y double, z double) RETURNS Geometry EXTERNAL NAME geom."MakePoint";
--ERROR: HOW TO CREATE A 4D POINT?
--CREATE FUNCTION ST_MakePoint(x double, y double, z double, m double) RETURNS Geometry EXTERNAL NAME geom."MakePoint";
CREATE FUNCTION ST_MakePointM(x double, y double, m double) RETURNS Geometry EXTERNAL NAME geom."MakePointM";
--CREATE FUNCTION ST_MakeLine(geometry set geoms)?????
--CREATE FUNCTION ST_MakeLine(geom1 Geometry, geom2 Geometry) RETURNS Geometry external name geom."MakeLine";
--CREATE FUNCTION ST_MakeLine(geoms_arr Geometry[]) RETURNS Geometry external name geom."MakeLine";
--CREATE FUNCTION ST_LineFromMultiPoint(pointGeom Geometry) RETURNS Geometry external name geom."LineFromMultiPoint"; --gets mutlipoint returns linestring
--CREATE FUNCTION ST_MakeEnvelope(xmin double, ymin double, xmax double, ymax double, srid SMALLINT) RETURNS Geometry external name geom."MakeEnvelope";
--CREATE FUNCTION ST_MakePolygon(geom Geometry) RETURNS Geometry external name geom."MakePolygon"; --gets linestring
--CREATE FUNCTION ST_MakePolygon(outerGeom Geometry, interiorGeoms Geometry[]) RETURNS Geometry external name geom."MakePolygon"; --gets linestrings
--CREATE FUNCTION ST_Polygon(geom Geometry, srid SMALLINT) RETURNS Geometry external name geom."Polygon" --gets linestring
--CREATE FUNCTION ST_MakeBox2D(lowLeftPointGeom Geometry, upRightPointGeom Geometry) RETURNS mbr external name geom."MakeBox2D"; --gets 2d points
--CREATE FUNCTION ST_3DMakeBox(lowLeftPointGeom Geometry, upRightPointGeom Geometry) RETURNS mbr external name geom."MakeBox3D"; --gets 3d points

-- Other constructors
--CREATE FUNCTION ST_Box2dFromGeoHash() RETURNS mbr external name geom."Box2dFromGeoHash";
--CREATE FUNCTION ST_GeomFromEWKB
--CREATE FUNCTION ST_GeomFromEWKT
--CREATE FUNCTION ST_GeomFromGML
--CREATE FUNCTION ST_GeomFromGeoJSON
--CREATE FUNCTION ST_GeomFromKML
--CREATE FUNCTION ST_GMLToSQL
--CREATE FUNCTION ST_PointFromGeoHash

-------------------------------------------------------------------------
-------------------------- Geometry Accessors ---------------------------
-------------------------------------------------------------------------
CREATE FUNCTION GeometryType(geom Geometry) RETURNS string EXTERNAL NAME geom."GeometryType1";
CREATE FUNCTION ST_Boundary(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."Boundary";
CREATE FUNCTION ST_CoordDim(geom Geometry) RETURNS integer EXTERNAL NAME geom."CoordDim";
CREATE FUNCTION ST_Dimension(geom Geometry) RETURNS integer EXTERNAL NAME geom."Dimension";
CREATE FUNCTION ST_EndPoint(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."EndPoint";
CREATE FUNCTION ST_Envelope(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."Envelope";
CREATE FUNCTION ST_ExteriorRing(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."ExteriorRing"; --gets polygon
CREATE FUNCTION ST_GeometryN(geom Geometry, geomNum integer) RETURNS Geometry EXTERNAL NAME geom."GeometryN";
CREATE FUNCTION ST_GeometryType(geom Geometry) RETURNS string EXTERNAL NAME geom."GeometryType2";
CREATE FUNCTION ST_InteriorRingN(geom Geometry, ringNum integer) RETURNS Geometry EXTERNAL NAME geom."InteriorRingN";
CREATE FUNCTION ST_IsClosed(geom Geometry) RETURNS boolean EXTERNAL NAME geom."IsClosed";
--CREATE FUNCTION ST_IsCollection(geom Geometry) RETURNS boolean EXTERNAL NAME
CREATE FUNCTION ST_IsEmpty(geom Geometry) RETURNS boolean EXTERNAL NAME geom."IsEmpty";
CREATE FUNCTION ST_IsRing(geom Geometry) RETURNS boolean EXTERNAL NAME geom."IsRing"; --is meaningfull only for linestrings
CREATE FUNCTION ST_IsSimple(geom Geometry) RETURNS boolean EXTERNAL NAME geom."IsSimple";
CREATE FUNCTION ST_IsValid(geom Geometry) RETURNS boolean EXTERNAL NAME geom."IsValid";
--CREATE FUNCTION ST_IsValid(geom Geometry, flags integer) RETURNS boolean EXTERNAL NAME
CREATE FUNCTION ST_IsValidReason(geom Geometry) RETURNS string EXTERNAL NAME geom."IsValidReason"; 
--CREATE FUNCTION ST_IsValidReason(geom Geometry, flags integer) RETURNS string EXTERNAL NAME
--CREATE FUNCTION ST_IsValidDetail(geom Geometry) RETURNS string EXTERNAL NAME geom."IsValidDetail"; 
--CREATE FUNCTION ST_IsValidDetail(geom Geometry, flags integer) RETURNS A_CUSTOM_ROW EXTERNAL NAME
--CREATE FUNCTION ST_M(geom Geometry) RETURNS double EXTERNAL NAME
--CREATE FUNCTION ST_NDims(geom Geometry) RETURNS integer EXTERNAL NAME
--CREATE FUNCTION ST_NPoints(geom Geometry) RETURNS integer EXTERNAL NAME geom;
CREATE FUNCTION ST_NRings(geom Geometry) RETURNS integer EXTERNAL NAME geom."NRings"; --is meaningfull for polygon and multipolygon
CREATE FUNCTION ST_NumGeometries(geom Geometry) RETURNS integer EXTERNAL NAME geom."NumGeometries";
CREATE FUNCTION ST_NumInteriorRings(geom Geometry) RETURNS integer EXTERNAL NAME geom."NumInteriorRings";
CREATE FUNCTION ST_NumInteriorRing(geom Geometry) RETURNS integer EXTERNAL NAME geom."NumInteriorRings";
--CREATE FUNCTION ST_NumPatches(geom Geometry) RETURNS integer EXTERNAL NAME --works only with polyhedral surface
CREATE FUNCTION ST_NumPoints(geom Geometry) RETURNS integer EXTERNAL NAME geom."NumPoints";
--CREATE FUNCTION ST_PatchN(geom Geometry, patchNum integer) RETURNS Geometry EXTERNAL NAME --works with polyhedral surface
CREATE FUNCTION ST_PointN(geom Geometry, pointNum integer) RETURNS Geometry EXTERNAL NAME geom."PointN";
CREATE FUNCTION ST_SRID(geom Geometry) RETURNS integer EXTERNAL NAME geom."getSRID";
CREATE FUNCTION ST_StartPoint(geom Geometry) RETURNS geometry EXTERNAL NAME geom."StartPoint";
--CREATE FUNCTION ST_Summary(geom Geometry) RETURNS string EXTERNAL NAME
CREATE FUNCTION ST_X(geom Geometry) RETURNS double EXTERNAL NAME geom."X"; --gets point
CREATE FUNCTION ST_XMax(geom Geometry) RETURNS double EXTERNAL NAME geom."XMaxFromWKB";
CREATE FUNCTION ST_XMax(box mbr) RETURNS double EXTERNAL NAME geom."XMaxFromMBR";
CREATE FUNCTION ST_XMin(geom Geometry) RETURNS double EXTERNAL NAME geom."XMinFromWKB";
CREATE FUNCTION ST_XMin(box mbr) RETURNS double EXTERNAL NAME geom."XMinFromMBR";
CREATE FUNCTION ST_Y(geom Geometry) RETURNS double EXTERNAL NAME geom."Y"; --gets point
CREATE FUNCTION ST_YMax(geom Geometry) RETURNS double EXTERNAL NAME geom."YMaxFromWKB";
CREATE FUNCTION ST_YMax(box mbr) RETURNS double EXTERNAL NAME geom."YMaxFromMBR";
CREATE FUNCTION ST_YMin(geom Geometry) RETURNS double EXTERNAL NAME geom."YMinFromWKB";
CREATE FUNCTION ST_YMin(box mbr) RETURNS double EXTERNAL NAME geom."YMinFromMBR";
CREATE FUNCTION ST_Z(geom Geometry) RETURNS double EXTERNAL NAME geom."Z"; --gets point
--CREATE FUNCTION ST_ZMax(box3d Geometry_OR_Box2D_OR_Box3D) RETURNS double EXTERNAL NAME
--CREATE FUNCTION ST_Zmflag(geom Geometry) RETURNS smallint EXTERNAL NAME --0=2d, 1=3dm, 2=3dz, 4=4d
--CREATE FUNCTION ST_ZMin(box3d Geometry_OR_Box2D_OR_Box3D) RETURNS double EXTERNAL NAME

-------------------------------------------------------------------------
--------------------------- Geometry Editors ----------------------------
-------------------------------------------------------------------------
--CREATE FUNCTION ST_AddPoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Affine RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Force2D RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Force3D RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Force3DZ RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Force3DM RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Force4D RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_ForceCollection RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_ForceRHR RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LineMerge RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_CollectionExtract RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_CollectionHomogenize RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Multi RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_RemovePoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Reverse RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Rotate RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_RotateX RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_RotateY RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_RotateZ RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Scale RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Segmentize RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_SetPoint RETURNS EXTERNAL NAME
CREATE FUNCTION ST_SetSRID(geom Geometry, srid integer) RETURNS Geometry EXTERNAL NAME geom."setSRID";
--CREATE FUNCTION ST_SnapToGrid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Snap RETURNS EXTERNAL NAME
CREATE FUNCTION getProj4(srid_in integer) RETURNS string 
BEGIN
	RETURN SELECT proj4text FROM spatial_ref_sys WHERE srid=srid_in; 
END;
CREATE FUNCTION InternalTransform(geom Geometry, srid_src integer, srid_dest integer, proj4_src string, proj4_dest string) RETURNS Geometry EXTERNAL NAME geom."Transform";
CREATE FUNCTION ST_Transform(geom Geometry, srid integer) RETURNS Geometry
BEGIN
	DECLARE srid_src integer;
	DECLARE proj4_src string;
	DECLARE proj4_dest string;

	SELECT st_srid(geom) INTO srid_src;
	SELECT getProj4(srid_src) INTO proj4_src;
	SELECT getProj4(srid) INTO proj4_dest;

	IF proj4_src IS NULL THEN
		RETURN SELECT InternalTransform(geom, srid_src, srid, 'null', proj4_dest); 
	ELSE
		IF proj4_dest IS NULL THEN
			RETURN SELECT InternalTransform(geom, srid_src, srid, proj4_src, 'null'); 
		ELSE
			RETURN SELECT InternalTransform(geom, srid_src, srid, proj4_src, proj4_dest);
		END IF;	
	END IF;
END;

--CREATE FUNCTION ST_Translate RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_TransScale RETURNS EXTERNAL NAME

-------------------------------------------------------------------------
--------------------------- Geometry Outputs ----------------------------
-------------------------------------------------------------------------
--CREATE FUNCTION ST_AsBinary RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsEWKB RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsEWKT RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsGeoJSON RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsGML RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsHEXEWKB RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsKML RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsSVG RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AsX3D RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_GeoHash RETURNS EXTERNAL NAME
CREATE FUNCTION ST_AsText(g Geometry) RETURNS string EXTERNAL NAME geom."AsText";
--CREATE FUNCTION ST_AsLatLonText RETURNS EXTERNAL NAME

-------------------------------------------------------------------------
------------------------------ Operators --------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
---------------- Spatial Relationships and Measurements -----------------
-------------------------------------------------------------------------
--CREATE FUNCTION ST_3DClosestPoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DDistance RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DDWithin RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DDFullyWithin RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DIntersects RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DLongestLine RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DMaxDistance RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DShortestLine RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Area(geom Geometry) RETURNS double EXTERNAL NAME geom."Area";
--CREATE FUNCTION ST_Area(geog Geography, use_spheroid boolean) RETURNS flt EXTERNAL NAME geom."Area";
--CREATE FUNCTION ST_Azimuth RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Centroid(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."Centroid";
--CREATE FUNCTION ST_ClosestPoint RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Contains(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Contains";
--CREATE FUNCTION ST_ContainsProperly RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Covers RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_CoveredBy RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Crosses(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Crosses";
--CREATE FUNCTION ST_LineCrossingDirection RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Disjoint(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Disjoint";
CREATE FUNCTION ST_Distance(geom1 Geometry, geom2 Geometry) RETURNS double EXTERNAL NAME geom."Distance";
--CREATE FUNCTION ST_Distance(geog1 Geometry, geog2 Geometry) RETURNS double EXTERNAL NAME geom."Distance"
--CREATE FUNCTION ST_Distance(geog1 Geometry, geog2 Geometry, use_spheroid boolean) RETURNS double EXTERNAL NAME geom."Distance"
--CREATE FUNCTION ST_HausdorffDistance RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_MaxDistance RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Distance_Sphere RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Distance_Spheroid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_DFullyWithin RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_DWithin RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Equals(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Equals";
--CREATE FUNCTION ST_HasArc RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Intersects(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Intersects";
--CREATE FUNCTION ST_Intersects(geog1 Geography, geog2 Geography) RETURNS boolean EXTERNAL NAME geom."Intersects";
CREATE FUNCTION ST_Length(geom Geometry) RETURNS double EXTERNAL NAME geom."Length";
--CREATE FUNCTION ST_Length(geog Geography, use_spheroid boolean) RETURNS double EXTERNAL NAME geom."Length";
CREATE FUNCTION ST_Length2D(geom Geometry) RETURNS double EXTERNAL NAME geom."Length";
--CREATE FUNCTION ST_3DLength RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Length_Spheroid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Length2D_Spheroid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DLength_Spheroid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LongestLine RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_OrderingEquals RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Overlaps(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Overlaps";
--CREATE FUNCTION ST_Perimeter RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Perimeter2D RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_3DPerimeter RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_PointOnSurface RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Project RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Relate(geom1 Geometry, geom2 Geometry, intersection_matrix_pattern string) RETURNS boolean EXTERNAL NAME geom."Relate";
--CREATE FUNCTION ST_Relate(geom1 Geometry, geom2 Geometry) RETURNS string EXTERNAL NAME geom."Relate";
--CREATE FUNCTION ST_Relate(geom1 Geometry, geom2 Geometry, boundary_node_rule integer) RETURNS string EXTERNAL NAME geom."Relate";
--CREATE FUNCTION ST_RelateMatch RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_ShortestLine RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Touches(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Touches";
CREATE FUNCTION ST_Within(geom1 Geometry, geom2 Geometry) RETURNS boolean EXTERNAL NAME geom."Withis";

-------------------------------------------------------------------------
------------------------- Geometry Processing ---------------------------
-------------------------------------------------------------------------
CREATE FUNCTION ST_Buffer(geom Geometry, radius double) RETURNS Geometry EXTERNAL NAME geom."Buffer";
--CREATE FUNCTION ST_Buffer(geom Geometry, radius double, circle_quarters_num integer) RETURNS Geometry EXTERNAL NAME geom."Buffer";
--CREATE FUNCTION ST_Buffer(geom Geometry, radius double, buffer_style_parameters string) RETURNS Geometry EXTERNAL NAME geom."Buffer";
--CREATE FUNCTION ST_Buffer(geog Geography, radius double) RETURNS Geometry EXTERNAL NAME geom."Buffer";
--CREATE FUNCTION ST_BuildArea RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Collect RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_ConcaveHull RETURNS EXTERNAL NAME
CREATE FUNCTION ST_ConvexHull(geom Geometry) RETURNS Geometry EXTERNAL NAME geom."ConvexHull";
--CREATE FUNCTION ST_CurveToLine RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_DelaunayTriangles RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Difference(geom1 Geometry, geom2 Geometry) RETURNS Geometry EXTERNAL NAME geom."Differnce";
--CREATE FUNCTION ST_Dump RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_DumpPoints RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_DumpRings RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_FlipCoordinates RETURNS EXTERNAL NAME
CREATE FUNCTION ST_Intersection(geom1 Geometry, geom2 Geometry) RETURNS Geometry EXTERNAL NAME geom."Intersection";
--CREATE FUNCTION ST_Intersection(geog1 Geography, geog2 Geography) RETURNS Geography EXTERNAL NAME geom."Intersection";
--CREATE FUNCTION ST_LineToCurve RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_MakeValid RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_MemUnion RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_MinimumBoundingCircle RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Polygonize RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Node RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_OffsetCurve RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_RemoveRepeatedPoints RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_SharedPaths RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Shift_Longitude RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Simplify RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_SimplifyPreserveTopology RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_Split RETURNS EXTERNAL NAME
CREATE FUNCTION ST_SymDifference(geom1 Geometry, geom2 Geometry) RETURNS Geometry EXTERNAL NAME geom."SymDifference";
--CREATE FUNCTION ST_Union(geoms Geometry set???) RETURNS Geometry EXTERNAL NAME geom."Union";
--CREATE FUNCTION ST_Union(geoms Geometry[]) RETURNS Geometry EXTERNAL NAME geom."Union";
CREATE FUNCTION ST_Union(geom1 Geometry, geom2 Geometry) RETURNS Geometry EXTERNAL NAME geom."Union";
--CREATE FUNCTION ST_UnaryUnion RETURNS EXTERNAL NAME

-------------------------------------------------------------------------
-------------------------- Linear Referencing ---------------------------
-------------------------------------------------------------------------
--CREATE FUNCTION ST_LineInterpolatePoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LineLocatePoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LineSubstring RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LocateAlong RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LocateBetween RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_LocateBetweenElevations RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_InterpolatePoint RETURNS EXTERNAL NAME
--CREATE FUNCTION ST_AddMeasure RETURNS EXTERNAL NAME

-------------------------------------------------------------------------
---------------------- Long Transactions Support ------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
----------------------- Miscellaneous Functions -------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
------------------------ Exceptional Functions --------------------------
-------------------------------------------------------------------------


-- CREATE FUNCTION Point(g Geometry) RETURNS Point external name geom.point;
-- CREATE FUNCTION Curve(g Geometry) RETURNS Curve external name geom.curve;
-- CREATE FUNCTION LineString(g Geometry) RETURNS LineString external name geom.linestring;
-- CREATE FUNCTION Surface(g Geometry) RETURNS Surface external name geom.surface;
-- CREATE FUNCTION Polygon(g Geometry) RETURNS Polygon external name geom.polygon;



