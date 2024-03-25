-- The main purpose of this SQL for data reports is to extract Location Codes for a Location in reference to a flexfield attribute (Attribute10 in this instance), with filter to quick search for said flexfield attribute, and additional filters for a distinct Set S0033 (in addition, COMMON). Also, added Location names since there could be several Location Codes per flexfield attribute.

SELECT DISTINCT PLDF.ATTRIBUTE10 "Attribute10" -- sample reference point from the client
	, PL.INTERNAL_LOCATION_CODE "LocationCode"
	, PLDFT.LOCATION_NAME "Location"
	, FSS.SET_NAME "BusinessUnit" -- for our client, Set Names are similarly Business Unit names
	, FSS.SET_CODE "SetCode"
FROM PER_LOCATIONS PL
	, PER_LOCATION_DETAILS_F PLDF
	, PER_LOCATION_DETAILS_F_TL PLDFT
	, FND_SETID_SETS FSS
	, HRC_INTEGRATION_KEY_MAP HIKM
WHERE 1 = 1
	AND PL.LOCATION_ID = PLDF.LOCATION_ID
	AND PLDF.LOCATION_DETAILS_ID = PLDFT.LOCATION_DETAILS_ID
	AND PL.SET_ID = FSS.SET_ID
	AND SYSDATE BETWEEN PLDF.EFFECTIVE_START_DATE AND PLDF.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN PLDFT.EFFECTIVE_START_DATE AND PLDFT.EFFECTIVE_END_DATE
	AND FSS.LANGUAGE = FSS.SOURCE_LANG
	AND PLDFT.LANGUAGE = PLDFT.SOURCE_LANG
	AND PL.LOCATION_ID = HIKM.SURROGATE_ID
	AND HIKM.OBJECT_NAME = 'Location'
	AND ATTRIBUTE10 = nvl(:StandortID, PLDF.ATTRIBUTE10)
	AND FSS.SET_CODE IN ('S0033', 'COMMON')
ORDER BY PLDF.ATTRIBUTE10, FSS.SET_NAME, PL.INTERNAL_LOCATION_CODE
