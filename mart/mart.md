# MART Layer — KPIs and Consumption Model

## Purpose of the MART Layer

The MART layer exposes **consumption-ready analytical outputs** derived exclusively from the ANALYSIS layer. It defines stable KPI views, derived metrics, and standardized result sets intended for reporting, dashboards, and documentation.

All computations rely solely on validated facts and dimensions from the ANALYSIS layer, which represents the authoritative semantic source of the model. The MART layer constitutes the **final analytical contract**: metrics are definitive, reusable, and independent from visualization or BI tooling.

---

## MART layer structure

The MART layer is logically divided into two components:

1. **KPI definition views**
   Stable, reusable SQL views that define the semantics of each KPI.
   These views contain no presentation logic.

2. **Consumption and documentation queries**
   Read-only SELECT queries built on top of KPI views.
   These queries apply ordering, limits, and formatting for reporting and documentation purposes.

This separation ensures semantic stability while allowing flexible consumption.

---

## KPI design principles

All KPIs adhere to the following design rules:

* One SQL view corresponds to one KPI
* KPI views contain **no presentation logic** (no ORDER BY, no LIMIT)
* No BI-specific assumptions are embedded
* All logic is derived exclusively from ANALYSIS-layer facts and dimensions
* Filters and validity rules are applied consistently
* Results are reproducible and comparable over time

Semantic stability is prioritized over consumption flexibility.

---

## Base reference population

The reference population for KPIs is defined implicitly by each KPI view. Inclusion and exclusion rules are enforced within the view logic and are therefore consistent across all consumption queries.

KPIs do not imply equivalence between different populations. Metrics computed on different subsets of inspections are not directly comparable unless explicitly stated.

---

## KPI populations and comparability

Each KPI documents the population it measures.

* KPIs computed on **all valid inspections** describe overall system behavior
* KPIs computed on **filtered subsets** (e.g. high-risk inspections, inspections with critical violations) describe conditional behavior

Differences between populations are treated as explicit analytical constraints, not as noise or data quality issues.

---

## KPI categories

### Frequency KPIs

Frequency KPIs measure rates or proportions of events.

Characteristics:

* Explicit event condition
* Stable and documented denominator
* Minimum volume thresholds to reduce volatility

These KPIs describe likelihood or exposure, not severity.

---

### Intensity KPIs

Intensity KPIs measure average magnitude within a defined subset of inspections. They describe severity **when an event occurs**, not overall system performance.

---

### Severity and impact KPIs

Impact KPIs estimate relative operational effects using normalized or proxy ratios. The meaning of both numerator and denominator is explicitly stated.

These KPIs indicate structural associations rather than causal relationships.

---

## V1 — Average Inspection Score by Area

**Definition**
Average inspection score computed at borough level. Higher values indicate worse inspection outcomes.

**Output**

| Area          | Avg Score |
| ------------- | --------- |
| QUEENS        | 18.92     |
| BROOKLYN      | 17.76     |
| BRONX         | 17.42     |
| MANHATTAN     | 16.93     |
| STATEN ISLAND | 16.73     |

**Interpretation**
Queens shows the highest average inspection score, indicating a higher overall level of violations compared to other boroughs. Staten Island records the lowest average score, suggesting better overall compliance. The gap between areas is moderate but consistent, pointing to structural geographic differences.

**Suggested visual**
Ordered bar chart by average score.

---

## V2 — Score Distribution by Area (Median & Tail Risk)

**Definition**
Distribution-based KPI capturing central tendency (median) and upper-tail risk (P90) of inspection scores by area.

**Output**

| Area          | Median | P90 | Inspections |
| ------------- | ------ | --- | ----------- |
| QUEENS        | 13     | 39  | 19,429      |
| BROOKLYN      | 12     | 37  | 21,857      |
| MANHATTAN     | 12     | 34  | 31,469      |
| BRONX         | 13     | 33  | 7,641       |
| STATEN ISLAND | 13     | 31  | 3,036       |

**Interpretation**
Median scores are closely aligned across boroughs, indicating a similar baseline level of inspection outcomes. Differences emerge in the upper tail: Queens and Brooklyn exhibit significantly higher P90 values. Cross-area differences are therefore driven by extreme inspection outcomes rather than shifts in central tendency.

**Suggested visual**
Boxplot or dot plot by area.

---

## V3 — High-Risk Inspections by Area

**Definition**
Share of inspections classified as high risk, defined as inspection score ≥ 28, computed at area level.

**Output**

| Area          | High Risk | Total  | High Risk % |
| ------------- | --------- | ------ | ----------- |
| QUEENS        | 4,042     | 19,429 | 20.80       |
| BROOKLYN      | 4,082     | 21,857 | 18.68       |
| MANHATTAN     | 5,234     | 31,469 | 16.63       |
| BRONX         | 1,245     | 7,641  | 16.29       |
| STATEN ISLAND | 419       | 3,036  | 13.80       |

**Interpretation**
Queens shows the highest concentration of high-risk inspections, exceeding 20%. Staten Island records the lowest share. The pattern cannot be explained by inspection volume alone, indicating geographic concentration of health risk.

**Suggested visual**
Percentage bar chart by area.

---

## Temporal KPIs

Temporal KPIs describe how inspection outcomes evolve over time.

* Time grain is annual
* All temporal logic joins explicitly to the date dimension
* Rolling averages are applied in the MART layer to smooth volatility

Temporal KPIs describe trends within observed coverage only.

---

## V4 — 3-Year Rolling Average Score Trend

**Definition**
Multi-year trend of average inspection scores by area using a 3-year rolling average.

```html
<div align="center">
  <img src="images/avg_score_trend_3y.png" width="70%" />
</div>
```

**Interpretation**
The trend shows a gradual worsening of scores up to 2020, followed by a general improvement in subsequent years. Boroughs converge toward higher values in the most recent period, suggesting either increased inspection strictness or deteriorating conditions. Relative differences persist but follow similar directional patterns.

---

## V5 — Impact of Critical Violations on Inspection Score

**Definition**
Comparison of average inspection scores based on the presence of at least one critical violation within an inspection.

**Output**

| Critical Violation | Inspections | Avg Score |
| ------------------ | ----------- | --------- |
| Yes                | 72,525      | 19.75     |
| No                 | 9,420       | 4.22      |

**Interpretation**
Inspections with critical violations exhibit substantially higher average scores. The separation between groups is large and structural, confirming that critical violations are the primary driver of inspection severity.

**Suggested visual**
Two-category bar chart.

---

## V6 — Closure Rate by Inspection Score Bucket

**Definition**
Closure rate computed by inspection score buckets, based on inspection action outcomes.

**Output**

| Score Bucket | Total  | Closed | Closure % |
| ------------ | ------ | ------ | --------- |
| 00–09        | 22,458 | 45     | 0.20      |
| 10–19        | 33,542 | 241    | 0.72      |
| 20–27        | 12,410 | 62     | 0.50      |
| 28+          | 15,022 | 1,222  | 8.13      |

**Interpretation**
Closure actions are nearly absent below 20 points. A sharp increase appears in the 28+ bucket, confirming a non-linear relationship between score severity and enforcement actions. Score thresholds align with operational decision-making.

**Suggested visual**
Bar or line chart by score bucket.

---

## V7 — Best Performing Cuisines

**Definition**
Ranking of cuisines with the lowest average inspection scores, subject to minimum inspection volume thresholds.

**Output**

| Cuisine                 | Inspections | Avg Score |
| ----------------------- | ----------- | --------- |
| Donuts                  | 2,046       | 10.90     |
| Hotdogs                 | 83          | 11.46     |
| Hamburgers              | 1,609       | 12.04     |
| Salads                  | 354         | 12.53     |
| Bottled Beverages       | 338         | 12.73     |
| Tex-Mex                 | 1,048       | 13.75     |
| Hotdogs/Pretzels        | 77          | 13.78     |
| Soups/Salads/Sandwiches | 116         | 13.83     |
| German                  | 87          | 14.78     |
| Coffee/Tea              | 6,772       | 15.02     |

**Interpretation**
Best-performing cuisines tend to be operationally simpler and more standardized. Minimum inspection thresholds ensure rankings reflect stable patterns rather than small-sample effects.

**Suggested visual**
Horizontal bar chart.

---

## V8 — Worst Performing Cuisines

**Definition**
Ranking of cuisines with the highest average inspection scores, subject to the same stability thresholds.

**Output**

| Cuisine          | Inspections | Avg Score |
| ---------------- | ----------- | --------- |
| Bangladeshi      | 336         | 31.18     |
| Creole           | 99          | 26.27     |
| Filipino         | 139         | 25.22     |
| African          | 317         | 25.03     |
| Pakistani        | 136         | 24.88     |
| Indian           | 1,043       | 23.11     |
| Chinese/Japanese | 135         | 22.74     |
| Soul Food        | 205         | 21.87     |
| Eastern European | 347         | 21.36     |
| Caribbean        | 2,744       | 21.17     |

**Interpretation**
These cuisines show persistently worse inspection outcomes. High inspection volumes for several categories indicate structural patterns rather than isolated anomalies. Associations should not be interpreted causally.

**Suggested visual**
Descending bar chart.

---

## Statistical stability thresholds

Thresholds act as analytical safeguards.

* Minimum inspection counts prevent unstable rankings
* Thresholds constrain interpretation rather than correcting data
* All thresholds are applied consistently across KPIs

---

## Ordering and ranking rules

Ordering and ranking logic is standardized.

* Ranking direction is explicitly defined per KPI
* Tie handling follows SQL window function semantics
* KPI views remain unordered; ordering is applied only in consumption queries

---

## Documentation and consumption queries

Consumption queries select exclusively from MART KPI views.

* Presentation logic (ORDER BY, LIMIT) is allowed
* Outputs are designed for direct inclusion in markdown tables and static reports
* No additional semantic transformation is performed

---

## Cross-KPI interpretation rules

KPIs describe complementary but non-equivalent aspects of inspection performance.

* Frequency measures how often outcomes occur
* Intensity measures how severe outcomes are when they occur
* Severity and impact describe structural relationships
* Temporal KPIs describe evolution over time

Metrics based on different populations are not directly comparable.

---

## Known limitations of the MART layer

* No predictive or causal metrics are provided
* Impact metrics rely on proxy relationships
* Selected KPIs apply restricted populations and thresholds
* Interpretation is bounded by ANALYSIS-layer semantics

---

## Readiness for visualization and reporting

MART outputs are structured for direct BI consumption.

Aggregation levels are explicit, metrics are stable, and semantic rules ensure consistency across dashboards, ranked tables, and time-series visualizations without requiring additional transformation logic.
