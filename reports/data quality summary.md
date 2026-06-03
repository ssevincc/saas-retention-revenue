# Data Quality Summary

## Project Snapshot
This project uses a synthetic SaaS subscription dataset to analyze customer retention, recurring revenue, churn behavior, product usage, and support experience.

The dataset was imported into PostgreSQL and organized into five core tables:

| Table | Purpose |
|---|---|
| `accounts` | Customer/company profile information, signup details, plan tier, trial status, and churn flag |
| `subscriptions` | Subscription lifecycle data, billing frequency, MRR, ARR, upgrades, downgrades, and churn status |
| `churn_events` | Detailed churn records including churn date, reason, refunds, reactivation, and pre-churn behavior |
| `feature_usage` | Product engagement data including feature usage, usage duration, and error counts |
| `support_tickets` | Customer support interactions, response time, resolution time, satisfaction score, and escalation status |

## Data Volume

| Table | Row Count |
|---|---:|
| `accounts` | [500] |
| `subscriptions` | [5000] |
| `churn_events` | [600] |
| `feature_usage` | [25000] |
| `support_tickets` | [2000] |

## Database Design Decisions
The dataset was modeled as a relational PostgreSQL database.

## Key Findings From Data Validation
The imported dataset was generally clean and ready for analysis.

Main validation findings:

- Core account, subscription, churn, feature usage, and support tables were imported successfully.
- Critical join fields were available for connecting the tables.
- No duplicate primary IDs were found in the main account, subscription, churn event, or support ticket tables.
- The `feature_usage` table contained duplicate `usage_id` values, so a separate surrogate key was used to preserve every usage record while maintaining row-level uniqueness.
- Date fields were suitable for time-based analysis, including subscription start dates, end dates, churn dates, and support ticket timelines.
- Revenue fields were usable for MRR, ARR, churned revenue, and refund analysis.
- Support and usage fields were available for deeper churn investigation.

## Why This Matters
The data quality process confirmed that the dataset can support reliable business analysis across three major areas:

1. **Revenue analytics**
   - MRR
   - ARR
   - revenue by plan tier
   - revenue by industry
   - churned revenue

2. **Customer retention analytics**
   - churn rate
   - churn by segment
   - churn reasons
   - churn trends over time

3. **Behavioral churn analysis**
   - feature usage patterns
   - support satisfaction
   - escalation behavior
   - pre-churn account activity

## Final Assessment
It contains enough relational depth to demonstrate joins, aggregations, data validation, revenue metrics, churn analysis, and customer behavior analysis.

After validation, the dataset was considered ready for revenue and churn analysis.