USE CDPH;

-- Note: Assumes the raw dataset has been loaded into a table named "FoodInspections"
SELECT CONCAT(CAST(DATEPART(YEAR, FoodInspections.InspectionDate) AS VARCHAR(4))
		,'/'
		,RIGHT('00' + CAST(DATEPART(MONTH, FoodInspections.InspectionDate) AS VARCHAR(2)), 2)) AS YearMonth
	,COUNT(CASE WHEN FoodInspections.Results IN ('Pass', 'Pass w/ Conditions', 'Fail') THEN 1 ELSE NULL END) AS FullyPerformedCount
	,COUNT(CASE WHEN FoodInspections.Results NOT IN ('Pass', 'Pass w/ Conditions', 'Fail') THEN 1 ELSE NULL END) AS NotFullyPerformedCount
FROM FoodInspections
GROUP BY DATEPART(YEAR, FoodInspections.InspectionDate)
	,DATEPART(MONTH, FoodInspections.InspectionDate)
ORDER BY YearMonth;