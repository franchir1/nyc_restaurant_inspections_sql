# NYC Restaurant Inspections — Data Analytics Project

## Project summary

This project analyzes **NYC restaurant inspection outcomes** to understand where health risk concentrates, how inspection severity behaves, and how enforcement actions are triggered.

Using public health inspection data, the project turns a complex and imperfect dataset into **reliable, comparable insights** through careful data modeling and KPI design.

The focus is on **analytical correctness and interpretability**, not dashboards or prediction.

---

## Dataset at a glance

**Source**
NYC Department of Health and Mental Hygiene (DOHMH) — Restaurant Inspection Results.

**Scale**

* **300k+ records** of inspection violations
* **84k reconstructed inspections**
* **30k+ restaurants**
* **5 NYC boroughs**
* **15+ years** of historical coverage

Each inspection may include **multiple violations**, which makes naïve aggregation incorrect.

---

## Why this data is challenging

This dataset is not analysis-ready.

Key issues:

* No unique inspection identifier
* Multiple violations per inspection
* Missing scores and inspection dates
* Inconsistent inspection actions
* Uneven coverage in early years

Instead of “fixing” the data, the project is built to **respect these constraints** and make them explicit in the analysis.

---

## How inspections are defined

Because no inspection ID exists, inspections are reconstructed as:

**one restaurant on one inspection date**

This definition allows:

* consistent counting of inspections
* correct aggregation of scores
* prevention of double counting

Multiple inspections may occur for the same restaurant in one day.

---

## Key analytical results

### Geographic differences

**Average inspection score (higher = worse):**

* Queens: ~19
* Brooklyn: ~18
* Bronx: ~17
* Manhattan: ~17
* Staten Island: ~16

Differences are **persistent and structural**, not driven by volume alone.

---

### Risk lives in the tail

Median inspection scores are similar across boroughs.

However, **extreme cases differ significantly**:

* P90 score in Queens: ~39
* P90 score in Manhattan: ~34

This shows that geographic risk differences emerge mainly in **severe inspections**.

---

### High-risk inspections (score ≥ 28)

Share of high-risk inspections:

* Queens: ~21%
* Brooklyn: ~19%
* Manhattan: ~17%
* Staten Island: ~14%

Some areas consistently face **higher exposure to severe health violations**.

---

### Impact of critical violations

Average inspection score:

* With at least one critical violation: **~20**
* Without critical violations: **~4**

Critical violations are the **main driver of inspection severity**, far more than the number of violations.

---

### Enforcement is non-linear

Restaurant closures are rare at low inspection scores.

Closure rate by score bucket:

* 0–19 → <1%
* 20–27 → ~0.5%
* 28+ → >8%

Enforcement actions appear only once **clear severity thresholds** are crossed.

---

### Trends over time

Using a 3-year rolling average:

* Inspection scores have **worsened in recent years**
* Boroughs evolve differently over time
* Relative ranking between areas remains stable

There is **no clear long-term improvement trend**.

---

## What this project demonstrates

This project shows how to:

* Turn messy public data into **defensible insights**
* Design KPIs that are **comparable and reproducible**
* Make assumptions explicit instead of hiding them
* Separate data modeling from reporting and visuals

It is an **analytical reasoning project**, not a visualization or BI exercise.

---

## How the project is structured (high level)

* Raw data is preserved and cleaned
* A consistent inspection-level model is built
* KPIs are defined as reusable SQL views

All results are fully reproducible from source data.

---

## Known limitations

* Inspections are reconstructed at restaurant–day level
* Some inspection attributes vary within the same day
* Early historical data is less complete

These limitations bound interpretation but do not affect internal consistency.

---

## Data source

[NYC Department of Health and Mental Hygiene (DOHMH) — Restaurant Inspection Results](https://catalog.data.gov/dataset/dohmh-new-york-city-restaurant-inspection-results). Open government data.