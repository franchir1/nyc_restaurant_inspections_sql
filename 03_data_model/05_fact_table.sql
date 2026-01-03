---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE DEFINITION
---------------------------------------------------------------------------------------------------------------------------

-- the measure value in the fact table (inspection_events_table) is the assigned score
-- Granularity: 1 row = 1 violation detected during an inspection

-- TABLE CREATION

CREATE TABLE inspection_events_table (
    event_key SERIAL PRIMARY KEY,                              -- primary key
    area_key INT NOT NULL REFERENCES area_dim(area_key),        -- surrogate key referencing the address dimension table
    date_key INT NOT NULL REFERENCES date_dim(date_key),        -- surrogate key referencing the time dimension
    establishment_key INT NOT NULL REFERENCES establishment_dim(establishment_key), -- surrogate key referencing the establishment dimension
    inspection_key INT NOT NULL REFERENCES inspection_dim(inspection_key),           -- surrogate key referencing the inspection dimension
    score_assigned INT NOT NULL                                 -- score assigned following the inspection
);

-- DATA INSERTION

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
FROM
    clean_data_table AS cdt

-- join with address dimension table
JOIN area_dim AS ad
    ON cdt.building_code = ad.building_code
    AND cdt.street_name = ad.street_name
    AND cdt.zip_code = ad.zip_code

-- join with date dimension table
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date

-- join with establishment dimension table
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code

-- join with inspection dimension table
JOIN inspection_dim AS id
    ON cdt.violation_code = id.violation_code;

SELECT *
FROM inspection_events_table AS iet
JOIN
    inspection_dim AS id ON iet.inspection_key = id.inspection_key
ORDER BY
date_key ASC


-- Check multiple violations per inspection (expected)
SELECT
    establishment_key,
    date_key,
    COUNT(*) AS rows_per_inspection
FROM inspection_events_table
GROUP BY establishment_key, date_key
HAVING COUNT(*) > 1;

-- check n. violations per inspection
SELECT
    n_viol_per_inspection,
    COUNT(*) AS inspections_count
FROM (
    SELECT
        establishment_key,
        date_key,
        COUNT(*) AS n_viol_per_inspection
    FROM inspection_events_table
    GROUP BY establishment_key, date_key
) t
GROUP BY n_viol_per_inspection
ORDER BY n_viol_per_inspection;

-- check

SELECT COUNT(*) AS inspections_clean
FROM (
  SELECT DISTINCT camis_code, inspection_date
  FROM clean_data_table
) t;

SELECT COUNT(*) AS inspections_fact
FROM (
  SELECT DISTINCT establishment_key, date_key
  FROM inspection_events_table
) AS t;

SELECT COUNT(*) AS inspections_missing_area
FROM (
  SELECT DISTINCT cdt.camis_code, cdt.inspection_date
  FROM clean_data_table AS cdt
  LEFT JOIN area_dim AS ad
    ON cdt.building_code = ad.building_code
   AND cdt.street_name  = ad.street_name
   AND cdt.zip_code     = ad.zip_code
  WHERE ad.area_key IS NULL
) t;

SELECT COUNT(*) AS inspections_missing_date
FROM (
  SELECT DISTINCT cdt.camis_code, cdt.inspection_date
  FROM clean_data_table AS cdt
  LEFT JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
  WHERE dd.date_key IS NULL
) t;

SELECT COUNT(*) AS inspections_missing_est
FROM (
  SELECT DISTINCT cdt.camis_code, cdt.inspection_date
  FROM clean_data_table AS cdt
  LEFT JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
  WHERE ed.establishment_key IS NULL
) t;


-- check if multiple events in the same day

SELECT
    cdt.camis_code,
    cdt.inspection_date,
    COUNT(DISTINCT cdt.action_taken) AS distinct_actions
FROM clean_data_table AS cdt
WHERE cdt.action_taken IS NOT NULL
GROUP BY cdt.camis_code, cdt.inspection_date
HAVING COUNT(DISTINCT cdt.action_taken) > 1;

SELECT
    cdt.camis_code,
    cdt.inspection_date,
    COUNT(DISTINCT cdt.score) AS distinct_scores,
    COUNT(DISTINCT cdt.grade) AS distinct_grades
FROM clean_data_table AS cdt
GROUP BY cdt.camis_code, cdt.inspection_date
HAVING COUNT(DISTINCT cdt.score) > 1
    OR COUNT(DISTINCT cdt.grade) > 1;


-- isp_number in different days
WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS n_inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT COUNT(*) AS total_restaurant_days
FROM daily_restaurant;

-- isp_number in the same day

WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS n_inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    COUNT(*) AS restaurant_days_with_multiple_inspections
FROM daily_restaurant
WHERE n_inspections_same_day > 1;

-- just 1 double inspection for the same day and the same restaurant, negligible

-- %

WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS n_inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN n_inspections_same_day > 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS pct_multiple_inspections_same_day
FROM daily_restaurant;

WITH daily_restaurant AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS n_inspections_same_day
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    n_inspections_same_day,
    COUNT(*) AS restaurant_days
FROM daily_restaurant
GROUP BY n_inspections_same_day
ORDER BY n_inspections_same_day;


SELECT*
FROM
inspection_events_table