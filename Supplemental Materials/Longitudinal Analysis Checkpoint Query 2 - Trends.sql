


--DECLARE VARIABLES FOR OUR ANALYSIS
DECLARE
@PreQuarters SMALLINT,
@PostQuarters SMALLINT

--SET THE NUMBER OF QUARTERS TO PULL
SET @PreQuarters = 8 --SET DESIRED OUTCOME QUARTERS PRECEDING THE PERIOD OF INTEREST
SET @PostQuarters = 8 --SET DESIRED OUTCOMES QUARTERS FOLLOWING THE PERIOD OF INTEREST

SELECT
F.Quarter_ID - P.Apprenticeship_End_Quarter_ID AS Quarters_Relative_to_Completion,
--COUNT(P.Person_ID) AS Completers,
ROUND(AVG(F.Primary_Employer_Wages),0) AS Avg_Primary_Employer_Wages

--,P.Gender
--,P.Race
--,P.Ethnicity
--,P.Disabled
--,P.Veteran
--,NNI.NAICS_Sector_Name
--,PEC.Rural_Urban_Continuum_Name

FROM 
--*******************************************************************************************************
--ADD YOUR TEAM'S COHORT TABLE HERE
tr_ar_2022.dbo.team2_cohort_josh C --COHORT
--AN INNER JOIN ON THE COHORT TABLE LIMITS THE SELECTION OF PERSON RECORDS TO THE COHORT OF INTEREST
--*******************************************************************************************************

JOIN tr_ar_2022.dbo.AR_MDIM_Person P ON (P.Apprentice_Number=C.apprnumber) --PERSON

JOIN tr_ar_2022.dbo.AR_FACT_Quarterly_Observation F --QUARTERLY OBSERVATION FACT
	ON (P.Person_ID=F.Person_ID) 
	AND (F.Quarter_ID BETWEEN (P.Apprenticeship_End_Quarter_ID-@PreQuarters) AND (P.Apprenticeship_End_Quarter_ID+@PostQuarters))  --QTRS PRE/POST COMPLETION
JOIN tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry NNI ON (P.Apprenticeship_NAICS_National_Industry_ID=NNI.NAICS_National_Industry_ID) --APPRENTICESHIP INDUSTRY
JOIN tr_ar_2022.dbo.AR_MDIM_Employer PE ON (PE.Employer_ID=F.Primary_Employer_ID)  --PRIMARY EMPLOYER
JOIN tr_ar_2022.dbo.AR_RDIM_County PEC ON (PEC.County_ID=PE.County_ID)  --PRIMARY EMPLOYER COUNTY

	
WHERE
P.Apprenticeship_Completer='Y'  --APPRENTICESHIP END COVERS MULTIPLE EXIT TYPES; SELECT ONLY COMPLETIONS

GROUP BY
(F.Quarter_ID - P.Apprenticeship_End_Quarter_ID) --QUARTERS_RELATIVE_TO_COMPLETION

--,P.Gender
--,P.Race
--,P.Ethnicity
--,P.Disabled
--,P.Veteran
--,NNI.NAICS_Sector_Name
--,NNI.NAICS_Subsector_Name
--,PEC.Rural_Urban_Continuum_Name

ORDER BY
(F.Quarter_ID - P.Apprenticeship_End_Quarter_ID) --QUARTERS RELATIVE TO COMPLETION




