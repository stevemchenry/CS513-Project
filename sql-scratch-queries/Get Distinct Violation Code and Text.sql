USE CDPH;

WITH SampleInspections AS
(
	SELECT *
	FROM DataOpenRefine
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
ORDER BY ViolationID ASC;