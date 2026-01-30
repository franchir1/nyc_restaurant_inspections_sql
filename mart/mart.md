# MART Layer — KPIs and Consumption Model

## Purpose of the MART Layer

The MART layer exposes **consumption-ready analytical outputs** derived exclusively from the ANALYSIS layer. It defines stable KPI views, derived metrics, and standardized result sets intended for reporting, dashboards, and documentation.

---

## MART layer structure

The MART layer is logically divided into two components:

1. **KPI definition views**
   Stable, reusable SQL views that define the semantics of each KPI.

2. **Consumption and documentation queries**
   Read-only SELECT queries built on top of KPI views.

This separation ensures semantic stability while allowing flexible consumption.

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

---

## V2 — Score Distribution by Area (Median & Tail Risk)

**Definition**
Median and upper-tail risk of inspection scores by area.

**Output**

| Area          | Median | P90 | Inspections |
| ------------- | ------ | --- | ----------- |
| QUEENS        | 13     | 39  | 19,429      |
| BROOKLYN      | 12     | 37  | 21,857      |
| MANHATTAN     | 12     | 34  | 31,469      |
| BRONX         | 13     | 33  | 7,641       |
| STATEN ISLAND | 13     | 31  | 3,036       |

**Interpretation**
Median scores are closely aligned across boroughs, indicating a similar baseline level. Differences emerge in the upper tail: Queens and Brooklyn exhibit significantly higher P90 values.

---

## V3 — High-Risk Inspections by Area

**Definition**
Share of inspections classified as high risk (inspection score ≥ 28) by area.

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

| Year | Bronx | Brooklyn | Manhattan | Queens | Staten Island |
|------|-------|----------|-----------|--------|---------------|
| 2008 | 0.00  |          |           |        |               |
| 2013 |       | 4.00     |           |        |               |
| 2014 |       | 14.86    |           |        |               |
| 2015 |       | 14.32    | 15.17     | 18.25  |               |
| 2016 | 6.25  | 17.27    | 13.27     | 13.40  | 10.75         |
| 2017 | 8.47  | 13.67    | 12.63     | 11.80  | 14.63         |
| 2018 | 12.33 | 14.99    | 11.18     | 10.32  | 15.47         |
| 2019 | 14.72 | 16.85    | 11.42     | 12.31  | 14.98         |
| 2020 | 18.09 | 17.45    | 12.43     | 15.49  | 11.81         |
| 2021 | 18.65 | 16.88    | 13.68     | 15.87  | 11.50         |
| 2022 | 17.15 | 15.95    | 14.64     | 16.30  | 13.35         |
| 2023 | 15.22 | 16.17    | 15.41     | 16.37  | 15.88         |
| 2024 | 16.63 | 17.13    | 16.27     | 17.72  | 16.16         |
| 2025 | 17.70 | 18.12    | 17.34     | 19.40  | 17.12         |


**Interpretation**
The chart shows heterogeneous but broadly comparable trajectories across areas. Trends are not synchronized.

In the most recent years, inspection scores converge across boroughs toward higher levels, indicating a general worsening rather than improvement.

Despite this convergence, relative ordering remains stable: some areas consistently perform better, others worse.

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
Inspections with critical violations exhibit substantially higher average scores if compared to non-critical violation inspections. The separation between groups is large and structural, confirming that critical violations are the primary driver of inspection severity.

---

## V6 — Closure Rate and critical rate by Inspection Score Bucket

**Definition**
This KPI combines two complementary measures computed at inspection grain and grouped by inspection score buckets.

**Output**

| Score Bucket | Total  | Closed | Closure % |
| ------------ | ------ | ------ | --------- |
| 00–09        | 22,458 | 45     | 0.20      |
| 10–19        | 33,542 | 241    | 0.72      |
| 20–27        | 12,410 | 62     | 0.50      |
| 28+          | 15,022 | 1,222  | 8.13      |

| Score bucket | Total inspections | Critical inspections | Critical inspections rate % |
| ------------ | ----------------- | -------------------- | --------------------------- |
| 00–09        | 20 971            | 11 927               | 56.87                       |
| 10–19        | 33 542            | 33 169               | 98.89                       |
| 20–27        | 12 410            | 12 409               | 99.99                       |
| 28+          | 15 488            | 15 023               | 97.00                       |

**Interpretation**
Closure actions are nearly absent below 20 points. A sharp increase appears in the 28+ bucket, confirming a non-linear relationship between score severity and enforcement actions.

Critical violations become almost universal as inspection scores increase. From the 10–19 bucket onward, nearly all inspections include at least one critical violation, while the 00–09 range is the only bucket where this is not dominant.

Compared with the closure-rate KPI, this shows that critical violations are necessary but not sufficient for enforcement: they appear early, but closures occur only once overall severity crosses a higher score threshold.

---

## V7 — Ranking Cuisines

**Definition**
Ranking of cuisines with the lowest/highest average inspection scores, subject to minimum inspection volume thresholds.

**Output**

| Cuisine (top 10)        | Inspections | Avg Score |
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

| Cuisine (bottom 10) | Inspections | Avg Score |
| ----------------  | ----------- | --------- |
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
Best-performing cuisines tend to be operationally simpler and more standardized. Minimum inspection thresholds are applied to filter out isolated anomalies and prevent unstable rankings.

---

## Known limitations of the MART layer

* No predictive or causal metrics are provided
* Impact metrics rely on proxy relationships

## Conclusions
The MART layer consolidates the project’s analytical intent into a small set of stable, defensible KPIs derived from an explicitly constrained data model.

Taken together, the KPIs show that inspection outcomes differ structurally across areas, that risk is driven primarily by upper-tail behavior rather than central tendencies, and that enforcement actions respond non-linearly to severity. Critical violations emerge early and broadly, while closures occur only beyond clear score thresholds.