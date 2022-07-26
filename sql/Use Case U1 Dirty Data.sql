USE CDPH;

-- Usage: Set the parameter values below to filter results as desired.
--
-- Two parameters, Results (@results) and Violations (@violations), are 
-- multi-valued parameters. Multi-valued parameters are provided as a string of
-- one or more candidate values delimited by pipes "|".
--
-- Each parameter may individually be set to NULL so that the query does not
-- include that parameter among its filtering criteria.

DECLARE @dateBegin DATE = '2012-01-01';	-- Demonstration value: From inspections performed on January 01, 2012...
DECLARE @dateEnd DATE = '2017-01-01';	-- Demonstration value: ...Until inspections performed on January 01, 2017
DECLARE @businessName NVARCHAR(250) = N'MCDONALD''S';	-- Demonstration value: All businesses whose name (or alias) contains "MCDONALD'S"
DECLARE @license INT = NULL	-- Demonstration value: NULL; not populated by user - no filter on license
DECLARE @results NVARCHAR(MAX) = N'Pass|Pass w/ Conditions'	-- Demonstration value: "Pass" or "Pass w/ Conditions" - a passing result
DECLARE @violations NVARCHAR(MAX) = N'1|2|3|5|8|9|11|12|22|33';	-- Demonstration value: An arbitrary selection of multiple codes

-- There are no user-modifiable parameters beyond this point

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

SELECT DataRaw.Inspection_ID AS InspectionID
	,CASE WHEN ((DataRaw.AKA_Name IS NOT NULL) AND (DataRaw.DBA_Name <> DataRaw.AKA_Name))
		THEN CONCAT(DataRaw.DBA_Name, N' (', DataRaw.AKA_Name, N')')
		ELSE DataRaw.DBA_Name END AS BusinessName
	,DataRaw.License
	,DataRaw.[Address]
	,DataRaw.City
	,DataRaw.[State]
	,DataRaw.Zip
	,DataRaw.Latitude
	,DataRaw.Longitude
	,DataRaw.Inspection_Date AS DatePerformed
	,DataRaw.Results AS Result
	,DataRaw_InspectionViolation.ViolationID
	,DataRaw_InspectionViolation.ViolationText
	,DataRaw_InspectionViolation.ViolationComment
FROM DataRaw
	INNER JOIN DataRaw_InspectionViolation ON DataRaw.Inspection_ID = DataRaw_InspectionViolation.Inspection_ID
WHERE (DataRaw.Inspection_Date >= @dateBegin OR @dateBegin IS NULL)
	AND (DataRaw.Inspection_Date < @dateEnd OR @dateEnd IS NULL)
	AND
	(
		(DataRaw.DBA_Name COLLATE Latin1_General_CS_AS LIKE CONCAT(N'%', @businessName, N'%'))
		OR
		(DataRaw.AKA_Name COLLATE Latin1_General_CS_AS LIKE CONCAT(N'%', @businessName, N'%'))
	)
	AND (DataRaw.License = @license OR @license IS NULL)
	AND ((DataRaw.Results IN (SELECT * FROM STRING_SPLIT(@results, '|'))) OR @results IS NULL)
	AND ((DataRaw_InspectionViolation.ViolationID IN (SELECT * FROM STRING_SPLIT(@violations, '|'))) OR @violations IS NULL)
ORDER BY DataRaw.Inspection_ID
	,DataRaw_InspectionViolation.ViolationID;