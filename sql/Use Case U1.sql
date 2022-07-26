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

SELECT Inspection.InspectionID
	,CASE WHEN ((BusinessAlias.[Name] IS NOT NULL) AND (Business.[Name] <> BusinessAlias.[Name]))
		THEN CONCAT(Business.[Name], N' (', BusinessAlias.[Name], N')')
		ELSE Business.[Name] END AS BusinessName
	,Business.License
	,Business.[Address]
	,Business.City
	,Business.[State]
	,Business.Zip
	,Business.Latitude
	,Business.Longitude
	,Inspection.DatePerformed
	,Result.[Name] AS Result
	,Violation.ViolationID
	,Violation.[Name]
	,InspectionViolation.Comments
FROM Violation
	INNER JOIN InspectionViolation
		INNER JOIN Inspection
			INNER JOIN Business ON Inspection.BusinessID = Business.BusinessID
			LEFT JOIN BusinessAlias ON Inspection.BusinessAliasID = BusinessAlias.BusinessAliasID
			INNER JOIN Result ON Inspection.ResultID = Result.ResultID
			ON InspectionViolation.InspectionID = Inspection.InspectionID
		ON Violation.ViolationID = InspectionViolation.ViolationID
WHERE (Inspection.DatePerformed >= @dateBegin OR @dateBegin IS NULL)
	AND (Inspection.DatePerformed < @dateEnd OR @dateEnd IS NULL)
	AND
	(
		(Business.[Name] LIKE CONCAT(N'%', @businessName, N'%'))
		OR
		(BusinessAlias.[Name] LIKE CONCAT(N'%', @businessName, N'%'))
	)
	AND (Business.License = @license OR @license IS NULL)
	AND ((Result.[Name] IN (SELECT * FROM STRING_SPLIT(@results, '|'))) OR @results IS NULL)
	AND ((Violation.ViolationID IN (SELECT * FROM STRING_SPLIT(@violations, '|'))) OR @violations IS NULL)
ORDER BY Inspection.InspectionID
	,Violation.ViolationID
	,InspectionViolation.InspectionViolationID;