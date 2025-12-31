-- ESTABLISHMENT DIMENSION TABLE

CREATE TABLE establishment_dim (
    establishment_key SERIAL PRIMARY KEY,      -- database key
    camis_code VARCHAR(10) NOT NULL UNIQUE,    -- natural key
    establishment_name VARCHAR(255),           -- establishment name
    cuisine_description VARCHAR(100)           -- cuisine type description
);

-- populate the establishment dimension table

INSERT INTO establishment_dim (
    camis_code,
    establishment_name,
    cuisine_description
)

SELECT DISTINCT -- prevents inserting establishments with the same CAMIS code multiple times
    cdt.camis_code,
    cdt.establishment_name,
    cdt.cuisine_description
FROM
    clean_data_table AS cdt
WHERE
    cdt.camis_code IS NOT NULL; -- exclude NULL values

-- insertion check
SELECT * FROM establishment_dim;
