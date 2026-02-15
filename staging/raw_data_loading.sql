/* ============================================================
   STAGING — DOHMH NYC Restaurant Inspections
   ============================================================

   Grain
   - 1 row = 1 violation recorded during an inspection
   - The same inspection can appear on multiple rows
     (one per violation)

   Data Constraints
   - The source dataset does NOT expose a stable inspection_id
   - Inspection-level uniqueness must be reconstructed downstream

   ============================================================ */

/*================================================
CREATE SCHEMA
=================================================*/

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analysis;
CREATE SCHEMA IF NOT EXISTS mart;


DROP TABLE IF EXISTS staging.raw_dohmh_inspections;

CREATE TABLE staging.raw_dohmh_inspections (

    camis                   TEXT,
    dba                     TEXT,
    boro                    TEXT,
    building                TEXT,
    street                  TEXT,
    zipcode                 TEXT,
    phone                   TEXT,
    cuisine_description     TEXT,

    inspection_date         TEXT,
    action                  TEXT,
    violation_code          TEXT,
    violation_description   TEXT,
    critical_flag           TEXT,
    score                   TEXT,
    grade                   TEXT,
    grade_date              TEXT,
    record_date             TEXT,
    inspection_type         TEXT,

    latitude                TEXT,
    longitude               TEXT,
    community_board         TEXT,
    council_district        TEXT,
    census_tract            TEXT,
    bin                     TEXT,
    bbl                     TEXT,
    nta                     TEXT,
    location                TEXT
);


COPY staging.raw_dohmh_inspections
FROM 'C:/Users/Lenovo/Documents/GitHub/nyc_restaurant_inspections_sql/staging/DOHMH_New_York_City_Restaurant_Inspection_Results_20260104.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ENCODING 'UTF8'
);

-- Quick validation sample
SELECT *
FROM staging.raw_dohmh_inspections
LIMIT 10;

/* ============================================================
   CLEAN STAGING TABLE
   Purpose:
   - Apply SQL-side normalization
   - Enforce consistent casing and null handling
   - Prepare data for dimensional modeling
   ============================================================ */

DROP TABLE IF EXISTS staging.clean_dohmh_inspections CASCADE;

CREATE TABLE staging.clean_dohmh_inspections AS
SELECT
    /* -----------------------------
       Business identifiers
       ----------------------------- */
    TRIM(camis)                             AS camis_code,

    /* -----------------------------
       Descriptive attributes
       ----------------------------- */
    INITCAP(TRIM(dba))                      AS establishment_name,
    NULLIF(UPPER(TRIM(boro)), '0')          AS area_name,
    INITCAP(TRIM(cuisine_description))      AS cuisine_description,

    /* -----------------------------
       Dates
       ----------------------------- */
    CASE
        WHEN inspection_date IN ('', '01/01/1900') THEN NULL
        ELSE TO_DATE(TRIM(inspection_date), 'MM/DD/YYYY')
    END                                     AS inspection_date,

    /* -----------------------------
       Inspection and violation details
       ----------------------------- */
    TRIM(action)                            AS action_taken,
    NULLIF(TRIM(violation_code), '')        AS violation_code,
    NULLIF(TRIM(violation_description), '') AS violation_description,
    NULLIF(UPPER(TRIM(critical_flag)), '')  AS critical_flag,

    /* -----------------------------
       Quantitative fields
       ----------------------------- */
    NULLIF(TRIM(score), '')::INT            AS score_assigned

FROM staging.raw_dohmh_inspections;


/* ============================================================
   SANITY CHECK
   Purpose: verify structure and basic transformations
   ============================================================ */

SELECT *
FROM staging.clean_dohmh_inspections
LIMIT 10;
