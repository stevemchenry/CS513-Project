USE CDPH;

DROP TABLE IF EXISTS InspectionViolation;
DROP TABLE IF EXISTS Inspection;
DROP TABLE IF EXISTS BusinessAlias;
DROP TABLE IF EXISTS Business;
DROP TABLE IF EXISTS Violation;
DROP TABLE IF EXISTS Result;
DROP TABLE IF EXISTS InspectionType;
DROP TABLE IF EXISTS Risk;
DROP TABLE IF EXISTS FacilityType;

CREATE TABLE FacilityType
(
	FacilityTypeID INT NOT NULL IDENTITY(1,1)
	,[Name] NVARCHAR(100)

	,CONSTRAINT PK_FacilityType PRIMARY KEY CLUSTERED (FacilityTypeID)
	,CONSTRAINT AK_FacilityType_Name UNIQUE ([Name])
);

CREATE TABLE Risk
(
	RiskID INT NOT NULL IDENTITY(1,1)
	,[Name] NVARCHAR(100)

	,CONSTRAINT PK_Risk PRIMARY KEY CLUSTERED (RiskID)
	,CONSTRAINT AK_Risk_Name UNIQUE ([Name])
);

CREATE TABLE InspectionType
(
	InspectionTypeID INT NOT NULL IDENTITY(1,1)
	,[Name] NVARCHAR(100)

	,CONSTRAINT PK_InspectionType PRIMARY KEY CLUSTERED (InspectionTypeID)
	,CONSTRAINT AK_InspectionType_Name UNIQUE ([Name])
);

CREATE TABLE Result
(
	ResultID INT NOT NULL IDENTITY(1,1)
	,[Name] NVARCHAR(100)

	,CONSTRAINT PK_Result PRIMARY KEY CLUSTERED (ResultID)
	,CONSTRAINT AK_Result_Name UNIQUE ([Name])
);

CREATE TABLE Violation
(
	ViolationID INT NOT NULL
	,[Name] NVARCHAR(500) NOT NULL

	,CONSTRAINT PK_Violation PRIMARY KEY CLUSTERED (ViolationID)
	,CONSTRAINT AK_Violation_Name UNIQUE ([Name])
);

CREATE TABLE Business
(
	BusinessID INT NOT NULL IDENTITY(1,1)
	,License INT NOT NULL
	,[Name] NVARCHAR(500) NOT NULL
	,[Address] NVARCHAR(250) NULL
	,City NVARCHAR(250) NULL
	,[State] NCHAR(2) NOT NULL
	,Zip NCHAR(5) NULL
	,Latitude FLOAT NULL
	,Longitude FLOAT NULL
	,[Location] NVARCHAR(100) NULL

	,CONSTRAINT PK_Business PRIMARY KEY CLUSTERED (BusinessID)
);

CREATE TABLE BusinessAlias
(
	BusinessAliasID INT NOT NULL IDENTITY(1,1)
	,BusinessID INT NOT NULL
	,[Name] NVARCHAR(500) NOT NULL

	,CONSTRAINT PK_BusinessAlias PRIMARY KEY CLUSTERED (BusinessAliasID)
	,CONSTRAINT AK_BusinessAlias_BusinessID_Name UNIQUE (BusinessID, [Name])
);

CREATE TABLE Inspection
(
	InspectionID INT NOT NULL
	,BusinessID INT NOT NULL
	,BusinessAliasID INT NULL
	,FacilityTypeID INT NULL
	,RiskID INT NULL
	,[DatePerformed] DATE NOT NULL
	,InspectionTypeID INT NULL
	,ResultID INT NOT NULL

	,CONSTRAINT PK_Inspection PRIMARY KEY CLUSTERED (InspectionID)
	,CONSTRAINT FK_Inspection_BusinessID__Business_BusinessID FOREIGN KEY (BusinessID) REFERENCES Business(BusinessID)
	,CONSTRAINT FK_Inspection_BusinessAliasID__BusinessAlias_BusinessAliasID FOREIGN KEY (BusinessAliasID) REFERENCES BusinessAlias(BusinessAliasID)
	,CONSTRAINT FK_Inspection_FacilityTypeID__FacilityType_FacilityTypeID FOREIGN KEY (FacilityTypeID) REFERENCES FacilityType(FacilityTypeID)
	,CONSTRAINT FK_Inspection_RiskID__Risk_RiskID FOREIGN KEY (RiskID) REFERENCES Risk(RiskID)
	,CONSTRAINT FK_Inspection_InspectionTypeID__InspectionType_InspectionTypeID FOREIGN KEY (InspectionTypeID) REFERENCES InspectionType(InspectionTypeID)
	,CONSTRAINT FK_Inspection_ResultID__Result_ResultID FOREIGN KEY (ResultID) REFERENCES Result(ResultID)
);

CREATE TABLE InspectionViolation
(
	InspectionViolationID INT NOT NULL IDENTITY(1,1)
	,InspectionID INT NOT NULL
	,ViolationID INT NOT NULL
	,Comments NVARCHAR(MAX) NULL

	,CONSTRAINT PK_InspectionViolation PRIMARY KEY CLUSTERED (InspectionViolationID)
	,CONSTRAINT FK_InspectionViolation_InspectionID__Inspection_InspectionID FOREIGN KEY (InspectionID) REFERENCES Inspection(InspectionID)
	,CONSTRAINT FK_InspectionViolation_ViolationID__Violation_ViolationID FOREIGN KEY (ViolationID) REFERENCES Violation(ViolationID)
	,INDEX IX_InspectionViolation_InspectionID NONCLUSTERED (InspectionID) INCLUDE (ViolationID)
	,INDEX IX_InspectionViolation_ViolationID NONCLUSTERED (ViolationID) INCLUDE (InspectionID)
);