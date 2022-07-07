USE CDPH;

-- Set the full filepath of the openrefine CSV output file relative to the 
-- SQL Server host machine
DECLARE @filename NVARCHAR(500) = '[openrefine-csv-output-filepath]'

-- ********
-- CAUTION: There are no user-modifiable parameters beyond this point
-- ********

-- Store the filename in a temporary table to presist across batches
DROP TABLE IF EXISTS #Filename;

SELECT T.[Filename] INTO #Filename
FROM
(VALUES(@filename)) AS T([Filename]);

-- Create the DataOpenRefine staging/relational analysis table
IF EXISTS
(
	SELECT 1
	FROM sys.columns
	WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[DataOpenRefine]')
)
BEGIN
	DROP TABLE DataOpenRefine;
END

CREATE TABLE DataOpenRefine
(
	Inspection_ID INT NOT NULL
	,DBA_Name NVARCHAR(250) NOT NULL
	,AKA_Name NVARCHAR(250) NULL
	,License INT NOT NULL
	,Facility_Type NVARCHAR(100) NULL
	,Risk NVARCHAR(100) NULL
	,[Address] NVARCHAR(100) NULL
	,City NVARCHAR(100) NULL
	,[State] NCHAR(2) NOT NULL
	,Zip NCHAR(5) NULL
	,Inspection_Date DATE NOT NULL
	,Inspection_Type NVARCHAR(100) NULL
	,Results NVARCHAR(100) NOT NULL
	,Violations NVARCHAR(MAX) NULL
	,Latitude FLOAT NULL
	,Longitude FLOAT NULL
	,[Location] NVARCHAR(100) NULL
	
	,CONSTRAINT PK_DataOpenRefine PRIMARY KEY CLUSTERED (Inspection_ID)
)

GO

-- Load the data from file
DECLARE @filename NVARCHAR(500) = (SELECT TOP(1) #Filename.[Filename] FROM #Filename)
DECLARE @sqlBulkInsert NVARCHAR(MAX) =
N'
BULK INSERT DataOpenRefine
FROM ''' + @filename + '''
WITH
(
	FORMAT = ''CSV''
	,CODEPAGE = ''65001''
	,FIRSTROW = 2
	,FIELDQUOTE = ''"''
	,FIELDTERMINATOR = '',''
	,ROWTERMINATOR = ''0x0A''
);
';

EXECUTE sp_executesql @sqlBulkInsert

-- Clean up
DROP TABLE #Filename