CREATE TABLE public.accounts (
account_id TEXT PRIMARY KEY,
account_name TEXT,
industry TEXT,
country TEXT,
signup_date date,
referral_source TEXT,
plan_tier TEXT,
seats INT,
is_trial BOOLEAN,
churn_flag BOOLEAN
);

CREATE TABLE public.churn_events (
churn_events_id TEXT PRIMARY KEY,
account_id TEXT REFERENCES public.accounts(account_id),
churn_date date,
reason_code TEXT,
refund_amount_usd NUMERIC(10, 2),
preceding_upgrade_flag BOOLEAN,
preceding_downgrade_flag BOOLEAN,
is_reactivation BOOLEAN,
feedback_text TEXT
);

CREATE TABLE public.subscriptions(
subscription_id TEXT PRIMARY KEY,
account_id TEXT REFERENCES public.accounts(account_id),
start_date date,
end_date date, 
plan_tier TEXT,
seats NUMERIC(10, 2),
mrr_amount NUMERIC(10, 2),
arr_amount NUMERIC(10, 2),
is_trial BOOLEAN,
upgrade_flag BOOLEAN,
downgrade_flag BOOLEAN,
churn_flag BOOLEAN,
billing_frequency TEXT,
auto_renew_flag BOOLEAN
);

CREATE TABLE public.feature_usage (
usage_id TEXT,
subscription_id TEXT REFERENCES public.subscriptions(subscription_id),
usage_date date,
feature_name TEXT,
usage_count INT,
usage_duration_secs INT,
error_count INT,
is_beta_feature BOOLEAN
);

CREATE TABLE public.support_tickets (
ticket_id TEXT PRIMARY KEY,
account_id TEXT REFERENCES public.accounts(account_id),
submitted_at date, 
closed_at date, 
resolution_time_hours NUMERIC(10, 2),
priority TEXT,
first_response_time_minutes INT,
satisfaction_score NUMERIC(10, 2),
escalation_flag BOOLEAN
);
