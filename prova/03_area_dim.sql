---------------------------------------------------------------------------------------------------------------------------
-- AREA DIMENSION
-- Grain: 1 row = 1 geographic area / borough
---------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS area_dim CASCADE;

CREATE TABLE area_dim (
    area_key SERIAL PRIMARY KEY,      -- Surrogate key
    area_name VARCHAR(25) UNIQUE      -- Borough / area name (natural key)
);

---------------------------------------------------------------------------------------------------------------------------
-- POPULATE AREA DIMENSION
---------------------------------------------------------------------------------------------------------------------------

INSERT INTO area_dim (
    area_name
)
SELECT DISTINCT
    area_name
FROM clean_data_table
WHERE area_name IS NOT NULL;

---------------------------------------------------------------------------------------------------------------------------
-- VALIDATION CHECKS
---------------------------------------------------------------------------------------------------------------------------

-- Total number of distinct areas
SELECT COUNT(*) AS total_areas
FROM area_dim;

-- 5

-- Visual sample
SELECT *
FROM area_dim
ORDER BY area_key;
