---------------------------------------------------------------------------------------------------------------------------
-- DATE DIMENSION
-- Grain: 1 row = 1 calendar date with at least one inspection
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS date_dim CASCADE;

CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,          -- Surrogate key in YYYYMMDD format (derived from inspection_date)
    inspection_date DATE UNIQUE,        -- Natural key (actual calendar date)
    inspection_year INT NOT NULL,       -- Year extracted from inspection_date
    inspection_month INT NOT NULL,      -- Month number (1–12)
    inspection_day INT NOT NULL        -- Day of month (1–31)
);

---------------------------------------------------------------------------------------------------------------------------
-- POPULATE DATE DIMENSION
---------------------------------------------------------------------------------------------------------------------------

INSERT INTO date_dim (
    date_key,
    inspection_date,
    inspection_year,
    inspection_month,
    inspection_day
)
SELECT DISTINCT
    -- Convert date to YYYYMMDD numeric format to generate a compact and sortable surrogate key
    TO_CHAR(inspection_date, 'YYYYMMDD')::INT AS date_key,

    inspection_date,

    -- Extract calendar components for time-based aggregations
    EXTRACT(YEAR FROM inspection_date)::INT AS inspection_year,
    EXTRACT(MONTH FROM inspection_date)::INT AS inspection_month,
    EXTRACT(DAY FROM inspection_date)::INT AS inspection_day

FROM clean_data_table
WHERE inspection_date IS NOT NULL;

---------------------------------------------------------------------------------------------------------------------------
-- VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- Total number of distinct inspection dates
SELECT COUNT(*) AS total_dates
FROM date_dim;

-- 1893

-- Visual sample ordered by calendar sequence
SELECT *
FROM date_dim
ORDER BY date_key
LIMIT 20;
