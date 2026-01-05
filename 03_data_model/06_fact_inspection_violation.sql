---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE: fact_inspection_violation (BRIDGE)
---------------------------------------------------------------------------------------------------------------------------
-- Granularity:
-- 1 row = 1 violation observed during 1 inspection
--
-- Notes:
-- - This table models the one-to-many relationship between inspections and violations.
-- - Duplicate raw records are intentionally collapsed.
-- - critical_flag is inspection-dependent and therefore belongs to this fact table.
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS fact_inspection_violation CASCADE;

CREATE TABLE fact_inspection_violation (
    inspection_violation_key SERIAL PRIMARY KEY,
    inspection_key INT NOT NULL REFERENCES fact_inspection(inspection_key),
    violation_key INT NOT NULL REFERENCES violation_dim(violation_key),
    critical_flag VARCHAR(15) NOT NULL
);


---------------------------------------------------------------------------------------------------------------------------
-- DATA LOADING
---------------------------------------------------------------------------------------------------------------------------

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
SELECT COUNT(*) AS inspection_violation_rows
FROM fact_inspection_violation;

-- 290K

-- CHECK 2: Uniqueness of the bridge grain (must return 0 rows)
SELECT
    inspection_key,
    violation_key,
    COUNT(*) AS duplicates
FROM fact_inspection_violation
GROUP BY inspection_key, violation_key
HAVING COUNT(*) > 1;

-- 0

-- CHECK 3: Coverage vs clean data (distinct inspection-violation pairs)
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

-- 290K

-- CHECK 4: Referential integrity (violations not matched to violation_dim)
SELECT COUNT(*) AS missing_violation_dim_matches
FROM (
    SELECT DISTINCT violation_code
    FROM clean_data_table
    WHERE violation_code IS NOT NULL
) cd
LEFT JOIN violation_dim vd
    ON cd.violation_code = vd.violation_code
WHERE vd.violation_code IS NULL;

-- 0

-- CHECK 5: Referential integrity (inspections not matched to fact_inspection)
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

-- 0



