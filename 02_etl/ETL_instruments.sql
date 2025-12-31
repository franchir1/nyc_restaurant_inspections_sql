-----------------------------------------------------------------------------------------------------------------------
-- TOOLS FOR DATA CLEANING AND TRANSFORMATION
-----------------------------------------------------------------------------------------------------------------------

-- Clears all data

TRUNCATE TABLE date_dim RESTART IDENTITY;
TRUNCATE TABLE establishment_dim RESTART IDENTITY;
TRUNCATE TABLE area_dim RESTART IDENTITY;
TRUNCATE TABLE inspection_dim RESTART IDENTITY; 
TRUNCATE TABLE inspection_events_table RESTART IDENTITY;

-- Clears all data from all dimensional tables even if referenced :)

TRUNCATE TABLE date_dim, establishment_dim, area_dim, inspection_dim
RESTART IDENTITY CASCADE;

------------------------------------------------------------------------------------------------------------------------
-- OTHER USEFUL COMMANDS FOR TABLE FORMATTING
------------------------------------------------------------------------------------------------------------------------

-- Removes NOT NULL constraints from columns, if still present and causing errors during data copy and insert
ALTER TABLE public.clean_data_table ALTER COLUMN camis_code DROP NOT NULL; 
ALTER TABLE public.clean_data_table ALTER COLUMN establishment_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN cuisine_description DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN area_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN building_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN street_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN zip_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN inspection_date DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN action_taken DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN violation_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN violation_description DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN critical_flag DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN score_assigned DROP NOT NULL;

-- Increases character limits for fields, in case a string exceeds the current length constraint
ALTER TABLE public.raw_data_table 
ALTER COLUMN violation_description TYPE VARCHAR(2000);
