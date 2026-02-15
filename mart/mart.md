# MART Layer — KPI Semantics and Results

## Role of the MART layer

The MART layer defines the **final analytical contract** of the project: a set of **stable, reusable KPI views** derived exclusively from the ANALYSIS star schema.

Each KPI includes:

* a clear definition (grain + population)
* a results table (what you actually get)
* a short interpretation (what it means, what it does not mean)

---

## KPI outputs included in this document

- V1. Average inspection score by area
- V2. Score distribution by area (median + P90)
- V3. High-risk inspections by area (score ≥ 28)
- V4. 3-year rolling trend by area (selected years)
- V5. Score impact of critical violations
- V6A. Closure rate by score bucket
- V6B. Critical violation rate by score bucket
- V7. Cuisine ranking (best / worst)

---

## V1 — Average inspection score by area

**Definition**
Average `score_assigned` per borough. Population excludes NULL scores.

**Results**

| Area          | Avg Score |
| ------------- | --------: |
| QUEENS        |     18.92 |
| BROOKLYN      |     17.76 |
| BRONX         |     17.42 |
| MANHATTAN     |     16.93 |
| STATEN ISLAND |     16.73 |

**Interpretation**
Queens has the highest average score (worse outcomes), Staten Island the lowest. This is a baseline comparison; it does not describe extreme cases.

---

## V2 — Score distribution by area (median & P90)

**Definition**
Median and 90th percentile of `score_assigned` per borough (NULL scores excluded).

**Results**

| Area          | Median | P90 | Inspections |
| ------------- | -----: | --: | ----------: |
| QUEENS        |     13 |  39 |      19,429 |
| BROOKLYN      |     12 |  37 |      21,857 |
| MANHATTAN     |     12 |  34 |      31,469 |
| BRONX         |     13 |  33 |       7,641 |
| STATEN ISLAND |     13 |  31 |       3,036 |

**Interpretation**
Typical outcomes are similar (median), but severe inspections differ strongly (P90). Geographic risk is mainly a tail-risk phenomenon.

---

## V3 — High-risk inspections by area (score ≥ 28)

**Definition**
High-risk share per borough, where high-risk = `score_assigned >= 28` (NULL scores excluded).

**Results**

| Area          | High Risk |  Total | High Risk % |
| ------------- | --------: | -----: | ----------: |
| QUEENS        |     4,042 | 19,429 |       20.80 |
| BROOKLYN      |     4,082 | 21,857 |       18.68 |
| MANHATTAN     |     5,234 | 31,469 |       16.63 |
| BRONX         |     1,245 |  7,641 |       16.29 |
| STATEN ISLAND |       419 |  3,036 |       13.80 |

**Interpretation**
Queens and Brooklyn consistently show higher exposure to severe inspections. This complements V1 and V2 by turning severity into an operational rate.

---

## V4 — 3-year rolling average score trend (selected output)

**Definition**
Yearly average score by area + 3-year rolling average (NULL scores excluded). Rolling values exist only where at least 3 years of data are available.

**Results (excerpt, most recent years)**

| Area          | Year | Avg Score (3y rolling) |
| ------------- | ---: | ---------------------: |
| BRONX         | 2023 |                  15.22 |
| BRONX         | 2024 |                  16.63 |
| BRONX         | 2025 |                  17.70 |
| BROOKLYN      | 2023 |                  16.17 |
| BROOKLYN      | 2024 |                  17.13 |
| BROOKLYN      | 2025 |                  18.12 |
| MANHATTAN     | 2023 |                  15.41 |
| MANHATTAN     | 2024 |                  16.27 |
| MANHATTAN     | 2025 |                  17.34 |
| QUEENS        | 2023 |                  16.37 |
| QUEENS        | 2024 |                  17.72 |
| QUEENS        | 2025 |                  19.40 |
| STATEN ISLAND | 2023 |                  15.88 |
| STATEN ISLAND | 2024 |                  16.16 |
| STATEN ISLAND | 2025 |                  17.12 |

**Interpretation**
Recent years trend upward across boroughs (worsening). Areas move differently, but relative ordering remains stable.

---

## V5 — Impact of critical violations on inspection score

**Definition**
Compare average inspection scores by whether an inspection has at least one CRITICAL violation.
Critical presence is derived at inspection grain via `BOOL_OR` over the bridge table.

**Results**

| Has ≥1 Critical Violation | Inspections | Avg Score |
| ------------------------- | ----------: | --------: |
| Yes                       |      72,525 |     19.75 |
| No                        |       9,420 |      4.22 |

**Interpretation**
The separation is structural: critical violations are the dominant severity driver.

---

## V6 — Enforcement behavior by score bucket

### V6A — Closure rate by score bucket

**Definition**
Closure proxy = `action_taken ILIKE '%Closed%'`. Bucketed by inspection score.

**Results**

| Score Bucket |  Total | Closed | Closure % |
| ------------ | -----: | -----: | --------: |
| 00–09        | 22,458 |     45 |      0.20 |
| 10–19        | 33,542 |    241 |      0.72 |
| 20–27        | 12,410 |     62 |      0.50 |
| 28+          | 15,022 |  1,222 |      8.13 |

**Interpretation**
Enforcement is non-linear: closures are rare until the highest severity bucket.

---

### V6B — Critical violation rate by score bucket

**Definition**
Share of inspections with at least one critical violation, bucketed by score.

**Results**

| Score Bucket |  Total | Critical | Critical % |
| ------------ | -----: | -------: | ---------: |
| 00–09        | 20,971 |   11,927 |      56.87 |
| 10–19        | 33,542 |   33,169 |      98.89 |
| 20–27        | 12,410 |   12,409 |      99.99 |
| 28+          | 15,488 |   15,023 |      97.00 |

**Interpretation**
Critical violations become nearly universal above 10 points, while closures only rise at 28+. Critical violations are necessary but not sufficient for closure actions.

---

## V7 — Cuisine ranking by inspection score (top and bottom)

**Definition**
Average inspection score by cuisine, filtered to cuisines with at least 50 inspections for stability.

**Best-performing cuisines (lowest avg score)**

| Cuisine                 | Inspections | Avg Score |
| ----------------------- | ----------: | --------: |
| Donuts                  |       2,046 |     10.90 |
| Hotdogs                 |          83 |     11.46 |
| Hamburgers              |       1,609 |     12.04 |
| Salads                  |         354 |     12.53 |
| Bottled Beverages       |         338 |     12.73 |
| Tex-Mex                 |       1,048 |     13.75 |
| Hotdogs/Pretzels        |          77 |     13.78 |
| Soups/Salads/Sandwiches |         116 |     13.83 |
| German                  |          87 |     14.78 |
| Coffee/Tea              |       6,772 |     15.02 |

**Worst-performing cuisines (highest avg score)**

| Cuisine          | Inspections | Avg Score |
| ---------------- | ----------: | --------: |
| Bangladeshi      |         336 |     31.18 |
| Creole           |          99 |     26.27 |
| Filipino         |         139 |     25.22 |
| African          |         317 |     25.03 |
| Pakistani        |         136 |     24.88 |
| Indian           |       1,043 |     23.11 |
| Chinese/Japanese |         135 |     22.74 |
| Soul Food        |         205 |     21.87 |
| Eastern European |         347 |     21.36 |
| Caribbean        |       2,744 |     21.17 |

**Interpretation**
Rankings are guarded by volume thresholds to reduce noise. These results describe inspection score severity, not causal performance drivers.

---

## Known analytical limitations

* Inspections are reconstructed at restaurant–day level (no inspection_id available)
* Some inspection attributes vary within the same reconstructed inspection
* “Closure” is inferred from free-text action descriptions (proxy)
* No causal or predictive claims are made

---

## Conclusion

The MART layer provides a small, defensible KPI set showing that:

* geographic differences are persistent
* risk concentration is mainly a tail phenomenon
* critical violations dominate severity outcomes
* enforcement actions respond after clear thresholds
* recent years show worsening trends
