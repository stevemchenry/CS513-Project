DECLARE @inspectionID INT = 58552;

-- Demonstrate reconstruction the original record (except for the delimited violations field)
SELECT Inspection.InspectionID
	,Business.[Name] AS BusinessName
	,BusinessAlias.[Name] AS BusinessAlias
	,Business.License
	,FacilityType.[Name] AS FacilityType
	,Risk.[Name] AS Risk
	,Business.[Address]
	,Business.City
	,Business.[State]
	,Business.Zip
	,Inspection.DatePerformed
	,InspectionType.[Name] AS InspectionType
	,Result.[Name] AS Result
	,Business.Latitude
	,Business.Longitude
	,Business.[Location]
FROM Inspection
	INNER JOIN Business ON Inspection.BusinessID = Business.BusinessID
	INNER JOIN Result ON Inspection.ResultID = Result.ResultID
	LEFT JOIN BusinessAlias ON Inspection.BusinessAliasID = BusinessAlias.BusinessAliasID
	LEFT JOIN InspectionType ON Inspection.InspectionTypeID = InspectionType.InspectionTypeID
	LEFT JOIN Risk ON Inspection.RiskID = Risk.RiskID
	LEFT JOIN FacilityType ON Inspection.FacilityTypeID = FacilityType.FacilityTypeID
WHERE Inspection.InspectionID = @inspectionID;

-- Retrieve the violations and comments assocaited with this inspection (if any)
SELECT Violation.ViolationID
	,Violation.[Name] AS ViolationName
	,InspectionViolation.Comments
FROM InspectionViolation
	INNER JOIN Violation ON InspectionViolation.ViolationID = Violation.ViolationID
WHERE InspectionViolation.InspectionID = @inspectionID
ORDER BY Violation.ViolationID
	,InspectionViolation.InspectionViolationID;