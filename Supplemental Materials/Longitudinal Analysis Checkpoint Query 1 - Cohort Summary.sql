

SELECT
COUNT(P.Person_ID) AS All_Cohort_Members

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

--INDUSTRY LISTED COURSE TO FINE
--,NNI.NAICS_Supersector_Name
--,NNI.NAICS_Sector_Name
--,NNI.NAICS_Subsector_Name
--,NNI.NAICS_Industry_Group_Name
--,NNI.NAICS_Industry_Name
--,NNI.NAICS_National_Industry_Name

--OCCUPATION
--,S.SOC_Major_Group_Name
--,S.SOC_Minor_Group_Name
--,S.SOC_Broad_Group_Name
--,S.SOC_Detailed_Occupation_Name

--COUNTY
--,CTY.Rural_Urban_Continuum_Name
--,CTY.Local_Workforce_Development_Area
--,CTY.County_Name

FROM 
--*******************************************************************************************************
--ADD YOUR TEAM'S COHORT TABLE HERE
tr_ar_2022.dbo.team2_cohort_josh C --COHORT
--AN INNER JOIN ON THE COHORT TABLE LIMITS THE SELECTION OF PERSON RECORDS TO THE COHORT OF INTEREST
--*******************************************************************************************************

JOIN tr_ar_2022.dbo.AR_MDIM_Person P ON (P.Apprentice_Number=C.apprnumber) --PERSON

--LOOK UP APPRENTICESHIP INDUSTRY WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT INDUSTRY.
LEFT JOIN tr_ar_2022.dbo.AR_RDIM_NAICS_National_Industry NNI ON (NNI.NAICS_National_Industry_ID=P.Apprenticeship_NAICS_National_Industry_ID)

--LOOK UP APPRENTICESHIP OCCUPATION WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT OCCUPATION.
LEFT JOIN tr_ar_2022.dbo.AR_RDIM_SOC_Detailed_Occupation S ON (S.SOC_Detailed_Occupation_ID=P.Apprenticeship_SOC_Detailed_Occupation_ID)

--LOOK UP APPRENTICESHIP PROGRAM COUNTY WHERE APPLICABLE.  OUTER JOIN IS USED TO AVOID EXCLUDING ROWS WITHOUT COUNTY.
LEFT JOIN tr_ar_2022.dbo.AR_RDIM_County CTY ON (CTY.County_ID=P.Apprenticeship_County_ID)

GROUP BY
--PERSON DEMOGRAPHICS
P.Gender
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
END

--INDUSTRY LISTED COURSE TO FINE
--,NNI.NAICS_Supersector_Name
--,NNI.NAICS_Sector_Name
--,NNI.NAICS_Subsector_Name
--,NNI.NAICS_Industry_Group_Name
--,NNI.NAICS_Industry_Name
--,NNI.NAICS_National_Industry_Name

--OCCUPATION
--,S.SOC_Major_Group_Name
--,S.SOC_Minor_Group_Name
--,S.SOC_Broad_Group_Name
--,S.SOC_Detailed_Occupation_Name

--COUNTY
--,CTY.Rural_Urban_Continuum_Name
--,CTY.Local_Workforce_Development_Area
--,CTY.County_Name

--DATA QUALITY
--,P.Apprenticeship_SSN_Complete


--HAVING COUNT(P.Person_ID) > 10  --UNCOMMENT THIS WHEN YOU ARE READY TO APPLY STATISTICAL CELL SIZE SUPPRESION.  YOU CAN ALSO FLIP THE RELATIONSHIP TO IDENTIFY WHAT IS BEING EXCLUDED





