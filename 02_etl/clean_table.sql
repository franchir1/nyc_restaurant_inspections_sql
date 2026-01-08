/* ============================================================
CLEAN_DATA_TABLE
============================================================

Purpose
Staging table containing fully cleaned, denormalized inspection
and violation-level records produced by the Power Query ETL.

This table represents the closest analytical approximation to
the raw source data, after standardization and cleaning.

Grain
- 1 row = 1 violation record observed during an inspection
- Multiple rows may exist for the same inspection
  (one row per violation)

Important:
- The concept of "inspection" is not uniquely identified
  in the source dataset.
- Inspection-level uniqueness must be inferred downstream.

Notes
- This table is NOT a fact table
- It is intentionally denormalized
- It acts as the single authoritative source for:
  - dimension population
  - fact table construction
  - validation and stress testing
*/

/* ----------------------------
Table definition
---------------------------- */

DROP TABLE IF EXISTS clean_data_table;

CREATE TABLE clean_data_table (

/* Establishment identifiers
   (business keys from the source system) */
camis_code VARCHAR(10) NOT NULL,
establishment_name VARCHAR(120),
cuisine_description VARCHAR(60),

/* Location attributes
   (textual, later normalized into area_dim) */
area_name VARCHAR(15),

/* Inspection attributes
   (may be repeated across multiple violation rows) */
inspection_date DATE,
action_taken VARCHAR(150),
score_assigned INT,

/* Violation attributes
   (violation-level grain) */
violation_code VARCHAR(5),
violation_description VARCHAR(2000),

/* Criticality flag
   - Not a pure inspection-level attribute
   - Not a pure violation-level attribute
   - Evaluated in the context of inspection + violation */
critical_flag VARCHAR(15)
);

/* ----------------------------
Data loading
----------------------------
Assumes data has already been:
- cleaned
- type-cast
- standardized in Power Query
*/

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

/* ----------------------------
Basic validation checks
---------------------------- */

/* CHECK 1: Total row count
   Confirms expected dataset volume */
SELECT
    COUNT(*) AS total_rows
FROM clean_data_table;

/*
Expected:
~295,000 rows
*/

/* CHECK 2: Inspection multiplicity
   Confirms that multiple violations per inspection exist
   (expected given the violation-level grain) */
SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS violations_per_inspection
FROM clean_data_table
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(*) > 1;

/* CHECK 3: Missing inspection dates
   These rows cannot be mapped to date_dim or fact_inspection
   and will be excluded from downstream facts */
SELECT
    COUNT(*) AS missing_inspection_date
FROM clean_data_table
WHERE inspection_date IS NULL;

/*
Observed: 3,366
*/

/* CHECK 4: Missing inspection scores
   Score is optional in the source dataset and may be absent
   for certain inspections */
SELECT
    COUNT(*) AS missing_score
FROM clean_data_table
WHERE score_assigned IS NULL;

/*
Observed: 16,214
*/

/* CHECK 5: Duplicate inspection proxies
   Identifies repeated rows sharing the same inspection proxy
   (camis_code + inspection_date + action_taken + score_assigned)

   These duplicates justify:
   - collapsing inspections at restaurant-day level
   - collapsing violations in the bridge fact table
*/
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(*) AS row_count
FROM clean_data_table
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

/* CHECK 6: Critical flag instability check
   Demonstrates that critical_flag is not stable at inspection
   proxy level and therefore cannot belong to fact_inspection */
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(DISTINCT critical_flag) AS distinct_critical_flags
FROM clean_data_table
WHERE critical_flag IS NOT NULL
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(DISTINCT critical_flag) > 2
ORDER BY distinct_critical_flags DESC;
