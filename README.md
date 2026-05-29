# Customer Churn & Revenue Risk Analysis

**Tools:** SQL (MySQL) · Python (scikit-learn) · Tableau · Excel
**Timeline:** October 2023 – December 2023

---

## Overview

Built a complete end-to-end churn analytics pipeline for a subscription-based business — from raw data in a normalized MySQL database through SQL risk modeling, Python machine learning scoring, an interactive Tableau dashboard, and an Excel executive summary with a live what-if scenario model.

The dataset covers 20 customers across Enterprise, Mid-Market, and SMB segments generating **$46,705 in active monthly recurring revenue**. Of the 20 customers, 8 churned (40% overall churn rate), representing **$4,855 in lost monthly revenue**.

---

## Live Dashboard
[View Interactive Dashboard on Tableau Public](https://public.tableau.com/views/ChurnRiskDashboard/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## Key Findings

- **Usage score is the #1 churn predictor.** Churned customers averaged a usage score of 13.1 vs 81.5 for active customers — a 6x gap. No churned customer scored above 19. No active customer scored below 47.
- **Billing tickets are 100% correlated with churn.** Every churned customer had billing support tickets with satisfaction scores of 2 or below. Every active customer had zero billing tickets.
- **Contract type perfectly predicts retention.** All 8 churned customers were on monthly contracts. All 7 annual contract customers remain active with 0% churn.
- **Enterprise is completely healthy, risk is concentrated in SMB and Mid-Market.** Enterprise churn rate: 0%. Mid-Market: 57.1%. SMB: 66.7%.
- **Reducing churn from 40% to 25% recovers $93,410 in annual revenue.** Cutting to 15% delivers $280,230 over 3 years.

---

## Project Structure

```
├── Churn-Analysis_create_database.sql   # Creates 4-table schema and inserts all data
├── Churn-Analysis_queries.sql           # 15+ SQL queries across 5 analytical sections
├── Churn_Executive_Summary.xlsx         # 4-tab Excel executive summary with what-if model
└── ChurnProject Files/
    ├── Churn-Analysis_churn_model.py    # Logistic regression churn scoring model
    ├── churn_master.csv                 # SQL master export — model input
    ├── churn_scored.csv                 # Model output with churn probabilities
    └── Churn Risk Dashboard.twb         # Tableau dashboard workbook
```

---

## Database Schema

| Table | Rows | Description |
|---|---|---|
| customers | 20 | Account profiles — segment, region, industry, account manager |
| subscriptions | 20 | Plan, MRR, contract type, churn status per customer |
| support_tickets | 32 | Support interactions with category, priority, satisfaction score |
| product_usage | 60 | Monthly behavioral metrics — logins, features used, usage score |

---

## SQL Analysis (5 sections)

| Section | What it does |
|---|---|
| 1 — Revenue Overview | MRR/ARR by segment and plan, revenue lost to churn, churn rate by segment |
| 2 — Churn Risk Signals | Usage trend analysis, billing ticket flags, CRITICAL/HIGH/MEDIUM/LOW risk classification |
| 3 — Customer Health Score | Composite score weighted: usage 50%, satisfaction 30%, tenure 20% |
| 4 — Usage Trend Analysis | Active vs churned usage comparison — avg score 81.5 vs 13.1 |
| 5 — Master Export | Single query joining all 4 tables → churn_master.csv for Python |

---

## Python Model

**File:** `Churn-Analysis_churn_model.py`
**Library:** scikit-learn LogisticRegression

**7 input features extracted from SQL:**
- `avg_usage_score` — composite product engagement score (0–100)
- `avg_logins` — monthly login frequency
- `avg_features_used` — product breadth of use
- `billing_tickets` — count of billing-category support tickets
- `avg_satisfaction` — support satisfaction score (1–5)
- `tenure_years` — length of customer relationship
- `monthly_revenue` — contract value

**Output:** `churn_scored.csv` — adds `churn_probability` (0–1) and `model_risk_label` to every customer row. All 8 churned customers scored Critical (0.877–0.983). All 12 active customers scored Low (0.005–0.127).

---

## Tableau Dashboard (4 sheets)

| Sheet | Chart type | What it shows |
|---|---|---|
| Revenue Overview | Stacked bar | MRR by segment split Active vs Churned |
| Churn Risk Heatmap | Colored matrix | Revenue concentration by segment × region with risk filter |
| Customer Health Scatter | Scatter plot | Every customer plotted usage score vs churn probability, sized by MRR |
| Usage by Risk Tier | Horizontal bar | Avg usage score per risk tier — Active vs Churned |

Dashboard includes a filter action — clicking any cell on the heatmap filters all 4 charts simultaneously.

---

## Excel Executive Summary (4 tabs)

| Tab | Contents |
|---|---|
| Summary | 4 KPI cards + full metrics table + model source note |
| Revenue Breakdown | MRR by plan, churn rate by segment, bar and pie charts |
| At-Risk Customers | All 20 accounts sorted by risk level then MRR, color coded, with annual revenue at risk |
| What-If Model | Change one input (target churn rate) → outputs update: customers retained, MRR recovered, annual and 3-year revenue impact |

**What-If Model at 25% target churn rate:**
- Customers retained: 2
- MRR recovered: $7,784/month
- Annual revenue recovered: $93,410
- 3-year revenue impact: $280,230

---

## How to Run

**SQL:**
```sql
-- 1. Open Churn-Analysis_create_database.sql in MySQL Workbench
-- 2. Uncomment the first two lines and run the file
CREATE DATABASE churn_analysis;
USE churn_analysis;
-- 3. Verify: SELECT COUNT(*) FROM product_usage; -- should return 60
-- 4. Open Churn-Analysis_queries.sql, run Section 5, export as churn_master.csv
```

**Python:**
```bash
# Place churn_master.csv and churn_model.py in the same folder
pip3 install pandas scikit-learn
python3 Churn-Analysis_churn_model.py
# Output: churn_scored.csv
```

**Tableau:**
```
Open Tableau → Connect → Text File → churn_scored.csv
Open Churn Risk Dashboard.twb
```

---
