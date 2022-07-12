SELECT DISTINCT License
	,[Location]
	,DBA_Name
	,[Address]
	,City
	,[State]
	,Zip
FROM DataOpenRefine
WHERE City IS NULL
ORDER BY License