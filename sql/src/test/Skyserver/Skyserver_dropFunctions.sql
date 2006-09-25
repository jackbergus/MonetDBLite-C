START TRANSACTION;

DROP FUNCTION fSkyVersion;
DROP FUNCTION fRerun;
DROP FUNCTION fRun;
DROP FUNCTION fCamcol;
DROP FUNCTION fField;
DROP FUNCTION fObj;
DROP FUNCTION fSDSS;
DROP FUNCTION fObjidFromSDSS;
DROP FUNCTION fObjidFromSDSSWithFF;
DROP FUNCTION fSpecidFromSDSS;
DROP FUNCTION fPlate;
DROP FUNCTION fMJD;
DROP FUNCTION fFiber;
DROP FUNCTION fPhotoStatusN;
DROP FUNCTION fPhotoStatus;
DROP FUNCTION fPrimTargetN;
DROP FUNCTION fPrimTarget;
DROP FUNCTION fSecTarget;
DROP FUNCTION fSecTargetN;
DROP FUNCTION fInsideMask;
DROP FUNCTION fInsideMaskN;
DROP FUNCTION fSpecZWarning;
DROP FUNCTION fSpecZWarningN;
DROP FUNCTION fImageMask;
DROP FUNCTION fImageMaskN;
DROP FUNCTION fTiMask;
DROP FUNCTION fTiMaskN;
DROP FUNCTION fPhotoModeN;
DROP FUNCTION fPhotoMode;
DROP FUNCTION fPhotoTypeN;
DROP FUNCTION fPhotoType;
DROP FUNCTION fMaskTypeN;
DROP FUNCTION fMaskType;
DROP FUNCTION fFieldQualityN;
DROP FUNCTION fFieldQuality;
DROP FUNCTION fPspStatus;
DROP FUNCTION fPspStatusN;
DROP FUNCTION fFramesStatus;
DROP FUNCTION fFramesStatusN;
DROP FUNCTION fSpecClass;
DROP FUNCTION fSpecClassN;
DROP FUNCTION fSpecLineNames;
DROP FUNCTION fSpecLineNamesN;
DROP FUNCTION fSpecZStatusN;
DROP FUNCTION fSpecZStatus;
DROP FUNCTION fHoleType;
DROP FUNCTION fHoleTypeN;
DROP FUNCTION fObjType;
DROP FUNCTION fObjTypeN;
DROP FUNCTION fProgramType;
DROP FUNCTION fProgramTypeN;
DROP FUNCTION fCoordType;
DROP FUNCTION fCoordTypeN;
DROP FUNCTION fFieldMask;
DROP FUNCTION fFieldMaskN;
DROP FUNCTION fPhotoFlagsN;
DROP FUNCTION fPhotoFlags;
DROP FUNCTION fMJDToGMT;
DROP FUNCTION fDistanceArcMinXYZ;
DROP FUNCTION fDistanceArcMinEq;
DROP FUNCTION fIAUFromEq;
DROP FUNCTION fDMS;
DROP FUNCTION fDMSbase;
DROP FUNCTION fHMS;
DROP FUNCTION fHMSbase;
DROP FUNCTION fMagToFlux;
DROP FUNCTION fMagToFluxErr;
DROP FUNCTION fEtaToNormal;
DROP FUNCTION fStripeToNormal;
DROP FUNCTION fGetLat;
DROP FUNCTION fGetLon;
DROP FUNCTION fGetLonLat;
DROP FUNCTION fEqFromMuNu;
DROP FUNCTION fCoordsFromEq;
DROP FUNCTION fMuFromEq;
DROP FUNCTION fNuFromEq;
DROP FUNCTION fEtaFromEq;
DROP FUNCTION fLambdaFromEq;
DROP FUNCTION fMuNuFromEq;
DROP FUNCTION fWedgeV3;
DROP FUNCTION fRotateV3;
DROP FUNCTION fTokenNext;
DROP FUNCTION fTokenAdvance;
DROP FUNCTION fNormalizeString;
DROP FUNCTION fTokenStringToTable;
DROP FUNCTION fReplace;
DROP FUNCTION fIsNumbers;
DROP FUNCTION fHtmToString;
DROP FUNCTION fHtmLookupXyz;
DROP FUNCTION fHtmXyz;
DROP FUNCTION fHtmLookupEq;
DROP FUNCTION fHtmEq;
DROP FUNCTION fGetNearbyObjAllXYZ;
DROP FUNCTION fGetNearbyObjAllEq;
DROP FUNCTION fGetNearestObjAllEq;
DROP FUNCTION fGetNearestObjIdEqMode;
DROP FUNCTION fGetNearbyObjXYZ;
DROP FUNCTION fGetNearestObjXYZ;
DROP FUNCTION fGetNearbyObjEq;
DROP FUNCTION fGetNearestObjEq;
DROP FUNCTION fGetNearestObjIdEq;
DROP FUNCTION fGetNearestObjIdAllEq;
DROP FUNCTION fGetNearestObjIdEqType;
DROP FUNCTION fGetObjFromRect;
DROP FUNCTION fGetObjectsEq;
DROP FUNCTION fGetObjectsMaskEq;
DROP FUNCTION fGetNearbyFrameEq;
DROP FUNCTION fGetNearestFrameEq;
DROP FUNCTION fGetNearestFrameidEq;
DROP FUNCTION fRegionFromString;
DROP FUNCTION fRegionNormalizeString;
DROP FUNCTION fRegionsContainingPointXYZ;
DROP FUNCTION fRegionsContainingPointEq;
DROP FUNCTION fRegionGetObjectsFromRegionId;
DROP FUNCTION fRegionGetObjectsFromString;
DROP FUNCTION fRegionIdToString;
DROP FUNCTION fRegionContainsPointXYZ;
DROP FUNCTION fRegionContainsPointEq;
DROP FUNCTION fRegionConvexIdToString;
DROP FUNCTION fRegionNot;
DROP FUNCTION fRegionArcLength;
DROP FUNCTION fRegionAreaTriangle;
DROP FUNCTION fRegionAreaSemiLune;
DROP FUNCTION fRegionAreaPatch;
DROP FUNCTION fRegionToArcs;
DROP FUNCTION fRegionBoundingCircle;
DROP FUNCTION fRegionOverlapString;
DROP FUNCTION fRegionOverlapId;
DROP FUNCTION fFootprintEq;
DROP FUNCTION fGetUrlFitsField;
DROP FUNCTION fGetUrlFitsSpectrum;
DROP FUNCTION fGetUrlSpecImg;
DROP FUNCTION fGetUrlFitsAtlas;
DROP FUNCTION fGetUrlNavEq;
DROP FUNCTION fGetUrlFitsBin;
DROP FUNCTION fGetUrlFitsMask;
DROP FUNCTION fGetUrlFrameImg;
DROP FUNCTION fGetUrlFitsCFrame;
DROP FUNCTION fGetUrlExpId;
DROP FUNCTION fGetUrlExpEq;
DROP FUNCTION fGetUrlNavId;
DROP FUNCTION fIndexName;
DROP FUNCTION fTileFileName;
DROP FUNCTION fDocColumnsWithRank;
DROP FUNCTION fDocColumns;
DROP FUNCTION fDocFunctionParams;
DROP FUNCTION fSpecDescription;
DROP FUNCTION fPhotoDescription;
DROP FUNCTION fEnum;
DROP FUNCTION fFirstFieldBit;
DROP FUNCTION fObjID;
DROP FUNCTION fPrimaryObjID;
DROP FUNCTION fDatediffSec;
DROP FUNCTION fRegionFuzz;
DROP FUNCTION fStripeOfRun;
DROP FUNCTION fStripOfRun;
DROP FUNCTION fGetDiagChecksum;

COMMIT;
