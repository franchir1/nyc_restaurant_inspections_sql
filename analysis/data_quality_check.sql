/* ============================================================
   ANALYSIS — DATA QUALITY & MODEL VALIDATION (COMPACT)
   ============================================================
   Objective
   - dimension table population check
   - fact table grain check
   - validation of core deterministic assumptions
   ============================================================ */


/* ============================================================
   CHECK 1 — Dimension population sanity
   All dimension tables must contain at least one row.
   Empty dimensions indicate upstream load or filter failures.
   ============================================================ */
SELECT
    (SELECT COUNT(*) FROM analysis.date_dim)          AS dates_cnt,
    (SELECT COUNT(*) FROM analysis.establishment_dim) AS establishments_cnt,
    (SELECT COUNT(*) FROM analysis.area_dim)          AS areas_cnt,
    (SELECT COUNT(*) FROM analysis.violation_dim)     AS violations_cnt;

"dates_cnt","establishments_cnt","areas_cnt","violations_cnt"
"6307","30659","5","151"


/* ============================================================
   CHECK 2 — fact_inspection grain validation
   Grain definition:
   - 1 row per establishment per inspection date

   Any duplicate (establishment_key, date_key) pairs
   represent a grain violation.
   Expected result: 0 rows
   ============================================================ */

SELECT
    establishment_key,
    date_key,
    COUNT(*) AS duplicates
FROM analysis.fact_inspection
GROUP BY establishment_key, date_key
HAVING COUNT(*) > 1;

"establishment_key","date_key","duplicates"
no data

/* ============================================================
   CHECK 3 — Coverage alignment: staging vs fact
   The number of distinct restaurant–day combinations
   in staging must equal the number derived from fact_inspection (84K rows)

   This verifies that no inspection-days were dropped
   or duplicated during fact construction.
   ============================================================ */
SELECT
    (SELECT COUNT(*)
     FROM analysis.fact_inspection) AS fact_inspections,
    (SELECT COUNT(*)
     FROM (
         SELECT DISTINCT camis_code, inspection_date
         FROM staging.clean_dohmh_inspections
         WHERE inspection_date IS NOT NULL
     ) s) AS staging_restaurant_days;

"fact_inspections","staging_restaurant_days"
"84317","84317"


/* ============================================================
   CHECK 4 — Core assumption stress test
   Modeling assumption:
   - Some restaurant–day inspections are associated with multiple action_taken values.
   - Expected result: 747
   ============================================================ */

WITH daily_actions AS (
    SELECT
        camis_code,
        inspection_date,
        COUNT(DISTINCT action_taken) AS action_cnt
    FROM staging.clean_dohmh_inspections
    WHERE inspection_date IS NOT NULL
      AND camis_code IS NOT NULL
      AND action_taken IS NOT NULL
    GROUP BY camis_code, inspection_date
)
SELECT
    COUNT(*) AS restaurant_days_with_multiple_actions
FROM daily_actions
WHERE action_cnt > 1;

-- is not possible to remove deterministically these rows

/* ============================================================
   CHECK 5 — Bridge table integrity
   fact_inspection_violation must enforce uniqueness
   at the inspection–violation level.

   Expected result: 0 rows
   ============================================================ */
SELECT
    inspection_key,
    violation_key,
    COUNT(*) AS duplicates
FROM analysis.fact_inspection_violation
GROUP BY inspection_key, violation_key
HAVING COUNT(*) > 1;