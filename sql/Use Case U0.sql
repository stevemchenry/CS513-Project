USE CDPH;

-- Assumes the raw dataset has been loaded into the "DataRaw" table
SELECT CONCAT(CAST(DATEPART(YEAR, DataRaw.Inspection_Date) AS VARCHAR(4))
		,'/'
		,RIGHT('00' + CAST(DATEPART(MONTH, DataRaw.Inspection_Date) AS VARCHAR(2)), 2)) AS YearMonth
	,COUNT(CASE WHEN DataRaw.Results IN ('Pass', 'Pass w/ Conditions', 'Fail') THEN 1 ELSE NULL END) AS FullyPerformedCount
	,COUNT(CASE WHEN DataRaw.Results NOT IN ('Pass', 'Pass w/ Conditions', 'Fail') THEN 1 ELSE NULL END) AS NotFullyPerformedCount
FROM DataRaw
GROUP BY DATEPART(YEAR, DataRaw.Inspection_Date)
	,DATEPART(MONTH, DataRaw.Inspection_Date)
ORDER BY YearMonth;