---------------------------------------------------------------------------------------------------------------------------
-- FACT TABLE DEFINITION
---------------------------------------------------------------------------------------------------------------------------

-- the measure value in the fact table (inspection_events_table) is the assigned score

-- TABLE CREATION

CREATE TABLE inspection_events_table (
    event_key SERIAL PRIMARY KEY,                              -- primary key
    area_key INT NOT NULL REFERENCES area_dim(area_key),        -- surrogate key referencing the address dimension table
    date_key INT NOT NULL REFERENCES date_dim(date_key),        -- surrogate key referencing the time dimension
    establishment_key INT NOT NULL REFERENCES establishment_dim(establishment_key), -- surrogate key referencing the establishment dimension
    inspection_key INT NOT NULL REFERENCES inspection_dim(inspection_key),           -- surrogate key referencing the inspection dimension
    score_assigned INT NOT NULL                                 -- score assigned following the inspection
);

-- DATA INSERTION

INSERT INTO inspection_events_table (
    area_key,
    date_key,
    establishment_key,
    inspection_key,
    score_assigned
)
SELECT
    ad.area_key,
    dd.date_key,
    ed.establishment_key,
    id.inspection_key,
    cdt.score_assigned
FROM
    clean_data_table AS cdt

-- join with address dimension table
JOIN area_dim AS ad
    ON cdt.building_code = ad.building_code
    AND cdt.street_name = ad.street_name
    AND cdt.zip_code = ad.zip_code

-- join with date dimension table
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date

-- join with establishment dimension table
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code

-- join with inspection dimension table
JOIN inspection_dim AS id
    ON cdt.violation_code = id.violation_code;
