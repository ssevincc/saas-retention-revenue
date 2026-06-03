=====================================================
-- 1. Record counts
-- Confirm that all CSV files were imported.
=====================================================

SELECT 'accounts' AS table_name, COUNT(*) AS row_count
FROM public.accounts

UNION ALL

SELECT 'subscriptions' AS table_name, COUNT(*) AS row_count
FROM public.subscriptions

UNION ALL

SELECT 'churn_events' AS table_name, COUNT(*) AS row_count
FROM public.churn_events

UNION ALL

SELECT 'feature_usage' AS table_name, COUNT(*) AS row_count
FROM public.feature_usage

UNION ALL

SELECT 'support_tickets' AS table_name, COUNT(*) AS row_count
FROM public.support_tickets;


-- =====================================================
-- 2. Duplicate primary IDs
-- Primary IDs should uniquely identify records.
-- =====================================================

SELECT account_id, COUNT(*) AS duplicate_count
FROM public.accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT subscription_id, COUNT(*) AS duplicate_count
FROM public.subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

SELECT churn_events_id, COUNT(*) AS duplicate_count
FROM public.churn_events
GROUP BY churn_events_id
HAVING COUNT(*) > 1;

SELECT ticket_id, COUNT(*) AS duplicate_count
FROM public.support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;


-- Feature usage note:
-- usage_id may not be unique in the raw dataset.
-- This check documents whether duplicate usage IDs exist.

SELECT usage_id, COUNT(*) AS duplicate_count
FROM public.feature_usage
GROUP BY usage_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- =====================================================
-- 3. Missing key fields
-- Important IDs and dates should not be null.
-- =====================================================

SELECT *
FROM public.accounts
WHERE account_id IS NULL
   OR signup_date IS NULL
   OR plan_tier IS NULL;

SELECT *
FROM public.subscriptions
WHERE subscription_id IS NULL
   OR account_id IS NULL
   OR start_date IS NULL;

SELECT *
FROM public.churn_events
WHERE churn_events_id IS NULL
   OR account_id IS NULL
   OR churn_date IS NULL;

SELECT *
FROM public.feature_usage
WHERE subscription_id IS NULL
   OR usage_date IS NULL
   OR feature_name IS NULL;

SELECT *
FROM public.support_tickets
WHERE ticket_id IS NULL
   OR account_id IS NULL
   OR submitted_at IS NULL;


-- =====================================================
-- 4. Foreign key relationship checks
-- Child records should connect to valid parent records.
-- =====================================================

-- Subscriptions without matching account
SELECT s.*
FROM public.subscriptions s
LEFT JOIN public.accounts a
    ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Churn events without matching account
SELECT c.*
FROM public.churn_events c
LEFT JOIN public.accounts a
    ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Feature usage without matching subscription
SELECT f.*
FROM public.feature_usage f
LEFT JOIN public.subscriptions s
    ON f.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

-- Support tickets without matching account
SELECT t.*
FROM public.support_tickets t
LEFT JOIN public.accounts a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- =====================================================
-- 5. Date validity checks
-- End dates and closed dates should not happen before start dates.
-- =====================================================

-- Subscriptions where end_date is earlier than start_date
SELECT *
FROM public.subscriptions
WHERE end_date IS NOT NULL
  AND end_date < start_date;

-- Support tickets where closed_at is earlier than submitted_at
SELECT *
FROM public.support_tickets
WHERE closed_at IS NOT NULL
  AND closed_at < submitted_at;

-- Churn events before account signup
SELECT c.*
FROM public.churn_events c
JOIN public.accounts a
    ON c.account_id = a.account_id
WHERE c.churn_date < a.signup_date;


-- =====================================================
-- 6. Numeric value checks
-- Revenue, usage, and support metrics should not contain impossible negative values.
-- =====================================================

-- Negative revenue values
SELECT *
FROM public.subscriptions
WHERE mrr_amount < 0
   OR arr_amount < 0;

-- Negative seats
SELECT *
FROM public.accounts
WHERE seats < 0;

SELECT *
FROM public.subscriptions
WHERE seats < 0;

-- Negative feature usage values
SELECT *
FROM public.feature_usage
WHERE usage_count < 0
   OR usage_duration_secs < 0
   OR error_count < 0;

-- Negative support timing values
SELECT *
FROM public.support_tickets
WHERE resolution_time_hours < 0
   OR first_response_time_minutes < 0;


-- =====================================================
-- 7. Boolean distribution checks
-- Confirm true/false fields imported correctly.
-- =====================================================

SELECT churn_flag, COUNT(*) AS account_count
FROM public.accounts
GROUP BY churn_flag
ORDER BY churn_flag;

SELECT is_trial, COUNT(*) AS account_count
FROM public.accounts
GROUP BY is_trial
ORDER BY is_trial;

SELECT churn_flag, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY churn_flag
ORDER BY churn_flag;

SELECT upgrade_flag, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY upgrade_flag
ORDER BY upgrade_flag;

SELECT downgrade_flag, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY downgrade_flag
ORDER BY downgrade_flag;

SELECT auto_renew_flag, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY auto_renew_flag
ORDER BY auto_renew_flag;


-- =====================================================
-- 8. Category distribution checks
-- Understand key categorical fields before analysis.
-- =====================================================

SELECT plan_tier, COUNT(*) AS account_count
FROM public.accounts
GROUP BY plan_tier
ORDER BY account_count DESC;

SELECT plan_tier, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY plan_tier
ORDER BY subscription_count DESC;

SELECT billing_frequency, COUNT(*) AS subscription_count
FROM public.subscriptions
GROUP BY billing_frequency
ORDER BY subscription_count DESC;

SELECT reason_code, COUNT(*) AS churn_event_count
FROM public.churn_events
GROUP BY reason_code
ORDER BY churn_event_count DESC;

SELECT priority, COUNT(*) AS ticket_count
FROM public.support_tickets
GROUP BY priority
ORDER BY ticket_count DESC;


-- =====================================================
-- 9. Revenue consistency check
-- ARR should usually equal MRR * 12 for monthly recurring revenue.
-- Small differences may exist because of rounding or business rules.
-- =====================================================

SELECT *
FROM public.subscriptions
WHERE mrr_amount IS NOT NULL
  AND arr_amount IS NOT NULL
  AND ABS(arr_amount - (mrr_amount * 12)) > 1;


-- =====================================================
-- 10. Summary checks
-- Produce simple values to document in the project.
-- =====================================================

SELECT
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM public.accounts;

SELECT
    MIN(signup_date) AS earliest_signup_date,
    MAX(signup_date) AS latest_signup_date
FROM public.accounts;

SELECT
    MIN(start_date) AS earliest_subscription_start,
    MAX(start_date) AS latest_subscription_start
FROM public.subscriptions;