-- ADDRESS DIMENSION TABLE

-- table creation

CREATE TABLE area_dim (
    area_key SERIAL PRIMARY KEY,          -- primary key
    area_name VARCHAR(25),                -- neighborhood
    building_code VARCHAR(10),            -- building code
    street_name VARCHAR(100),             -- street name
    zip_code VARCHAR(10),                 -- ZIP code
    -- combined uniqueness constraint to prevent duplicate addresses
    UNIQUE (building_code, street_name, zip_code) -- natural key
);

-- data insertion

INSERT INTO area_dim (
    area_name,
    building_code,
    street_name,
    zip_code
)

SELECT DISTINCT -- prevents inserting the same address more than once
    cdt.area_name,
    cdt.building_code,
    cdt.street_name,
    cdt.zip_code
FROM
    clean_data_table AS cdt
WHERE
    cdt.building_code IS NOT NULL
    AND cdt.street_name IS NOT NULL
    AND cdt.zip_code IS NOT NULL; -- exclude NULL values

-- insertion check
SELECT * FROM establishment_dim;
