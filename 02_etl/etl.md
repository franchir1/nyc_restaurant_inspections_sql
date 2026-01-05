# ETL Pipeline – NYC Health Inspections

## Overview
The ETL process integrates raw NYC Health Inspection data into a clean dimensional model
optimized for analytical queries and BI reporting.

The pipeline combines:
- SQL transformations (PostgreSQL)
- Power Query for data ingestion, cleaning, and shaping

The final output is a star schema composed of dimension tables and fact tables.

---

## Source Data
Raw data is sourced from NYC Health Department inspection records and includes:
- inspection dates
- establishment information
- geographic areas
- inspection scores
- violation events

Data is loaded into PostgreSQL as raw tables and then transformed.

---

## ETL Architecture

**Flow:**

Raw CSV  
→ Power Query (cleaning & normalization)  
→ PostgreSQL staging tables  
→ SQL transformations  
→ Dimensional model (star schema)

Power Query is used as the primary **EL (Extract & Load)** layer, while SQL handles
**data modeling and business logic**.

---

## Power Query – Data Cleaning & Preparation

Power Query performs the following steps consistently across all entities:

- Column renaming and standardization
- Data type enforcement
- Removal of rows with null or invalid business keys
- Deduplication of business keys
- Basic normalization (e.g. trimming text, uppercasing codes)

No aggregations are performed in Power Query.

Power Query output tables represent **clean, row-level data**.

---

## Data Quality Checks

Data quality is enforced at two levels:

### Power Query
- Removal of rows with missing critical fields
- Consistent data types
- Early detection of malformed records

### SQL
- Primary key uniqueness checks
- Referential integrity between fact and dimension tables
- Grain validation on fact tables

All checks passed before dimensional loading.

---

## Dimensional Modeling

The final model follows a **star schema**.

### Dimensions
- `date_dim`
- `area_dim`
- `establishment_dim`
- `violation_dim`

Each dimension:
- Uses surrogate keys
- Contains no metrics
- Represents a single business entity

---

## Fact Tables

### `fact_inspection`
**Grain:** one row per inspection

Measures:
- score_assigned

Foreign keys:
- date
- establishment
- area

---

### `fact_inspection_violation`
**Grain:** one row per violation event per inspection

Purpose:
- track frequency and distribution of critical violations

Foreign keys:
- inspection
- violation
- area
- date

---

## Loading Strategy

- Full refresh ETL
- Dimensions loaded before facts
- Fact tables loaded only after all dimension keys are resolved

---

## Assumptions & Limitations

- Inspection score interpretation: higher score indicates worse outcome
- No late-arriving dimensions handled (e.g. fact records are loaded only after all dimension tables are fully refreshed,
preventing late-arriving dimension scenarios)
- Historical corrections overwrite previous data (e.g. inspection scores may be overwritten if the source system updates past inspection records
)
- Analysis assumes stable inspection policy across areas

---
