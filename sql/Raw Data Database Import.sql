USE CDPH;

-- Set the full filepath of the raw CSV file relative to the 
-- SQL Server host machine
DECLARE @filename NVARCHAR(500) = '[raw-data-csv-filepath]'

-- ********
-- CAUTION: There are no user-modifiable parameters beyond this point
-- ********

-- Store the filename in a temporary table to presist across batches
DROP TABLE IF EXISTS #Filename;

SELECT T.[Filename] INTO #Filename
FROM
(VALUES(@filename)) AS T([Filename]);

-- Create the DataRaw staging/relational analysis table
IF EXISTS
(
	SELECT 1
	FROM sys.columns
	WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[DataRaw]')
)
BEGIN
	DROP TABLE DataRaw;
END

CREATE TABLE DataRaw
(
	Inspection_ID INT NOT NULL
	,DBA_Name NVARCHAR(250) NULL
	,AKA_Name NVARCHAR(250) NULL
	,License INT NULL
	,Facility_Type NVARCHAR(100) NULL
	,Risk NVARCHAR(100) NULL
	,[Address] NVARCHAR(100) NULL
	,City NVARCHAR(100) NULL
	,[State] NCHAR(2) NOT NULL
	,Zip NCHAR(5) NULL
	,Inspection_Date DATE NULL
	,Inspection_Type NVARCHAR(100) NULL
	,Results NVARCHAR(100) NULL
	,Violations NVARCHAR(MAX) NULL
	,Latitude FLOAT NULL
	,Longitude FLOAT NULL
	,[Location] NVARCHAR(100) NULL
	
	,CONSTRAINT PK_DataRaw PRIMARY KEY CLUSTERED (Inspection_ID)
)

GO

-- Load the data from file
DECLARE @filename NVARCHAR(500) = (SELECT TOP(1) #Filename.[Filename] FROM #Filename)
DECLARE @sqlBulkInsert NVARCHAR(MAX) =
N'
BULK INSERT DataRaw
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