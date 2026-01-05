---------------------------------------------------------------------------------------------------------------------------
-- VIOLATION DIMENSION
-- Grain: 1 row = 1 unique violation type
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS violation_dim CASCADE;

CREATE TABLE violation_dim (
    violation_key SERIAL PRIMARY KEY,
    violation_code VARCHAR(10) NOT NULL UNIQUE,
    violation_description VARCHAR(1000)
);

---------------------------------------------------------------------------------------------------------------------------
-- POPULATE VIOLATION DIMENSION
---------------------------------------------------------------------------------------------------------------------------

INSERT INTO violation_dim (
    violation_code,
    violation_description
)
SELECT
    violation_code,
    MAX(violation_description) AS violation_description -- collapsing all violation descriptions for the same code into one
FROM clean_data_table
WHERE violation_code IS NOT NULL
GROUP BY violation_code;

---------------------------------------------------------------------------------------------------------------------------
-- VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- Total number of distinct violation types
SELECT COUNT(*) AS total_violations
FROM violation_dim;

-- 151

-- Visual sample
SELECT *
FROM violation_dim
ORDER BY violation_key;
