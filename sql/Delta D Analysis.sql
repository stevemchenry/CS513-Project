USE CDPH;

-- PREREQUISITE: Before executing this script, it is expected that the user
-- has 1) executed "sql/Raw Data Database Import.sql" to import the raw
-- (dirty) source data into the database, as the table named "DataRaw"
-- and 2) executed workflow W to completion such that the table named
-- "DataOpenRefine" exists and contains the cleaned (but non-normalized)
-- dataset

-- This script using the terms "element" and "value", where an element is
-- an instance of a value within a set; consider the set:
-- {1, 2, 3, 3, 4, 4, 4, 5}
-- This set contains 8 elements, and 5 values

-- Throughout this script, values from the raw data are explicitly collated
-- as case-sensitive, accent-sensitive to avoid underreporting by databases
-- or columns configured with case-insensitive collations

-- *******************
-- Inspection ID field
-- *******************

-- Demonstrate that there are no non-unique Inspection IDs in the raw source data
WITH DataRaw_Inspection_ID AS
(
	SELECT DR.Inspection_ID
	FROM DataRaw AS DR
	GROUP BY DR.Inspection_ID
	HAVING COUNT(DR.Inspection_ID) > 1
)

SELECT COUNT(DataRaw_Inspection_ID.Inspection_ID) AS Inspection_ID_DataRaw_NonUniqueCount
FROM DataRaw_Inspection_ID;

-- Demonstrate that there are no non-unique Inspection IDs in the cleaned data
DECLARE @icvCheckValue INT;

WITH DataOpenRefine_Inspection_ID AS
(
	SELECT DOR.Inspection_ID
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.Inspection_ID
	HAVING COUNT(DOR.Inspection_ID) > 1
)

SELECT @icvCheckValue = COUNT(DataOpenRefine_Inspection_ID.Inspection_ID)
FROM DataOpenRefine_Inspection_ID;

SELECT @icvCheckValue AS Inspection_ID_DataOpenRefine_NonUniqueCount;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: Inspection ID must be unique.', 1;

GO

-- **************
-- DBA Name field
-- **************

-- Calculate the number of DBA Name values that were merged as inconsistent duplicates
WITH DataRaw_DBA_Name AS
(
	SELECT DISTINCT DR.DBA_Name COLLATE Latin1_General_CS_AS AS DBA_Name
	FROM DataRaw AS DR
	GROUP BY DR.DBA_Name COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_DBA_Name AS
(
	SELECT DISTINCT DOR.DBA_Name AS DBA_Name
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.DBA_Name
)

SELECT (SELECT COUNT(*) FROM DataRaw_DBA_Name) - (SELECT COUNT(*) FROM DataOpenRefine_DBA_Name) AS DBA_Name_MergedValueCount;

-- Calculate the number of DBA Name elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.DBA_Name) AS DBA_Name_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.DBA_Name COLLATE Latin1_General_CS_AS <> DR.DBA_Name COLLATE Latin1_General_CS_AS

GO

-- **************
-- AKA Name field
-- **************

-- Calculate the number of AKA Name values that were merged as inconsistent duplicates
WITH DataRaw_AKA_Name AS
(
	SELECT DISTINCT DR.AKA_Name COLLATE Latin1_General_CS_AS AS AKA_Name
	FROM DataRaw AS DR
	GROUP BY DR.AKA_Name COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_AKA_Name AS
(
	SELECT DISTINCT DOR.AKA_Name AS AKA_Name
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.AKA_Name
)

SELECT (SELECT COUNT(*) FROM DataRaw_AKA_Name) - (SELECT COUNT(*) FROM DataOpenRefine_AKA_Name) AS AKA_Name_MergedValueCount;

-- Calculate the number of AKA Name elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.AKA_Name) AS AKA_Name_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.AKA_Name COLLATE Latin1_General_CS_AS <> DR.AKA_Name COLLATE Latin1_General_CS_AS

GO

-- *************
-- License field
-- *************

-- Demonstrate that 15 license elements (cells) were empty (NULL) in the raw source data
SELECT COUNT(*) AS License_DataRaw_NULLCount
FROM DataRaw AS DR
WHERE DR.License IS NULL

-- Demonstrate that all empty (NULL) license elsments are resolved in the cleaned data
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue = COUNT(*)
FROM DataOpenRefine AS DOR
WHERE DOR.License IS NULL

SELECT @icvCheckValue AS License_DataOpenRefine_NULLCount;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: License must be non-NULL.', 1;

GO

-- *******************************************
-- Facility Type field (optional/supplemental)
-- *******************************************

-- Calculate the number of Facility Type values that were optionally merged as inconsistent duplicates
WITH DataRaw_Facility_Type AS
(
	SELECT DISTINCT DR.Facility_Type COLLATE Latin1_General_CS_AS AS Facility_Type
	FROM DataRaw AS DR
	GROUP BY DR.Facility_Type COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_Facility_Type AS
(
	SELECT DISTINCT DOR.Facility_Type AS Facility_Type
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.Facility_Type
)

SELECT (SELECT COUNT(*) FROM DataRaw_Facility_Type) - (SELECT COUNT(*) FROM DataOpenRefine_Facility_Type) AS Facility_Type_MergedCount;

-- Calculate the number of Facility Type elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.Facility_Type) AS Facility_Type_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.Facility_Type COLLATE Latin1_General_CS_AS <> DR.Facility_Type COLLATE Latin1_General_CS_AS

GO

-- *************
-- Address field
-- *************

-- Calculate the number of address values that were merged as inconsistent duplicates
WITH DataRaw_Address AS
(
	SELECT DISTINCT DR.[Address] COLLATE Latin1_General_CS_AS AS [Address]
	FROM DataRaw AS DR
	GROUP BY DR.[Address] COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_Address AS
(
	SELECT DISTINCT DOR.[Address] AS [Address]
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.[Address]
)

SELECT (SELECT COUNT(*) FROM DataRaw_Address) - (SELECT COUNT(*) FROM DataOpenRefine_Address) AS Address_MergedCount;

-- Calculate the number of Address elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.[Address]) AS Address_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.[Address] COLLATE Latin1_General_CS_AS <> DR.[Address] COLLATE Latin1_General_CS_AS
	OR DATALENGTH(DOR.[Address]) <> DATALENGTH(DR.[Address])
	OR DR.[Address] IS NULL;

-- Demonstrate that no NULL addresses exist in the cleaned data
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue = COUNT(DOR.[Address])
FROM DataOpenRefine AS DOR
WHERE DOR.[Address] IS NULL;

SELECT @icvCheckValue AS Address_DataOpenRefine_NULLCount;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: Address must be non-NULL.', 1;

GO

-- **********
-- City field
-- **********

-- Number of NULL City elements in the original raw data
SELECT COUNT(*) AS City_DataRaw_NULL
FROM DataRaw AS DR
WHERE DR.City IS NULL;

-- Number of NULL City elements in the cleaned data
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue =  COUNT(*)
FROM DataOpenRefine AS DOR
WHERE DOR.City IS NULL;

SELECT @icvCheckValue AS City_DataCleaned_NULL;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: City must be non-NULL.', 1;

-- Calculate the number of city values that were merged as inconsistent duplicates
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

SELECT (SELECT COUNT(*) FROM DataRaw_City) - (SELECT COUNT(*) FROM DataOpenRefine_City) AS City_MergedValueCount;

-- Calculate the number of City elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.City) AS City_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.City COLLATE Latin1_General_CS_AS <> DR.City COLLATE Latin1_General_CS_AS
	OR DR.City IS NULL;

GO

-- ***********
-- State field
-- ***********

-- Demonstrate that 8 state elements were empty (NULL) in the raw source data
SELECT COUNT(*) AS State_DataRaw_NULL
FROM DataRaw AS DR
WHERE DR.[State] IS NULL
	OR TRIM(DR.[State]) = '';

-- Demonstrate that no state elements were empty (NULL) in the cleaned data
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue = COUNT(*)
FROM DataOpenRefine AS DOR
WHERE DOR.[State] IS NULL;

SELECT @icvCheckValue AS State_DataOpenRefine_NULL;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: State must be non-NULL.', 1;

GO

-- *********
-- Zip field
-- *********

-- Number of NULL Zip elements in the original dataset
SELECT COUNT(*) AS Zip_DataRaw_NULL
FROM DataRaw AS DR
WHERE DR.Zip IS NULL
	OR TRIM(DR.Zip) = '';

-- Number of NULL Zip elements in the cleaned dataset
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue = COUNT(*)
FROM DataOpenRefine AS DOR
WHERE DOR.Zip IS NULL;

SELECT @icvCheckValue AS Zip_DataOpenRefine_NULL;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: Zip must be non-NULL.', 1;

-- Calculate the number of Zip elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.Zip) AS Zip_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.Zip COLLATE Latin1_General_CS_AS <> DR.Zip COLLATE Latin1_General_CS_AS
	OR DR.Zip IS NULL;

GO

-- *********************************************
-- Inspection Type field (optional/supplemental)
-- *********************************************

-- Calculate the number of Inspection Type values that were optionally merged as inconsistent duplicates
WITH DataRaw_Inspection_Type AS
(
	SELECT DISTINCT DR.Inspection_Type COLLATE Latin1_General_CS_AS AS Inspection_Type
	FROM DataRaw AS DR
	GROUP BY DR.Inspection_Type COLLATE Latin1_General_CS_AS
)

,DataOpenRefine_Inspection_Type AS
(
	SELECT DISTINCT DOR.Inspection_Type AS Inspection_Type
	FROM DataOpenRefine AS DOR
	GROUP BY DOR.Inspection_Type
)

SELECT (SELECT COUNT(*) FROM DataRaw_Inspection_Type) - (SELECT COUNT(*) FROM DataOpenRefine_Inspection_Type) AS Inspection_Type_MergedCount;

-- Calculate the number of Inspection Type elements (cells) that were merged as inconsistent duplicates
SELECT COUNT(DOR.Inspection_Type) AS InspectionType_MergedElementCount
FROM DataOpenRefine AS DOR
	INNER JOIN DataRaw AS DR ON DOR.Inspection_ID = DR.Inspection_ID
WHERE DOR.Inspection_Type COLLATE Latin1_General_CS_AS <> DR.Inspection_Type COLLATE Latin1_General_CS_AS

GO

-- *********************************************
-- Violations field
-- *********************************************

-- Demonstrate that 568,654 violation instances exist in the raw source data
DECLARE @icvCheckValue1 INT;
DECLARE @icvCheckValue2 INT;

WITH DataRaw_InspectionViolation AS
(
	SELECT Inspection_ID
		,ViolationID
		,ViolationText
		,CASE WHEN LEN(ViolationComment) > 0 THEN ViolationComment ELSE NULL END AS ViolationComment
	FROM
	(
		SELECT Inspection_ID
			,CAST(SUBSTRING(RawViolationText, 0, ViolationPosition) AS INT) AS ViolationID
			,SUBSTRING(RawViolationText, (ViolationPosition + 2), (ViolationCommentPosition - (ViolationPosition + 2))) AS ViolationText
			,TRIM(SUBSTRING(RawViolationText, ViolationCommentPosition + 12, LEN(RawViolationText))) AS ViolationComment
			,RawViolationText
		FROM
		(
			SELECT Inspection_ID
				,PATINDEX('% - Comments:%', RawViolationText) AS ViolationCommentPosition
				,PATINDEX('%.%', RawViolationText) AS ViolationPosition
				,RawViolationText
			FROM
			(
				SELECT Inspection_ID
					,TRIM(value) AS RawViolationText
				FROM DataRaw
					CROSS APPLY STRING_SPLIT(Violations, '|')
			) AS RawViolation
		) AS InspectedRawViolation
	) AS ExtractedViolation
)

SELECT @icvCheckValue1 = COUNT(DataRaw_InspectionViolation.ViolationID)
FROM DataRaw_InspectionViolation;

SELECT @icvCheckValue1 AS Violations_DataRaw_Count;

-- Demonstrate that all 568,654 violations are properly extracted during the Stage 3 normalization process
SELECT @icvCheckValue2 = COUNT(*)
FROM InspectionViolation;

SELECT @icvCheckValue2 AS Violations_DataOpenRefine_Count;


IF @icvCheckValue1 <> @icvCheckValue1
	THROW 51000, 'Integrity constraint violation: Same number of normalized and concatenated violations must exist.', 1;

GO

-- ************************************
-- Longitude, Latitude, Location fields
-- ************************************

-- Demonstrate that 544 records contained empty (NULL) location elements in the raw source data
SELECT COUNT(*) AS Location_DataRaw_NULL
FROM DataRaw AS DR
WHERE DR.[Location] IS NULL
	OR DR.Longitude IS NULL
	OR DR.Latitude IS NULL;

-- Demonstrate that no records contained empty (NULL) location elements in the cleaned data
DECLARE @icvCheckValue INT;

SELECT @icvCheckValue = COUNT(*)
FROM DataOpenRefine AS DOR
WHERE DOR.[Location] IS NULL
	OR DOR.Longitude IS NULL
	OR DOR.Latitude IS NULL;

SELECT @icvCheckValue AS Location_DataCleaned_NULL;

IF @icvCheckValue > 0
	THROW 51000, 'Integrity constraint violation: Longitude, Latitude, and Location must be non-NULL.', 1;

GO
