-- Unparsed view from the staging table
SELECT DOR.Inspection_ID
	,DOR.Violations
FROM DataOpenRefine AS DOR
WHERE DOR.Inspection_ID = 48216;

-- Normalized view from the schema-loaded dataset
SELECT InspectionViolation.InspectionID
	,Violation.ViolationID
	,Violation.[Name] AS ViolationName
	,InspectionViolation.Comments
FROM inspection
	INNER JOIN InspectionViolation on Inspection.InspectionID = InspectionViolation.InspectionID
	INNER JOIN Violation on InspectionViolation.ViolationID = Violation.ViolationID
WHERE Inspection.InspectionID = 48216;