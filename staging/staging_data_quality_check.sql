/* ============================================================
   STAGING — DATA QUALITY & COHERENCE CHECKS
   Target table: staging.clean_dohmh_inspections
   ============================================================

   Scope
   Validation queries used to assess structural consistency
   and semantic reliability of the staging dataset prior to
   dimensional modeling.

   ============================================================ */


/* ------------------------------------------------------------
   CHECK 1 — Row volume
   Validates overall dataset size against expectations
------------------------------------------------------------ */
SELECT
    COUNT(*) AS total_rows
FROM staging.clean_dohmh_inspections;

-- 300K rows

/* ------------------------------------------------------------
   CHECK 2 — Inspection multiplicity
   Confirms that multiple violations can occur within
   the same inspection event, consistent with the
   violation-level grain
------------------------------------------------------------ */
SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS violations_per_inspection
FROM staging.clean_dohmh_inspections
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(*) > 1
ORDER BY violations_per_inspection DESC
LIMIT
    10;


/* ------------------------------------------------------------
   CHECK 3 — Missing inspection dates
   Records without an inspection_date cannot be linked
   to date_dim or included in inspection-level facts
------------------------------------------------------------ */
SELECT
    COUNT(*) AS missing_inspection_date
FROM staging.clean_dohmh_inspections
WHERE inspection_date IS NULL;

/* ------------------------------------------------------------
   CHECK 4 — Missing inspection scores
   Inspection score is not mandatory in the source data
   and must be treated as nullable downstream
------------------------------------------------------------ */
SELECT
    COUNT(*) AS missing_score
FROM staging.clean_dohmh_inspections
WHERE score_assigned IS NULL;


/* ------------------------------------------------------------
   CHECK 5 — Duplicate inspection proxies
   Inspection proxy definition:
     (camis_code + inspection_date + action_taken + score_assigned)

   Purpose
   - Validate collapsing inspections to restaurant-day grain
   - Support aggregation of violations via a bridge fact
------------------------------------------------------------ */

SELECT
    SUM(inspections_same_day)
FROM

(SELECT
    camis_code,
    inspection_date,
    COUNT(DISTINCT action_taken) AS inspections_same_day
FROM staging.clean_dohmh_inspections
WHERE inspection_date IS NOT NULL
  AND camis_code IS NOT NULL
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(DISTINCT action_taken) > 1)

-- 1.5K duplicate records of inspections (action taken) for the same day, same restaurant

SELECT
    COUNT(DISTINCT (camis_code, inspection_date, action_taken, score_assigned))
        AS total_inspections_by_action_proxy
FROM staging.clean_dohmh_inspections
WHERE
    camis_code IS NOT NULL
    AND inspection_date IS NOT NULL
    AND action_taken IS NOT NULL
    AND score_assigned IS NOT NULL;

-- 84K rows (total distinct inspections)


-- this proxy definition has 84 K rows, 750 of which are duplicates (0.9%), otherwise the inspection is not identifiable as event


/* ------------------------------------------------------------
   CHECK 6 — Critical flag variability for the inspection proxy level
------------------------------------------------------------ */
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(DISTINCT critical_flag) AS distinct_critical_flags
FROM staging.clean_dohmh_inspections
WHERE critical_flag IS NOT NULL
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(DISTINCT critical_flag) > 1
ORDER BY distinct_critical_flags DESC
LIMIT
    10;

-- This means that critical_flag is violation-level-depending, not inspection-level
