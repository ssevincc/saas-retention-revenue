# Final Insights Report

## Project Overview
This project analyzes customer retention and recurring revenue for a SaaS subscription business using PostgreSQL. The goal is to understand where revenue comes from, which customers churn, and what business patterns are associated with churn.

## Business Questions
This analysis focuses on the following questions:

1. What is the company’s total recurring revenue?
2. Which plan tiers generate the most MRR and ARR?
3. What is the overall customer churn rate?
4. Which customer segments have the highest churn?
5. What are the most common churn reasons?
6. How much recurring revenue is associated with churned customers?
7. How do product usage and support experience relate to churn?

## Revenue Findings

### Total Recurring Revenue
The company generated:

- Total MRR: `11338747`
- Total ARR: `136064964`
- Average MRR per subscription: `2267.75`

### Revenue by Plan Tier
The highest revenue-generating plan tier was `Enterprise`, contributing `8473221` in MRR.

This suggests that insert interpretation, higher-tier customers are a major driver of recurring revenue.

### Revenue by Industry
The top revenue-generating industry was FinTech, followed by DevTools.

This may indicate that the product has stronger market fit in certain industries.

### Revenue by Referral Source
The referral source with the highest total MRR was organic.

This channel may be worth further investment if it also shows strong retention.

## Churn Findings

### Overall Churn Rate
The overall account churn rate was 22%.

This means that approximately 22 out of every 100 customers churned.

### Churn by Plan Tier
The plan tier with the highest churn rate was Enterprise at 22.08%.

This may suggest that customers on this plan experience lower value, weaker onboarding, pricing concerns, or product limitations.

### Churn by Industry
The industry with the highest churn rate was DevTools.

This could indicate weaker product-market fit or different customer expectations in that segment.

### Churn by Referral Source
The referral source with the highest churn rate was `event`.

This may suggest that this acquisition channel brings in lower-quality or less committed customers.

### Churn Reasons
The most common churn reason was `features`.

Top churn reasons included:

| Reason | Churn Events |
|---|---:|
| Features | 114 |
| Support | 104 |
| Budget | 104 |

These reasons provide direction for retention strategy.

## Revenue Lost From Churn
Churned subscriptions represented:

- Churned MRR: `3252292`
- Churned ARR: `39027504`

This shows the financial impact of customer churn beyond customer count alone.

## Product Usage And Churn
Churned accounts had an average usage count of `390`, compared with `110` for retained accounts.

If churned customers had lower usage, this suggests that product engagement is an important retention signal.

## Support Experience And Churn
Churned accounts had:

- Average satisfaction score: `3.97`
- Average resolution time: `35.92`
- Escalated tickets: `71`

If churned customers had lower satisfaction or longer resolution times, support experience may be a meaningful churn driver.

## Recommendations

1. Improve onboarding for the plan tier with the highest churn rate.
2. Investigate the most common churn reason and connect it to product or pricing improvements.
3. Monitor customers with low product usage as potential churn risks.
4. Review support processes for customers with low satisfaction scores.
5. Invest more in acquisition channels that combine high revenue with low churn.
6. Track churned MRR monthly, not just customer churn count.

## Conclusion
The analysis shows that churn is not evenly distributed across customer segments. Plan tier, referral source, product usage, and support experience all provide useful signals for understanding retention. By focusing on high-churn segments and improving early customer engagement, the business can reduce revenue loss and improve long-term customer value.