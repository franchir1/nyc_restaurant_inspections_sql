# NYC Health Inspections – End-to-End Data Analysis (SQL & BI)

This project analyzes **NYC Department of Health (DOHMH)** restaurant inspection data using a complete analytical pipeline:

**Raw data → ETL → Star schema → SQL analysis → Business insights**

The focus is on **system-level behavior and long-term dynamics**, not on isolated inspection events.  
Individual inspections are used as analytical units, but conclusions are drawn exclusively from **aggregated and longitudinal patterns**.

---

## Project overview

This analysis investigates whether the NYC health inspection system behaves in a **structurally balanced and proportionate** way across geography, time, and establishments.

In particular, the project examines whether:

- inspection coverage is proportional across NYC areas
- inspection outcomes differ structurally between boroughs
- inspection volume and outcomes evolve over time
- critical hygiene violations show geographic concentration
- establishments improve over time or persistently underperform

---

## Analytical goals

The project is designed to support **decision-oriented analysis** and addresses the following questions:

- Do inspection outcomes differ structurally across NYC areas?
- Are inspections distributed proportionally to the number of establishments?
- How do inspection scores and volumes evolve over time?
- Where are critical hygiene violation events concentrated?
- Do establishments improve, or do problems persist over time?

The approach is **KPI-driven**, normalized, and explicitly grounded in grain-aware analysis.

---

## Dataset

**Source:** NYC DOHMH Restaurant Inspection Results  

**Original grain:** inspection × violation

Key challenges of the raw dataset:
- duplication of inspection scores across violations
- mixed analytical grains
- uneven historical coverage

These issues are resolved through explicit ETL design and dimensional modeling.

---

## ETL pipeline

The ETL process is documented in detail in `etl.md`.

### Architecture

Raw CSV  
→ **Power Query** (cleaning & normalization)  
→ PostgreSQL staging tables  
→ **SQL transformations**  
→ Dimensional star schema

### Power Query responsibilities
- column renaming and standardization
- data type enforcement
- removal of invalid business keys
- deduplication
- basic normalization  
- **no aggregations or analytical feature engineering**

### SQL responsibilities
- surrogate key generation
- grain enforcement
- referential integrity checks
- fact table construction

**ETL strategy:** full refresh

---

## Data model

The analytical layer is built on a **pure star schema**, designed to ensure:

- correct metric aggregation
- explicit grain control
- BI-friendly joins
- interview-level explainability

**Dimensions contain no metrics or derived analytical features.**  
All measures are stored exclusively in fact tables.

### Star schema layout

<figure style="text-align: center; margin: 1.5rem 0;">
  <img src="star_schema_sql.png" alt="Star schema data model layout" style="max-width: 70%; height: auto;" />
  <figcaption style="margin-top: 0.5rem; font-style: italic;">
    Star schema used for analytical modeling
  </figcaption>
</figure>

### How to read the schema

- `fact_inspection` is the **central fact table**, one row per inspection
- Dimensions describe **when**, **where**, and **which establishment**
- `fact_inspection_violation` stores **violation events linked to inspections**
- Violations are separated to **avoid inspection score duplication**

Detailed modeling choices and grain definitions are documented in `data_model.md`.

### Dimensions
- `date_dim` – calendar attributes
- `area_dim` – geographic area (borough)
- `establishment_dim` – restaurant entity
- `violation_dim` – violation code and description

### Fact tables

#### `fact_inspection`
**Grain:** one row per inspection  
**Measure:** `score_assigned`

Used for:
- average inspection scores
- inspection volumes
- temporal trends
- establishment-level improvement analysis

#### `fact_inspection_violation`
**Grain:** one row per violation event per inspection

Used for:
- critical violation frequency
- violation persistence
- geographic distribution of violations

Violations are modeled separately to **avoid inspection score duplication**.

---

## Methodological principles

- inspection scores are treated as **unitary per inspection**
- comparisons rely on **normalized metrics**
- no metrics or derived features are stored in dimensions
- derived analytical features (e.g. weekday vs weekend) are computed **at query time**
- fact tables are **aggregated before joining**
- early years with sparse coverage are interpreted cautiously

These choices ensure semantic correctness and analytical robustness.

---

## Tools & technologies

- **Database:** PostgreSQL
- **SQL:** CTEs, window functions, advanced aggregations
- **ETL:** Excel Power Query
- **Visualization:** Python (`pandas`, `matplotlib`)
- **IDE:** Visual Studio Code
- **Version control:** Git / GitHub

---

## Skills demonstrated

- dimensional modeling (star schema)
- grain control and metric correctness
- surrogate keys and referential integrity
- complex analytical SQL
- KPI-oriented analysis
- end-to-end data pipeline design and documentation

---

## Documentation

- Data model → `data_model.md`
- ETL process → `etl.md`
- SQL queries → `Q1.sql` … `Q6.sql`
- Results → `queries_results.md`
