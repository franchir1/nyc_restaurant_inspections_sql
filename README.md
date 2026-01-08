# NYC Health Inspections – End-to-End Data Analysis (SQL & BI)

This project analyzes **NYC Department of Health (DOHMH)** restaurant inspection data using a complete analytical pipeline:

**Raw data → ETL → Star schema → SQL analysis → Business insights**

The focus is on **system-level behavior and long-term dynamics**, not on isolated inspection records.
Individual inspections are used as analytical units, but conclusions are drawn exclusively from **aggregated, normalized, and longitudinal patterns**.

---

## Project overview

This analysis investigates whether the NYC health inspection system behaves in a **structurally balanced and proportionate** way across geography, time, and establishments.

In particular, the project examines whether:

* inspection coverage is proportional across NYC areas
* inspection outcomes differ structurally between boroughs
* inspection volume and outcomes evolve over time
* critical hygiene violations show geographic concentration
* establishments improve over time or persistently underperform

The goal is not descriptive reporting, but **analytical interpretation of systemic behavior**.

---

## Analytical goals

The project is designed to support **decision-oriented analysis** and addresses questions such as:

* Do inspection outcomes differ structurally across NYC areas?
* Are inspections distributed proportionally to the number of establishments?
* How do inspection scores and volumes evolve over time?
* Where are critical hygiene violations concentrated?
* Do establishments improve, or do problems persist over time?

The approach is **KPI-driven**, explicitly **grain-aware**, and grounded in dimensional modeling best practices.

---

## Dataset

**Source:** NYC DOHMH – Restaurant Inspection Results

**Original grain:** inspection × violation

Key challenges of the raw dataset:

* inspection scores duplicated across violations
* mixed analytical grains
* lack of a reliable inspection identifier
* uneven historical coverage

These issues are resolved through explicit ETL design and dimensional modeling choices.

---

## ETL pipeline

The full ETL process is documented in detail in `etl.md`.

### Architecture

Raw CSV
→ **Power Query** (cleaning & normalization)
→ PostgreSQL staging table (`clean_data_table`)
→ **SQL transformations**
→ Dimensional star schema

### Power Query responsibilities

* column renaming and standardization
* data type enforcement
* normalization of textual attributes
* handling of invalid or placeholder values
* **no aggregations or analytical feature engineering**

### SQL responsibilities

* surrogate key generation
* grain enforcement
* referential integrity checks
* dimension and fact table construction

**ETL strategy:** full refresh

---

## Data model

The analytical layer is built on a **star schema–based design**, optimized to ensure:

* correct metric aggregation
* explicit grain control
* BI-friendly joins
* clear explainability in technical reviews and interviews

Dimensions contain **no metrics or derived analytical features**.
All measures are stored exclusively in fact tables.

---

## Star schema

<img src="star_schema_sql.png" alt="" style="display:block; margin: 1.5rem auto; max-width:100%; height: auto;">

### How to read the schema

* `fact_inspection` is the **central fact table**
* One row represents **one restaurant-day with at least one inspection**
* Dimensions describe **when**, **where**, and **which establishment**
* `fact_inspection_violation` is a **dependent bridge fact**
* Violations are separated to **avoid inspection score duplication**

Detailed modeling choices and grain definitions are documented in `data_model.md`.

---

## Dimensions

* `date_dim` – calendar attributes
* `area_dim` – geographic area (borough)
* `establishment_dim` – restaurant entity
* `violation_dim` – violation code and description

All dimensions use surrogate keys and contain no analytical metrics.

---

## Fact tables

### `fact_inspection`

**Grain:** one row per restaurant-day with at least one inspection
**Measure:** `score_assigned`

Used for:

* average inspection scores
* inspection volumes
* temporal trends
* establishment-level improvement analysis

---

### `fact_inspection_violation`

**Grain:** one row per (inspection, violation type)

Used for:

* critical violation frequency
* violation persistence
* geographic distribution of violations

Violations are modeled separately to:

* avoid inspection score duplication
* support stable aggregation
* preserve inspection-level measures

This table must be queried **through `fact_inspection`**, not as a standalone star.

---

## Methodological principles

* inspections are approximated at **restaurant-day level**
* inspection scores are treated as **unitary per inspection**
* comparisons rely on **normalized metrics**
* no metrics or derived features are stored in dimensions
* derived analytical features are computed **at query time**
* fact tables are **aggregated before joining**
* early years with sparse coverage are interpreted cautiously

These principles ensure **semantic correctness and analytical robustness**.

---

## Tools & technologies

* **Database:** PostgreSQL
* **SQL:** CTEs, window functions, advanced aggregations
* **ETL:** Power Query
* **Visualization:** Python (`pandas`, `matplotlib`)
* **IDE:** Visual Studio Code
* **Version control:** Git / GitHub

---

## Skills demonstrated

* dimensional modeling (star schema)
* grain control and metric correctness
* surrogate keys and referential integrity
* complex analytical SQL
* KPI-oriented analysis
* end-to-end data pipeline design and documentation

---

## Further Documentation & Deep Dives

Additional documentation and source code structure:

- **Raw source data (CSV)**  
  [`01_raw_data/`](01_raw_data/)

- **ETL process documentation**  
  [`02_etl/etl.md`](02_etl/etl.md)

- **Dimensional data model documentation**  
  [`03_data_model/data_model.md`](03_data_model/data_model.md)

- **Data model SQL definitions (dimensions & facts)**  
  [`03_data_model/`](03_data_model/)

- **Analytical SQL queries**  
  [`04_queries/`](04_queries/)

- **Query results and interpretations**  
  [`04_queries/queries_results.md`](04_queries/queries_results.md)

For the visual exploration of the same dataset, see the
**Power BI companion project**:  
[`nyc_restaurant_inspections_powerbi`](../nyc_restaurant_inspections_powerbi)
