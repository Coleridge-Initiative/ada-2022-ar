
--LOAD RDIM_CIP_Classification
INSERT INTO tr_ar_2022.dbo.AR_RDIM_CIP_Classification(
	CIP_Classification_ID,
	CIP_Classification_Code,
	CIP_Classification_Name,
	CIP_Category_Code,
	CIP_Category_Name,
	CIP_Series_Code,
	CIP_Series_Name,
	CIP_Series_Short_Name,
	CIP_Classification_High_Demand_Flag
)
SELECT
CAST(REPLACE(CCLS.Code,'.','') AS INT) AS CIP_Classification_ID,
CCLS.Code AS CIP_Classification_Code,
CCLS.Name AS CIP_Classification_Name,
CCAT.Code AS CIP_Category_Code,
CCAT.Name AS CIP_Category_Name,
CSER.Code AS CIP_Series_Code,
CSER.Name AS CIP_Series_Name,
CSER.Short_Name AS CIP_Series_Short_Name,
CASE WHEN CDEM.cip_code IS NULL THEN 'N' ELSE 'Y' END AS CIP_Classification_High_Demand

FROM 
ds_ar_dhe.dbo.cip_classification CCLS
JOIN ds_ar_dhe.dbo.cip_category CCAT ON (CCAT.Code=CCLS.CIP_Category)
JOIN ds_ar_dhe.dbo.cip_series CSER ON (CSER.Code=CCAT.CIP_Series)
LEFT JOIN ds_ar_dhe.dbo.cip_highdemand_productivity CDEM ON (CDEM.cip_code+'.'+CDEM.cip_detail =CCLS.Code)

--REDACTED



--LOAD RDIM_NAICS_NATIONAL_INDUSTRY
INSERT INTO tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry (
	NAICS_National_Industry_ID,
	NAICS_National_Industry_Code,
	NAICS_National_Industry_Name,
	NAICS_Industry_Code,
	NAICS_Industry_Name,
	NAICS_Industry_Group_Code,
	NAICS_Industry_Group_Name,
	NAICS_Subsector_Code,
	NAICS_Subsector_Name,
	NAICS_Sector_Code,
	NAICS_Sector_Name,
	NAICS_Supersector_Code,
	NAICS_Supersector_Name,	
	NAICS_Domain_Code,
	NAICS_Domain_Name
)

SELECT
CAST(NNI.Code AS INT) AS NAICS_National_Industry_ID,
NNI.Code AS NAICS_National_Industry_Code,
NNI.Name AS NAICS_National_Industry_Name,
NI.Code AS NAICS_Industry_Code,
NI.Name AS NAICS_Industry_Name,
NIG.Code AS NAICS_Industry_Group_Code,
NIG.Name AS NAICS_Industry_Group_Name,
NSUB.Code AS NAICS_Subsector_Code,
NSUB.Name AS NAICS_Subsector_Name,
NSEC.Code AS NAICS_Sector_Code,
NSEC.Name AS NAICS_Sector_Name,
NSUP.Code AS NAICS_Supersector_Code,
NSUP.Name AS NAICS_Supersector_Name,
ND.Code AS NAICS_Domain_Code,
ND.Name AS NAICS_Domain_Name

FROM
ds_ar_dws.dbo.NAICS_National_Industry NNI
JOIN ds_ar_dws.dbo.NAICS_Industry NI ON (NI.Code=NNI.NAICS_Industry)
JOIN ds_ar_dws.dbo.NAICS_Industry_Group NIG ON (NIG.Code=NI.NAICS_Industry_Group)
JOIN ds_ar_dws.dbo.NAICS_Subsector NSUB ON (NSUB.Code=NIG.NAICS_Subsector)
JOIN ds_ar_dws.dbo.NAICS_Sector NSEC ON (NSEC.Code=NSUB.NAICS_Sector)
JOIN ds_ar_dws.dbo.NAICS_Super_Sector NSUP ON (NSUP.Code=NSEC.NAICS_Super_Sector)
JOIN ds_ar_dws.dbo.NAICS_Domain ND ON (ND.Code=NSUP.NAICS_Domain)




--LOAD RDIM_COUNTY
INSERT INTO tr_ar_2022.dbo.AR_RDIM_County (
	County_ID,
	County_Code,
	County_Name,
	State_Code,
	State_Name,
	Rural_Urban_Continuum_Code,
	Rural_Urban_Continuum_Name,
	Local_Workforce_Development_Area
)
SELECT 
CAST(C.Code AS SMALLINT) AS County_ID,
C.Code AS County_Code,
C.Name AS County_Name,
'AR' AS State_Code,
'Arkansas' AS State_Name,
C.Rural_Urban_Continuum AS 'Rural_Urban_Continuum_Code',

CASE WHEN C.Rural_Urban_Continuum = 1 THEN 'Counties in metro areas of 1 million population or more'
	WHEN C.Rural_Urban_Continuum = 2 THEN 'Counties in metro areas of 250,000 to 1 million population'
	WHEN C.Rural_Urban_Continuum = 3 THEN 'Counties in metro areas of fewer than 250,000 population'
	WHEN C.Rural_Urban_Continuum = 4 THEN 'Urban population of 20,000 or more, adjacent to a metro area'
	WHEN C.Rural_Urban_Continuum = 5 THEN 'Urban population of 20,000 or more, not adjacent to a metro area'
	WHEN C.Rural_Urban_Continuum = 6 THEN 'Urban population of 2,500 to 19,999, adjacent to a metro area'
	WHEN C.Rural_Urban_Continuum = 7 THEN 'Urban population of 2,500 to 19,999, not adjacent to a metro area'
	WHEN C.Rural_Urban_Continuum = 8 THEN 'Completely rural or less than 2,500 urban population, adjacent to a metro area'
	WHEN C.Rural_Urban_Continuum = 9 THEN 'Completely rural or less than 2,500 urban population, not adjacent to a metro area'
	END AS Rural_Urban_Continuum_Name,

C.Local_Workforce_Development_Area

FROM 
ds_ar_dws.dbo.CountyByLWDA C




--LOAD RDIM_Quarter


-- Declare and set variables for loop
DECLARE
@StartDate DATE,
@EndDate DATE,
@Date DATE,
@ID SMALLINT

SET @StartDate = '2001-01-01'
SET @EndDate = '2021-12-31'
SET @ID = 1

SET @Date = @StartDate

TRUNCATE TABLE tr_ar_2022.dbo.AR_RDIM_Quarter

WHILE @Date <= @EndDate
BEGIN

INSERT INTO tr_ar_2022.dbo.AR_RDIM_Quarter (
Quarter_ID,
Quarter_Code,
Calendar_Year,
Calendar_Quarter,
Calendar_Month_Number_Start,
Calendar_Month_Number_End,
Start_Date,
End_Date
)
VALUES
(
@ID, --Quarter_ID,
CAST(DATEPART(YY,@Date) AS CHAR(4)) + 'Q' + CAST(DATEPART(Q,@Date) AS CHAR(1)), --Quarter_Code
DATEPART(YY,@Date), --Calendar_Year
DATEPART(Q,@Date), --Calendar_Quarter
DATEPART(MM,@Date), -- AS Calendar_Month_Number_Start
DATEPART(MM,@Date) + 2, -- AS Calendar_Month_End
@Date, -- AS Start_Date
DATEADD(D,-1,DATEADD(Q,1,@Date)) -- AS End_Date
)
	
    SET @Date = dateadd(mm,3,@Date )
    SET @ID =@ID +1
END
























