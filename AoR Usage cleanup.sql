SELECT DISTINCT 'DELETE/MERGE' "METADATA"
	, 'AreasOfResponsibility' "AreaOfResponsibility"
	, PAR.RESPONSIBILITY_NAME "ResponsibilityName"
	, PAPF.PERSON_NUMBER "PersonNumber"
	, PAR.RESPONSIBILITY_TYPE "ResponsibilityType"
	, PAAM.ASSIGNMENT_NUMBER "AssignmentNumber"
	, TO_CHAR(PAR.START_DATE, 'YYYY/MM/DD') "StartDate"
	, PAR.WORK_CONTACTS_FLAG "WorkContactsFlag"
	, PAR.USAGE "Usage"
	, PAR.STATUS "Status"
	, HIKM.SOURCE_SYSTEM_OWNER "SourceSystemOwner"
	, HIKM.SOURCE_SYSTEM_ID "SourceSystemId"
FROM PER_ASG_RESPONSIBILITIES PAR
	, PER_ALL_PEOPLE_F PAPF
	, HRC_INTEGRATION_KEY_MAP HIKM
	, PER_ALL_ASSIGNMENTS_M PAAM
WHERE 1 = 1
	AND PAR.ASG_RESPONSIBILITY_ID = HIKM.SURROGATE_ID
	AND PAPF.PERSON_ID = PAR.PERSON_ID
	AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
	AND PAR.RESPONSIBILITY_TYPE IN ('DB_OPS'
	, 'DB_HRBP'
	, 'DB_OC_PD_DATA'
	, 'DB_KOORDINATION_NAQ')
	AND PAAM.ASSIGNMENT_ID = PAR.ASSIGNMENT_ID
	AND PAAM.ASSIGNMENT_TYPE NOT LIKE '%T'
	AND PAAM.EFFECTIVE_START_DATE = (SELECT MAX(PAAM2.EFFECTIVE_START_DATE) FROM PER_ALL_ASSIGNMENTS_M PAAM2 WHERE PAAM2.PERSON_ID = PAAM.PERSON_ID)
	AND HIKM.OBJECT_NAME = 'AssignmentResponsibility'
