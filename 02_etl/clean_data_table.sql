---------------------------------------------------------------------------------------------------------------------------
-- RAW DATA LOADING
---------------------------------------------------------------------------------------------------------------------------
-- Definition of the dataset columns to be analyzed

/*
Name,Type,Description
CAMIS,Text,Unique identifier (10 digits) for the entity (restaurant) and its permit. Static.
DBA,Text,Commercial name (Doing Business As) of the restaurant.
BORO,Text,Borough where the entity is located (1=MANHATTAN, 5=STATEN ISLAND, etc.).
BUILDING,Text,Building number for the location.
STREET,Text,Street name for the location.
ZIPCODE,Text,Postal code of the location.
PHONE,Text,Phone number provided by the owner/operator.
CUISINE DESCRIPTION,Text,Type of cuisine served by the restaurant. Optional field.
INSPECTION DATE,Floating Timestamp,Inspection date (1/1/1900 if not yet inspected).
ACTION,Text,Action associated with the inspection (e.g., Violations were cited, Establishment re-opened).
VIOLATION CODE,Text,Violation code associated with the inspection.
VIOLATION DESCRIPTION,Text,Description of the violation.
CRITICAL FLAG,Text,Critical violation indicator ("Critical", "Not Critical").
SCORE,Number,Total score for a specific inspection.
GRADE,Text,Grade assigned to the inspection (A, B, C, N=Not Yet Graded, Z/P=Grade Pending).
GRADE DATE,Floating Timestamp,Date when the current grade was assigned to the restaurant.
RECORD DATE,Floating Timestamp,Extraction date for the production of this dataset.
INSPECTION TYPE,Text,Combination of inspection program and inspection type performed.
Latitude,Number,Latitude of the restaurant location.
Longitude,Number,Longitude of the restaurant location.
Community Board,Text,Community Board where the restaurant is located.
Council District,Text,Council District where the restaurant is located.
Census Tract,Text,Census Tract where the restaurant is located.
BIN,Text,Building Identification Number.
BBL,Text,Borough Block Lot number.
NTA,Text,Neighborhood Tabulation Area.
Location,Point,Geospatial location data (point).
*/

-- Creation of the table used to load the raw CSV data

CREATE TABLE raw_data_table (
    -- Identification and base data
    camis_code VARCHAR(10) NOT NULL,            -- Unique identifier code for the entity (restaurant/establishment).
    dba_name VARCHAR(120),                      -- Commercial name under which the entity operates (Doing Business As).
    boro_name VARCHAR(15),                      -- Borough or geographic district name (e.g., Manhattan, Brooklyn).
    building_number VARCHAR(15),                -- Building street number where the entity is located.
    street_name VARCHAR(100),                   -- Street name.
    zip_code VARCHAR(5) NOT NULL,               -- Postal code of the location.
    --phone_number VARCHAR(15),                   -- Phone number of the entity.
    cuisine_description VARCHAR(60),            -- Type of cuisine served or primary activity (e.g., Pizza, Italian).

    -- Inspection and scoring data
    inspection_date DATE,                       -- Date on which the inspection was carried out.
    action_taken VARCHAR(100),                  -- Description of the action taken (e.g., Violations cited, Establishment reopened).
    violation_code VARCHAR(5) NOT NULL,         -- Specific alphanumeric code of the violated regulation.
    violation_description VARCHAR(500),         -- Full textual description of the violation.
    critical_flag VARCHAR(15),                  -- Indicator classifying the severity of the violation (Critical, Not Critical).
    score_assigned INT                         -- Numeric score assigned to the inspection (higher is worse).
    --grade_assigned VARCHAR(2),                  -- Final grade assigned to the entity (A, B, C or pending).
    --grade_date DATE,                            -- Date on which the grade was formally assigned.
    --inspection_type VARCHAR(80),                -- Inspection category (e.g., Initial, Re-inspection, Follow-up).
    
    -- Administrative and geographic data
    --record_date DATE,                           -- Extraction and registration date of the record.
    --latitude NUMERIC(10, 7),                    -- Latitude geographic coordinate (Y).
    --longitude NUMERIC(10, 7),                   -- Longitude geographic coordinate (X).
    --community_board VARCHAR(5),                 -- Community Board identification code.
    --council_district VARCHAR(5),                -- Council District identification code.
    --census_tract VARCHAR(6),                    -- Census Tract identification code.
    --bin_number VARCHAR(10),                     -- Building Identification Number.
    --bbl_number VARCHAR(15),                     -- Borough Block and Lot number.
    --nta_code VARCHAR(5),                        -- Neighborhood Tabulation Area code.
    --location_ VARCHAR(255)                      -- String describing the geographic location (e.g., POINT(long lat)).
);

---------------------------------------------------------------------------------------------------------------------------
-- RAW DATA CLEANING AND TRANSFORMATION (performed with Power Query)
---------------------------------------------------------------------------------------------------------------------------

-- 1) removal of columns not required for the analytical objectives

-- 2) column renaming

-- 3) correct date formatting to YYYYMMDD

-- 4) replacement of dummy values or empty spaces with NULL

-- 5) data type correction

CREATE TABLE raw_data_table(
    camis_code VARCHAR(10) NOT NULL,
    establishment_name VARCHAR(120),
    area_name VARCHAR(15),
    building_code VARCHAR(15),
    street_name VARCHAR(150),
    zip_code VARCHAR(5) NOT NULL,
    cuisine_description VARCHAR(60),
    inspection_date DATE,
    action_taken VARCHAR(150),
    violation_code VARCHAR(5) NOT NULL,
    violation_description VARCHAR(2000),
    critical_flag VARCHAR(15),
    score_assigned INT
);

DROP TABLE raw_data_table;

-- INSERT CLEANED DATA INTO TABLE

COPY public.raw_data_table (
    camis_code, establishment_name, area_name, building_code, street_name, zip_code, 
    cuisine_description, inspection_date, action_taken, violation_code, 
    violation_description, critical_flag, score_assigned
)
FROM 'C:\raw_data\raw_data_table.csv' 
WITH (FORMAT csv, DELIMITER ';', HEADER, ENCODING 'UTF8', QUOTE '"');

-- Inspection date and assigned score must always be present, so we pre-filter them

DROP TABLE clean_data_table;

CREATE TABLE clean_data_table(
    camis_code VARCHAR(10) NOT NULL,
    establishment_name VARCHAR(120),
    area_name VARCHAR(15),
    building_code VARCHAR(15),
    street_name VARCHAR(150),
    zip_code VARCHAR(5) NOT NULL,
    cuisine_description VARCHAR(60),
    inspection_date DATE,
    action_taken VARCHAR(150),
    violation_code VARCHAR(5) NOT NULL,
    violation_description VARCHAR(2000),
    critical_flag VARCHAR(15),
    score_assigned INT
);

-- Score and inspection date are fundamental values for a consistent analysis

INSERT INTO clean_data_table (

    camis_code, establishment_name, area_name, building_code, street_name, zip_code, 
    cuisine_description, inspection_date, action_taken, violation_code, 
    violation_description, critical_flag, score_assigned

)
SELECT *
FROM
    raw_data_table
WHERE
    inspection_date IS NOT NULL
    AND score_assigned IS NOT NULL;

-- Visualization check
SELECT *
FROM
    clean_data_table;

SELECT
  violation_code,
  COUNT(DISTINCT action_taken) AS n_actions,
  COUNT(DISTINCT critical_flag) AS n_critical_flags
FROM clean_data_table
WHERE violation_code IS NOT NULL
GROUP BY violation_code
HAVING COUNT(DISTINCT action_taken) > 1
    OR COUNT(DISTINCT critical_flag) > 1;
