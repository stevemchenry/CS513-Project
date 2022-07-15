USE CDPH;

SELECT DISTINCT License
	,[Location]
	,DBA_Name
	,[Address]
	,City
	,[State]
	,Zip
FROM DataOpenRefine
WHERE Zip IS NULL
ORDER BY License