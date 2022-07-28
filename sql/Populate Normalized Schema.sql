USE CDPH;

BEGIN TRANSACTION

-- Generate a BusinessID for all businesses in the staging table
IF EXISTS
(
	SELECT 1
	FROM sys.columns
	WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[DataOpenRefine]')
		AND sys.columns.[name] = N'BusinessID'
)
BEGIN
	ALTER TABLE DataOpenRefine
	DROP COLUMN BusinessID;
END

ALTER TABLE DataOpenRefine
ADD BusinessID INT NULL 

GO

UPDATE DataOpenRefine
SET BusinessID = T.BusinessID
FROM
(
	SELECT DOR.Inspection_ID
	,DENSE_RANK() OVER (ORDER BY DOR.License
			,DOR.DBA_Name
			,DOR.[Address]
			,DOR.City
			,DOR.[State]
			,DOR.Zip
			,DOR.Latitude
			,DOR.Longitude
			,DOR.[Location]) AS BusinessID
	FROM DataOpenRefine AS DOR
) T
WHERE DataOpenRefine.Inspection_ID = T.Inspection_ID

-- Populate the FacilityType table (supplementary to U1)
INSERT INTO FacilityType([Name])
SELECT DISTINCT DOR.Facility_Type
FROM DataOpenRefine AS DOR
WHERE DOR.Facility_Type IS NOT NULL
ORDER BY DOR.Facility_Type;

-- Populate the Risk table
INSERT INTO Risk([Name])
SELECT DISTINCT DOR.Risk
FROM DataOpenRefine AS DOR
WHERE DOR.Risk IS NOT NULL
ORDER BY DOR.Risk;

-- Populate the InspectionType table (supplementary to U1)
INSERT INTO InspectionType([Name])
SELECT DISTINCT DOR.Inspection_Type
FROM DataOpenRefine AS DOR
WHERE DOR.Inspection_Type IS NOT NULL
ORDER BY DOR.Inspection_Type;

-- Populate the Result table
INSERT INTO Result([Name])
SELECT DISTINCT DOR.Results
FROM DataOpenRefine AS DOR
ORDER BY DOR.Results;

-- Populate the Violation table
WITH SampleInspections AS
(
	SELECT *
	FROM DataOpenRefine
)

INSERT INTO Violation
	(
		ViolationID
		,[Name]
	)
SELECT DISTINCT ViolationID
	,ViolationText
FROM
(
	SELECT CAST(SUBSTRING(RawViolationText, 0, ViolationPosition) AS INT) AS ViolationID
		,SUBSTRING(RawViolationText, (ViolationPosition + 2), (ViolationCommentPosition - (ViolationPosition + 2))) AS ViolationText
		,SUBSTRING(RawViolationText, ViolationCommentPosition + 12, LEN(RawViolationText)) AS ViolationComment
		,RawViolationText
	FROM
	(
		SELECT PATINDEX('% - Comments:%', RawViolationText) AS ViolationCommentPosition
			,PATINDEX('%.%', RawViolationText) AS ViolationPosition
			,RawViolationText
		FROM
		(
			SELECT TRIM(value) AS RawViolationText
			FROM SampleInspections
				CROSS APPLY STRING_SPLIT(Violations, '|')
		) AS RawViolation
	) AS InspectedRawViolation
) AS ExtractedViolation
ORDER BY ViolationID;

-- Populate the Business table
SET IDENTITY_INSERT Business ON;

INSERT INTO Business
	(
		BusinessID
		,License
		,[Name]
		,[Address]
		,City
		,[State]
		,Zip
		,Latitude
		,Longitude
		,[Location]
	)
SELECT DISTINCT DOR.BusinessID
	,DOR.License
	,DOR.DBA_Name
	,DOR.[Address]
	,DOR.City
	,DOR.[State]
	,DOR.Zip
	,DOR.Latitude
	,DOR.Longitude
	,DOR.[Location]
FROM DataOpenRefine AS DOR
ORDER BY DOR.License
	,DOR.DBA_Name;

SET IDENTITY_INSERT Business OFF;

-- Populate the BusinessAlias table
INSERT INTO BusinessAlias(BusinessID, [Name])
SELECT DISTINCT DOR.BusinessID
	,DOR.AKA_Name
FROM DataOpenRefine AS DOR
WHERE DOR.AKA_Name IS NOT NULL
ORDER BY DOR.BusinessID
	,DOR.AKA_Name;

-- Populate the Inspection table
INSERT INTO Inspection
	(
		InspectionID
		,BusinessID
		,BusinessAliasID
		,FacilityTypeID
		,RiskID
		,DatePerformed
		,InspectionTypeID
		,ResultID
	)
SELECT DOR.Inspection_ID
	,DOR.BusinessID
	,BusinessAlias.BusinessAliasID
	,FacilityType.FacilityTypeID
	,Risk.RiskID
	,DOR.Inspection_Date
	,InspectionType.InspectionTypeID
	,Result.ResultID
FROM DataOpenRefine AS DOR
	LEFT JOIN BusinessAlias ON (DOR.BusinessID = BusinessAlias.BusinessID AND DOR.AKA_Name = BusinessAlias.[Name])
	LEFT JOIN FacilityType ON DOR.Facility_Type = FacilityType.[Name]
	LEFT JOIN Risk ON DOR.Risk = Risk.[Name]
	LEFT JOIN InspectionType ON DOR.Inspection_Type = InspectionType.[Name]
	INNER JOIN Result ON DOR.Results = Result.[Name];

-- Populate the InspectionViolation table
INSERT INTO InspectionViolation
	(
		InspectionID
		,ViolationID
		,Comments
	)
SELECT NormalizedViolation.Inspection_ID
	,NormalizedViolation.ViolationID
	,CASE WHEN LEN(NormalizedViolation.ViolationComment) > 0 THEN NormalizedViolation.ViolationComment ELSE NULL END AS ViolationComment
FROM
(
	SELECT InspectedRawViolation.Inspection_ID
		,CAST(SUBSTRING(InspectedRawViolation.RawViolationText, 0, InspectedRawViolation.ViolationPosition) AS INT) AS ViolationID
		,TRIM(SUBSTRING(RawViolationText, ViolationCommentPosition + 12, LEN(RawViolationText))) AS ViolationComment
	FROM
	(
		SELECT PATINDEX('% - Comments:%', RawViolationText) AS ViolationCommentPosition
			,PATINDEX('%.%', RawViolationText) AS ViolationPosition
			,RawViolationText
			,RawViolation.Inspection_ID
		FROM
		(
			SELECT TRIM(value) AS RawViolationText
				,DOR.Inspection_ID
			FROM DataOpenRefine AS DOR
				CROSS APPLY STRING_SPLIT(DOR.Violations, '|')
		) AS RawViolation
	) AS InspectedRawViolation
) AS NormalizedViolation

-- Clean up
ALTER TABLE DataOpenRefine
DROP COLUMN BusinessID;

COMMIT TRANSACTION