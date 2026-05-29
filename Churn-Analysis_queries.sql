-- ============================================================
-- PROJECT 2: Customer Churn & Revenue Risk Analysis
-- File: analysis_queries.sql
-- Description: All SQL queries used in the analysis.
--              Add USE churn_analysis; at the top before running.
--              Results feed into Python, Tableau, and Excel.
-- ============================================================

USE churn_analysis;

-- ============================================================
-- SECTION 1: REVENUE OVERVIEW
-- Tableau Sheet: "Revenue Overview"
-- Excel Tab: "Executive Summary"
-- ============================================================

-- 1A. Total MRR (Monthly Recurring Revenue) by segment and status
SELECT
    c.segment,
    s.status,
    COUNT(DISTINCT c.customer_id)               AS customer_count,
    SUM(s.monthly_revenue)                      AS total_mrr,
    ROUND(AVG(s.monthly_revenue), 2)            AS avg_mrr_per_customer
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.segment, s.status
ORDER BY c.segment, s.status;

-- 1B. MRR at risk — active customers by plan, showing revenue exposure
SELECT
    s.plan_name,
    s.contract_type,
    COUNT(*)                                    AS active_customers,
    SUM(s.monthly_revenue)                      AS mrr,
    SUM(s.monthly_revenue * 12)                 AS arr
FROM subscriptions s
WHERE s.status = 'Active'
GROUP BY s.plan_name, s.contract_type
ORDER BY mrr DESC;

-- 1C. Revenue lost to churn — total and by segment
SELECT
    c.segment,
    COUNT(*)                                    AS churned_customers,
    SUM(s.monthly_revenue)                      AS lost_mrr,
    SUM(s.monthly_revenue * 12)                 AS lost_arr_equivalent
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
WHERE s.status = 'Churned'
GROUP BY c.segment
ORDER BY lost_mrr DESC;

-- 1D. Churn rate by segment
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)               AS total_customers,
    SUM(CASE WHEN s.status = 'Churned' THEN 1 ELSE 0 END) AS churned,
    SUM(CASE WHEN s.status = 'Active'  THEN 1 ELSE 0 END) AS active,
    ROUND(
        SUM(CASE WHEN s.status = 'Churned' THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT c.customer_id), 1
    )                                           AS churn_rate_pct
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.segment
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- SECTION 2: CHURN RISK SIGNALS
-- Tableau Sheet: "Churn Risk"
-- Python: churn_model.py uses the master export from Section 5
-- ============================================================

-- 2A. Support ticket volume and avg satisfaction per customer
--     High ticket volume + low satisfaction = churn signal
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    s.status,
    s.monthly_revenue,
    COUNT(t.ticket_id)                          AS total_tickets,
    SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) AS billing_tickets,
    ROUND(AVG(t.satisfaction_score), 2)         AS avg_satisfaction,
    MIN(t.satisfaction_score)                   AS min_satisfaction
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name, c.segment, s.status, s.monthly_revenue
ORDER BY billing_tickets DESC, avg_satisfaction ASC;

-- 2B. Usage trend — last 3 months avg usage score per customer
--     Declining usage score is the strongest churn predictor
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    s.status,
    s.monthly_revenue,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    MIN(u.usage_score)                          AS min_usage_score,
    MAX(u.usage_score)                          AS max_usage_score,
    ROUND(MAX(u.usage_score) - MIN(u.usage_score), 1) AS usage_score_drop,
    ROUND(AVG(u.login_count), 1)                AS avg_logins,
    ROUND(AVG(u.features_used), 1)              AS avg_features_used
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN product_usage u ON c.customer_id = u.customer_id
GROUP BY c.customer_id, c.full_name, c.segment, s.status, s.monthly_revenue
ORDER BY avg_usage_score ASC;

-- 2C. Customers with BOTH low usage AND billing tickets — highest risk
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    c.region,
    s.status,
    s.monthly_revenue,
    s.contract_type,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    COUNT(t.ticket_id)                          AS total_tickets,
    SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) AS billing_tickets,
    ROUND(AVG(t.satisfaction_score), 1)         AS avg_satisfaction,
    CASE
        WHEN AVG(u.usage_score) < 20
         AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 2
        THEN 'CRITICAL'
        WHEN AVG(u.usage_score) < 40
         AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 1
        THEN 'HIGH'
        WHEN AVG(u.usage_score) < 60
        THEN 'MEDIUM'
        ELSE 'LOW'
    END                                         AS risk_level
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN product_usage u ON c.customer_id = u.customer_id
LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name, c.segment, c.region,
         s.status, s.monthly_revenue, s.contract_type
ORDER BY
    FIELD(risk_level,'CRITICAL','HIGH','MEDIUM','LOW'),
    s.monthly_revenue DESC;

-- 2D. Revenue at risk by risk level — for executive summary
SELECT
    risk_data.risk_level,
    COUNT(*)                                    AS customers,
    SUM(risk_data.monthly_revenue)              AS mrr_at_risk,
    SUM(risk_data.monthly_revenue * 12)         AS arr_at_risk
FROM (
    SELECT
        c.customer_id,
        s.monthly_revenue,
        CASE
            WHEN AVG(u.usage_score) < 20
             AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 2
            THEN 'CRITICAL'
            WHEN AVG(u.usage_score) < 40
             AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 1
            THEN 'HIGH'
            WHEN AVG(u.usage_score) < 60
            THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
    JOIN product_usage u ON c.customer_id = u.customer_id
    LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
    WHERE s.status = 'Active'
    GROUP BY c.customer_id, s.monthly_revenue
) AS risk_data
GROUP BY risk_data.risk_level
ORDER BY FIELD(risk_data.risk_level,'CRITICAL','HIGH','MEDIUM','LOW');


-- ============================================================
-- SECTION 3: CUSTOMER HEALTH SCORING
-- Tableau Sheet: "Customer Health"
-- ============================================================

-- 3A. Composite customer health score
--     Combines usage, support satisfaction, and tenure
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    c.region,
    c.industry,
    c.account_manager,
    s.plan_name,
    s.monthly_revenue,
    s.contract_type,
    s.status,
    DATEDIFF(CURDATE(), c.signup_date) / 365.0  AS tenure_years,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    ROUND(AVG(t.satisfaction_score), 2)         AS avg_support_satisfaction,
    COUNT(t.ticket_id)                          AS lifetime_tickets,
    -- Health score: weighted combination
    ROUND(
        (AVG(u.usage_score) * 0.5)
      + (COALESCE(AVG(t.satisfaction_score), 3) * 10 * 0.3)
      + (LEAST(DATEDIFF(CURDATE(), c.signup_date) / 365.0, 5) * 4 * 0.2),
        1
    )                                           AS health_score,
    CASE
        WHEN (AVG(u.usage_score) * 0.5)
           + (COALESCE(AVG(t.satisfaction_score), 3) * 10 * 0.3)
           + (LEAST(DATEDIFF(CURDATE(), c.signup_date) / 365.0, 5) * 4 * 0.2) >= 75
        THEN 'Healthy'
        WHEN (AVG(u.usage_score) * 0.5)
           + (COALESCE(AVG(t.satisfaction_score), 3) * 10 * 0.3)
           + (LEAST(DATEDIFF(CURDATE(), c.signup_date) / 365.0, 5) * 4 * 0.2) >= 50
        THEN 'At Risk'
        ELSE 'Critical'
    END                                         AS health_status
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN product_usage u ON c.customer_id = u.customer_id
LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name, c.segment, c.region, c.industry,
         c.account_manager, s.plan_name, s.monthly_revenue,
         s.contract_type, s.status
ORDER BY health_score ASC;

-- 3B. Health score summary by account manager
--     Who is managing the riskiest accounts?
SELECT
    c.account_manager,
    COUNT(DISTINCT c.customer_id)               AS customers_managed,
    SUM(s.monthly_revenue)                      AS total_mrr_managed,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    ROUND(AVG(t.satisfaction_score), 2)         AS avg_satisfaction,
    SUM(CASE WHEN s.status = 'Churned' THEN 1 ELSE 0 END) AS churned_accounts
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN product_usage u ON c.customer_id = u.customer_id
LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
GROUP BY c.account_manager
ORDER BY avg_usage_score ASC;


-- ============================================================
-- SECTION 4: USAGE TREND ANALYSIS
-- Tableau Sheet: "Usage Trends"
-- ============================================================

-- 4A. Monthly usage trend — active vs churned customers
SELECT
    DATE_FORMAT(u.usage_month, '%Y-%m')         AS month,
    s.status,
    COUNT(DISTINCT u.customer_id)               AS customers,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    ROUND(AVG(u.login_count), 1)                AS avg_logins,
    ROUND(AVG(u.features_used), 1)              AS avg_features_used,
    ROUND(AVG(u.api_calls), 0)                  AS avg_api_calls
FROM product_usage u
JOIN subscriptions s ON u.customer_id = s.customer_id
GROUP BY DATE_FORMAT(u.usage_month, '%Y-%m'), s.status
ORDER BY month, s.status;

-- 4B. Usage score 3 months before churn vs 3 months for active customers
--     This is the key insight — shows the usage cliff before churn
SELECT
    s.status,
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    ROUND(AVG(u.login_count), 1)                AS avg_logins,
    ROUND(AVG(u.api_calls), 0)                  AS avg_api_calls,
    ROUND(AVG(u.features_used), 1)              AS avg_features
FROM subscriptions s
JOIN product_usage u ON s.customer_id = u.customer_id
GROUP BY s.status
ORDER BY avg_usage_score DESC;


-- ============================================================
-- SECTION 5: MASTER EXPORT FOR PYTHON & TABLEAU
-- Save as: churn_master.csv
-- This single file feeds the Python churn model AND Tableau.
-- ============================================================

SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    c.region,
    c.industry,
    c.account_manager,
    DATEDIFF(CURDATE(), c.signup_date) / 365.0  AS tenure_years,
    s.plan_name,
    s.monthly_revenue,
    s.contract_type,
    s.status,
    CASE WHEN s.status = 'Churned' THEN 1 ELSE 0 END AS churned,
    -- Usage features
    ROUND(AVG(u.usage_score), 1)                AS avg_usage_score,
    ROUND(AVG(u.login_count), 1)                AS avg_logins,
    ROUND(AVG(u.features_used), 1)              AS avg_features_used,
    ROUND(AVG(u.api_calls), 0)                  AS avg_api_calls,
    ROUND(MAX(u.usage_score) - MIN(u.usage_score), 1) AS usage_score_drop,
    -- Support features
    COUNT(DISTINCT t.ticket_id)                 AS total_tickets,
    SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) AS billing_tickets,
    ROUND(AVG(t.satisfaction_score), 2)         AS avg_satisfaction,
    -- Risk flag
    CASE
        WHEN AVG(u.usage_score) < 20
         AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 2
        THEN 'CRITICAL'
        WHEN AVG(u.usage_score) < 40
         AND SUM(CASE WHEN t.category = 'Billing' THEN 1 ELSE 0 END) >= 1
        THEN 'HIGH'
        WHEN AVG(u.usage_score) < 60
        THEN 'MEDIUM'
        ELSE 'LOW'
    END                                         AS risk_level
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN product_usage u ON c.customer_id = u.customer_id
LEFT JOIN support_tickets t ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id, c.full_name, c.segment, c.region, c.industry,
    c.account_manager, c.signup_date, s.plan_name, s.monthly_revenue,
    s.contract_type, s.status
ORDER BY avg_usage_score ASC;
