/* ============================================================
   ANALYSIS — DIMENSION TABLES
   ============================================================

   Scope
   Definition and population of all dimension tables
   supporting the inspection star schema.

   Design Rules
   - All dimensions are sourced exclusively from staging data
   - Surrogate keys are generated at this layer
   ============================================================ */


/* ============================================================
   DATE DIMENSION
   Grain: 1 row = 1 calendar date
   ============================================================ */

DROP TABLE IF EXISTS analysis.date_dim CASCADE;

CREATE TABLE analysis.date_dim (
    date_key INT PRIMARY KEY,           -- Format: YYYYMMDD
    inspection_date DATE UNIQUE NOT NULL,

    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,

    month_name TEXT NOT NULL,
    day_of_week INT NOT NULL,           -- ISO standard: 1=Mon … 7=Sun
    day_name TEXT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

INSERT INTO analysis.date_dim
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT         AS date_key,
    d                                  AS inspection_date,

    EXTRACT(YEAR  FROM d)::INT          AS year,
    EXTRACT(MONTH FROM d)::INT          AS month,
    EXTRACT(DAY   FROM d)::INT          AS day,

    TO_CHAR(d, 'Month')                 AS month_name,
    EXTRACT(ISODOW FROM d)::INT         AS day_of_week,
    TO_CHAR(d, 'Day')                   AS day_name,
    (EXTRACT(ISODOW FROM d) IN (6,7))   AS is_weekend
FROM generate_series(
    (SELECT MIN(inspection_date)
     FROM staging.clean_dohmh_inspections -- generate calendar from MAX and MIN of the clean_dohmh_inspections staging table
     WHERE inspection_date IS NOT NULL),
    (SELECT MAX(inspection_date)
     FROM staging.clean_dohmh_inspections
     WHERE inspection_date IS NOT NULL),
    INTERVAL '1 day'
) AS d;


-- Structural validation sample
SELECT *
FROM analysis.date_dim
ORDER BY inspection_date
LIMIT 10;


/* ============================================================
   ESTABLISHMENT DIMENSION
   Grain: 1 row = 1 establishment (CAMIS)
   ============================================================ */

DROP TABLE IF EXISTS analysis.establishment_dim CASCADE;

CREATE TABLE analysis.establishment_dim (
    establishment_key SERIAL PRIMARY KEY,
    camis_code VARCHAR(10) NOT NULL UNIQUE,
    establishment_name VARCHAR(255),
    cuisine_description VARCHAR(100)
);

INSERT INTO analysis.establishment_dim (
    camis_code,
    establishment_name,
    cuisine_description
)
SELECT DISTINCT
    camis_code,
    establishment_name,
    cuisine_description
FROM staging.clean_dohmh_inspections
WHERE camis_code IS NOT NULL;

-- Enforce business key uniqueness
CREATE UNIQUE INDEX idx_establishment_dim_camis
    ON analysis.establishment_dim (camis_code);


/* ============================================================
   AREA DIMENSION
   Grain: 1 row = 1 borough / administrative area
   ============================================================ */

DROP TABLE IF EXISTS analysis.area_dim CASCADE;

CREATE TABLE analysis.area_dim (
    area_key SERIAL PRIMARY KEY,
    area_name VARCHAR(25) UNIQUE
);

INSERT INTO analysis.area_dim (area_name)
SELECT DISTINCT
    area_name
FROM staging.clean_dohmh_inspections
WHERE area_name IS NOT NULL;


/* ============================================================
   VIOLATION DIMENSION
   Grain: 1 row = 1 violation type
   ============================================================ */

DROP TABLE IF EXISTS analysis.violation_dim CASCADE;

CREATE TABLE analysis.violation_dim (
    violation_key SERIAL PRIMARY KEY,
    violation_code VARCHAR(10) NOT NULL UNIQUE,
    violation_description VARCHAR(1000)
);

INSERT INTO analysis.violation_dim (
    violation_code,
    violation_description
)
SELECT
    violation_code,
    MAX(violation_description) AS violation_description
FROM staging.clean_dohmh_inspections
WHERE violation_code IS NOT NULL
GROUP BY violation_code;

-- Enforce violation code stability
CREATE UNIQUE INDEX idx_violation_dim_code
    ON analysis.violation_dim (violation_code);
