# NYC Health Inspections — End-to-End Data Analysis (SQL)

This project analyzes **NYC Department of Health (DOHMH)** restaurant inspection data through a complete analytical pipeline:

**Raw data → ETL → Star schema → SQL analysis → System-level insights**

The analysis focuses on **structural behavior and long-term dynamics** of the inspection system.  
Individual inspections are treated as analytical units, while conclusions are drawn exclusively from **aggregated, normalized, and longitudinal patterns**.

---

## Analytical Scope

This project investigates whether the NYC health inspection system behaves in a **balanced and proportionate** way across:

- geography
- time
- establishments

The goal is **not descriptive reporting**, but the analytical interpretation of **system-level behavior**.

---

## Analytical Questions

The project addresses decision-oriented questions such as:

- Do inspection outcomes differ structurally across NYC areas?
- Are inspections distributed proportionally to the number of establishments?
- How do inspection scores and volumes evolve over time?
- Where are critical hygiene violations geographically concentrated?
- Do establishments improve over time or persistently underperform?

The approach is **KPI-driven**, explicitly **grain-aware**, and grounded in **dimensional modeling best practices**.

---

## Dataset

**Source:** NYC DOHMH — Restaurant Inspection Results  
**Original grain:** inspection × violation

Key challenges of the raw dataset:

- inspection scores duplicated across violations
- mixed analytical grains
- absence of a reliable inspection identifier
- uneven historical coverage

These issues are resolved through explicit ETL design and modeling choices.

---

## ETL Pipeline

The full ETL process is documented in `etl.md`.

### Architecture

Raw CSV  
→ **Power Query** (cleaning & normalization)  
→ PostgreSQL staging table (`clean_data_table`)  
→ **SQL transformations**  
→ Dimensional star schema

### Power Query (non-aggregating)

- column renaming and standardization  
- data type enforcement  
- normalization of textual attributes  
- handling of invalid or placeholder values  
- **no aggregations or analytical feature engineering**

### SQL Transformations

- surrogate key generation  
- grain enforcement  
- referential integrity checks  
- construction of fact and dimension tables  

**ETL strategy:** full refresh

---

## Data Model

The analytical layer is built on a **star schema**, designed to ensure:

- correct metric aggregation  
- explicit grain control  
- BI-friendly joins  
- analytical explainability  

Dimensions contain **no metrics or derived features**.  
All measures are stored exclusively in fact tables.

---

## Star Schema

*(diagram unchanged)*

### Schema interpretation

- `fact_inspection` is the **central fact table**
- One row represents **one restaurant-day with at least one inspection**
- Dimensions describe **when**, **where**, and **which establishment**
- `fact_inspection_violation` is a **dependent bridge fact**
- Violations are separated to **avoid inspection score duplication**

Detailed modeling decisions are documented in `data_model.md`.

---

## Dimensions

- `date_dim` — calendar attributes  
- `area_dim` — geographic area (borough)  
- `establishment_dim` — restaurant entity  
- `violation_dim` — violation code and description  

All dimensions use surrogate keys and contain no analytical metrics.

---

## Fact Tables

### `fact_inspection`

**Grain:** one row per restaurant-day with at least one inspection  
**Measure:** `score_assigned`

Supports:
- average inspection scores
- inspection volumes
- temporal trend analysis
- establishment-level performance tracking

---

### `fact_inspection_violation`

**Grain:** one row per (inspection, violation type)

Supports:
- critical violation frequency
- violation persistence
- geographic concentration analysis

This table must be queried **through `fact_inspection`** to preserve analytical correctness.

---

## Methodological Principles

- inspections approximated at **restaurant-day level**
- inspection scores treated as **unitary per inspection**
- comparisons rely on **normalized metrics**
- no metrics stored in dimensions
- derived features computed **at query time**
- fact tables aggregated **before joins**
- early years with sparse coverage interpreted cautiously

These constraints ensure **semantic correctness and analytical robustness**.

---

## Tools & Technologies

- **Database:** PostgreSQL  
- **SQL:** CTEs, window functions, analytical aggregations  
- **ETL:** Power Query  
- **Visualization:** Python (`pandas`, `matplotlib`)  
- **IDE:** Visual Studio Code  
- **Version control:** Git / GitHub  

---

## Skills Demonstrated

- dimensional modeling (star schema)
- explicit grain control
- surrogate keys and referential integrity
- complex analytical SQL
- KPI-oriented analysis
- end-to-end analytical pipeline design

---

## Documentation & Deep Dives

- Raw source data  
  [`01_raw_data/`](01_raw_data/DOHMH_New_York_City_Restaurant_Inspection_Results_20260104_1k.csv)

- ETL documentation  
  [`02_etl/etl.md`](02_etl/etl.md)

- Dimensional data model  
  [`03_data_model/data_model.md`](03_data_model/data_model.md)

- SQL table definitions  
  [`03_data_model/`](03_data_model/)

- Analytical SQL queries  
  [`04_queries/`](04_queries/)

- Query results and interpretations  
  [`04_queries/queries_results.md`](04_queries/queries_results.md)

For visualization of the same dataset, see the companion project:  
[`nyc_restaurant_inspections_powerbi`](../nyc_restaurant_inspections_powerbi)
