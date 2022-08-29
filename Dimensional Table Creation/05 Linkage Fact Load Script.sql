



--LOAD FACT TABLE

--DECLARE COMMON TABLE EXPRESSION FOR DISTINCT PERSON QUARTER OBSERVATIONS IN RANGE OF AR EMPLOYMENT OR APPRENTICESHIP

WITH Person_Quarter_Observations AS (
	SELECT
	P.Person_ID,
	Q.Quarter_ID,
		
	CASE WHEN (Q.Quarter_ID BETWEEN P.Apprenticeship_Start_Quarter_ID AND P.Apprenticeship_End_Quarter_ID) THEN 'Y'
		WHEN ((P.Apprenticeship_End_Quarter_ID IS NULL) AND (Q.Quarter_ID >= P.Apprenticeship_Start_Quarter_ID)) THEN 'Y'
		ELSE 'N'
	END AS Apprenticeship_Participation
	
	FROM 
	tr_ar_2022.dbo.AR_MDIM_Person P
	JOIN tr_ar_2022.dbo.AR_RDIM_Quarter Q ON
		(Q.Quarter_ID BETWEEN P.First_AR_Employment_Quarter_ID  AND P.Last_AR_Employment_Quarter_ID) --EMPLOYMENT QUARTERS
			OR (Q.Quarter_ID BETWEEN P.Apprenticeship_Start_Quarter_ID AND P.Apprenticeship_End_Quarter_ID) --COMPLETED APPRENTICE QUARTERS
			OR ((P.Apprenticeship_End_Quarter_ID IS NULL) AND (Q.Quarter_ID >= P.Apprenticeship_Start_Quarter_ID)) --CURRENT APPRENTICE QUARTER
	-- REDACTED
),
Wage_Rank AS (
	SELECT
	P.Person_ID,
	Q.Quarter_ID,
	ROW_NUMBER() OVER(PARTITION BY P.Person_ID, Q.Quarter_ID ORDER BY W.Employee_Wage_Amount DESC) AS RANK,
	E.Employer_ID,
	W.Employee_Wage_Amount
	
	FROM 
	ds_ar_dws.dbo.ui_wages_lehd W
	JOIN tr_ar_2022.dbo.AR_MDIM_Person P ON (W.Employee_SSN=P.SSN)
	JOIN tr_ar_2022.dbo.AR_MDIM_Employer E ON (E.State_EIN=W.State_EIN)
	JOIN tr_ar_2022.dbo.AR_RDIM_Quarter Q ON ((W.Reporting_Period_Year=Q.Calendar_Year) AND (W.Reporting_Period_Quarter=Q.Calendar_Quarter))
),
Primary_Employer_Wage AS (
	SELECT
	WR.Person_ID,
	WR.Quarter_ID,
	WR.Employer_ID AS Primary_Employer_ID,
	WR.Employee_Wage_Amount AS Primary_Employer_Wages
	
	FROM
	Wage_Rank WR
	
	WHERE
	WR.RANK=1
),
All_Employer_Wage AS (
	SELECT 
	WR.Person_ID,
	WR.Quarter_ID,
	COUNT(WR.Employer_ID) AS Employer_Count,
	SUM(WR.Employee_Wage_Amount) AS Total_Wages
	
	FROM 
	Wage_Rank WR
	
	GROUP BY
	WR.Person_ID,
	WR.Quarter_ID
)

--LOAD QUARTERLY OBSERVATION FACT TABLE
INSERT INTO tr_ar_2022.dbo.AR_FACT_Quarterly_Observation (
	Person_ID,
	Quarter_ID,
	Employed,
	Primary_Employer_ID,
	Primary_Employer_Wages,
	Total_Wages,
	Employer_Count,
	Apprenticeship_Participation,
	Primary_Employer_Beginning_of_Quarter_Employment,
	Primary_Employer_End_of_Quarter_Employment,
	Primary_Employer_Full_Quarter_Employment
)
SELECT 
PQO.Person_ID,
PQO.Quarter_ID,
CASE WHEN PEW.Person_ID IS NULL THEN 'N' ELSE 'Y' END AS Employed,
PEW.Primary_Employer_ID,
PEW.Primary_Employer_Wages,
AEW.Total_Wages,
AEW.Employer_Count,
PQO.Apprenticeship_Participation,

CASE WHEN PEW.Primary_Employer_ID = PPEW.Primary_Employer_ID THEN 'Y'
	WHEN PEW.Primary_Employer_ID <> PPEW.Primary_Employer_ID THEN 'N'
	ELSE 'N'
END AS Primary_Employer_Beginning_of_Quarter_Employment,

CASE WHEN PEW.Primary_Employer_ID = SPEW.Primary_Employer_ID THEN 'Y'
	WHEN PEW.Primary_Employer_ID <> SPEW.Primary_Employer_ID THEN 'N'
	ELSE 'N'
END AS Primary_Employer_End_of_Quarter_Employment,

CASE WHEN (PEW.Primary_Employer_ID = PPEW.Primary_Employer_ID) AND (PEW.Primary_Employer_ID = SPEW.Primary_Employer_ID) THEN 'Y'
	WHEN (PEW.Primary_Employer_ID <> PPEW.Primary_Employer_ID) OR (PEW.Primary_Employer_ID <> SPEW.Primary_Employer_ID) THEN 'N'
	ELSE 'N'
END AS Primary_Employer_Full_Quarter_Employment


FROM
Person_Quarter_Observations PQO
LEFT JOIN Primary_Employer_Wage PEW ON (PEW.Person_ID=PQO.Person_ID) AND (PEW.Quarter_ID=PQO.Quarter_ID) 
LEFT JOIN All_Employer_Wage AEW ON (AEW.Person_ID=PQO.Person_ID) AND (AEW.Quarter_ID=PQO.Quarter_ID) 
LEFT JOIN Primary_Employer_Wage PPEW ON (PPEW.Person_ID=PQO.Person_ID) AND (PPEW.Quarter_ID=PQO.Quarter_ID-1) --PRIOR QUARTER (t-1) PRIMARY EMPLOYER WAGE
LEFT JOIN Primary_Employer_Wage SPEW ON (SPEW.Person_ID=PQO.Person_ID) AND (SPEW.Quarter_ID=PQO.Quarter_ID+1) --SUBSEQUENT QUARTER (t+1) PRIMARY EMPLOYER WAGE

























