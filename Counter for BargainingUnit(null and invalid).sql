SELECT COUNT(DISTINCT PERSON_NUMBER) "PersonWithNotValidBU" FROM (
SELECT DISTINCT PAPF.PERSON_NUMBER "PERSON_NUMBER"
	, nvl(CASE WHEN PAAM.BARGAINING_UNIT_CODE IS NOT NULL
		THEN (CASE WHEN PAAM.BARGAINING_UNIT_CODE NOT IN (SELECT DISTINCT FLVB.LOOKUP_CODE
								FROM FND_LOOKUP_VALUES_B FLVB
								WHERE 1 = 1
									AND FLVB.LOOKUP_TYPE = 'BARGAINING_UNIT_CODE') THEN 'INVALID' ELSE 'VALID' END)
		ELSE ''
		END, 'NULL') "BARGAINING_UNIT_STATUS"
FROM (PER_ALL_ASSIGNMENTS_M PAAM
	LEFT JOIN PER_ACTION_OCCURRENCES PAO
	ON PAO.ACTION_OCCURRENCE_ID = PAAM.ACTION_OCCURRENCE_ID)
		LEFT JOIN PER_ACTION_REASONS_B PARB
		ON PARB.ACTION_REASON_ID = PAO.ACTION_REASON_ID
	, PER_ALL_PEOPLE_F PAPF
	, PER_PERIODS_OF_SERVICE PPOS
	, HR_ORGANIZATION_UNITS_F_TL HOUFT_LE
	, HR_ORG_UNIT_CLASSIFICATIONS_F HOUCF_LE
	, HRC_INTEGRATION_KEY_MAP HIKM
	, HR_ORGANIZATION_UNITS_F_TL HOUFT_BU
	, HR_ORG_UNIT_CLASSIFICATIONS_F HOUCF_BU
WHERE 1 = 1
	AND HOUFT_BU.ORGANIZATION_ID = PAAM.BUSINESS_UNIT_ID
	AND HOUCF_BU.ORGANIZATION_ID = PAAM.BUSINESS_UNIT_ID
	AND HOUCF_BU.CLASSIFICATION_CODE = 'FUN_BUSINESS_UNIT'
	AND PAAM.PERSON_ID = PAPF.PERSON_ID
	AND HIKM.SURROGATE_ID = PAAM.ASSIGNMENT_ID
	AND PAAM.ASSIGNMENT_TYPE NOT LIKE '%T%'
	AND PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
	AND PAAM.PRIMARY_FLAG = 'Y'
	AND PPOS.PRIMARY_FLAG = 'Y'
	AND PPOS.PERSON_ID = PAPF.PERSON_ID
	AND PPOS.LEGAL_ENTITY_ID = HOUFT_LE.ORGANIZATION_ID
	AND HOUFT_LE.ORGANIZATION_ID = HOUCF_LE.ORGANIZATION_ID
	AND HIKM.OBJECT_NAME = 'Assignment'
	AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN HOUFT_LE.EFFECTIVE_START_DATE AND HOUFT_LE.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN HOUCF_LE.EFFECTIVE_START_DATE AND HOUCF_LE.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN HOUFT_BU.EFFECTIVE_START_DATE AND HOUFT_BU.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN HOUCF_BU.EFFECTIVE_START_DATE AND HOUCF_BU.EFFECTIVE_END_DATE
ORDER BY PAPF.PERSON_NUMBER, TO_CHAR(PAAM.EFFECTIVE_START_DATE, 'YYYY/MM/DD')
) WHERE 1 = 1
	AND BARGAINING_UNIT_STATUS IN ('INVALID', 'NULL')
