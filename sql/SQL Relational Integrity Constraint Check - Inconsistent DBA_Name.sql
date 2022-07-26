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

,LicenseUsage AS
(
	SELECT *
		,COUNT(*) OVER (PARTITION BY License) AS LicenseDistinctUsageCount
	FROM DistinctBusiness
)

,NonUniqueLicenseUsage AS
(
	SELECT *
	FROM LicenseUsage
	WHERE LicenseUsage.LicenseDistinctUsageCount > 1
)

SELECT *
FROM NonUniqueLicenseUsage
ORDER BY License
	,DBA_Name