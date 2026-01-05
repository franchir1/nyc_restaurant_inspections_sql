# NYC Health Inspections – End-to-End Data Analysis (SQL & BI)

This project analyzes **NYC Department of Health (DOHMH)** restaurant inspection data using a complete analytical pipeline:

**Raw data → ETL → Star schema → SQL analysis → Business insights**

The focus is on **system-level behavior and long-term dynamics**, not on isolated inspection events.

---

## Quick insights (executive summary)

Before diving into the queries, the analysis reveals that:

- Health inspections are **proportionally distributed** across NYC areas
- Average inspection quality shows **moderate but structural differences** between boroughs
- A **structural expansion of inspection coverage starts in 2022**
- ~**59% of establishments improve** over time, while a stable minority does not
- Critical violations are **geographically balanced once normalized**
- Persistent problems are mainly **structural and operational**, not location-driven

These insights are demonstrated and validated through the SQL analyses described below.

---

## Analytical goals

The project answers the following questions:

- Do inspection outcomes differ structurally across NYC areas?
- Are inspections distributed proportionally to the number of establishments?
- How do inspection scores and volumes evolve over time?
- Where are critical hygiene violations concentrated?
- Do establishments improve, or do problems persist over time?

The approach is **KPI-driven**, normalized, and designed for **decision support**.

---

## Dataset

Source: NYC DOHMH Restaurant Inspection Results  

Original grain: **inspection × violation**

Key challenges of the raw dataset:
- duplication of inspection scores across violations
- mixed analytical grains
- uneven historical coverage

These issues are resolved through explicit ETL and dimensional modeling.

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
- **no aggregations**

### SQL responsibilities
- surrogate key generation
- grain enforcement
- referential integrity checks
- fact table construction

ETL strategy: **full refresh**

---

## Data model

The analytical layer is built on a **pure star schema**, designed to ensure:

- correct metric aggregation
- explicit grain control
- BI-friendly joins
- interview-level explainability

Dimensions contain **no metrics** and use surrogate keys.  
All measures are stored exclusively in fact tables.

### Star schema layout

<figure style="text-align: center; margin: 2rem 0;">
  <img 
    src="03_data_model/star_scheme_sql.png" 
    alt="Star schema data model layout" 
    style="max-width: 70%; height: auto;"
  />
  <figcaption style="margin-top: 0.5rem; font-style: italic;">
    Data model layout
  </figcaption>
</figure>

### Dimensions
- `date_dim` – calendar attributes and weekend flag
- `area_dim` – borough and neighborhood
- `establishment_dim` – restaurant entity
- `violation_dim` – violation code and critical flag

### Fact tables

#### `fact_inspection`
**Grain:** one row per inspection  
**Measure:** `score_assigned`

Used for:
- average inspection scores
- inspection volumes
- temporal trends
- establishment improvement analysis

#### `fact_inspection_violation`
**Grain:** one row per violation per inspection

Used for:
- critical violation frequency
- violation persistence
- geographic distribution of violations

Violations are modeled separately to **avoid score duplication**.

---

## SQL analysis overview

Analyses are organized by **business question** and implemented in PostgreSQL.

### Q1 – Data quality and proportionality
- average inspection score by area
- inspections per establishment

**Insight:**  
Inspection coverage is proportional across areas; quality differences are moderate and structural.

---

### Q2 – Critical violation events
- critical violations per establishment by area

**Insight:**  
After normalization, critical-event rates are very similar across boroughs.

---

### Q3 – Temporal evolution
- yearly inspection score trends (post-filtered)

**Insight:**  
A clear structural break appears from **2022 onward**, driven by expanded inspection coverage rather than short-term shocks.

---

### Q4 – Inspection scheduling
- weekday vs weekend inspections

**Insight:**  
~97% of inspections occur on weekdays, indicating a highly standardized inspection process.

---

### Q5 – Establishment improvement over time
- comparison between first and last inspection

**Insight:**  
Approximately **59% of establishments improve**, while a substantial minority does not.

---

### Q6 – Persistent non-improvement
- most frequent violations
- geographic distribution of non-improving establishments

**Insight:**  
Non-improving establishments are evenly distributed across areas; recurring violations are mainly structural and operational.

---

## Methodological principles

- inspection scores are treated as **unitary per inspection**
- comparisons rely on **normalized metrics**
- no metrics stored in dimensions
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
- end-to-end data pipeline documentation

---

## Documentation

- ETL process → `etl.md`
- Data model → `data_model.md`
- SQL queries → `Q1.sql` … `Q6.sql`
- Results → `queries_results.md`
