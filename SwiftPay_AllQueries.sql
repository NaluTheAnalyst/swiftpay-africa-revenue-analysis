-- ============================================================
--  SwiftPay Africa  |  Revenue & Growth Analysis
--  SQL Server 2019
-- ============================================================

USE SwiftPayAfrica;
GO


-- QUESTION 1: Revenue by Subscription Plan
SELECT
    p.plan_name,
    SUM(t.fee_charged) AS total_revenue
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
JOIN plans p ON m.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY total_revenue DESC

-- Results:
-- Enterprise    450,448,902.68
-- Business       88,243,804.82
-- Growth         20,980,540.18
-- Starter           778,936.90


-- QUESTION 2: Transaction Success Rate by Payment Method
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
    CAST(SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS failure_rate_pct
FROM transactions
GROUP BY payment_method
ORDER BY failure_rate_pct DESC

-- Results:
-- card            5,305    953    17.96%
-- ussd            5,276    534    10.12%
-- mobile_money    5,249    412     7.85%
-- bank_transfer   5,248    280     5.34%


-- QUESTION 3: Top 10 Merchants by Transaction Volume
SELECT TOP 10
    m.business_name,
    SUM(t.amount) AS total_amount
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.business_name
ORDER BY total_amount DESC

-- Results:
-- Dangote Consumer Goods Ltd     42,090,833,085
-- Zenith Logistics Nigeria       32,222,433,046
-- HealthPlus Pharmacy Chain       2,051,971,701
-- UACN Property Development       2,005,553,423
-- Novare Retail Centres           1,973,427,929
-- Pan-African Schools Network     1,415,643,716
-- Chicken Republic Foods          1,398,885,879
-- CoolBoys Media Group            1,396,137,011
-- QuickMart Superstore              243,854,886
-- NorthStar Real Estate             185,640,686


-- QUESTION 4: Monthly Revenue Trend
SELECT
    MONTH(transaction_date) AS month_number,
    DATENAME(MONTH, transaction_date) AS month_name,
    SUM(fee_charged) AS total_revenue
FROM transactions
GROUP BY MONTH(transaction_date), DATENAME(MONTH, transaction_date)
ORDER BY month_number

-- Results:
-- January       26,093,594.11
-- February      39,567,990.19
-- March         51,052,192.64
-- April         47,092,720.97
-- May           61,176,468.22
-- June          58,792,398.43
-- July          35,754,842.73
-- August        30,989,900.83
-- September     31,958,584.81
-- October       54,859,508.81
-- November      59,578,783.14
-- December      63,535,199.70


-- QUESTION 5: Merchant Activation Rate
WITH first_transactions AS (
    SELECT
        m.merchant_id,
        m.business_name,
        m.onboarded_date,
        MIN(t.transaction_date) AS first_transaction_date,
        DATEDIFF(DAY, m.onboarded_date, MIN(t.transaction_date)) AS days_to_activate
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
    WHERE t.status = 'successful'
    GROUP BY m.merchant_id, m.business_name, m.onboarded_date
)
SELECT
    COUNT(*) AS total_merchants,
    SUM(CASE WHEN days_to_activate <= 30 THEN 1 ELSE 0 END) AS activated_within_30_days,
    CAST(SUM(CASE WHEN days_to_activate <= 30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS activation_rate_pct
FROM first_transactions

-- Results:
-- total_merchants: 30
-- activated_within_30_days: 30
-- activation_rate_pct: 100.00%


-- QUESTION 6: Industry Performance — Volume & Failure Rate
SELECT
    m.industry,
    SUM(t.amount) AS total_volume,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN t.status = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
    CAST(SUM(CASE WHEN t.status = 'failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS failure_rate_pct
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.industry
ORDER BY total_volume DESC

-- Results:
-- Manufacturing     42,091,645,436    5,423    563    10.38%
-- Logistics         32,579,801,549    5,120    556    10.86%
-- Retail             2,414,565,626    2,453    243     9.91%
-- Real Estate        2,222,586,829    1,847    186    10.07%
-- Healthcare         2,216,079,240    1,797    190    10.57%
-- Education          1,711,093,937    1,721    165     9.59%
-- Food & Beverage    1,698,475,630    1,748    174     9.95%
-- Media              1,400,167,801      969    102    10.53%


-- QUESTION 7: Month-on-Month Revenue Growth Rate
WITH monthly_revenue AS (
    SELECT
        MONTH(transaction_date) AS month_number,
        DATENAME(MONTH, transaction_date) AS month_name,
        SUM(fee_charged) AS total_revenue
    FROM transactions
    GROUP BY MONTH(transaction_date), DATENAME(MONTH, transaction_date)
)
SELECT
    month_name,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month_number) AS prev_month_revenue,
    CAST((total_revenue - LAG(total_revenue) OVER (ORDER BY month_number))
        * 100.0 / LAG(total_revenue) OVER (ORDER BY month_number) AS DECIMAL(5,2)) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month_number

-- Results:
-- January       26,093,594    NULL          NULL
-- February      39,567,990    26,093,594    +51.64%
-- March         51,052,192    39,567,990    +29.02%
-- April         47,092,720    51,052,192     -7.76%
-- May           61,176,468    47,092,720    +29.91%
-- June          58,792,398    61,176,468     -3.90%
-- July          35,754,842    58,792,398    -39.18%
-- August        30,989,900    35,754,842    -13.33%
-- September     31,958,584    30,989,900     +3.13%
-- October       54,859,508    31,958,584    +71.66%
-- November      59,578,783    54,859,508     +8.60%
-- December      63,535,199    59,578,783     +6.64%


-- QUESTION 8: Merchant Churn Detection
WITH active_h1 AS (
    SELECT DISTINCT merchant_id
    FROM transactions
    WHERE status = 'successful'
    AND MONTH(transaction_date) BETWEEN 1 AND 6
),
active_q4 AS (
    SELECT DISTINCT merchant_id
    FROM transactions
    WHERE status = 'successful'
    AND MONTH(transaction_date) BETWEEN 10 AND 12
)
SELECT
    m.merchant_id,
    m.business_name,
    m.industry,
    m.plan_id
FROM active_h1 h1
JOIN merchants m ON h1.merchant_id = m.merchant_id
WHERE h1.merchant_id NOT IN (SELECT merchant_id FROM active_q4)

-- Results:
-- Kaduna Grain Mills       Manufacturing    Starter
-- SkyHigh Properties       Real Estate      Growth
-- Delta Marine Freight     Logistics        Starter
-- Brilliant Minds Tutors   Education        Growth
-- TechFlow ICT Solutions   Media            Starter
-- FreshFarm Produce Ltd    Food & Beverage  Growth


-- QUESTION 9: Revenue Concentration — Pareto Analysis
WITH merchant_revenue AS (
    SELECT
        m.merchant_id,
        m.business_name,
        SUM(t.fee_charged) AS revenue
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
    GROUP BY m.merchant_id, m.business_name
),
quintiles AS (
    SELECT
        merchant_id,
        business_name,
        revenue,
        NTILE(5) OVER (ORDER BY revenue DESC) AS quintile
    FROM merchant_revenue
)
SELECT
    quintile,
    COUNT(*) AS merchant_count,
    SUM(revenue) AS total_revenue,
    CAST(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER() AS DECIMAL(5,2)) AS revenue_share_pct
FROM quintiles
GROUP BY quintile
ORDER BY quintile

-- Results:
-- Quintile 1 (top 20%)      6 merchants    514,479,355    91.80%
-- Quintile 2                6 merchants     33,846,710     6.04%
-- Quintile 3                6 merchants      9,803,477     1.75%
-- Quintile 4                6 merchants      1,944,567     0.35%
-- Quintile 5 (bottom 20%)   6 merchants        378,073     0.07%


-- QUESTION 10: Lost Revenue from Failed Transactions
WITH failed_revenue AS (
    SELECT
        t.payment_method,
        t.amount,
        p.transaction_fee_pct,
        t.amount * p.transaction_fee_pct / 100 AS lost_fee
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
    JOIN plans p ON m.plan_id = p.plan_id
    WHERE t.status = 'failed'
)
SELECT
    payment_method,
    COUNT(*) AS failed_transactions,
    SUM(amount) AS failed_volume,
    CAST(SUM(lost_fee) AS DECIMAL(15,2)) AS lost_fee_revenue
FROM failed_revenue
GROUP BY payment_method
ORDER BY lost_fee_revenue DESC

-- Results:
-- card            953    3,946,141,291    29,658,093.24
-- ussd            534    2,233,354,450    16,737,878.00
-- mobile_money    412    1,699,604,165    12,792,347.03
-- bank_transfer   280    1,163,831,909     8,670,599.39
-- TOTAL         2,179    9,042,931,815    67,858,917.66
