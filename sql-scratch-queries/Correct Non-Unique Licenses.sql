--
-- STEP 1: Identify licenses associated with multiple DBA_Names, addresses, or coordinates
--
DROP TABLE IF EXISTS #NonUniqueLicenseInstance;

WITH DistinctLicense AS
(
SELECT DISTINCT DOR.License
	,DOR.DBA_Name
FROM DataOpenRefine AS DOR
)

,NonUniqueLicense AS
(
SELECT DistinctLicense.License
FROM DistinctLicense
GROUP BY DistinctLicense.License
HAVING COUNT(DistinctLicense.License) > 2
)

SELECT DISTINCT DOR.License
	,DOR.DBA_Name
	,DOR.[Address]
	,DOR.City
	,DOR.Zip
	,DOR.Longitude
	,DOR.Latitude
	,DOR.[Location]
	,MIN(DOR.Inspection_Date) OVER (PARTITION BY DOR.License, DOR.DBA_Name) AS EarliestInspection
	,MAX(DOR.Inspection_Date) OVER (PARTITION BY DOR.License, DOR.DBA_Name) AS MostRecentInspection
INTO #NonUniqueLicenseInstance
FROM DataOpenRefine AS DOR
	INNER JOIN NonUniqueLicense ON DOR.License = NonUniqueLicense.License;

-- Sanity check: Review identified non-unique license instances
--SELECT *
--FROM #NonUniqueLicenseInstance
--ORDER BY License

-- Sanity check: Review unique license-DBA names (i.e. not identified as non-unique)
SELECT DISTINCT DOR.License
	,DOR.DBA_Name
FROM DataOpenRefine AS DOR
WHERE DOR.License NOT IN (SELECT License FROM #NonUniqueLicenseInstance);