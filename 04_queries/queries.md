# SQL Analysis – Query Overview

The analyses are organized into folders (`Q1`–`Q6`) and ordered progressively: from **data quality and consistency checks** to the **identification of structural criticalities** in the inspection system.

Each analysis folder contains:

* description of the analytical question
* explanation of the applied logic
* complete SQL query
* output (CSV tables and/or charts)
* final interpretation of results

## [Q1](/04_queries/Q1/Q1.md) – Data quality and inspection proportionality

**Question:**
Is the number of inspections **proportional to the number of establishments**
for each area of New York City?

This analysis verifies that:

* the inspection system is evenly distributed
* subsequent analyses are not affected by structural data bias

## [Q2](/04_queries/Q2/Q2.md) – Area criticality

**Question:**
Which areas show a **higher incidence of critical events**,
normalized by the total number of inspections?

The objective is to compare areas correctly,
taking into account different inspection intensities.

## [Q3](/04_queries/Q3/Q3.md) – Temporal trend analysis

**Questions:**

* Do average establishment scores improve or deteriorate over time?
* How does the number of inspections per area change over the years?

This analysis provides the temporal context
necessary to correctly interpret all other metrics.

## [Q4](/04_queries/Q4/Q4.md) – Criticality during weekends

**Question:**
Are hygiene regulation violations
more frequent during **weekends**
compared to weekdays?

The analysis distinguishes between:

* raw distribution of violations
* distribution normalized by the number of days

## [Q5](/04_queries/Q5/Q5.md) – Establishment improvement over time

**Question:**
Are corrective actions taken after inspections
**effective in the long term**?

The analysis compares the score of the first and last inspection
to evaluate the overall improvement of establishments.

## [Q6](/04_queries/Q6/Q6.md) – Identification of major critical issues

**Question:**
Which characteristics are shared by establishments
that **do not show improvement** between the first and last inspection?

In particular:

* geographic distribution
* most recurring violations
* structural criticality patterns

---

*Back to the [README](/README.md)*
