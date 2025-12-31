-- INSPECTION DIMENSION TABLE

-- table creation

CREATE TABLE inspection_dim (
    inspection_key SERIAL PRIMARY KEY,         -- primary key
    violation_code VARCHAR(10) NOT NULL UNIQUE, -- natural key
    violation_description VARCHAR(1000),       -- violation type description
    action_taken VARCHAR(255),                 -- action taken following the violation
    critical_flag VARCHAR(25)                  -- criticality
);

-- data insertion

INSERT INTO inspection_dim (
    violation_code,
    violation_description,
    action_taken,
    critical_flag
)
SELECT
    cdt.violation_code,
    cdt.violation_description,
    cdt.action_taken,
    cdt.critical_flag
FROM
    clean_data_table AS cdt
WHERE
    cdt.violation_code IS NOT NULL
ON CONFLICT (violation_code) DO NOTHING; -- handle conflicts to avoid inserting the same violation code twice

-- data visualization check (70 unique codes)
SELECT *
FROM inspection_dim
ORDER BY inspection_key;
