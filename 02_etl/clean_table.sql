---------------------------------------------------------------------------------------------------------------------------
-- CLEAN DATA TABLE
-- Purpose: Store cleaned inspection and violation records coming from Power Query ETL
-- Grain: 1 row = 1 violation recorded during an inspection
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS clean_data_table;

CREATE TABLE clean_data_table (

    -- Establishment identifiers
    camis_code VARCHAR(10) NOT NULL,
    establishment_name VARCHAR(120),
    cuisine_description VARCHAR(60),

    -- Location
    area_name VARCHAR(15),

    -- Inspection attributes
    inspection_date DATE,
    action_taken VARCHAR(150),
    score_assigned INT,

    -- Violation attributes
    violation_code VARCHAR(5),
    violation_description VARCHAR(2000),
    critical_flag VARCHAR(15)

);

---------------------------------------------------------------------------------------------------------------------------
-- DATA LOADING
-- Data is assumed to be fully cleaned and normalized in Power Query
---------------------------------------------------------------------------------------------------------------------------

COPY clean_data_table (
    camis_code,
    establishment_name,
    area_name,
    cuisine_description,
    inspection_date,
    action_taken,
    violation_code,
    violation_description,
    critical_flag,
    score_assigned
)
FROM 'C:\Users\Lenovo\Desktop\sql_data_cleaning.csv'
WITH (
    FORMAT csv,
    DELIMITER ';',
    HEADER,
    ENCODING 'UTF8',
    QUOTE '"'
);

---------------------------------------------------------------------------------------------------------------------------
-- BASIC VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- Row count check
SELECT COUNT(*) AS total_rows
FROM clean_data_table;

-- 295K rows loaded

-- Inspection multiplicity check (expected > 1 for some inspections) CHECK: OK
SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS violations_per_inspection
FROM clean_data_table
GROUP BY camis_code, inspection_date
HAVING COUNT(*) > 1;

-- Presence of inspection-level attributes
SELECT
    COUNT(*) AS missing_inspection_date
FROM clean_data_table
WHERE inspection_date IS NULL;

-- 3366

SELECT
    COUNT(*) AS missing_score
FROM clean_data_table
WHERE score_assigned IS NULL;

-- 16214

-- are there more than 1 inspection for the same establishment in the same day?

SELECT
    camis_code,
    inspection_date,
    COUNT(DISTINCT action_taken) AS different_actions,
    COUNT(DISTINCT score_assigned) AS different_scores,
    COUNT(*) AS rows
FROM clean_data_table
WHERE inspection_date IS NOT NULL
GROUP BY
    camis_code,
    inspection_date
HAVING
    COUNT(DISTINCT action_taken) > 1
    OR COUNT(DISTINCT score_assigned) > 1
ORDER BY rows DESC;



---------------------------------------------------------------------------------------------------------------------------
-- END OF FILE
---------------------------------------------------------------------------------------------------------------------------
