USE CDPH;

WITH DistinctBusiness AS
(
	SELECT DISTINCT License
		,DBA_Name
		,[Address]
		,City
		,[State]
		,Zip
	FROM DataOpenRefine
	WHERE License <> 0
)

,LicenseDBANameUsage AS
(
	SELECT *
		,COUNT(*) OVER (PARTITION BY License, DBA_Name) AS LicenseDBANameDistinctUsageCount
	FROM DistinctBusiness
)

,NonUniqueLicenseDBANameUsage AS
(
	SELECT *
	FROM LicenseDBANameUsage
	WHERE LicenseDBANameUsage.LicenseDBANameDistinctUsageCount > 1
)

SELECT *
FROM NonUniqueLicenseDBANameUsage
ORDER BY License
	,DBA_Name