USE CDPH;

SELECT DISTINCT License
	,[Location]
	,DBA_Name
	,[Address]
	,City
	,[State]
	,Zip
	,[Location]
FROM DataOpenRefine
WHERE [Address] IS NULL
	OR City IS NULL
	OR Zip IS NULL
ORDER BY License