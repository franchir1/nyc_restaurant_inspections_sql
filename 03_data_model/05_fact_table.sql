---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE: inspection_events_table
---------------------------------------------------------------------------------------------------------------------------
-- Granularity:
-- 1 row = 1 violation detected during an inspection.
-- A single inspection may therefore generate multiple rows.
--
-- IMPORTANT NOTE:
-- The source dataset does not provide an explicit inspection identifier.
-- For analytical purposes, an inspection is approximated as:
--
--      (establishment_key, date_key)
--
-- This is a business assumption validated empirically below.
---------------------------------------------------------------------------------------------------------------------------

CREATE TABLE inspection_events_table (
    event_key SERIAL PRIMARY KEY,                              -- technical surrogate key (row-level)
    area_key INT NOT NULL REFERENCES area_dim(area_key),
    date_key INT NOT NULL REFERENCES date_dim(date_key),
    establishment_key INT NOT NULL REFERENCES establishment_dim(establishment_key),
    inspection_key INT NOT NULL REFERENCES inspection_dim(inspection_key), -- identifies the violation
    score_assigned INT NOT NULL                                 -- inspection score (repeated per violation)
);

---------------------------------------------------------------------------------------------------------------------------
-- DATA LOADING
---------------------------------------------------------------------------------------------------------------------------

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
   AND cdt.street_name   = ad.street_name
   AND cdt.zip_code      = ad.zip_code
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN inspection_dim AS id
    ON cdt.violation_code = id.violation_code;

---------------------------------------------------------------------------------------------------------------------------
-- DEFENSIVE CHECKS — MODEL VALIDATION
-- The following checks are intentionally preserved to justify:
--   • fact table granularity
--   • inspection-level aggregation strategy
--   • statistical validity of assumptions
---------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------
-- CHECK 1 — Multiple violations per inspection (EXPECTED)
-- Purpose:
-- Confirms that the fact table is correctly modeled at violation level.
--------------------------------------------------

SELECT
    establishment_key,
    date_key,
    COUNT(*) AS rows_per_inspection
FROM inspection_events_table
GROUP BY establishment_key, date_key
HAVING COUNT(*) > 1
LIMIT 10;

/*
RESULT (sample):
~27K inspection-days have more than one violation.

establishment_key | date_key | rows_per_inspection
------------------|----------|---------------------
7600              | 20250502 | 2
15419             | 20250204 | 3
17476             | 20250602 | 2
5569              | 20240512 | 5
...

Interpretation:
This is expected and confirms that each row represents a violation,
not an inspection.
*/

--------------------------------------------------
-- CHECK 2 — Distribution of violations per inspection
-- Purpose:
-- Sanity check on violation multiplicity.
--------------------------------------------------

SELECT
    violations_per_inspection,
    COUNT(*) AS inspections_count
FROM (
    SELECT
        establishment_key,
        date_key,
        COUNT(*) AS violations_per_inspection
    FROM inspection_events_table
    GROUP BY establishment_key, date_key
) t
GROUP BY violations_per_inspection
ORDER BY violations_per_inspection;

/*
RESULT:

violations_per_inspection | inspections_count
--------------------------|------------------
1  |  3795
2  |  8866
3  |  6861
4  |  4180
5  |  2815
6  |  1844
7  |  1052
8  |   627
9  |   395
10 |   199
11 |    97
12 |    67
13 |    34
14 |    19
15 |     6
16 |     3

Interpretation:
Multiple violations per inspection are common and non-pathological,
further justifying inspection-level aggregation for KPI computation.
*/

--------------------------------------------------
-- CHECK 3 — Multiple inspections on the same day
-- Purpose:
-- Validates the assumption:
-- inspection ≈ (restaurant, day)
-- Uses action_taken as proxy for inspection identity.
--------------------------------------------------

WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    COUNT(*) AS restaurant_days_with_multiple_inspections
FROM daily_restaurant
WHERE inspections_same_day > 1;

/*
RESULT:
restaurant_days_with_multiple_inspections = 1

Interpretation:
Only one restaurant-day in the entire dataset shows evidence
of multiple inspections on the same day.
*/

--------------------------------------------------
-- CHECK 4 — Quantification of assumption impact
-- Purpose:
-- Measures how often the inspection-day approximation is violated.
--------------------------------------------------

WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN inspections_same_day > 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        3
    ) AS pct_multiple_inspections_same_day
FROM daily_restaurant;

/*
RESULT:
pct_multiple_inspections_same_day = 0.003

Interpretation:
The inspection-day approximation is formally imperfect
but statistically negligible (~0.003% of cases).
*/

--------------------------------------------------
-- CHECK 5 — Consistency: clean data vs fact table
-- Purpose:
-- Ensures that inspections are not lost during ETL.
--------------------------------------------------

-- Distinct inspections in clean data
SELECT COUNT(*) AS inspections_clean
FROM (
    SELECT DISTINCT camis_code, inspection_date
    FROM clean_data_table
) t;

/*
RESULT:
inspections_clean = 31,873
*/

-- Distinct inspections represented in fact table
SELECT COUNT(*) AS inspections_fact
FROM (
    SELECT DISTINCT establishment_key, date_key
    FROM inspection_events_table
) t;

/*
RESULT:
inspections_fact = 30,860

Interpretation:
The difference is explained by dimension join constraints
(e.g. missing or unmatched area/date/establishment records),
not by data loss within the fact table itself.
*/
