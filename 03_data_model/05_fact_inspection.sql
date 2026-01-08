---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE: fact_inspection
---------------------------------------------------------------------------------------------------------------------------
-- Grain:
-- 1 row = 1 restaurant-day with at least one inspection
--
-- Methodological note:
-- The source dataset does not provide a reliable inspection-level identifier.
-- Inspections are therefore approximated at restaurant-day level.
-- Multiple inspections occurring on the same day for the same establishment
-- are deterministically collapsed into a single record.
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS fact_inspection CASCADE;

CREATE TABLE fact_inspection (
    inspection_key SERIAL PRIMARY KEY,             -- Surrogate key for restaurant-day inspection
    establishment_key INT NOT NULL
        REFERENCES establishment_dim(establishment_key),
    area_key INT NOT NULL
        REFERENCES area_dim(area_key),
    date_key INT NOT NULL
        REFERENCES date_dim(date_key),
    score_assigned INT,                             -- Worst score observed for the restaurant-day
    action_taken VARCHAR(150)                       -- Canonical action taken (deterministically selected)
);

---------------------------------------------------------------------------------------------------------------------------
-- DATA LOADING
---------------------------------------------------------------------------------------------------------------------------

INSERT INTO fact_inspection (
    establishment_key,
    area_key,
    date_key,
    score_assigned,
    action_taken
)
SELECT
    ed.establishment_key,

    -- Area is an establishment-level attribute.
    -- In case of inconsistencies in the source, the value is collapsed deterministically.
    MIN(ad.area_key) AS area_key,

    dd.date_key,

    -- Worst score of the day retained (conservative assumption)
    MAX(cdt.score_assigned) AS score_assigned,

    -- Canonical action selected deterministically
    MAX(cdt.action_taken) AS action_taken

FROM clean_data_table AS cdt
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN area_dim AS ad
    ON cdt.area_name = ad.area_name
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date

WHERE cdt.inspection_date IS NOT NULL

GROUP BY
    ed.establishment_key,
    dd.date_key;

---------------------------------------------------------------------------------------------------------------------------
-- VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- CHECK 1: Row count (how many inspections were generated)
SELECT COUNT(*) AS inspections_fact
FROM fact_inspection;

-- 84K rows

-- CHECK 2: Uniqueness of the business grain (should be 0 rows)
SELECT
    establishment_key,
    date_key,
    COUNT(*) AS duplicates
FROM fact_inspection
GROUP BY establishment_key, date_key
HAVING COUNT(*) > 1;

-- 0 rows

-- CHECK 3: Coverage vs clean data (distinct inspections present in clean data)
-- Note: clean_data_table grain is violation-level, so we count distinct restaurant-days.
SELECT COUNT(*) AS inspections_clean
FROM (
    SELECT DISTINCT camis_code, inspection_date
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
) t;

-- 84K rows

-- CHECK 4: Coverage gap explained by missing/unmatched dimensions
-- 4a) Missing dates (clean rows with inspection_date not found in date_dim)
SELECT COUNT(*) AS missing_date_dim_matches
FROM (
    SELECT DISTINCT inspection_date
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
) cd
LEFT JOIN date_dim dd
    ON cd.inspection_date = dd.inspection_date
WHERE dd.inspection_date IS NULL;

-- zero

-- 4b) Missing establishments (clean rows with camis_code not found in establishment_dim)
SELECT COUNT(*) AS missing_establishment_dim_matches
FROM (
    SELECT DISTINCT camis_code
    FROM clean_data_table
    WHERE camis_code IS NOT NULL
) cd
LEFT JOIN establishment_dim ed
    ON cd.camis_code = ed.camis_code
WHERE ed.camis_code IS NULL;

-- zero

-- 4c) Missing areas (clean rows with area_name not found in area_dim)
SELECT COUNT(*) AS missing_area_dim_matches
FROM (
    SELECT DISTINCT area_name
    FROM clean_data_table
    WHERE area_name IS NOT NULL
) cd
LEFT JOIN area_dim ad
    ON cd.area_name = ad.area_name
WHERE ad.area_name IS NULL;

-- zero

-- CHECK 5: Assumption stress test (multiple inspections on same restaurant-day proxy)
-- Uses action_taken as a proxy signal. If >1 distinct action exists for the same restaurant-day,
-- it suggests multiple inspections on the same day for that establishment.
WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS actions_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND camis_code IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT COUNT(*) AS restaurant_days_with_multiple_actions
FROM daily_restaurant
WHERE actions_same_day > 1;

-- 747

-- CHECK 6: Quantify assumption impact (% of restaurant-days with multiple actions)
WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS actions_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND camis_code IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN actions_same_day > 1 THEN 1 ELSE 0 END) / COUNT(*),
        3
    ) AS pct_restaurant_days_with_multiple_actions
FROM daily_restaurant;

-- 0.886 

-- SAMPLE VIEW
SELECT *
FROM fact_inspection
ORDER BY inspection_key
LIMIT 20;