--NAME: ZAINAB PARVEEN
--UNIVERSITY ROLL NUMBER: 2215002066
--III year SEC D
-- Project Name : Market Segmentation Analysis of Bank's Customer Base


--------------------------------------------------------------- Problem Statement -----------------------------------------------------------------------
-- Apex Industrial Credit & Investment Bank (AICIB) is a commercial bank that serves both commercial and retail customers across India. 
-- With strategically located branches in India, as well as convenient digital and virtual banking tools, AICIB has established itself 
-- as a trusted financial partner for its diverse clientele. Its retail offerings include credit cards, loans and savings accounts. 


-- 1.Merge Customer and Transaction Data
-- It's crucial for segmenting customers based on both financial behaviors and demographic attributes
SELECT 
    t."CUSTOMER_ID", 
    t."FICO_SCORE", 
    t."CATEGORY", 
    t."ACCOUNT_CATEGORY", 
    t."ACCOUNT_STATUS", 
    t."HIGHEST_CREDIT", 
    t."ACCOUNT_BALANCE", 
    u."FIRST_NAME", 
    u."LAST_NAME", 
    u."CITY", 
    u."STATE" 
FROM 
    "transaction_line" t
JOIN 
    "user_data" u
ON 
    t."CUSTOMER_ID" = u."CUSTOMER_ID";


-- 2. Summary of active vs closed accounts.

SELECT
	"ACCOUNT_STATUS",
	COUNT(*) AS total_account_status
FROM
	transaction_line tl
GROUP BY
	1
ORDER BY
	1;
	
-- 3. Breakdown of account types (e.g., loans, credit cards) and their current balances.

select "ACCOUNT_CATEGORY",
    COUNT(*) AS count,
    SUM(CAST("ACCOUNT_BALANCE" AS NUMERIC)) AS total_current_balance
FROM
    transaction_line tl
GROUP BY
    "ACCOUNT_CATEGORY"
ORDER BY
    "ACCOUNT_CATEGORY";

-- 4. Analysis of loan amounts vs. account balances.

SELECT
    "ACCOUNT_CATEGORY",
    AVG(CAST("SANCTIONED_AMOUNT" AS NUMERIC)) AS avg_loan_amount,
    AVG(CAST("ACCOUNT_BALANCE" AS NUMERIC)) AS avg_account_balance
FROM
    transaction_line tl
GROUP BY
    "ACCOUNT_CATEGORY";

	
-- 5. overview of the closure percentages for different loan types by ownership type (Individual vs Joint Account) 

SELECT
	"ACCOUNT_CATEGORY",
	"OWNERSHIP_TYPE",
	COUNT(*) AS total_accounts,
	SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) AS closed_accounts,
	ROUND(SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 2) AS closure_percentage
FROM
	transaction_line tl
GROUP BY
	1,
	2
ORDER BY
	2,
	1;

-- 6. Let’s start by segmenting customers based on FICO scores

    SELECT
        "CUSTOMER_ID",
        CAST("FICO_SCORE" AS INTEGER) AS fico_score,
        "ACCOUNT_CATEGORY", 
        CASE 
            WHEN CAST("FICO_SCORE" AS INTEGER) BETWEEN 300 AND 549 THEN 'Very Poor'
            WHEN CAST("FICO_SCORE" AS INTEGER) BETWEEN 550 AND 649 THEN 'Poor'
            WHEN CAST("FICO_SCORE" AS INTEGER) BETWEEN 650 AND 749 THEN 'Fair'
            WHEN CAST("FICO_SCORE" AS INTEGER) BETWEEN 750 AND 849 THEN 'Good'
            WHEN CAST("FICO_SCORE" AS INTEGER) BETWEEN 850 AND 949 THEN 'Excellent'
        END AS credit_segment
    FROM
        transaction_line tl 

-- 7.  Identify High-Value Customers. Identifies customers with high credit limits and account balances. 
-- High-value customers are key targets for upselling
SELECT 
    "CUSTOMER_ID", 
    SUM(CAST("HIGHEST_CREDIT" AS DECIMAL)) AS "TOTAL_CREDIT_LIMIT", 
    SUM(CAST("ACCOUNT_BALANCE" AS DECIMAL)) AS "TOTAL_BALANCE"
FROM 
    "transaction_line"
GROUP BY 
    "CUSTOMER_ID"
HAVING 
    SUM(CAST("ACCOUNT_BALANCE" AS DECIMAL)) > 100000;





-- 8. Product Usage Segmentation: Categorizing customers by the types of accounts they hold (e.g., Auto Loans, Credit Cards, etc.).

WITH product_segmentation AS (
SELECT
	"CUSTOMER_ID",
	STRING_AGG(DISTINCT "ACCOUNT_CATEGORY", ', ') AS product_mix
FROM
	transaction_line tl
GROUP BY
	"CUSTOMER_ID"
)
SELECT
	product_mix,
	COUNT("CUSTOMER_ID") AS total_customers
FROM
	product_segmentation ps
GROUP BY
	1;


-- 9. Account Activity Segmentation: Segmenting customers by the status of their accounts (whether they have more active or closed accounts).

SELECT
	"CUSTOMER_ID",
	SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) AS active_accounts,
	SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) AS closed_accounts,
	CASE
		WHEN SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) > SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) THEN 'More Active'
		WHEN SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) < SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) THEN 'More Closed'
		ELSE 'EQUAL'
	END AS account_activity_segment
FROM
	transaction_line tl
GROUP BY
	1;


-- 10. Account Activity Segmentation Count 

WITH account_segments AS (
SELECT
	"CUSTOMER_ID",
	SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) AS active_accounts,
	SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) AS closed_accounts,
	CASE
		WHEN SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) > SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) THEN 'More Active'
		WHEN SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) < SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) THEN 'More Closed'
		ELSE 'EQUAL'
	END AS account_activity_segment
FROM
	transaction_line tl
GROUP BY
	1
)
SELECT
	account_activity_segment,
	COUNT("CUSTOMER_ID") AS total_customers
FROM
	account_segments ass
GROUP BY
	1
ORDER BY
	1;


-- 11.Analyze Popular Transaction Categories. Understanding which transaction categories are most common helps AICIB identify key areas of customer spending.
SELECT 
    "CATEGORY", 
    COUNT(*) AS "TRANSACTION_COUNT"
FROM 
    "transaction_line"
GROUP BY 
    "CATEGORY"
ORDER BY 
    "TRANSACTION_COUNT" DESC;
   
   
   
-- 12.Determine Customers Eligible for Upselling
   SELECT 
    "CUSTOMER_ID", 
    "ACCOUNT_CATEGORY", 
    CAST("ACCOUNT_BALANCE" AS DECIMAL) AS "BALANCE"
FROM 
    "transaction_line"
WHERE 
    CAST("ACCOUNT_BALANCE" AS DECIMAL) > 50000;  
   
   
-- 13.Assess Regional Customer Distribution
   
  SELECT 
    u."STATE", 
    COUNT(DISTINCT t."CUSTOMER_ID") AS "CUSTOMER_COUNT"
FROM 
    "transaction_line" t
JOIN 
    "user_data" u
ON 
    t."CUSTOMER_ID" = u."CUSTOMER_ID"
GROUP BY 
    u."STATE";
   
   
-- 14.Track Aging Accounts
SELECT 
    "CUSTOMER_ID", 
    CAST("TENURE_MONTHS" AS INTEGER) AS "TENURE_MONTHS"
FROM 
    "transaction_line"
WHERE 
    CAST("TENURE_MONTHS" AS INTEGER) > 120;  
   
-- 15. This query is used to get an overview of customers' contact details and their associated account activity.
-- By having direct contact information (EMAIL, PHONE_NUMBER), the bank can contact the customer for personalized offers.
SELECT 
    u."CUSTOMER_ID",
    u."FIRST_NAME",
    u."LAST_NAME",
    u."EMAIL",
    u."PHONE_NUMBER",
    COUNT(DISTINCT t."ROW_ID") AS "Total_Transactions",
    MAX(t."LAST_PAYMENT_DATE") AS "Last_Payment_Date",
    SUM(CAST(t."ACCOUNT_BALANCE" AS DECIMAL)) AS "Total_Balance"
FROM 
    "user_data" u
JOIN 
    "transaction_line" t ON u."CUSTOMER_ID" = t."CUSTOMER_ID"
WHERE 
    u."EMAIL" IS NOT NULL  -- Ensuring customers have email addresses
GROUP BY 
    u."CUSTOMER_ID", u."FIRST_NAME", u."LAST_NAME", u."EMAIL", u."PHONE_NUMBER"
ORDER BY 
    "Total_Transactions" DESC;


   

   
-- CO-OCCURENCE ON CATOGARY OF ACCOUNTS
SELECT 
    t1."CATEGORY" AS "Product_1",
    t2."CATEGORY" AS "Product_2",
    COUNT(DISTINCT t1."CUSTOMER_ID") AS "Co_occurrence_Count"
FROM 
    "transaction_line" t1
JOIN 
    "transaction_line" t2 ON t1."CUSTOMER_ID" = t2."CUSTOMER_ID"
WHERE 
    t1."CATEGORY" <> t2."CATEGORY"
GROUP BY 
    t1."CATEGORY", t2."CATEGORY"
ORDER BY 
    "Co_occurrence_Count" DESC;




-- CROSS SELL SUMMARY BY PRODUCT CATEGORY   
 SELECT 
    "CATEGORY" AS "Product_Category",
    COUNT(DISTINCT "CUSTOMER_ID") AS "Total_Customers",
    COUNT(DISTINCT CASE WHEN "CATEGORY" = 'Loan' THEN "CUSTOMER_ID" END) AS "Loan_Customers",
    COUNT(DISTINCT CASE WHEN "CATEGORY" = 'Credit Card' THEN "CUSTOMER_ID" END) AS "Credit_Card_Customers",
    COUNT(DISTINCT CASE WHEN "CATEGORY" = 'Savings' THEN "CUSTOMER_ID" END) AS "Savings_Customers",
    ROUND(
        (COUNT(DISTINCT CASE WHEN "CATEGORY" = 'Credit Card' THEN "CUSTOMER_ID" END) * 100.0) / COUNT(DISTINCT "CUSTOMER_ID"), 2
    ) AS "Credit_Card_Percentage",
    ROUND(
        (COUNT(DISTINCT CASE WHEN "CATEGORY" = 'Loan' THEN "CUSTOMER_ID" END) * 100.0) / COUNT(DISTINCT "CUSTOMER_ID"), 2
    ) AS "Loan_Percentage"
FROM 
    "transaction_line"
GROUP BY 
    "CATEGORY";

   
-- Cross-Sell Customers Pivot Analysis   
   SELECT 
    "ACCOUNT_STATUS",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Gold Loan' THEN "CUSTOMER_ID" END) AS "Loan_Customers",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Credit Card' THEN "CUSTOMER_ID" END) AS "Credit_Card_Customers",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Personal Loan' THEN "CUSTOMER_ID" END) AS "Savings_Customers",
    (COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Gold Loan' THEN "CUSTOMER_ID" END) * 100.0) / COUNT(DISTINCT "CUSTOMER_ID")
    AS "Loan_Percentage",
    (COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Credit Card' THEN "CUSTOMER_ID" END) * 100.0) / COUNT(DISTINCT "CUSTOMER_ID")
    AS "Credit_Card_Percentage",
    (COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Personal Loan' THEN "CUSTOMER_ID" END) * 100.0) / COUNT(DISTINCT "CUSTOMER_ID")
    AS "Savings_Percentage"
FROM 
    "transaction_line"
GROUP BY 
    "ACCOUNT_STATUS"
ORDER BY 
    "ACCOUNT_STATUS";


-- cross-sell oportunities by costumer tenure
SELECT 
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM TO_DATE("OPENING_DATE", 'DD-MM-YYYY')) AS "Customer_Tenure_Years",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Gold Loan' THEN "CUSTOMER_ID" END) AS "Loan_Customers",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Credit Card' THEN "CUSTOMER_ID" END) AS "Credit_Card_Customers",
    COUNT(DISTINCT CASE WHEN "ACCOUNT_CATEGORY" = 'Personal Loan' THEN "CUSTOMER_ID" END) AS "Personal_Loan_Customers"
FROM 
    "transaction_line"
WHERE 
    "OPENING_DATE" IS NOT NULL
GROUP BY 
    "Customer_Tenure_Years"
ORDER BY 
    "Customer_Tenure_Years";
    