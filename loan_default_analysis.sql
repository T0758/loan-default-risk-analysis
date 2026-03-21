-----------------------------------
-- LOAN DEFAULT RISK ANALYSIS PROJECT
-- Author: Daniel Tindi
-- Description: Analysis of borrower and loan data to
-- identify key drivers of loan default risk
-----------------------------------

DESCRIBE borrower_profiles;
DESCRIBE loan_applications;

-- checking for null values

SELECT 
	COUNT(*) AS total_rows,
    COUNT(CASE WHEN borrower_id = NULL THEN 1 END) AS borrower_id_nulls,
    COUNT(CASE WHEN age = NULL THEN 1 END) AS age_nulls,
    COUNT(CASE WHEN state = NULL THEN 1 END) AS state_nulls,
    COUNT(CASE WHEN education_level = NULL THEN 1 END) AS education_level_nulls,
    COUNT(CASE WHEN employment_status = NULL THEN 1 END) AS employment_status_nulls,
    COUNT(CASE WHEN years_employed = NULL THEN 1 END) AS years_employed_nulls,
    COUNT(CASE WHEN annual_income = NULL THEN 1 END) AS annual_income_nulls,
    COUNT(CASE WHEN credit_score = NULL THEN 1 END) AS credit_score_nulls,
    COUNT(CASE WHEN home_ownership = NULL THEN 1 END) AS home_ownership_nulls,
    COUNT(CASE WHEN dependents = NULL THEN 1 END) AS dependents_nulls,
    COUNT(CASE WHEN existing_monthly_debt = NULL THEN 1 END) AS existing_monthly_debt_nulls
FROM borrower_profiles;

SELECT
	COUNT(*) AS total_rows,
    COUNT(CASE WHEN loan_id = NULL THEN 1 END) AS loan_id_nulls,
    COUNT(CASE WHEN borrower_id = NULL THEN 1 END) AS borrower_id_nulls,
    COUNT(CASE WHEN application_date = NULL THEN 1 END) AS appliaction_date_nulls,
    COUNT(CASE WHEN loan_purpose = NULL THEN 1 END) AS loan_purpose_nulls,
    COUNT(CASE WHEN loan_amount = NULL THEN 1 END) AS loan_amount_nulls,
    COUNT(CASE WHEN term_months = NULL THEN 1 END) AS term_months_nulls,
    COUNT(CASE WHEN interest_rate = NULL THEN 1 END) AS interest_rate_nulls,
    COUNT(CASE WHEN monthly_payment = NULL THEN 1 END) AS monthly_payment_nulls,
    COUNT(CASE WHEN dti_ratio = NULL THEN 1 END) AS dti_ratio_nulls,
    COUNT(CASE WHEN loan_status = NULL THEN 1 END) AS loan_status_nulls,
    COUNT(CASE WHEN days_delinquent = NULL THEN 1 END) AS days_delinquent_nulls,
    COUNT(CASE WHEN defaulted = NULL THEN 1 END) AS defaulted_nulls
FROM loan_applications;

-- overall default rate analysis

WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT 
COUNT(*) as total_loans,
SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS total_defaults,
ROUND(
(SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)/COUNT(*)) * 100, 2
) AS overall_default_rate
FROM base_data;

-- credit score analysis

WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT
	CASE
		WHEN credit_score BETWEEN 520 AND 599 THEN '520-599'
        WHEN credit_score BETWEEN 600 AND 649 THEN '600-649'
        WHEN credit_score BETWEEN 650 AND 699 THEN '650-699'
        WHEN credit_score BETWEEN 700 AND 749 THEN '700-749'
        ELSE '750+'
	END AS credit_bucket,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS defaults,
    ROUND(
		SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) * 100/ COUNT(*), 2
        ) AS default_rate
	FROM base_data
    GROUP BY credit_bucket;
    
-- dti ratio analysis

WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT 
CASE
	WHEN dti_ratio <30 THEN '<30'
	WHEN dti_ratio BETWEEN 30 AND 40 THEN '30-40'
	WHEN dti_ratio BETWEEN 40 AND 50 THEN '40-50'
	ELSE '50+'
END AS dti_ratio_percentage,
COUNT(*) AS total_loans,
SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS total_defaults,
ROUND(
	SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) * 100/COUNT(*)
	) AS default_rate
FROM base_data
GROUP BY 
dti_ratio_percentage;
 
 -- employment status + years employed to default rate analysis
 
WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    bp.years_employed,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT employment_status,
years_employed,
COUNT(*) AS total_loans,
SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS total_defaults,
ROUND(
	(SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)/ COUNT(*)) *100
	) as default_rate
FROM base_data
GROUP BY employment_status, years_employed
ORDER BY default_rate DESC;

-- loan purpose to default rate analysis

WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT loan_purpose,
COUNT(*) AS total_loans,
SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS total_defaults,
ROUND(
	(SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)/COUNT(*)) *100
	) AS default_rate
FROM base_data
GROUP BY loan_purpose
ORDER BY default_rate DESC;

-- age to default rate analysis

WITH base_data AS(
SELECT
	bp.borrower_id,
    bp.age,
    bp.employment_status,
    la.loan_purpose,
    la.loan_status,
    bp.credit_score,
    la.dti_ratio
FROM borrower_profiles bp
JOIN loan_applications la
ON bp.borrower_id = la.borrower_id
)
SELECT
CASE
	WHEN age BETWEEN 20 AND 25 THEN '20-25'
	WHEN age BETWEEN 25 AND 30 THEN '25-30'
	WHEN age BETWEEN 30 AND 35 THEN '30-35'
	WHEN age BETWEEN 35 AND 40 THEN '35-40'
	WHEN age BETWEEN 40 AND 45 THEN '40-45'
	WHEN age BETWEEN 45 AND 50 THEN '45-50'
	ELSE '50+'
END AS age_brackets,
COUNT(*) AS total_loans,
SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS total_defaults,
ROUND(
	(SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)/COUNT(*)) * 100
	) AS default_rate
FROM base_data
GROUP BY age_brackets
ORDER BY default_rate DESC;

    -- rik scoring model
    
    WITH base_data AS(
	SELECT
		bp.borrower_id,
		age,
		credit_score,
		employment_status,
		loan_purpose,
		loan_status,
		dti_ratio
	FROM borrower_profiles bp
    JOIN loan_applications la
    ON bp.borrower_id = la.borrower_id
    ),
    risk_scoring AS (
    SELECT *,
		CASE WHEN credit_score < 600 THEN 2 ELSE 0 END +
        CASE WHEN dti_ratio > 0.4 THEN 2 ELSE 0 END +
        CASE WHEN employment_status = 'Part_time' THEN 1 ELSE 0 END
        AS risk_score
	FROM base_data
    )
    SELECT
		risk_score,
        COUNT(*) AS total_loans,
        (SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)/COUNT(*)) * 100
        AS default_rate
	FROM risk_scoring
    GROUP BY risk_score
    ORDER BY risk_score;
    
    
            
    

	



