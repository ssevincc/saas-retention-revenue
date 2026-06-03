-- =====================================================
-- 1. Total recurring revenue
-- Calculate total MRR and ARR across all subscriptions.
-- =====================================================

SELECT
    ROUND(SUM(mrr_amount), 2) AS total_mrr,
    ROUND(SUM(arr_amount), 2) AS total_arr,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr_per_subscription,
    ROUND(AVG(arr_amount), 2) AS avg_arr_per_subscription
FROM public.subscriptions;


-- =====================================================
-- 2. Revenue by plan tier
-- Identify which subscription plans generate the most revenue.
-- =====================================================

SELECT
    plan_tier,
    COUNT(*) AS total_subscriptions,
    COUNT(DISTINCT account_id) AS total_accounts,
    ROUND(SUM(mrr_amount), 2) AS total_mrr,
    ROUND(SUM(arr_amount), 2) AS total_arr,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr_per_subscription
FROM public.subscriptions
GROUP BY plan_tier
ORDER BY total_mrr DESC;


-- =====================================================
-- 3. Revenue by billing frequency
-- Compare revenue from monthly vs annual billing.
-- =====================================================

SELECT
    billing_frequency,
    COUNT(*) AS total_subscriptions,
    COUNT(DISTINCT account_id) AS total_accounts,
    ROUND(SUM(mrr_amount), 2) AS total_mrr,
    ROUND(SUM(arr_amount), 2) AS total_arr,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr
FROM public.subscriptions
GROUP BY billing_frequency
ORDER BY total_mrr DESC;


-- =====================================================
-- 4. Revenue by industry
-- Purpose: Find which customer industries contribute the most revenue.
-- =====================================================

SELECT
    a.industry,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(s.subscription_id) AS total_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(SUM(s.arr_amount), 2) AS total_arr,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_per_subscription
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
GROUP BY a.industry
ORDER BY total_mrr DESC;


-- =====================================================
-- 5. Revenue by country
-- Identify top revenue-generating countries.
-- =====================================================

SELECT
    a.country,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(s.subscription_id) AS total_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(SUM(s.arr_amount), 2) AS total_arr,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_per_subscription
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
GROUP BY a.country
ORDER BY total_mrr DESC;


-- =====================================================
-- 6. Revenue by referral source
-- Evaluate which acquisition channels bring the most revenue.
-- =====================================================

SELECT
    a.referral_source,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(s.subscription_id) AS total_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(SUM(s.arr_amount), 2) AS total_arr,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_per_subscription
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
GROUP BY a.referral_source
ORDER BY total_mrr DESC;


-- =====================================================
-- 7. Average revenue per account by plan tier
-- Calculate ARPA, average revenue per account.
-- =====================================================

SELECT
    s.plan_tier,
    COUNT(DISTINCT s.account_id) AS total_accounts,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(
        SUM(s.mrr_amount) / NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS avg_mrr_per_account
FROM public.subscriptions s
GROUP BY s.plan_tier
ORDER BY avg_mrr_per_account DESC;


-- =====================================================
-- 8. Revenue by churn status
-- Compare revenue from churned vs retained accounts.
-- =====================================================

SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(s.subscription_id) AS total_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_per_subscription
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;


-- =====================================================
-- 9. Revenue lost from churn
-- Estimate MRR and ARR associated with churned subscriptions.
-- =====================================================

SELECT
    COUNT(DISTINCT s.account_id) AS churned_accounts,
    COUNT(s.subscription_id) AS churned_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS churned_mrr,
    ROUND(SUM(s.arr_amount), 2) AS churned_arr
FROM public.subscriptions s
JOIN public.accounts a
    ON s.account_id = a.account_id
WHERE a.churn_flag = TRUE
   OR s.churn_flag = TRUE;


-- =====================================================
-- 10. Revenue retained from non-churned accounts
-- Estimate MRR and ARR from active/retained accounts.
-- =====================================================

SELECT
    COUNT(DISTINCT s.account_id) AS retained_accounts,
    COUNT(s.subscription_id) AS retained_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS retained_mrr,
    ROUND(SUM(s.arr_amount), 2) AS retained_arr
FROM public.subscriptions s
JOIN public.accounts a
    ON s.account_id = a.account_id
WHERE a.churn_flag = FALSE
  AND s.churn_flag = FALSE;


-- =====================================================
-- 11. Revenue by trial status
-- Compare revenue between trial and non-trial customers.
-- =====================================================

SELECT
    s.is_trial,
    COUNT(DISTINCT s.account_id) AS total_accounts,
    COUNT(s.subscription_id) AS total_subscriptions,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr
FROM public.subscriptions s
GROUP BY s.is_trial
ORDER BY total_mrr DESC;


-- =====================================================
-- 12. Monthly new MRR by subscription start month
-- Track new recurring revenue added each month.
-- =====================================================

SELECT
    DATE_TRUNC('month', start_date)::date AS subscription_start_month,
    COUNT(subscription_id) AS new_subscriptions,
    COUNT(DISTINCT account_id) AS new_accounts,
    ROUND(SUM(mrr_amount), 2) AS new_mrr
FROM public.subscriptions
GROUP BY DATE_TRUNC('month', start_date)::date
ORDER BY subscription_start_month;


-- =====================================================
-- 13. Monthly churned MRR by subscription end month
-- Estimate recurring revenue lost by month from ended or churned subscriptions.
-- =====================================================

SELECT
    DATE_TRUNC('month', end_date)::date AS subscription_end_month,
    COUNT(subscription_id) AS ended_subscriptions,
    COUNT(DISTINCT account_id) AS churned_accounts,
    ROUND(SUM(mrr_amount), 2) AS churned_mrr
FROM public.subscriptions
WHERE end_date IS NOT NULL
  AND churn_flag = TRUE
GROUP BY DATE_TRUNC('month', end_date)::date
ORDER BY subscription_end_month;


-- =====================================================
-- 14. Net MRR movement by month
-- Compare new MRR and churned MRR by month.
-- =====================================================

WITH new_mrr AS (
    SELECT
        DATE_TRUNC('month', start_date)::date AS MONTH,
        SUM(mrr_amount) AS new_mrr
    FROM public.subscriptions
    GROUP BY DATE_TRUNC('month', start_date)::date
),

churned_mrr AS (
    SELECT
        DATE_TRUNC('month', end_date)::date AS MONTH,
        SUM(mrr_amount) AS churned_mrr
    FROM public.subscriptions
    WHERE end_date IS NOT NULL
      AND churn_flag = TRUE
    GROUP BY DATE_TRUNC('month', end_date)::date
)

SELECT
    COALESCE(n.month, c.month) AS MONTH,
    ROUND(COALESCE(n.new_mrr, 0), 2) AS new_mrr,
    ROUND(COALESCE(c.churned_mrr, 0), 2) AS churned_mrr,
    ROUND(COALESCE(n.new_mrr, 0) - COALESCE(c.churned_mrr, 0), 2) AS net_mrr_change
FROM new_mrr n
FULL OUTER JOIN churned_mrr c
    ON n.month = c.month
ORDER BY MONTH;


-- =====================================================
-- 15. Top 20 accounts by MRR
-- Identify highest-value customer accounts.
-- =====================================================

SELECT
    a.account_id,
    a.account_name,
    a.industry,
    a.country,
    a.referral_source,
    a.plan_tier,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr,
    ROUND(SUM(s.arr_amount), 2) AS total_arr,
    COUNT(s.subscription_id) AS total_subscriptions
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
GROUP BY
    a.account_id,
    a.account_name,
    a.industry,
    a.country,
    a.referral_source,
    a.plan_tier
ORDER BY total_mrr DESC
LIMIT 20;