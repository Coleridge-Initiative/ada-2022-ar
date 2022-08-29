
--PERSON LOAD SCRIPT



--DECLARE COMMON TABLE EXPRESSION WITH DISTINCT AR-EMPLOYED PERSONS
WITH Person_Employment
AS (
	SELECT 
	Employee_SSN AS SSN,
	MIN(Q.Quarter_ID) AS First_Employment_Quarter,
	MAX(Q.Quarter_ID) AS Last_Employment_Quarter,
	COUNT(DISTINCT Q.Quarter_ID) AS Quarters_Employed
	
	FROM 
	ds_ar_dws.dbo.ui_wages_lehd UIWL
	JOIN tr_ar_2022.dbo.AR_RDIM_Quarter Q ON (UIWL.Reporting_Period_Year=Q.Calendar_Year) AND (UIWL.Reporting_Period_Quarter=Q.Calendar_Quarter)
	
	GROUP BY
	Employee_SSN
-- REDACTED
),


--DECLARE COMMON TABLE EXPRESSION WITH DISTINT AR APPRENTICESHIP PARTICIPANTS
Person_Apprenticeship AS (
	SELECT
	RXW.ssn AS SSN,
	
	CASE WHEN RA.gender = 'F' THEN 'Female'
		WHEN RA.gender = 'M' THEN 'Male'
		ELSE NULL
	END AS Gender,
	
	COALESCE(RA.race, 'Not Reported') AS Race,
	
	CASE WHEN RA.ethnicity = 'H' THEN 'Hispanic'
		WHEN RA.ethnicity = 'N' THEN 'Non-Hispanic'
		WHEN RA.ethnicity = 'NP' THEN NULL
		ELSE NULL
	END AS Ethnicity,
	
	CASE WHEN RA.disabled = 'NP' THEN NULL
		ELSE RA.disabled
	END AS Disabled,
	
	CASE WHEN RA.vetstatind = 'NP' THEN NULL
		ELSE RA.vetstatind
	END AS Veteran,
	
	CASE WHEN ISNUMERIC(RA.ageatstart) <> 1 THEN NULL
		WHEN CAST(REPLACE(RA.ageatstart,',','') AS INT) BETWEEN 0 and 99 
			THEN YEAR(RA.startdt) - CAST(REPLACE(RA.ageatstart,',','') AS INT)
		ELSE NULL
	END AS Year_of_Birth,
	
	CAST(RA.education AS TINYINT) AS Education,
	
	CASE WHEN RA.apprstatus IN ('DL','DU','DR','IR','PR') THEN 'N'
		ELSE 'Y' 
	END AS Apprenticeship_Participant,
	
	CASE WHEN RA.apprstatus = 'CO' THEN 'Y' 
		ELSE 'N'
	END AS Apprenticeship_Completer,
	
	CASE WHEN RA.apprstatus = 'CA' THEN 'Cancelled'
		WHEN RA.apprstatus = 'CO' THEN 'Completed'
		WHEN RA.apprstatus = 'RE' THEN 'Registered'
		WHEN RA.apprstatus = 'RI' THEN 'Reinstated'
		WHEN RA.apprstatus = 'SU' THEN 'Suspended'
		WHEN RA.apprstatus = 'TR' THEN 'Transferred'
		WHEN RA.apprstatus = 'UP' THEN 'Updated'
		WHEN RA.apprstatus = 'IC' THEN 'Interim Completed'
		WHEN RA.apprstatus = 'PR' THEN 'Pending Registration'
		WHEN RA.apprstatus = 'IR' THEN 'Incomplete Registration'
		WHEN RA.apprstatus = 'DR' THEN 'Denied Registration'
		WHEN RA.apprstatus = 'DL' THEN 'Deleted'
		WHEN RA.apprstatus = 'DU' THEN 'Duplicate'
		WHEN RA.apprstatus = 'PU' THEN 'Pending Update'
		ELSE NULL
	END AS Apprenticeship_Status,
	
	RA.psnumber AS Apprenticeship_Program_Number,
	RA.progname AS Apprenticeship_Program_Name,
	AC.County_ID AS Apprenticeship_County_ID,
	
	CASE WHEN ISNUMERIC(RA.ageatstart) <> 1 THEN NULL
		WHEN CAST(REPLACE(RA.ageatstart,',','') AS INT) BETWEEN 0 and 99 
			THEN CAST(REPLACE(RA.ageatstart,',','') AS INT)
		ELSE NULL
	END AS Apprenticeship_Age_at_Start,
		
	ASQ.Quarter_ID AS Apprenticeship_Start_Quarter_ID,
	AEQ.Quarter_ID AS Apprenticeship_End_Quarter_ID,
	AI.NAICS_National_Industry_ID,
	AO.SOC_Detailed_Occupation_ID,
	RA.orgtype AS Apprenticeship_Organization_Type,
	RA.startingwage AS Apprenticeship_Starting_Hourly_Wage,
	RA.exitwage AS Apprenticeship_Exit_Hourly_Wage,
	CASE WHEN RXW.ssn IS NULL THEN 'N'
		ELSE 'Y'
	END AS Apprenticeship_SSN_Complete,
	RA.apprnumber AS Apprentice_Number
	
	FROM 
	ds_public_1.dbo.rapids_apprentice RA
	JOIN ds_public_1.dbo.rapids_program RP ON (RP.psid =RA.psid)
	LEFT JOIN ds_ar_osd.dbo.ar_rapids_xwalk RXW ON (RXW.rapids_number=RA.apprnumber)
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_Quarter ASQ ON (RA.startdt BETWEEN ASQ.Start_Date AND ASQ.End_Date)  --APPRENTICESHIP START QUARTER
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_Quarter AEQ ON (RA.exitwagedt BETWEEN AEQ.Start_Date  AND AEQ.End_Date) --APPRENTICESHIP END QUARTER
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_County AC ON (AC.County_Name=RA.county) AND (AC.State_Code=RA.progstate) --APPRENTICESHIP COUNTY
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_SOC_Detailed_Occupation AO ON (SUBSTRING(RA.onetsoccode,1,7) = AO.SOC_Detailed_Occupation_Code) --APPRENTICESHIP OCCUPATION
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry AI ON (RA.naicscode=AI.NAICS_National_Industry_Code) --APPRENTICESHIP INDUSTRY
	
	WHERE
	RA.progstate = 'AR'  --ARKANSAS APPRENTICESHIP PROGRAMS
	--REDACTED
	)


INSERT INTO tr_ar_2022.dbo.AR_MDIM_Person (
	SSN,
	First_AR_Employment_Quarter_ID,
	Last_AR_Employment_Quarter_ID,
	AR_Quarters_Employed,
	Gender,
	Race,
	Ethnicity,
	Disabled,
	Veteran,
	Year_of_Birth,
	Education,
	Apprenticeship_Participant,
	Apprenticeship_Completer,
	Apprenticeship_Status,
	Apprenticeship_Program_Number,
	Apprenticeship_Program_Name,
	Apprenticeship_County_ID,
	Apprenticeship_Age_at_Start,
	Apprenticeship_Start_Quarter_ID,
	Apprenticeship_End_Quarter_ID,
	Apprenticeship_NAICS_National_Industry_ID,
	Apprenticeship_SOC_Detailed_Occupation_ID,
	Apprenticeship_Organization_Type,
	Apprenticeship_SSN_Complete,
	Apprentice_Number
)


SELECT
PE.SSN,
PE.First_Employment_Quarter,
PE.Last_Employment_Quarter,
PE.Quarters_Employed,
PA.Gender,
PA.Race,
PA.Ethnicity,
PA.Disabled,
PA.Veteran,
PA.Year_of_Birth,
PA.Education,
COALESCE(PA.Apprenticeship_Participant,'N'),
COALESCE(PA.Apprenticeship_Completer,'N'),
PA.Apprenticeship_Status,
PA.Apprenticeship_Program_Number,
PA.Apprenticeship_Program_Name,
PA.Apprenticeship_County_ID,
PA.Apprenticeship_Age_at_Start,
PA.Apprenticeship_Start_Quarter_ID,
PA.Apprenticeship_End_Quarter_ID,
PA.NAICS_National_Industry_ID,
PA.SOC_Detailed_Occupation_ID,
PA.Apprenticeship_Organization_Type,
PA.Apprenticeship_SSN_Complete,
PA.Apprentice_Number

FROM
Person_Employment PE
FULL OUTER JOIN Person_Apprenticeship PA ON (PE.SSN=PA.SSN)

--DISTINCT PERSONS: REDACTED







