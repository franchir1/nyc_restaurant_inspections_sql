---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE: fact_inspection_violation (BRIDGE FACT)
---------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This table models the relationship between inspections and violations without
-- duplicating inspection-level measures (e.g. inspection score).
--
-- Grain:
-- 1 row = 1 violation type associated with 1 inspection (restaurant-day)
--
-- Conceptual notes:
-- - The source dataset is violation-level and may contain duplicate rows.
-- - Raw duplicates are intentionally collapsed.
-- - The analytical grain is therefore (inspection_key, violation_key).
-- - This table should be treated as a dependent fact, not as a standalone star.
--
-- Critical flag handling:
-- - The critical_flag is inspection-dependent.
-- - It is neither violation-level nor inspection-level in the raw data.
-- - For analytical purposes, it is stored at the inspection–violation grain.
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS fact_inspection_violation CASCADE;

CREATE TABLE fact_inspection_violation (
    inspection_violation_key SERIAL PRIMARY KEY,   -- Surrogate identifier for bridge rows
    inspection_key INT NOT NULL
        REFERENCES fact_inspection(inspection_key),
    violation_key INT NOT NULL
        REFERENCES violation_dim(violation_key),
    critical_flag VARCHAR(15) NOT NULL              -- Criticality of the violation in the inspection context
);

---------------------------------------------------------------------------------------------------------------------------
-- DATA LOADING
---------------------------------------------------------------------------------------------------------------------------
-- Strategy:
-- - Join raw violation records to the inspection grain (establishment + date).
-- - Collapse duplicate violation records using DISTINCT.
-- - Preserve the inspection–violation relationship only once per inspection.

INSERT INTO fact_inspection_violation (
    inspection_key,
    violation_key,
    critical_flag
)
SELECT DISTINCT
    fi.inspection_key,
    vd.violation_key,
    cdt.critical_flag
FROM clean_data_table AS cdt
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
JOIN fact_inspection AS fi
    -- Join on the inspection grain: establishment + date
    ON fi.establishment_key = ed.establishment_key
   AND fi.date_key = dd.date_key
JOIN violation_dim AS vd
    ON cdt.violation_code = vd.violation_code
WHERE cdt.violation_code IS NOT NULL;

---------------------------------------------------------------------------------------------------------------------------
-- VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- CHECK 1: Row count
-- Expected: number of distinct (inspection, violation) pairs
SELECT COUNT(*) AS inspection_violation_rows
FROM fact_inspection_violation;

-- ~290K rows

-- CHECK 2: Grain uniqueness
-- Ensures that each (inspection_key, violation_key) pair appears only once
SELECT
    inspection_key,
    violation_key,
    COUNT(*) AS duplicates
FROM fact_inspection_violation
GROUP BY inspection_key, violation_key
HAVING COUNT(*) > 1;

-- Expected result: 0 rows

-- CHECK 3: Coverage vs source data
-- Compares the bridge table with distinct inspection–violation pairs
-- derived from the clean (violation-level) dataset
SELECT COUNT(*) AS inspection_violation_clean
FROM (
    SELECT DISTINCT
        camis_code,
        inspection_date,
        violation_code
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
      AND violation_code IS NOT NULL
) t;

-- Expected: same order of magnitude as fact_inspection_violation (~290K)

-- CHECK 4: Referential integrity – violation dimension
-- Ensures that all violation codes are mapped to violation_dim
SELECT COUNT(*) AS missing_violation_dim_matches
FROM (
    SELECT DISTINCT violation_code
    FROM clean_data_table
    WHERE violation_code IS NOT NULL
) cd
LEFT JOIN violation_dim vd
    ON cd.violation_code = vd.violation_code
WHERE vd.violation_code IS NULL;

-- Expected result: 0

-- CHECK 5: Referential integrity – inspection fact
-- Ensures that all inspection records from the source
-- are successfully mapped to fact_inspection
SELECT COUNT(*) AS missing_inspection_matches
FROM (
    SELECT DISTINCT
        camis_code,
        inspection_date
    FROM clean_data_table
    WHERE inspection_date IS NOT NULL
) cd
LEFT JOIN establishment_dim ed
    ON cd.camis_code = ed.camis_code
LEFT JOIN date_dim dd
    ON cd.inspection_date = dd.inspection_date
LEFT JOIN fact_inspection fi
    ON fi.establishment_key = ed.establishment_key
   AND fi.date_key = dd.date_key
WHERE fi.inspection_key IS NULL;

-- Expected result: 0

---------------------------------------------------------------------------------------------------------------------------
-- CRITICAL_FLAG DEPENDENCY ANALYSIS
---------------------------------------------------------------------------------------------------------------------------
-- The following checks demonstrate that critical_flag is NOT a pure
-- inspection-level nor violation-level attribute in the raw dataset.

-- CHECK 6: Multiple critical flags for the same inspection proxy
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(critical_flag)
FROM clean_data_table
WHERE inspection_date IS NOT NULL
  AND critical_flag = 'CRITICAL'
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(critical_flag) > 2;

-- Result: ~23K rows
-- Interpretation: multiple critical flags may exist within the same inspection proxy

-- CHECK 7: Critical flag distribution by violation code
SELECT
    violation_code,
    COUNT(critical_flag) AS critical_flags
FROM clean_data_table
WHERE violation_code IS NOT NULL
  AND critical_flag IS NOT NULL
GROUP BY violation_code
HAVING COUNT(critical_flag) > 1
ORDER BY critical_flags DESC;

-- Interpretation: no stable correlation between violation codes and criticality

-- CHECK 8: Critical flag consistency at inspection–violation level
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    violation_code,
    COUNT(DISTINCT critical_flag) AS distinct_critical_flags
FROM clean_data_table
WHERE inspection_date IS NOT NULL
  AND violation_code IS NOT NULL
  AND critical_flag IS NOT NULL
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    violation_code
HAVING COUNT(DISTINCT critical_flag) > 1;

-- Expected result: 0
-- Interpretation: critical_flag is stable at inspection–violation grain

-- CHECK 9: Evidence of repeated critical violations across inspections
SELECT
    camis_code,
    violation_code,
    COUNT(critical_flag)
FROM clean_data_table
WHERE camis_code IS NOT NULL
  AND violation_code IS NOT NULL
  AND critical_flag = 'CRITICAL'
GROUP BY
    camis_code,
    violation_code
HAVING COUNT(critical_flag) > 1
LIMIT 10;

---------------------------------------------------------------------------------------------------------------------------
-- FINAL DEPENDENCY VERDICT
---------------------------------------------------------------------------------------------------------------------------
-- Determines the true dependency level of critical_flag in the source data

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM (
                SELECT
                    camis_code,
                    inspection_date,
                    action_taken,
                    score_assigned,
                    COUNT(DISTINCT critical_flag)
                FROM clean_data_table
                GROUP BY
                    camis_code,
                    inspection_date,
                    action_taken,
                    score_assigned
                HAVING COUNT(DISTINCT critical_flag) > 1
            ) t
        ) THEN 'NOT inspection-level'

        WHEN EXISTS (
            SELECT 1
            FROM (
                SELECT
                    violation_code,
                    COUNT(DISTINCT critical_flag)
                FROM clean_data_table
                GROUP BY violation_code
                HAVING COUNT(DISTINCT critical_flag) > 1
            ) t
        ) THEN 'NOT violation-level'

        ELSE 'inspection-violation-level'
    END AS critical_flag_dependency;

-- Result:
-- 'NOT inspection-level'
-- Conclusion:
-- critical_flag belongs at the inspection–violation grain and is correctly
-- modeled in fact_inspection_violation.
