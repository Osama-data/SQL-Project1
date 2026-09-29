# Restaurant Customer & Loyalty Analytics
### SQL · Window Functions · Business Rules

A compact SQL case study exploring customer spending, visit patterns, menu preferences, and loyalty eligibility. The dataset is based on [Danny Ma's Danny's Diner challenge](https://8weeksqlchallenge.com/case-study-1/); it is a learning case study, not a client engagement.

[SQL analysis](SQLP1.sql) · [Relationship diagram](Entity%20Relationship%20Diagram.png)

## Model

| Table | Purpose |
| --- | --- |
| sales | Purchased items by customer and date |
| menu | Product names and prices |
| members | Customer membership start dates |

Repeated sales rows may represent multiple purchased items. The source has no transaction ID or time-of-day column, so same-day purchases cannot be sequenced reliably.

## Skills demonstrated

- Joins and grouped aggregation for customer metrics.
- Common table expressions for readable analytical steps.
- Ranking functions for customer preferences and first/last dates.
- Explicit membership boundaries and loyalty calculations.
- Tie handling that returns all qualifying first-day items.

## Run the analysis

Use a fresh PostgreSQL development database or schema and execute `SQLP1.sql`. The script creates and populates three tables before running the analysis. It is intentionally not destructive and will fail if those tables already exist; use a new schema for a clean rerun.

The analysis now terminates each statement explicitly. First and last purchase queries retain ties, and membership eligibility starts on the join date.

## Expected checks on the included sample

| Check | Expected result |
| --- | --- |
| Total spend | A: 76, B: 74, C: 36 |
| Distinct visit days | A: 4, B: 6, C: 2 |
| First-day items | A: sushi and curry; B: curry; C: ramen |
| First member purchase | A: curry; B: sushi |
| Most purchased item | ramen: 8 purchased items |

## Business-rule choices

Membership is effective on the join date. The first-week promotion covers that date plus the following six days. The promotional multiplier does not stack with the sushi multiplier. The January promotion query counts purchases after membership begins and before February 2021.

For production use, add transaction identifiers, price history, enforced keys, and a documented policy for refunded items. This small sample does not establish large-data performance.

## Validation

The accompanying [regression check](tests/check_analysis.py) exercises the first nine analytical queries against the included sample using SQLite and tests tie and join-date boundaries. The PostgreSQL-specific tenth query still requires execution in PostgreSQL.

---
[Explore the full Power BI, Fabric & Data Engineering portfolio](https://github.com/Osama-data/Power-Bi-Projects)
