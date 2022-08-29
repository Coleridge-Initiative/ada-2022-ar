

--DBEAVER HAS A KNOWN ISSUE USING VARIABLES INSIDE OF CTES, WHICH THIS USES; THIS WILL RUN FINE IN MICROSOFT SQL SERVER MANAGEMENT STUDIO OR R

--DECLARE VARIABLES FOR OUR ANALYSIS
DECLARE
@PreQuarters SMALLINT,
@PostQuarters SMALLINT

--SET THE NUMBER OF QUARTERS TO PULL
SET @PreQuarters = 0 --SET DESIRED OUTCOME QUARTERS PRECEDING THE PERIOD OF INTEREST
SET @PostQuarters = 8 --SET DESIRED OUTCOMES QUARTERS FOLLOWING THE PERIOD OF INTEREST
;
--DECLARE COMMON TABLE EXPRESSION TO HOLD OBSERVATIONS ON INTEREST FOR OUR COHORT AND SELECTED QUARTERS
WITH OBSERVATIONS_OF_INTEREST AS (
	SELECT
	F.Quarter_ID - P.Apprenticeship_End_Quarter_ID AS Quarters_Relative_to_Completion
	,P.Person_ID
	,F.Primary_Employer_ID
	,F.Employed
	,F.Primary_Employer_Wages
	,F.Total_Wages
	
	--PERSON DEMOGRAPHICS
	,P.Gender
	,P.Race
	,P.Ethnicity
	,P.Disabled
	,P.Veteran
	
	--PUT APPRENTICESHIP STARTING AGE INTO STANDARD DEPT OF LABOR AGE RANGES FOR FEDERAL REPORTING
	,CASE WHEN P.Apprenticeship_Age_at_Start < 16 THEN '< 16'	
		WHEN P.Apprenticeship_Age_at_Start BETWEEN 16 AND 18 THEN '16 - 18'
		WHEN P.Apprenticeship_Age_at_Start BETWEEN 19 AND 24 THEN '19 - 24'
		WHEN P.Apprenticeship_Age_at_Start BETWEEN 25 AND 44 THEN '25 - 44'
		WHEN P.Apprenticeship_Age_at_Start BETWEEN 45 AND 54 THEN '45 - 54'
		WHEN P.Apprenticeship_Age_at_Start BETWEEN 55 AND 59 THEN '55 - 59'
		WHEN P.Apprenticeship_Age_at_Start > 60 THEN '60+'
		ELSE NULL
	END AS 'Apprenticeship_Age_Range_at_Start'
	
	--APPRENTICESHIP INDUSTRY
	,ANNI.NAICS_Supersector_Name AS Apprenticeship_NAICS_Supersector_Name
	,ANNI.NAICS_Sector_Name AS Apprenticeship_NAICS_Sector_Name
	,ANNI.NAICS_Subsector_Name AS Apprenticeship_NAICS_Subsector_Name
	,PENNI.NAICS_Industry_Group_Name AS Apprenticeship_NAICS_Industry_Group_Name
	,ANNI.NAICS_Industry_Name AS Apprenticeship_NAICS_Industry_Name
	,ANNI.NAICS_National_Industry_Name AS Apprenticeship_NAICS_National_Industry_Name
	
	--PRIMARY EMPLOYER INDUSTRY
	,PENNI.NAICS_Supersector_Name AS Primary_Employment_NAICS_Supersector_Name
	,PENNI.NAICS_Sector_Name AS Primary_Employment_NAICS_Sector_Name
	,PENNI.NAICS_Subsector_Name AS Primary_Employment_NAICS_Subsector_Name
	,PENNI.NAICS_Industry_Group_Name AS Primary_Employment_NAICS_Industry_Group_Name
	,PENNI.NAICS_Industry_Name AS Primary_Employment_NAICS_Industry_Name
	,PENNI.NAICS_National_Industry_Name AS Primary_Employment_NAICS_National_Industry_Name
	
	--APPRENTICESHIP OCCUPATION
	,S.SOC_Major_Group_Name
	,S.SOC_Minor_Group_Name
	,S.SOC_Broad_Group_Name
	,S.SOC_Detailed_Occupation_Name
	
	--APPRENTICESHIP EMPLOYER COUNTYI 
	,ACTY.Rural_Urban_Continuum_Name AS Apprenticeship_Rural_Urban_Continuum_Name
	,ACTY.Local_Workforce_Development_Area AS Apprenticeship_Local_Workforce_Development_Area
	,ACTY.County_Name AS Apprenticeship_County_Name
	
	--PRIMARY EMPLOYER COUNTYI 
	,PECTY.Rural_Urban_Continuum_Name AS Primary_Employer_Rural_Urban_Continuum_Name
	,PECTY.Local_Workforce_Development_Area AS Primary_Employer_Local_Workforce_Development_Area
	,PECTY.County_Name AS Primary_Employer_County_Name
	
	FROM 
	--*******************************************************************************************************
	--ADD YOUR TEAM'S COHORT TABLE HERE
	tr_ar_2022.dbo.team2_cohort_josh C --COHORT
	--AN INNER JOIN ON THE COHORT TABLE LIMITS THE SELECTION OF PERSON RECORDS TO THE COHORT OF INTEREST
	--*******************************************************************************************************
	
	JOIN tr_ar_2022.dbo.AR_MDIM_Person P ON (P.Apprentice_Number=C.apprnumber) --PERSON
	
	JOIN tr_ar_2022.dbo.AR_FACT_Quarterly_Observation F --QUARTERLY OBSERVATION FACT
		ON ((P.Person_ID=F.Person_ID) AND (F.Quarter_ID = (P.Apprenticeship_End_Quarter_ID-@PreQuarters))) 
		OR ((P.Person_ID=F.Person_ID) AND (F.Quarter_ID = (P.Apprenticeship_End_Quarter_ID+@PostQuarters)))
			
	--LOOK UP APPRENTICESHIP INDUSTRY WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT INDUSTRY.
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry ANNI ON (ANNI.NAICS_National_Industry_ID=P.Apprenticeship_NAICS_National_Industry_ID)
	
	--LOOK UP APPRENTICESHIP OCCUPATION WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT OCCUPATION.
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_SOC_Detailed_Occupation S ON (S.SOC_Detailed_Occupation_ID=P.Apprenticeship_SOC_Detailed_Occupation_ID)
	
	--LOOK UP APPRENTICESHIP PROGRAM COUNTY WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT COUNTY.
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_County ACTY ON (ACTY.County_ID=P.Apprenticeship_County_ID)	
	
	--LOOK UP PRIMARY EMPLOYER WHERE APPLICABLE
	LEFT JOIN tr_ar_2022.dbo.AR_MDIM_Employer PE ON (PE.Employer_ID=F.Primary_Employer_ID)  --PRIMARY EMPLOYER
	
	--LOOK UP PRIMARY EMPLOYER COUNTY WHERE APPLICABLE
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_County PECTY ON (PECTY.County_ID=PE.County_ID)  --PRIMARY EMPLOYER COUNTY
	
	--LOOK UP PRIMARY EMPLOYER INDUSTRY WHERE APPLICABLE
	LEFT JOIN tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry PENNI ON (PE.NAICS_National_Industry_ID=PENNI.NAICS_National_Industry_ID) --APPRENTICESHIP INDUSTRY
	
	WHERE
	P.Apprenticeship_Completer='Y'  --APPRENTICESHIP END COVERS MULTIPLE EXIT TYPES; SELECT ONLY COMPLETIONS
)
--CALCULATE OUR PERSON-LEVEL LONGITUDINAL OUTCOMES
,PERSON_LONGITUDINAL_OUTCOMES AS (
	SELECT
	--PERSON CHARACTERISTICS
	FO.Person_ID
	,FO.Gender
	,FO.Race
	,FO.Ethnicity
	,FO.Disabled
	,FO.Veteran
	,FO.Apprenticeship_Age_Range_at_Start

	--EMPLOYER
	,FO.Employed AS Employed_First_Observation
	,SO.Employed AS Employed_Second_Observation
	,CASE WHEN FO.Employed = 'Y' AND SO.Employed = 'Y' THEN 1.0 ELSE 0 END AS Employment_Retention

	,FO.Primary_Employer_ID AS Primary_Employer_ID_First_Observation
	,SO.Primary_Employer_ID AS Primary_Employer_ID_Second_Observation
	,CASE WHEN FO.Primary_Employer_ID=SO.Primary_Employer_ID THEN 1.0 ELSE 0 END AS Same_Primary_Employer_Retention

	,FO.Primary_Employer_Wages AS Primary_Employer_Wages_First_Observation
	,SO.Primary_Employer_Wages AS Primary_Employer_Wages_Second_Observation
	,CASE WHEN FO.Employed = 'Y' AND SO.Employed = 'Y' THEN SO.Primary_Employer_Wages - FO.Primary_Employer_Wages ELSE 0 END AS Primary_Employer_Wages_Difference
	,CASE WHEN FO.Employed = 'Y' AND SO.Employed = 'Y' THEN (SO.Primary_Employer_Wages - FO.Primary_Employer_Wages) / FO.Primary_Employer_Wages ELSE 0 END AS Primary_Employer_Wages_Percent_Difference

	,FO.Total_Wages AS Total_Wages_First_Observation
	,SO.Total_Wages AS Total_Wages_Second_Observation


	--INDUSTRY
	,FO.Apprenticeship_NAICS_Supersector_Name
	,SO.Primary_Employment_NAICS_Supersector_Name
	,CASE WHEN FO.Apprenticeship_NAICS_Supersector_Name = SO.Primary_Employment_NAICS_Supersector_Name THEN 1.0 ELSE 0 END AS Same_NAICS_Supersector_Retention

	,FO.Apprenticeship_NAICS_Sector_Name
	,SO.Primary_Employment_NAICS_Sector_Name
	,FO.Apprenticeship_NAICS_Subsector_Name
	,SO.Primary_Employment_NAICS_Subsector_Name
	,FO.Apprenticeship_NAICS_Industry_Group_Name
	,SO.Primary_Employment_NAICS_Industry_Group_Name
	,FO.Apprenticeship_NAICS_Industry_Name
	,SO.Primary_Employment_NAICS_Industry_Name
	,FO.Apprenticeship_NAICS_National_Industry_Name
	,SO.Primary_Employment_NAICS_National_Industry_Name

	--COUNTY
	,FO.Apprenticeship_County_Name
	,SO.Primary_Employer_County_Name
	,FO.Apprenticeship_Local_Workforce_Development_Area
	,SO.Primary_Employer_Local_Workforce_Development_Area
	,FO.Apprenticeship_Rural_Urban_Continuum_Name
	,SO.Primary_Employer_Rural_Urban_Continuum_Name

	--OCCUPATION
	,FO.SOC_Major_Group_Name
	,FO.SOC_Minor_Group_Name
	,FO.SOC_Broad_Group_Name
	,FO.SOC_Detailed_Occupation_Name

	FROM 
	OBSERVATIONS_OF_INTEREST FO --FIRST OBSERVATION
	JOIN OBSERVATIONS_OF_INTEREST SO --SECOND OBSERVATION
		ON  (FO.Person_ID=SO.Person_ID)
	WHERE
		FO.Quarters_Relative_to_Completion=@PreQuarters
		AND SO.Quarters_Relative_to_Completion=@PostQuarters
)

SELECT 
PLO.Apprenticeship_NAICS_SuperSector_Name
,AVG(PLO.Employment_Retention) AS Employment_Retention_Rate
,AVG(PLO.Same_Primary_Employer_Retention) AS Primary_Employer_Retention_Rate
,AVG(PLO.Same_NAICS_Supersector_Retention) AS NAICS_Supersector_Retention_Rate
,AVG(PLO.Primary_Employer_Wages_Percent_Difference) AS Average_Primary_Employer_Wages_Percent_Difference

FROM
PERSON_LONGITUDINAL_OUTCOMES PLO

GROUP BY
PLO.Apprenticeship_NAICS_SuperSector_Name














