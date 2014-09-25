 /* The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2014 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * Foteini Alvanaki
 */

#include "geom.h"

//it gets two BATs with x,y coordinates and returns a new BAT with the points
static BAT* BATMakePoint2D(BAT* xBAT, BAT* yBAT, BAT* candidatesBAT) {
	BAT *outBAT = NULL;

	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT)) {
		GDKerror("BATMakePoint2D: BATs must have dense heads");
		return NULL;
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		GDKerror("BATMakePoint2D: BATs must be aligned");
		return NULL;
	}

	
	if(candidatesBAT == NULL ) {
		//iterator over the BATs	
		BATiter xBAT_iter = bat_iterator(xBAT);
		BATiter yBAT_iter = bat_iterator(yBAT);
		BUN i;

		//create a new BAT
		if ((outBAT = BATnew(TYPE_void, ATOMindex("wkb"), BATcount(xBAT), TRANSIENT)) == NULL) {
			GDKerror("BATMakePoint2D: Could not create new BAT for the output");
			return NULL;
		}

		//set the first idx of the new BAT equal to that of the x BAT (which is equal to the y BAT)
		BATseqbase(outBAT, xBAT->hseqbase);
		
		for (i = BUNfirst(xBAT); i < BATcount(xBAT); i++) { 
			str err = NULL;
			wkb* point = NULL;
			double *x = (double*) BUNtail(xBAT_iter, i + BUNfirst(xBAT));
			double *y = (double*) BUNtail(yBAT_iter, i + BUNfirst(yBAT));
	
			if ((err = geomMakePoint2D(&point, x, y)) != MAL_SUCCEED) {
				BBPreleaseref(outBAT->batCacheid);
				GDKerror("BATMakePoint2D: %s", err);
				GDKfree(err);
				return NULL;
			}
			BUNappend(outBAT,point,TRUE); //add the result to the outBAT
			GDKfree(point);
		}
	} else {
		//iterator over the candidates	
		BATiter candidatesBAT_iter = bat_iterator(candidatesBAT);
		BATiter xBAT_iter = bat_iterator(xBAT);
		BATiter yBAT_iter = bat_iterator(yBAT);
		BUN i;

		//create a new BAT
		if ((outBAT = BATnew(TYPE_void, ATOMindex("wkb"), BATcount(candidatesBAT), TRANSIENT)) == NULL) {
			GDKerror("BATMakePoint2D: Could not create new BAT for the output");
			return NULL;
		}

		//set the first idx of the new BAT equal to that of the x BAT (which is equal to the y BAT)
		BATseqbase(outBAT, candidatesBAT->hseqbase);
		
		for (i = BUNfirst(candidatesBAT); i < BATcount(candidatesBAT); i++) { 
			str err = NULL;
			wkb* point = NULL;
			oid candidateOID = *(oid*)BUNtail(candidatesBAT_iter, i+BUNfirst(candidatesBAT)-candidatesBAT->hseqbase);

			//get the x,y values at this oid
			double *x = (double*) BUNtail(xBAT_iter, candidateOID + BUNfirst(xBAT) - xBAT->hseqbase);
			double *y = (double*) BUNtail(yBAT_iter, candidateOID + BUNfirst(yBAT) - yBAT->hseqbase);
	
			if ((err = geomMakePoint2D(&point, x, y)) != MAL_SUCCEED) {
				BBPreleaseref(outBAT->batCacheid);
				GDKerror("BATMakePoint2D: %s", err);
				GDKfree(err);
				return NULL;
			}
			BUNappend(outBAT,point,TRUE); //add the result to the outBAT
			GDKfree(point);
		}
	}

	return outBAT;

}

static BAT* BATSetSRID(BAT* pointsBAT, int srid) {
	BAT *outBAT = NULL;
	BATiter pointsBAT_iter;	
	BUN p=0, q=0;
	wkb *pointWKB = NULL;

	//check if the BAT has dense heads and are aligned
	if (!BAThdense(pointsBAT)) {
		GDKerror("BATSetSRID: BAT must have dense heads");
		return NULL;
	}

	//create a new BAT
	if ((outBAT = BATnew(TYPE_void, ATOMindex("wkb"), BATcount(pointsBAT), TRANSIENT)) == NULL) {
		GDKerror("BATSetSRID: Could not create new BAT for the output");
		return NULL;
	}

	//set the first idx of the new BAT equal to that of the x BAT (which is equal to the y BAT)
	BATseqbase(outBAT, pointsBAT->hseqbase);

	//iterator over the BATs	
	pointsBAT_iter = bat_iterator(pointsBAT);
	 
	BATloop(pointsBAT, p, q) { //iterate over all valid elements
		str err = NULL;
		wkb *outWKB = NULL;

		pointWKB = (wkb*) BUNtail(pointsBAT_iter, p);
		if ((err = wkbSetSRID(&outWKB, &pointWKB, &srid)) != MAL_SUCCEED) { //set SRID
			BBPreleaseref(outBAT->batCacheid);
			GDKerror("BATSetSRID: %s", err);
			GDKfree(err);
			return NULL;
		}
		BUNappend(outBAT,outWKB,TRUE); //add the point to the new BAT
		GDKfree(outWKB);
		outWKB = NULL;
	}

	return outBAT;
}

static BAT* BATContains(wkb** geomWKB, BAT* geometriesBAT) {
	BAT *outBAT = NULL;
	BATiter geometriesBAT_iter;	
	BUN p=0, q=0;
	wkb *geometryWKB = NULL;

	//check if the BAT has dense heads and are aligned
	if (!BAThdense(geometriesBAT)) {
		GDKerror("BATContains: BAT must have dense heads");
		return NULL;
	}

	//create a new BAT
	if ((outBAT = BATnew(TYPE_void, ATOMindex("bit"), BATcount(geometriesBAT), TRANSIENT)) == NULL) {
		GDKerror("BATContains: Could not create new BAT for the output");
		return NULL;
	}

	//set the first idx of the new BAT equal to that of the x BAT (which is equal to the y BAT)
	BATseqbase(outBAT, geometriesBAT->hseqbase);

	//iterator over the BATs	
	geometriesBAT_iter = bat_iterator(geometriesBAT);
	 
	BATloop(geometriesBAT, p, q) { //iterate over all valid elements
		str err = NULL;
		bit outBIT = 0;

		geometryWKB = (wkb*) BUNtail(geometriesBAT_iter, p);
		if ((err = wkbContains(&outBIT, geomWKB, &geometryWKB)) != MAL_SUCCEED) { //set SRID
			BBPreleaseref(outBAT->batCacheid);
			GDKerror("BATContains: %s", err);
			GDKfree(err);
			return NULL;
		}
		BUNappend(outBAT,&outBIT,TRUE); //add the point to the new BAT
	}

	return outBAT;

}

str wkbPointsContains_geom_bat(bat* outBAT_id, wkb** geomWKB, bat* xBAT_id, bat* yBAT_id, int* srid) {
	BAT *xBAT=NULL, *yBAT=NULL, *outBAT=NULL;
	BAT *pointsBAT = NULL, *pointsWithSRIDBAT=NULL;
	str ret=MAL_SUCCEED;

	//get the descriptors of the BATs
	if ((xBAT = BATdescriptor(*xBAT_id)) == NULL) {
		throw(MAL, "batgeom.Contains", RUNTIME_OBJECT_MISSING);
	}
	if ((yBAT = BATdescriptor(*yBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		throw(MAL, "batgeom.Contains", RUNTIME_OBJECT_MISSING);
	}
	
	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT)) {
		ret = createException(MAL, "batgeom.Contains", "BATs must have dense heads");
		goto clean;
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		ret=createException(MAL, "batgeom.Contains", "BATs must be aligned");
		goto clean;
	}

	//here the BAT version of some contain function that takes the BATs of the x y coordinates should be called
	//create the points BAT
	if((pointsBAT = BATMakePoint2D(xBAT, yBAT, NULL)) == NULL) {
		ret = createException(MAL, "batgeom.Contains", "Problem creating the points from the coordinates");
		goto clean;
	}

	if((pointsWithSRIDBAT = BATSetSRID(pointsBAT, *srid)) == NULL) {
		ret = createException(MAL, "batgeom.Contains", "Problem setting srid to the points");
		goto clean;
	}

	if((outBAT = BATContains(geomWKB, pointsWithSRIDBAT)) == NULL) {
		ret = createException(MAL, "batgeom.Contains", "Problem evalauting the contains");
		goto clean;
	}

	BBPkeepref(*outBAT_id = outBAT->batCacheid);
	goto clean;

clean:
	if(xBAT)
		BBPreleaseref(xBAT->batCacheid);
	if(yBAT)
		BBPreleaseref(yBAT->batCacheid);
	if(pointsBAT)
		BBPreleaseref(pointsBAT->batCacheid);
	if(pointsWithSRIDBAT)
		BBPreleaseref(pointsWithSRIDBAT->batCacheid);
	return ret;
}

//Aternative implementation of contains using ???
inline double isLeft( double P0x, double P0y, double P1x, double P1y, double P2x, double P2y) {
    return ( (P1x - P0x) * (P2y - P0y) - (P2x -  P0x) * (P1y - P0y) );
}

//static str pnpoly_(int *out, int nvert, dbl *vx, dbl *vy, int *point_x, int *point_y) {
static str pnpoly_(int *out, const GEOSGeometry *geosGeometry, int *point_x, int *point_y) {
    BAT *bo = NULL, *bpx = NULL, *bpy = NULL;
    dbl *px = NULL, *py = NULL;
    BUN i = 0;
    unsigned int j = 0;
    struct timeval stop, start;
    unsigned long long t;
    bte *cs = NULL;

	const GEOSCoordSequence *coordSeq;
	unsigned int geometryPointsNum=0 ;

	/* get the coordinates of the points comprising the geometry */
	if(!(coordSeq = GEOSGeom_getCoordSeq(geosGeometry)))
		return createException(MAL, "batgeom.Contains", "GEOSGeom_getCoordSeq failed");
	
	/* get the number of points in the geometry */
	GEOSCoordSeq_getSize(coordSeq, &geometryPointsNum);

	/*Get the BATs*/
	if ((bpx = BATdescriptor(*point_x)) == NULL) {
        	throw(MAL, "geom.point", RUNTIME_OBJECT_MISSING);
   	}

    	if ((bpy = BATdescriptor(*point_y)) == NULL) {
        	BBPreleaseref(bpx->batCacheid);
        	throw(MAL, "geom.point", RUNTIME_OBJECT_MISSING);
    	}

   	/*Check BATs alignment*/
    	if ( bpx->htype != TYPE_void || bpy->htype != TYPE_void ||bpx->hseqbase != bpy->hseqbase || BATcount(bpx) != BATcount(bpy)) {
      		BBPreleaseref(bpx->batCacheid);
        	BBPreleaseref(bpy->batCacheid);
        	throw(MAL, "geom.point", "both point bats must have dense and aligned heads");
    	}

    	/*Create output BAT*/
    	if ((bo = BATnew(TYPE_void, ATOMindex("bte"), BATcount(bpx), TRANSIENT)) == NULL) {
        	BBPreleaseref(bpx->batCacheid);
        	BBPreleaseref(bpy->batCacheid);
        	throw(MAL, "geom.point", MAL_MALLOC_FAIL);
    	}
    	BATseqbase(bo, bpx->hseqbase);

    	/*Iterate over the Point BATs and determine if they are in Polygon represented by vertex BATs*/
    	px = (dbl *) Tloc(bpx, BUNfirst(bpx));
    	py = (dbl *) Tloc(bpy, BUNfirst(bpx));

    	gettimeofday(&start, NULL);
    	cs = (bte*) Tloc(bo,BUNfirst(bo));
    	for (i = 0; i < BATcount(bpx); i++) { //for each point in the x, y BATs
       		int wn = 0;
        	for (j = 0; j < geometryPointsNum; j++) { //check each point in the geometry (the exteriorRing)
			double xCurrent=0.0, yCurrent=0.0, xNext=0.0, yNext=0.0;
			if(GEOSCoordSeq_getX(coordSeq, j, &xCurrent) == -1 || GEOSCoordSeq_getX(coordSeq, j+1, &xNext) == -1)
				return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getX failed");
			if(GEOSCoordSeq_getY(coordSeq, j, &yCurrent) == -1 || GEOSCoordSeq_getY(coordSeq, j+1, &yNext) == -1)
				return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getY failed");
            		if (yCurrent <= py[i]) {
                		if (yNext > py[i])
                    			if (isLeft( xCurrent, yCurrent, xNext, yNext, px[i], py[i]) > 0)
                        			++wn;
            		}
            		else {
                		if (yNext  <= py[i])
                    			if (isLeft(xCurrent, yCurrent, xNext, yNext, px[i], py[i]) < 0)
                        			--wn;
            		}
        	}
        	*cs++ = wn & 1;
    	}
    gettimeofday(&stop, NULL);
    t = 1000 * (stop.tv_sec - start.tv_sec) + (stop.tv_usec - start.tv_usec) / 1000;
    printf("took %llu ms\n", t);

    gettimeofday(&start, NULL);
    //BATsetcount(bo,cnt);
    BATderiveProps(bo,FALSE);
    gettimeofday(&stop, NULL);
    t = 1000 * (stop.tv_sec - start.tv_sec) + (stop.tv_usec - start.tv_usec) / 1000;
    printf("Append took %llu ms\n", t);

    BBPreleaseref(bpx->batCacheid);
    BBPreleaseref(bpy->batCacheid);
    BBPkeepref(*out = bo->batCacheid);
    return MAL_SUCCEED;
}

//static str pnpolyWithHoles_(int *out, int nvert, dbl *vx, dbl *vy, int nholes, dbl **hx, dbl **hy, int *hn, int *point_x, int *point_y) {
static str pnpolyWithHoles_(int *out, GEOSGeom geosGeometry, unsigned int interiorRingsNum, int *point_x, int *point_y) {
    BAT *bo = NULL, *bpx = NULL, *bpy;
    dbl *px = NULL, *py = NULL;
    BUN i = 0;
    unsigned int j = 0, h = 0;
    bte *cs = NULL;

	const GEOSGeometry *exteriorRingGeometry;
	const GEOSCoordSequence *exteriorRingCoordSeq;
	unsigned int exteriorRingPointsNum=0 ;

    /*Get the BATs*/
    if ((bpx = BATdescriptor(*point_x)) == NULL) {
        throw(MAL, "geom.point", RUNTIME_OBJECT_MISSING);
    }
    if ((bpy = BATdescriptor(*point_y)) == NULL) {
        BBPreleaseref(bpx->batCacheid);
        throw(MAL, "geom.point", RUNTIME_OBJECT_MISSING);
    }

    /*Check BATs alignment*/
    if ( bpx->htype != TYPE_void ||
            bpy->htype != TYPE_void ||
            bpx->hseqbase != bpy->hseqbase ||
            BATcount(bpx) != BATcount(bpy)) {
        BBPreleaseref(bpx->batCacheid);
        BBPreleaseref(bpy->batCacheid);
        throw(MAL, "geom.point", "both point bats must have dense and aligned heads");
    }

    /*Create output BAT*/
    if ((bo = BATnew(TYPE_void, ATOMindex("bte"), BATcount(bpx), TRANSIENT)) == NULL) {
        BBPreleaseref(bpx->batCacheid);
        BBPreleaseref(bpy->batCacheid);
        throw(MAL, "geom.point", MAL_MALLOC_FAIL);
    }
    BATseqbase(bo, bpx->hseqbase);

	//get the exterior ring of the geometry	
	if(!(exteriorRingGeometry = GEOSGetExteriorRing(geosGeometry)))
		return createException(MAL, "batgeom.Contains", "GEOSGetExteriorRing failed");

	/* get the coordinates of the points comprising the exteriorRing */
	if(!(exteriorRingCoordSeq = GEOSGeom_getCoordSeq(exteriorRingGeometry)))
		return createException(MAL, "batgeom.Contains", "GEOSGeom_getCoordSeq failed");
	
	/* get the number of points in the exterior ring */
	GEOSCoordSeq_getSize(exteriorRingCoordSeq, &exteriorRingPointsNum);

    /*Iterate over the Point BATs and determine if they are in Polygon represented by vertex BATs*/
    px = (dbl *) Tloc(bpx, BUNfirst(bpx));
    py = (dbl *) Tloc(bpy, BUNfirst(bpx));
   // cnt = BATcount(bpx);
    cs = (bte*) Tloc(bo,BUNfirst(bo));
    for (i = 0; i < BATcount(bpx); i++) {
        int wn = 0;

        //First check the holes
        for (h = 0; h < interiorRingsNum; h++) {
		const GEOSGeometry *interiorRingGeometry;
		const GEOSCoordSequence *interiorRingCoordSeq;
		unsigned int interiorRingPointsNum=0 ;

		//get the interior ring
		if(!(interiorRingGeometry = GEOSGetInteriorRingN(geosGeometry, h)))
			return createException(MAL, "batgeom.Contains", "GEOSGetInteriorRingN failed");
		
		/* get the coordinates of the points comprising the interior ring */
		if(!(interiorRingCoordSeq = GEOSGeom_getCoordSeq(interiorRingGeometry)))
			return createException(MAL, "batgeom.Contains", "GEOSGeom_getCoordSeq failed");
	
		/* get the number of points in the interior ring */
		GEOSCoordSeq_getSize(interiorRingCoordSeq, &interiorRingPointsNum);
            
		wn = 0;
            	for (j = 0; j < interiorRingPointsNum; j++) { //check each point in the interior ring
			double xCurrent=0.0, yCurrent=0.0, xNext=0.0, yNext=0.0;

			if(GEOSCoordSeq_getX(interiorRingCoordSeq, j, &xCurrent) == -1 || GEOSCoordSeq_getX(interiorRingCoordSeq, j+1, &xNext) == -1)
				return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getX failed");
			if(GEOSCoordSeq_getY(interiorRingCoordSeq, j, &yCurrent) == -1 || GEOSCoordSeq_getY(interiorRingCoordSeq, j+1, &yNext) == -1)
				return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getY failed");
            		if (yCurrent <= py[i]) {
                		if (yNext > py[i])
                    			if (isLeft( xCurrent, yCurrent, xNext, yNext, px[i], py[i]) > 0)
                        			++wn;
            		} else {
                		if (yNext  <= py[i])
                    			if (isLeft(xCurrent, yCurrent, xNext, yNext, px[i], py[i]) < 0)
                        			--wn;
            		}
		}

            	//It is in one of the holes no reason to check the others
            	if (wn)
                	break;
        }

	//found in the holes there is no reason to check the external ring
        if (wn) 
            continue;

        /*If not in any of the holes, check inside the Polygon*/
	for (j = 0; j < exteriorRingPointsNum; j++) { //check each point in the exterior ring)
		double xCurrent=0.0, yCurrent=0.0, xNext=0.0, yNext=0.0;
		if(GEOSCoordSeq_getX(exteriorRingCoordSeq, j, &xCurrent) == -1 || GEOSCoordSeq_getX(exteriorRingCoordSeq, j+1, &xNext) == -1)
			return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getX failed");
		if(GEOSCoordSeq_getY(exteriorRingCoordSeq, j, &yCurrent) == -1 || GEOSCoordSeq_getY(exteriorRingCoordSeq, j+1, &yNext) == -1)
			return createException(MAL, "batgeom.Contains", "GEOSCoordSeq_getY failed");
        	if (yCurrent <= py[i]) {
               		if (yNext > py[i])
               			if (isLeft( xCurrent, yCurrent, xNext, yNext, px[i], py[i]) > 0)
                       			++wn;
        	} else {
                	if (yNext  <= py[i])
               			if (isLeft(xCurrent, yCurrent, xNext, yNext, px[i], py[i]) < 0)
                       			--wn;
            	}
        }
        *cs++ = wn&1;
    }
   // BATsetcount(bo,cnt);
    BATderiveProps(bo,FALSE);
    BBPreleaseref(bpx->batCacheid);
    BBPreleaseref(bpy->batCacheid);
    BBPkeepref(*out = bo->batCacheid);
    return MAL_SUCCEED;
}

#define POLY_NUM_VERT 120
#define POLY_NUM_HOLE 10

str wkbPointsContains2_geom_bat(bat* out, wkb** geomWKB, bat* point_x, bat* point_y, int* srid) {
	int interiorRingsNum = 0;
	GEOSGeom geosGeometry;
	str msg = NULL;

	//check if geometry a and the points have the same srid
	if((*geomWKB)->srid != *srid) 
		return createException(MAL, "batgeom.Contains", "Geometry and points should have the same srid");

	//get the GEOS representation of the geometry
	if(!(geosGeometry = wkb2geos(*geomWKB)))
		return createException(MAL, "batgeom.Contains", "wkb2geos failed");
	//check if the geometry is a polygon
	if((GEOSGeomTypeId(geosGeometry)+1) != wkbPolygon)
		return createException(MAL, "batgeom.Contains", "Geometry should be a polygon");

	//get the number of interior rings of the polygon
	if((interiorRingsNum = GEOSGetNumInteriorRings(geosGeometry)) == -1) {
		return createException(MAL, "batgeom.Contains", "GEOSGetNumInteriorRings failed");
	}

	if(interiorRingsNum > 0) {
		msg = pnpolyWithHoles_(out, geosGeometry, interiorRingsNum, point_x, point_y);
	} else {
		//get the exterior ring
		const GEOSGeometry *exteriorRingGeometry;
		if(!(exteriorRingGeometry = GEOSGetExteriorRing(geosGeometry)))
			return createException(MAL, "batgeom.Contains", "GEOSGetExteriorRing failed");
		msg = pnpoly_(out, exteriorRingGeometry, point_x, point_y);
	}
	return msg;
}


str wkbFilteredPointsContains_geom_bat(bat* outBAT_id, wkb** geomWKB, bat* xBAT_id, bat* yBAT_id, bat* candidatesBAT_id, int* srid) {
	BAT *xBAT=NULL, *yBAT=NULL, *candidatesBAT=NULL, *outBAT=NULL;
	BAT *pointsBAT = NULL, *pointsWithSRIDBAT=NULL;
	str ret=MAL_SUCCEED;

	//get the descriptors of the BATs
	if ((xBAT = BATdescriptor(*xBAT_id)) == NULL) {
		throw(MAL, "batgeom.wkbContainsFiltered", RUNTIME_OBJECT_MISSING);
	}
	if ((yBAT = BATdescriptor(*yBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		throw(MAL, "batgeom.wkbContainsFiltered", RUNTIME_OBJECT_MISSING);
	}
	if ((candidatesBAT = BATdescriptor(*candidatesBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		throw(MAL, "batgeom.wkbContainsFiltered", RUNTIME_OBJECT_MISSING);
	}
	
	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT) || !BAThdense(candidatesBAT)) {
		ret = createException(MAL, "batgeom.wkbContainsFiltered", "BATs must have dense heads");
		goto clean;
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		ret=createException(MAL, "batgeom.wkbContainsFiltered", "BATs must be aligned");
		goto clean;
	}

	//here the BAT version of some contain function that takes the BATs of the x y coordinates should be called
	//create the points BAT
	if((pointsBAT = BATMakePoint2D(xBAT, yBAT, candidatesBAT)) == NULL) {
		ret = createException(MAL, "batgeom.wkbContainsFiltered", "Problem creating the points from the coordinates");
		goto clean;
	}
	//set the srid	
	if((pointsWithSRIDBAT = BATSetSRID(pointsBAT, *srid)) == NULL) {
		ret = createException(MAL, "batgeom.wkbContainsFiltered", "Problem setting srid to the points");
		goto clean;
	}
	//check the contains
	if((outBAT = BATContains(geomWKB, pointsWithSRIDBAT)) == NULL) {
		ret = createException(MAL, "batgeom.wkbContainsFiltered", "Problem evalauting the contains");
		goto clean;
	}


	BBPkeepref(*outBAT_id = outBAT->batCacheid);
	goto clean;

clean:
	if(xBAT)
		BBPreleaseref(xBAT->batCacheid);
	if(yBAT)
		BBPreleaseref(yBAT->batCacheid);
	if(candidatesBAT)
		BBPreleaseref(candidatesBAT->batCacheid);
	if(pointsBAT)
		BBPreleaseref(pointsBAT->batCacheid);
	if(pointsWithSRIDBAT)
		BBPreleaseref(pointsWithSRIDBAT->batCacheid);
	return ret;
}

static BAT* BATDistance(wkb** geomWKB, BAT* geometriesBAT) {
	BAT *outBAT = NULL;
	BATiter geometriesBAT_iter;	
	BUN p=0, q=0;

	//check if the BAT has dense heads and are aligned
	if (!BAThdense(geometriesBAT)) {
		GDKerror("BATDistance: BAT must have dense heads");
		return NULL;
	}

	//create a new BAT
	if ((outBAT = BATnew(TYPE_void, ATOMindex("dbl"), BATcount(geometriesBAT), TRANSIENT)) == NULL) {
		GDKerror("BATDistance: Could not create new BAT for the output");
		return NULL;
	}

	//set the first idx of the new BAT equal to that of the x BAT (which is equal to the y BAT)
	BATseqbase(outBAT, geometriesBAT->hseqbase);

	//iterator over the BATs	
	geometriesBAT_iter = bat_iterator(geometriesBAT);
	 
	BATloop(geometriesBAT, p, q) { //iterate over all valid elements
		str err = NULL;
		double val = 0.0;

		wkb *geometryWKB = (wkb*) BUNtail(geometriesBAT_iter, p);
		if ((err = wkbDistance(&val, geomWKB, &geometryWKB)) != MAL_SUCCEED) {
			BBPreleaseref(outBAT->batCacheid);
			GDKerror("BATDistance: %s", err);
			GDKfree(err);
			return NULL;
		}
		BUNappend(outBAT,&val,TRUE);
	}

	return outBAT;
}

str wkbPointsDistance_geom_bat(bat* outBAT_id, wkb** geomWKB, bat* xBAT_id, bat* yBAT_id, int* srid) {
	BAT *xBAT=NULL, *yBAT=NULL, *outBAT=NULL;
	BAT *pointsBAT = NULL, *pointsWithSRIDBAT=NULL;
	str ret=MAL_SUCCEED;

	//get the descriptors of the BATs
	if ((xBAT = BATdescriptor(*xBAT_id)) == NULL) {
		throw(MAL, "batgeom.Distance", RUNTIME_OBJECT_MISSING);
	}
	if ((yBAT = BATdescriptor(*yBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		throw(MAL, "batgeom.Distance", RUNTIME_OBJECT_MISSING);
	}
	
	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT)) {
		ret = createException(MAL, "batgeom.Distance", "BATs must have dense heads");
		goto clean;
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		ret=createException(MAL, "batgeom.Distance", "BATs must be aligned");
		goto clean;
	}
/* This will be used when custom spatial functions are used 
	//project the x and y BATs
	xFilteredBAT = BATproject(candidatesBAT, xBAT);
	if(xFilteredBAT == NULL) {
		ret=createException(MAL,"batgeom.wkbContainsFiltered","Problem projecting xBAT");
		goto clean;
	}
	yFilteredBAT = BATproject(candidatesBAT, yBAT);
	if(xFilteredBAT == NULL) {
		ret=createException(MAL,"batgeom.wkbContainsFiltered","Problem projecting yBAT");
		goto clean;
	}
*/
	//here the BAT version of some contain function that takes the BATs of the x y coordinates should be called
	//create the points BAT
	if((pointsBAT = BATMakePoint2D(xBAT, yBAT, NULL)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem creating the points from the coordinates");
		goto clean;
	}

	if((pointsWithSRIDBAT = BATSetSRID(pointsBAT, *srid)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem setting srid to the points");
		goto clean;
	}

	if((outBAT = BATDistance(geomWKB, pointsWithSRIDBAT)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem evalauting the contains");
		goto clean;
	}

	BBPkeepref(*outBAT_id = outBAT->batCacheid);
	goto clean;

clean:
	if(xBAT)
		BBPreleaseref(xBAT->batCacheid);
	if(yBAT)
		BBPreleaseref(yBAT->batCacheid);
	if(pointsBAT)
		BBPreleaseref(pointsBAT->batCacheid);
	if(pointsWithSRIDBAT)
		BBPreleaseref(pointsWithSRIDBAT->batCacheid);
	return ret;
}

str wkbFilteredPointsDistance_geom_bat(bat* outBAT_id, wkb** geomWKB, bat* xBAT_id, bat* yBAT_id, bat* candidatesBAT_id, int* srid) {
	BAT *xBAT=NULL, *yBAT=NULL, *candidatesBAT=NULL, *outBAT=NULL;
	BAT *pointsBAT = NULL, *pointsWithSRIDBAT=NULL;
	str ret=MAL_SUCCEED;

	//get the descriptors of the BATs
	if ((xBAT = BATdescriptor(*xBAT_id)) == NULL) {
		throw(MAL, "batgeom.Distance", RUNTIME_OBJECT_MISSING);
	}
	if ((yBAT = BATdescriptor(*yBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		throw(MAL, "batgeom.Distance", RUNTIME_OBJECT_MISSING);
	}
	if ((candidatesBAT = BATdescriptor(*candidatesBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		throw(MAL, "batgeom.Distance", RUNTIME_OBJECT_MISSING);
	}
	
	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT) || !BAThdense(candidatesBAT)) {
		ret = createException(MAL, "batgeom.Distance", "BATs must have dense heads");
		goto clean;
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		ret=createException(MAL, "batgeom.Distance", "BATs must be aligned");
		goto clean;
	}

	if((pointsBAT = BATMakePoint2D(xBAT, yBAT, candidatesBAT)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem creating the points from the coordinates");
		goto clean;
	}

	//set the srid	
	if((pointsWithSRIDBAT = BATSetSRID(pointsBAT, *srid)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem setting srid to the points");
		goto clean;
	}

	//compute the distance
	if((outBAT = BATDistance(geomWKB, pointsWithSRIDBAT)) == NULL) {
		ret = createException(MAL, "batgeom.Distance", "Problem evalauting the contains");
		goto clean;
	}

	BBPkeepref(*outBAT_id = outBAT->batCacheid);
	goto clean;

clean:
	if(xBAT)
		BBPreleaseref(xBAT->batCacheid);
	if(yBAT)
		BBPreleaseref(yBAT->batCacheid);
	if(candidatesBAT)
		BBPreleaseref(candidatesBAT->batCacheid);
	if(pointsBAT)
		BBPreleaseref(pointsBAT->batCacheid);
	if(pointsWithSRIDBAT)
		BBPreleaseref(pointsWithSRIDBAT->batCacheid);
	return ret;
}


str wkbFilterWithImprints_geom_bat(bat* candidateOIDsBAT_id, wkb** geomWKB, bat* xBAT_id, bat* yBAT_id) {
	BAT *xBAT=NULL, *yBAT=NULL, *xCandidateOIDsBAT=NULL, *candidateOIDsBAT=NULL;
	mbr* geomMBR;
	str err;
	double xmin=0.0, xmax=0.0, ymin=0.0, ymax=0.0;

	//get the descriptors of the BATs
	if ((xBAT = BATdescriptor(*xBAT_id)) == NULL) {
		throw(MAL, "batgeom.Filter", RUNTIME_OBJECT_MISSING);
	}
	if ((yBAT = BATdescriptor(*yBAT_id)) == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		throw(MAL, "batgeom.Filter", RUNTIME_OBJECT_MISSING);
	}

	//check if the BATs have dense heads and are aligned
	if (!BAThdense(xBAT) || !BAThdense(yBAT)) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		return createException(MAL, "batgeom.Filter", "BATs must have dense heads");
	}
	if(xBAT->hseqbase != yBAT->hseqbase || BATcount(xBAT) != BATcount(yBAT)) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		return createException(MAL, "batgeom.Filter", "BATs must be aligned");
	}

	//create the MBR of the geom
	if((err = wkbMBR(&geomMBR, geomWKB)) != MAL_SUCCEED) {
		str msg;
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		msg = createException(MAL, "batgeom.Filter", "%s", err);
		GDKfree(err);
		return msg;
	}
	
	//get candidateOIDs from xBAT (limits are considred to be inclusive)
	xmin = geomMBR->xmin;
	xmax = geomMBR->xmax;
	xCandidateOIDsBAT = BATsubselect(xBAT, NULL, &xmin, &xmax, 1, 1, 0);
	if(xCandidateOIDsBAT == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		return createException(MAL,"batgeom.Filter","Problem filtering xBAT");
	}
	
	//get candidateOIDs using yBAT and xCandidateOIDsBAT
	ymin = geomMBR->ymin;
	ymax = geomMBR->ymax;
	candidateOIDsBAT = BATsubselect(yBAT, xCandidateOIDsBAT, &ymin, &ymax, 1, 1, 0);
	if(candidateOIDsBAT == NULL) {
		BBPreleaseref(xBAT->batCacheid);
		BBPreleaseref(yBAT->batCacheid);
		return createException(MAL,"batgeom.Filter","Problem filtering yBAT");
	}

	BBPreleaseref(xBAT->batCacheid);
	BBPreleaseref(yBAT->batCacheid);
	BBPkeepref(*candidateOIDsBAT_id = candidateOIDsBAT->batCacheid);
	return MAL_SUCCEED;
}



