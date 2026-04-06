# SwiftPay Africa — Revenue & Growth Analysis

## Project Overview

SwiftPay Africa is a fictional B2B payment infrastructure company based in Lagos, Nigeria. This project analyses SwiftPay's full-year 2023 transaction data to uncover revenue trends, identify commercial risks, and deliver actionable recommendations — the kind of analysis a Revenue or Growth Analyst would present to a client or senior leadership.

The entire analysis was performed using **SQL Server 2019** across a dataset of 21,000+ transactions.

---

## Dataset

| Table | Description | Rows |
|---|---|---|
| `plans` | Subscription tiers and fee structure | 4 |
| `merchants` | All onboarded businesses | 30 |
| `transactions` | Every payment processed in 2023 | 21,078 |
| `settlements` | Fund disbursements back to merchants | 326 |

---

## Key Findings

1. **Extreme revenue concentration** — The top 20% of merchants generate 91.8% of all fee revenue. Just 2 Enterprise merchants account for over 80% of total revenue
2. **Card payment failure rate** — Card payments fail at 17.96%, more than 3x the rate of bank transfers at 5.34%
3. **Q3 revenue dip** — Revenue dropped 39% in July, the single largest monthly decline of the year
4. **Merchant churn** — 6 of 28 active H1 merchants had zero transactions by Q4, a 21% churn rate
5. **Lost revenue from failures** — SwiftPay lost NGN 67.8 million in fee revenue due to failed transactions — 12% of actual earned revenue
6. **Strong Q4 recovery** — October recorded +71.66% month-on-month growth, the strongest single-month jump of the year

---

## Strategic Recommendations

| Priority | Recommendation | Expected Impact |
|---|---|---|
| 1 | Fix card payment failure rate from 17.96% to industry standard 3-5% | Recover up to NGN 22M in lost fees |
| 2 | Introduce enterprise retention programme for top 2 merchants | Protect 80% of total fee revenue |
| 3 | Launch Q3 merchant incentive campaign ahead of July dip | Reduce seasonal revenue drop |
| 4 | Build 30-day inactivity alert for Starter and Growth merchants | Reduce 21% churn rate |
| 5 | Upsell mid-tier merchants to reduce revenue concentration | Diversify away from 91.8% risk |

---

## Tools Used

- SQL Server 2019
- SQL Server Management Studio (SSMS)
