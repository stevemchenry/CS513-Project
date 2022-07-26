USE CDPH;

-- Throughout this script, values from the raw data are explicitly collated
-- as case-sensitive, accent-sensitive to avoid underreporting by databases
-- or columns configured with case-insensitive collations

-- DBA Name field number of merged values
WITH DataRaw_DBA_Name AS
(
	SELECT DISTINCT DR.DBA_Name COLLATE Latin1_General_CS_AS AS [Name]
	FROM DataRaw AS DR
	GROUP BY DR.DBA_Name COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_DBA_Name AS
(
	SELECT DISTINCT DOR.DBA_Name AS [Name]
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.DBA_Name
)

SELECT (SELECT COUNT(*) FROM DataRaw_DBA_Name) - (SELECT COUNT(*) FROM DataOpenRefine_DBA_Name) AS MergedCount_DBA_Name;

GO

-- AKA Name field number of merged values
WITH DataRaw_AKA_Name AS
(
	SELECT DISTINCT DR.AKA_Name COLLATE Latin1_General_CS_AS AS [Name]
	FROM DataRaw AS DR
	GROUP BY DR.AKA_Name COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_AKA_Name AS
(
	SELECT DISTINCT DOR.AKA_Name AS [Name]
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.AKA_Name
)

SELECT (SELECT COUNT(*) FROM DataRaw_AKA_Name) - (SELECT COUNT(*) FROM DataOpenRefine_AKA_Name) AS MergedCount_AKA_Name;

GO

-- Address field number of merged values
WITH DataRaw_Address AS
(
	SELECT DISTINCT DR.[Address] COLLATE Latin1_General_CS_AS AS [Address]
	FROM DataRaw AS DR
	GROUP BY DR.Address COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_Address AS
(
	SELECT DISTINCT DOR.[Address] AS [Address]
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.Address
)

SELECT (SELECT COUNT(*) FROM DataRaw_Address) - (SELECT COUNT(*) FROM DataOpenRefine_Address) AS MergedCount_Address;

GO

-- City field number of merged values
WITH DataRaw_City AS
(
	SELECT DISTINCT DR.City COLLATE Latin1_General_CS_AS AS City
	FROM DataRaw AS DR
	GROUP BY DR.City COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_City AS
(
	SELECT DISTINCT DOR.City AS City
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.City
)

SELECT (SELECT COUNT(*) FROM DataRaw_City) - (SELECT COUNT(*) FROM DataOpenRefine_City) AS MergedCount_City;

GO

-- Zip field number of NULL values resolved
SELECT COUNT(*) AS ResolvedCount_Zip
FROM DataRaw AS DR
WHERE DR.Zip IS NULL;

GO

-- Location field number of NULL values resolved
SELECT COUNT(*) AS ResolvedCount_Location
FROM DataRaw AS DR
WHERE DR.[Location] IS NULL;

GO

-- Violation field number of violations
SELECT COUNT(*) AS Count_Violations
FROM InspectionViolation;