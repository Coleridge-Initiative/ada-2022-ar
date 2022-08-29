USE tr_ar_2022


--CREATE REFERENCE DIMENSION TABLE FOR CLASSIFICATION OF INSTRUCTIONAL PROGRAMS
CREATE TABLE [dbo].[AR_RDIM_CIP_Classification]
( 
	[CIP_Classification_ID] integer  NOT NULL ,
	[CIP_Classification_Code] char(7)  NULL ,
	[CIP_Classification_Name] varchar(100)  NULL ,
	[CIP_Category_Name]  varchar(100)  NULL ,
	[CIP_Category_Code]  char(5)  NULL ,
	[CIP_Series_Code]    char(2)  NULL ,
	[CIP_Series_Name]    varchar(100)  NULL ,
	[CIP_Series_Short_Name] varchar(100)  NULL ,
	[CIP_Classification_High_Demand_Flag] char(1)  NULL ,
	[CIP_Classification_STEM_Flag] char(1)  NULL ,
	[CIP_Classification_Career_Pathway] char(18)  NULL ,
	[CIP_Classification_Career_Cluster] char(18)  NULL 
)


ALTER TABLE [dbo].[AR_RDIM_CIP_Classification]
	ADD CONSTRAINT [XPKCIP_Classification] PRIMARY KEY  CLUSTERED ([CIP_Classification_ID] ASC)




--CREATE REFERENCE DIMENSION FOR COUNTY
CREATE TABLE [dbo].[AR_RDIM_County]
( 
	[County_ID]          smallint  NOT NULL ,
	[County_Code]        char(5)  NULL ,
	[County_Name]        varchar(50)  NULL ,	
	[State_Code]         char(2)  NULL ,
	[State_Name]         varchar(50)  NULL,
	[Rural_Urban_Continuum_Code] tinyint  NULL ,
	[Rural_Urban_Continuum_Name] varchar(100)  NULL ,	
	[Local_Workforce_Development_Area] varchar(10)  NULL
)


ALTER TABLE [dbo].[AR_RDIM_County]
	ADD CONSTRAINT [XPKCounty] PRIMARY KEY  CLUSTERED ([County_ID] ASC)




--CREATE REFERENCE DIMENSION FOR INDUSTRY
CREATE TABLE [dbo].[AR_RDIM_NAICS_National_Industry]
( 
	[NAICS_National_Industry_ID] integer  NOT NULL ,
	[NAICS_National_Industry_Code] char(6)  NULL ,
	[NAICS_National_Industry_Name] varchar(200)  NULL ,
	[NAICS_Industry_Code] char(5)  NULL ,
	[NAICS_Industry_Name] varchar(200)  NULL ,
	[NAICS_Industry_Group_Code] char(4)  NULL ,
	[NAICS_Industry_Group_Name] varchar(200)  NULL ,
	[NAICS_Subsector_Code] char(3)  NULL ,
	[NAICS_Subsector_Name] varchar(200)  NULL ,
	[NAICS_Sector_Code]  char(5)  NULL ,
	[NAICS_Sector_Name]  varchar(200)  NULL ,
	[NAICS_Supersector_Code] char(4)  NULL ,
	[NAICS_Supersector_Name] varchar(200)  NULL,
	[NAICS_Domain_Code]  char(3)  NULL ,
	[NAICS_Domain_Name]  varchar(200)  NULL
	
)


ALTER TABLE [dbo].[AR_RDIM_NAICS_National_Industry]
	ADD CONSTRAINT [XPKNAICS_National_Industry] PRIMARY KEY  CLUSTERED ([NAICS_National_Industry_ID] ASC)




--CREATE REFERENCE TIME DIMENSION FOR QUARTER

CREATE TABLE [dbo].[AR_RDIM_Quarter]
( 
	[Quarter_ID]         smallint  NOT NULL ,
	[Quarter_Code]		char(6) NULL,
	[Calendar_Year]      smallint  NULL ,
	[Calendar_Quarter]   tinyint  NULL ,
	[Calendar_Month_Number_Start] tinyint  NULL ,
	[Calendar_Month_Number_End] tinyint  NULL ,
	[Start_Date]         date  NULL ,
	[End_Date]           date  NULL 
)


ALTER TABLE [dbo].[AR_RDIM_Quarter]
	ADD CONSTRAINT [XPKQuarter] PRIMARY KEY  CLUSTERED ([Quarter_ID] ASC)




--CREATE REFERENCE DIMENSION FOR OCCUPATION
CREATE TABLE [dbo].[AR_RDIM_SOC_Detailed_Occupation]
( 
	[SOC_Detailed_Occupation_ID] integer  NOT NULL ,
	[SOC_Detailed_Occupation_Code] char(7)  NULL ,
	[SOC_Detailed_Occupation_Name] varchar(105)  NULL ,
	[SOC_Broad_Group_Code] char(7)  NULL ,
	[SOC_Broad_Group_Name] varchar(100)  NULL ,
	[SOC_Minor_Group_Code] char(7)  NULL ,
	[SOC_Minor_Group_Name] varchar(100)  NULL ,
	[SOC_Major_Group_Code] char(7)  NULL ,
	[SOC_Major_Group_Name] varchar(100)  NULL 
)


ALTER TABLE [dbo].[AR_RDIM_SOC_Detailed_Occupation]
	ADD CONSTRAINT [XPKSOC_Detailed_Occupation] PRIMARY KEY  CLUSTERED ([SOC_Detailed_Occupation_ID] ASC)





--CREATE MASTER DIMENSION FOR EMPLOYER
CREATE TABLE [dbo].[AR_MDIM_Employer]
( 
	[Employer_ID]        integer IDENTITY(1,1) NOT NULL ,
	[Federal_EIN]        char(64)  NULL ,	
	[State_EIN] char(64) NULL,
	[NAICS_National_Industry_ID] integer  NULL ,
	[County_ID]          smallint  NULL ,
	[Multiple_Worksite_Record] char(1)  NULL
)


ALTER TABLE [dbo].[AR_MDIM_Employer]
	ADD CONSTRAINT [XPKEmployer] PRIMARY KEY  CLUSTERED ([Employer_ID] ASC)


ALTER TABLE [dbo].[AR_MDIM_Employer]
	ADD CONSTRAINT [R_14] FOREIGN KEY ([NAICS_National_Industry_ID]) REFERENCES [dbo].[AR_RDIM_NAICS_National_Industry]([NAICS_National_Industry_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Employer]
	ADD CONSTRAINT [R_15] FOREIGN KEY ([County_ID]) REFERENCES [dbo].[AR_RDIM_County]([County_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION






--CREATE MASTER DIMENSION FOR PERSON
CREATE TABLE [dbo].[AR_MDIM_Person]
( 
	[Person_ID]          int IDENTITY(1,1) NOT NULL ,
	[SSN]                char(64)  NULL ,
	[First_AR_Employment_Quarter_ID] smallint  NULL ,
	[Last_AR_Employment_Quarter_ID] smallint  NULL ,	
	[AR_Quarters_Employed] smallint  NULL,	
	[Last_AR_Employer_ID] integer  NULL ,	
	[Gender]             varchar(25)  NULL ,
	[Race]               varchar(50)  NULL ,
	[Ethnicity]          varchar(50)  NULL ,
	[Disabled]           char(1)  NULL ,
	[Veteran]            char(1)  NULL ,
	[Year_of_Birth]      smallint  NULL ,
	[Education]          tinyint  NULL ,
	[Apprenticeship_Participant] char(1)  NULL ,
	[Apprenticeship_Completer] char(1)  NULL ,
	[Apprenticeship_Status] varchar(25)  NULL ,	
	[Apprenticeship_Program_Number] varchar(20)  NULL ,
	[Apprenticeship_Program_Name] varchar(100)  NULL ,	
	[Apprenticeship_County_ID] smallint  NULL ,
	[Apprenticeship_Age_at_Start] tinyint  NULL ,
	[Apprenticeship_Start_Quarter_ID] smallint  NULL ,
	[Apprenticeship_End_Quarter_ID] smallint  NULL ,	
	[Apprenticeship_NAICS_National_Industry_ID] integer  NULL ,	
	[Apprenticeship_SOC_Detailed_Occupation_ID] integer  NULL ,
	[Apprenticeship_Organization_Type] varchar(50)  NULL ,	
	[Apprenticeship_CIP_Classification_ID] integer  NULL ,
	[Apprenticeship_Employer_ID] integer  NULL 
)


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [XPKPerson] PRIMARY KEY  CLUSTERED ([Person_ID] ASC)




ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_12] FOREIGN KEY ([Apprenticeship_CIP_Classification_ID]) REFERENCES [dbo].[AR_RDIM_CIP_Classification]([CIP_Classification_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_13] FOREIGN KEY ([Apprenticeship_SOC_Detailed_Occupation_ID]) REFERENCES [dbo].[AR_RDIM_SOC_Detailed_Occupation]([SOC_Detailed_Occupation_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_16] FOREIGN KEY ([Apprenticeship_Employer_ID]) REFERENCES [dbo].[AR_MDIM_Employer]([Employer_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_17] FOREIGN KEY ([Apprenticeship_NAICS_National_Industry_ID]) REFERENCES [dbo].[AR_RDIM_NAICS_National_Industry]([NAICS_National_Industry_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_21] FOREIGN KEY ([Apprenticeship_Start_Quarter_ID]) REFERENCES [dbo].[AR_RDIM_Quarter]([Quarter_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_22] FOREIGN KEY ([Apprenticeship_End_Quarter_ID]) REFERENCES [dbo].[AR_RDIM_Quarter]([Quarter_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_23] FOREIGN KEY ([First_AR_Employment_Quarter_ID]) REFERENCES [dbo].[AR_RDIM_Quarter]([Quarter_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION

ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_24] FOREIGN KEY ([Last_AR_Employment_Quarter_ID]) REFERENCES [dbo].[AR_RDIM_Quarter]([Quarter_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_25] FOREIGN KEY ([Last_AR_Employer_ID]) REFERENCES [dbo].[AR_MDIM_Employer]([Employer_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_MDIM_Person]
	ADD CONSTRAINT [R_26] FOREIGN KEY ([Apprenticeship_County_ID]) REFERENCES [dbo].[AR_RDIM_County]([County_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION

		
		
--CREATE FACT TABLE FOR QUARTERLY OBSERVATIONS AND LONGITUDINAL METRICS
CREATE TABLE [dbo].[AR_FACT_Quarterly_Observation]
( 
	[Person_ID]          integer  NOT NULL ,	
	[Quarter_ID]         smallint  NOT NULL ,
	[Employed]           char(1)  NULL ,	
	[Primary_Employer_ID] integer  NULL ,
	[Primary_Employer_Wages] decimal(11,2)  NULL ,
	[Total_Wages]        decimal(11,2)  NULL ,
	[Employer_Count]     tinyint  NULL ,
	[Stable_Employment]  char(1)  NULL ,
	[Hire]               char(1)  NULL ,
	[Separation]         char(1)  NULL ,
	[Recall]             char(1)  NULL ,
	[Apprenticeship_Participation] char(1)  NULL 
)


ALTER TABLE [dbo].[AR_FACT_Quarterly_Observation]
	ADD CONSTRAINT [XPKQuarterly_Observation] PRIMARY KEY  CLUSTERED ([Person_ID] ASC,[Quarter_ID] ASC)



ALTER TABLE [dbo].[AR_FACT_Quarterly_Observation]
	ADD CONSTRAINT [R_1] FOREIGN KEY ([Quarter_ID]) REFERENCES [dbo].[AR_RDIM_Quarter]([Quarter_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_FACT_Quarterly_Observation]
	ADD CONSTRAINT [R_2] FOREIGN KEY ([Primary_Employer_ID]) REFERENCES [dbo].[AR_MDIM_Employer]([Employer_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION


ALTER TABLE [dbo].[AR_FACT_Quarterly_Observation]
	ADD CONSTRAINT [R_3] FOREIGN KEY ([Person_ID]) REFERENCES [dbo].[AR_MDIM_Person]([Person_ID])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION












