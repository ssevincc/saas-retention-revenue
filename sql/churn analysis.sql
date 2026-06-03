-- =====================================================
-- 1. Overall account churn rate
-- Measure the percentage of accounts that churned.
-- =====================================================

SELECT
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    SUM(CASE WHEN churn_flag = FALSE THEN 1 ELSE 0 END) AS retained_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts;


-- =====================================================
-- 2. Churn by plan tier
-- Identify which plans have the highest churn rates.
-- =====================================================

SELECT
    plan_tier,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts
GROUP BY plan_tier
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 3. Churn by industry
-- Find industries with above-average churn.
-- =====================================================

SELECT
    industry,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts
GROUP BY industry
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 4. Churn by country
-- Compare churn rates across countries.
-- =====================================================

SELECT
    country,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts
GROUP BY country
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 5. Churn by referral source
-- Evaluate which acquisition sources bring less-retained customers.
-- =====================================================

SELECT
    referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts
GROUP BY referral_source
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 6. Monthly churn events
-- Track churn volume over time.
-- =====================================================

SELECT
    DATE_TRUNC('month', churn_date)::date AS churn_month,
    COUNT(*) AS churn_events
FROM public.churn_events
GROUP BY DATE_TRUNC('month', churn_date)::date
ORDER BY churn_month;


-- =====================================================
-- 7. Churn reasons
-- Identify the most common cancellation reasons.
-- =====================================================

SELECT
    reason_code,
    COUNT(*) AS churn_events,
    ROUND(SUM(refund_amount_usd), 2) AS total_refunds,
    ROUND(AVG(refund_amount_usd), 2) AS avg_refund
FROM public.churn_events
GROUP BY reason_code
ORDER BY churn_events DESC;


-- =====================================================
-- 8. MRR lost from churned subscriptions
-- Estimate revenue associated with churned subscriptions.
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
-- 9. Churn by trial status
-- Compare churn between trial and non-trial accounts.
-- =====================================================

SELECT
    is_trial,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts
GROUP BY is_trial
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 10. Churn by billing frequency
-- Compare churn between monthly and annual billing.
-- =====================================================

SELECT
    billing_frequency,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS subscription_churn_rate_pct
FROM public.subscriptions
GROUP BY billing_frequency
ORDER BY subscription_churn_rate_pct DESC;


-- =====================================================
-- 11. Churn by upgrade/downgrade behavior
-- Understand whether plan movement is associated with churn.
-- =====================================================

SELECT
    upgrade_flag,
    downgrade_flag,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS subscription_churn_rate_pct
FROM public.subscriptions
GROUP BY upgrade_flag, downgrade_flag
ORDER BY subscription_churn_rate_pct DESC;


-- =====================================================
-- 12. Churn events with preceding upgrade/downgrade
-- Analyze whether churn happened after account plan changes.
-- =====================================================

SELECT
    preceding_upgrade_flag,
    preceding_downgrade_flag,
    COUNT(*) AS churn_events,
    ROUND(SUM(refund_amount_usd), 2) AS total_refunds
FROM public.churn_events
GROUP BY preceding_upgrade_flag, preceding_downgrade_flag
ORDER BY churn_events DESC;


-- =====================================================
-- 13. Feature usage comparison: churned vs retained accounts
-- Compare product usage behavior between churned and retained customers.
-- =====================================================

SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(f.usage_id) AS total_usage_records,
    ROUND(AVG(f.usage_count), 2) AS avg_usage_count,
    ROUND(AVG(f.usage_duration_secs), 2) AS avg_usage_duration_secs,
    ROUND(AVG(f.error_count), 2) AS avg_error_count
FROM public.accounts a
JOIN public.subscriptions s
    ON a.account_id = s.account_id
JOIN public.feature_usage f
    ON s.subscription_id = f.subscription_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;


-- =====================================================
-- 14. Top features used by churned accounts
-- Identify which features churned accounts used most often.
-- =====================================================

SELECT
    f.feature_name,
    COUNT(*) AS usage_records,
    ROUND(SUM(f.usage_count), 2) AS total_usage_count,
    ROUND(AVG(f.error_count), 2) AS avg_error_count
FROM public.feature_usage f
JOIN public.subscriptions s
    ON f.subscription_id = s.subscription_id
JOIN public.accounts a
    ON s.account_id = a.account_id
WHERE a.churn_flag = TRUE
GROUP BY f.feature_name
ORDER BY total_usage_count DESC;


-- =====================================================
-- 15. Support ticket comparison: churned vs retained accounts
-- Compare support experience between churned and retained customers.
-- =====================================================

SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(t.ticket_id) AS total_tickets,
    ROUND(AVG(t.resolution_time_hours), 2) AS avg_resolution_time_hours,
    ROUND(AVG(t.first_response_time_minutes), 2) AS avg_first_response_time_minutes,
    ROUND(AVG(t.satisfaction_score), 2) AS avg_satisfaction_score,
    SUM(CASE WHEN t.escalation_flag = TRUE THEN 1 ELSE 0 END) AS escalated_tickets
FROM public.accounts a
LEFT JOIN public.support_tickets t
    ON a.account_id = t.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;


-- =====================================================
-- 16. Churn rate by support satisfaction group
-- Check whether lower support satisfaction is linked to churn.
-- =====================================================

WITH account_support AS (
    SELECT
        a.account_id,
        a.churn_flag,
        AVG(t.satisfaction_score) AS avg_satisfaction_score
    FROM public.accounts a
    LEFT JOIN public.support_tickets t
        ON a.account_id = t.account_id
    GROUP BY a.account_id, a.churn_flag
)

SELECT
    CASE
        WHEN avg_satisfaction_score IS NULL THEN 'No Support Tickets'
        WHEN avg_satisfaction_score < 3 THEN 'Low Satisfaction'
        WHEN avg_satisfaction_score < 4 THEN 'Medium Satisfaction'
        ELSE 'High Satisfaction'
    END AS satisfaction_group,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM account_support
GROUP BY satisfaction_group
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 17. Churn rate by product usage level
-- Segment accounts by product usage and compare churn rates.
-- =====================================================

WITH account_usage AS (
    SELECT
        a.account_id,
        a.churn_flag,
        COALESCE(SUM(f.usage_count), 0) AS total_usage_count
    FROM public.accounts a
    LEFT JOIN public.subscriptions s
        ON a.account_id = s.account_id
    LEFT JOIN public.feature_usage f
        ON s.subscription_id = f.subscription_id
    GROUP BY a.account_id, a.churn_flag
)

SELECT
    CASE
        WHEN total_usage_count = 0 THEN 'No Usage'
        WHEN total_usage_count < 100 THEN 'Low Usage'
        WHEN total_usage_count < 500 THEN 'Medium Usage'
        ELSE 'High Usage'
    END AS usage_group,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM account_usage
GROUP BY usage_group
ORDER BY churn_rate_pct DESC;


-- =====================================================
-- 18. Accounts with churn events but account churn_flag is false
-- Identify possible consistency issues between churn_events and account flags.
-- =====================================================

SELECT
    a.account_id,
    a.account_name,
    a.churn_flag,
    COUNT(c.churn_events_id) AS churn_event_count
FROM public.accounts a
JOIN public.churn_events c
    ON a.account_id = c.account_id
WHERE a.churn_flag = FALSE
GROUP BY a.account_id, a.account_name, a.churn_flag
ORDER BY churn_event_count DESC;


-- =====================================================
-- 19. Churned accounts without churn event records
-- Identify churned accounts missing detailed churn event data.
-- =====================================================

SELECT
    a.account_id,
    a.account_name,
    a.plan_tier,
    a.churn_flag
FROM public.accounts a
LEFT JOIN public.churn_events c
    ON a.account_id = c.account_id
WHERE a.churn_flag = TRUE
  AND c.churn_events_id IS NULL;


-- =====================================================
-- 20. Churn summary by plan tier and billing frequency
-- Combine plan and billing behavior to find high-risk subscription groups.
-- =====================================================

SELECT
    s.plan_tier,
    s.billing_frequency,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN s.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        SUM(CASE WHEN s.churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS subscription_churn_rate_pct,
    ROUND(SUM(CASE WHEN s.churn_flag = TRUE THEN s.mrr_amount ELSE 0 END), 2) AS churned_mrr
FROM public.subscriptions s
GROUP BY s.plan_tier, s.billing_frequency
ORDER BY subscription_churn_rate_pct DESC, churned_mrr DESC;