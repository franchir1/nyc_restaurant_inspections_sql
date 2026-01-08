# ETL Pipeline – NYC Health Inspections

## Overview
The ETL pipeline integrates raw NYC Health Inspection data into a clean,
well-documented dimensional model optimized for analytical queries and BI reporting.

The process combines:
- **Power Query** for data ingestion, cleaning, and normalization
- **SQL (PostgreSQL)** for dimensional modeling and fact construction

The final output is an analytical **star schema–based model** composed of
conformed dimensions and fact tables.

---

## Source Data
Raw data is sourced from NYC Department of Health (DOHMH) restaurant inspection records.

The dataset includes:
- inspection dates
- establishment identifiers and attributes
- geographic areas (boroughs)
- inspection scores
- violation records and criticality flags

The original data is provided at **inspection × violation grain** and does not
expose a reliable inspection-level identifier.

---

## ETL Architecture

### Flow

Raw CSV  
→ **Power Query** (cleaning & normalization)  
→ PostgreSQL staging table (`clean_data_table`)  
→ **SQL transformations**  
→ Dimensional model (star schema)

Power Query acts as the **Extract & Load (EL)** layer, while SQL is responsible for:
- grain enforcement
- surrogate key generation
- referential integrity
- analytical modeling logic

---

## Star Schema Overview

<div style="text-align: center; margin: 1.5rem 0;">
  <img src="star_schema_sql.png" alt="" style="max-width: 100%; height: auto;">
</div>



The model follows a classic star schema design with a dependent bridge fact table
used to model inspection–violation relationships without duplicating inspection measures.

---

## Power Query – Data Cleaning & Preparation

Power Query produces a **single denormalized staging dataset**
(`clean_data_table`) that represents the cleaned version of the raw source data.

### Responsibilities
- Column renaming to canonical names
- Data type enforcement
- Normalization of textual attributes
- Replacement of invalid or placeholder values (e.g. fake dates, empty strings)
- Trimming and standardization of codes and descriptions

No aggregations or analytical feature engineering are performed in Power Query.

### Output Characteristics
- **Grain:** 1 row = 1 violation recorded during an inspection
- Inspection-level uniqueness is not enforced at this stage
- Rows with missing inspection dates are retained but excluded from downstream facts

---

## Data Quality Checks

Data quality is enforced at two levels.

### Power Query
- Consistent data types
- Removal or nullification of invalid business keys
- Early detection of malformed or placeholder values

### SQL
- Primary key uniqueness on dimensions
- Referential integrity between facts and dimensions
- Explicit grain validation on fact tables
- Coverage checks between staging data and facts

All validation checks pass before dimensional loading.

---

## Dimensional Modeling

The analytical model follows a **star schema–based design**.

### Dimensions
- `date_dim`
- `area_dim`
- `establishment_dim`
- `violation_dim`

Each dimension:
- uses surrogate keys
- represents a single business entity
- contains no metrics or derived analytical features

Dimensions are populated from `clean_data_table` using DISTINCT selections.

---

## Fact Tables

### `fact_inspection`
**Grain:**  
1 row = 1 restaurant-day with at least one inspection

Because the source dataset does not expose a reliable inspection identifier,
inspections are approximated at **restaurant-day level**.

Multiple inspections occurring on the same day for the same establishment
are deterministically collapsed.

Measures:
- `score_assigned` (worst score of the day)

Attributes:
- `action_taken`

Foreign Keys:
- `date_key`
- `establishment_key`
- `area_key`

---

### `fact_inspection_violation`
**Grain:**  
1 row = 1 (inspection, violation type)

This table models the many-to-many relationship between inspections and violations.

Purpose:
- track violation frequency
- analyze critical vs non-critical violations
- support compliance and concentration analysis

Foreign Keys:
- `inspection_key`
- `violation_key`

> This is a **dependent bridge fact table** and must always be queried
> through `fact_inspection` to inherit temporal and spatial context.

---

## Loading Strategy

- Full refresh ETL
- Dimensions loaded before facts
- Fact tables loaded only after all dimension keys are resolved
- No late-arriving dimension handling is required due to full refresh strategy

---

## Assumptions & Limitations

- Inspections are approximated at restaurant-day level
- Higher inspection scores indicate worse outcomes
- The model does not preserve the ordering or timing of violations within inspections
- Historical corrections overwrite previous data during refresh
- Early years with sparse coverage should be interpreted cautiously
- The model is optimized for **analytical accuracy**, not operational auditing

---

## Summary

This ETL pipeline:
- resolves mixed-grain source data
- enforces explicit analytical grains
- guarantees metric correctness
- produces a BI-ready star schema
- remains fully aligned with documented modeling assumptions

*Back to the [README](/README.md)*
