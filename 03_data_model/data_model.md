# Data Model – Star Schema

## Objective

This chapter describes the **analytical data model** used to analyze
the results of New York City health inspections.

The model is built starting from the `clean_data_table`
(final output of the ETL phase) and is designed to:

* support temporal and geographic analysis
* improve aggregation performance
* reduce redundancy in the original dataset
* clearly separate facts and dimensions

---

## Modeling approach

A **star schema** was adopted, with:

* one central **fact table**
* multiple **dimension tables** linked via surrogate keys

This approach is typical of **data warehouse** systems
and enables building queries that are:

* more readable
* more performant
* easier to extend over time

The original dataset is a “flat” table in which
master, geographic, and temporal information is repeated many times
(one row per event / violation).
Star schema normalization eliminates these duplications.

---

## Model overview

<p align="center">
  <img src="star_scheme_sql.png" alt="description" width="600"><br>
  <em>Star schema of the data model</em>
</p>

### Dimension tables

* `date_dim` — inspection time dimension
* `area_dim` — geographic dimension (addresses / areas)
* `establishment_dim` — establishment dimension
* `inspection_dim` — inspection / violation dimension

### Fact table

* `inspection_events_table` — inspection events with the measure `score_assigned`

---

# 1) Dimension tables

## 1.1 `date_dim` – Time dimension

### Purpose

Represents the temporal dimension of inspections, enabling:

* aggregations by year, month, day
* time-based trend analysis
* distinction between weekdays and weekends

### Structure

* **Surrogate key**: `date_key` (INT, `YYYYMMDD` format)
* **Natural key**: `inspection_date` (DATE, UNIQUE)

```sql
CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,
    inspection_date DATE UNIQUE,
    inspection_year INT NOT NULL,
    inspection_month INT NOT NULL,
    inspection_day INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);
```

### Population

The table is populated via a `SELECT DISTINCT`
from `clean_data_table` to avoid duplicates.

```sql
INSERT INTO date_dim (
    date_key,
    inspection_date,
    inspection_year,
    inspection_month,
    inspection_day,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(cdt.inspection_date, 'YYYYMMDD')::INT,
    cdt.inspection_date,
    EXTRACT(YEAR FROM cdt.inspection_date),
    EXTRACT(MONTH FROM cdt.inspection_date),
    EXTRACT(DAY FROM cdt.inspection_date),
    CASE
        WHEN EXTRACT(DOW FROM cdt.inspection_date) IN (0,6)
        THEN TRUE ELSE FALSE
    END
FROM clean_data_table AS cdt
WHERE cdt.inspection_date IS NOT NULL;
```

---

## 1.2 `establishment_dim` – Establishment dimension

### Purpose

Collects establishment master data
to support analysis of:

* individual restaurant performance
* comparison across cuisine types
* long-term evolution of the same establishment

### Structure

* **Surrogate key**: `establishment_key`
* **Natural key**: `camis_code` (unique)

```sql
CREATE TABLE establishment_dim (
    establishment_key SERIAL PRIMARY KEY,
    camis_code VARCHAR(10) NOT NULL UNIQUE,
    establishment_name VARCHAR(255),
    cuisine_description VARCHAR(100)
);
```

### Population

```sql
INSERT INTO establishment_dim (
    camis_code,
    establishment_name,
    cuisine_description
)
SELECT DISTINCT
    cdt.camis_code,
    cdt.establishment_name,
    cdt.cuisine_description
FROM clean_data_table AS cdt
WHERE cdt.camis_code IS NOT NULL;
```

---

## 1.3 `area_dim` – Geographic dimension

### Purpose

Normalizes location information to support:

* comparison across neighborhoods / areas
* geographic analysis
* normalization of indicators by area

### Structure

* **Surrogate key**: `area_key`
* **Composite natural key**:
  `(building_code, street_name, zip_code)`

```sql
CREATE TABLE area_dim (
    area_key SERIAL PRIMARY KEY,
    area_name VARCHAR(25),
    building_code VARCHAR(10),
    street_name VARCHAR(100),
    zip_code VARCHAR(10),
    UNIQUE (building_code, street_name, zip_code)
);
```

### Population

```sql
INSERT INTO area_dim (
    area_name,
    building_code,
    street_name,
    zip_code
)
SELECT DISTINCT
    cdt.area_name,
    cdt.building_code,
    cdt.street_name,
    cdt.zip_code
FROM clean_data_table AS cdt
WHERE
    cdt.building_code IS NOT NULL
    AND cdt.street_name IS NOT NULL
    AND cdt.zip_code IS NOT NULL;
```

---

## 1.4 `inspection_dim` – Inspection / violation dimension

### Purpose

Describes the inspection event from a regulatory perspective:

* violation code
* description
* action taken
* criticality level

This dimension enables analysis of:

* most frequent violations
* distribution by criticality
* recurring corrective actions

### Structure

* **Surrogate key**: `inspection_key`
* **Natural key**: `violation_code`

```sql
CREATE TABLE inspection_dim (
    inspection_key SERIAL PRIMARY KEY,
    violation_code VARCHAR(10) NOT NULL UNIQUE,
    violation_description VARCHAR(1000),
    action_taken VARCHAR(255),
    critical_flag VARCHAR(25)
);
```

### Population

```sql
INSERT INTO inspection_dim (
    violation_code,
    violation_description,
    action_taken,
    critical_flag
)
SELECT
    cdt.violation_code,
    cdt.violation_description,
    cdt.action_taken,
    cdt.critical_flag
FROM clean_data_table AS cdt
WHERE cdt.violation_code IS NOT NULL
ON CONFLICT (violation_code) DO NOTHING;
```

---

# 2) Fact table

## `inspection_events_table`

### Purpose

The fact table represents the **inspection event**
in the analytical model.

It contains:

* **surrogate keys** referencing dimensions
* the **primary measure**: `score_assigned`

Each row represents **one inspection / violation event**.

### Structure

```sql
CREATE TABLE inspection_events_table (
    event_key SERIAL PRIMARY KEY,
    area_key INT NOT NULL REFERENCES area_dim(area_key),
    date_key INT NOT NULL REFERENCES date_dim(date_key),
    establishment_key INT NOT NULL REFERENCES establishment_dim(establishment_key),
    inspection_key INT NOT NULL REFERENCES inspection_dim(inspection_key),
    score_assigned INT NOT NULL
);
```

---

## Fact table population

### Logic

Population is performed starting from the `clean_data_table`,
replacing natural keys with surrogate keys through joins on dimension tables.

```sql
INSERT INTO inspection_events_table (
    area_key,
    date_key,
    establishment_key,
    inspection_key,
    score_assigned
)
SELECT
    ad.area_key,
    dd.date_key,
    ed.establishment_key,
    id.inspection_key,
    cdt.score_assigned
FROM clean_data_table AS cdt
JOIN area_dim AS ad
    ON cdt.building_code = ad.building_code
   AND cdt.street_name = ad.street_name
   AND cdt.zip_code = ad.zip_code
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN inspection_dim AS id
    ON cdt.violation_code = id.violation_code;
```

---

## Technical considerations

### Fact table granularity

The original dataset may contain:

* multiple violations for the same inspection
* multiple rows for the same establishment and date

This implies that the fact table
may contain multiple rows for the same logical “event”.
During analysis, it is therefore crucial to distinguish between:

* event counts
* violation counts

---

## Data model output

At the end of the modeling phase, a **complete star schema model** is obtained, consisting of:

* 4 dimension tables
* 1 fact table

This model represents the single foundation for all SQL analyses and project visualizations.

*Back to the [README](/README.md)*
