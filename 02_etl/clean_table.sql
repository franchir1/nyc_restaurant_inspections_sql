/* ============================================================
CLEAN_DATA_TABLE
============================================================

Purpose
Staging table containing fully cleaned inspection and
violation-level records produced by Power Query ETL.

Grain
- 1 row = 1 violation recorded during an inspection
- Multiple rows may exist for the same inspection
    (one per violation)

Notes
- This table is NOT a fact table
- It serves as the single source for dimensional and
    fact table population
*/

/* ----------------------------
Table definition
---------------------------- */

DROP TABLE IF EXISTS clean_data_table;

CREATE TABLE clean_data_table (

/* Establishment identifiers */
camis_code VARCHAR(10) NOT NULL,
establishment_name VARCHAR(120),
cuisine_description VARCHAR(60),

/* Location */
area_name VARCHAR(15),

/* Inspection attributes */
inspection_date DATE,
action_taken VARCHAR(150),
score_assigned INT,

/* Violation attributes */
violation_code VARCHAR(5),
violation_description VARCHAR(2000),
critical_flag VARCHAR(15)
);

/* ----------------------------
Data loading
---------------------------- */

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

/* Total row count */
SELECT
COUNT(*) AS total_rows
FROM clean_data_table;

/*
Expected:
~295,000 rows
*/

/* Inspection multiplicity check
(multiple violations per inspection are expected)
*/
SELECT
camis_code,
inspection_date,
COUNT(*) AS violations_per_inspection
FROM clean_data_table
GROUP BY
camis_code,
inspection_date
HAVING COUNT(*) > 1;

/* Missing inspection dates */
SELECT
COUNT(*) AS missing_inspection_date
FROM clean_data_table
WHERE inspection_date IS NULL;

/*
Observed: 3,366
*/

/* Missing inspection scores */
SELECT
COUNT(*) AS missing_score
FROM clean_data_table
WHERE score_assigned IS NULL;

/*
Observed: 16,214
*/
