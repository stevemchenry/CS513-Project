TRUNCATE TABLE DataOpenRefine;

BULK INSERT DataOpenRefine
FROM '[openrefine-output-filename]'
WITH
(
	FORMAT = 'CSV'
	,CODEPAGE = '65001'
	,FIRSTROW = 2
	,FIELDQUOTE = '"'
	,FIELDTERMINATOR = ','
	,ROWTERMINATOR = '0x0A'
);