---------------------------------------------------------------------------------------------------------------------------
-- DIMENSION TABLE DEFINITIONS
---------------------------------------------------------------------------------------------------------------------------

-- TIME DIMENSION TABLE

-- table creation

CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,              -- primary key
    inspection_date DATE UNIQUE,            -- natural key
    inspection_year INT NOT NULL,           -- inspection year
    inspection_month INT NOT NULL,          -- inspection month
    inspection_day INT NOT NULL,            -- inspection day
    is_weekend BOOLEAN NOT NULL             -- weekday vs weekend indicator
);

-- visualization check
SELECT * FROM date_dim;

-- data insertion

INSERT INTO date_dim (
    date_key,
    inspection_date,
    inspection_year,
    inspection_month,
    inspection_day,
    is_weekend
)

SELECT DISTINCT -- prevents inserting duplicate dates, since multiple inspections may occur on the same date
    TO_CHAR(cdt.inspection_date, 'YYYYMMDD')::INT AS date_key, -- converts the date to 'YYYYMMDD' format and then to integer, for optimized database handling
    cdt.inspection_date,
    EXTRACT(YEAR FROM cdt.inspection_date) AS inspection_year,
    EXTRACT(MONTH FROM cdt.inspection_date) AS inspection_month,
    EXTRACT(DAY FROM cdt.inspection_date) AS inspection_day,
    -- extract day of week using the "DOW" function to distinguish weekdays from weekends
    CASE
        WHEN EXTRACT(DOW FROM cdt.inspection_date) IN (0, 6) THEN TRUE ELSE FALSE -- 0 = Sunday, 6 = Saturday
    END AS is_weekend
FROM
    clean_data_table AS cdt
WHERE
    cdt.inspection_date IS NOT NULL; -- exclude NULL values

-- visualization check
SELECT *
FROM date_dim
ORDER BY date_key;
