# ETL – Data Extraction, Cleaning, and Loading

## Dataset source

The original dataset includes:

* establishment information
* inspection dates and types
* detected violations
* assigned scores
* extensive administrative and geographic data

Not all columns are relevant. Targeted selection and normalization are therefore required.

## Raw data preparation

The original DOHMH dataset is initially processed **outside the database** using **Power Query (Excel)**.

The applied transformations include:

1. removal of administrative and non-relevant columns
2. renaming columns with semantic names
3. normalization of date formats
4. replacement of empty or dummy values with `NULL`
5. data type correction
6. removal of rows missing `inspection_date` or `score_assigned`

At the end of this phase, the dataset is exported as a CSV file and used as input for PostgreSQL.

## Creation of the intermediate table

In the PostgreSQL database, a **staging** table named `raw_data_table` is created.

This table:

* **does not represent the original raw dataset**
* contains data **already cleaned and normalized** via Power Query
* serves as an intermediate layer before final filtering

```sql
CREATE TABLE raw_data_table (
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
```

## Loading cleaned data

The cleaned dataset is exported as a CSV file and loaded into PostgreSQL using the `COPY` command.

```sql
COPY public.raw_data_table (
    camis_code,
    establishment_name,
    area_name,
    building_code,
    street_name,
    zip_code,
    cuisine_description,
    inspection_date,
    action_taken,
    violation_code,
    violation_description,
    critical_flag,
    score_assigned
)
FROM 'C:\raw_data\raw_data_table.csv'
WITH (FORMAT csv, DELIMITER ';', HEADER, ENCODING 'UTF8', QUOTE '"');
```

## Creation of the final table

The `clean_data_table` represents the **final dataset** used throughout the project.

```sql
CREATE TABLE clean_data_table (
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
```

## Filtering invalid rows

To ensure consistent analysis, only rows containing:

* a **valid inspection date**
* a **valid assigned score**

are inserted into the final table.

```sql
INSERT INTO clean_data_table
SELECT *
FROM raw_data_table
WHERE inspection_date IS NOT NULL
  AND score_assigned IS NOT NULL;
```

### Rationale

* without a date → no temporal analysis
* without a score → no performance evaluation

## Database reset and maintenance tools

During development and testing, it is necessary to quickly clean tables.

```sql
TRUNCATE TABLE date_dim RESTART IDENTITY;
TRUNCATE TABLE establishment_dim RESTART IDENTITY;
TRUNCATE TABLE area_dim RESTART IDENTITY;
TRUNCATE TABLE inspection_dim RESTART IDENTITY;
TRUNCATE TABLE inspection_events_table RESTART IDENTITY;
```

For a full cleanup with active constraints:

```sql
TRUNCATE TABLE
    date_dim,
    establishment_dim,
    area_dim,
    inspection_dim
RESTART IDENTITY CASCADE;
```

## Constraint management and schema adjustment

During loading and joins, some `NOT NULL` constraints may cause errors. For this reason, they are temporarily removed.

```sql
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
```

To prevent truncation of violation descriptions:

```sql
ALTER TABLE public.raw_data_table
ALTER COLUMN violation_description TYPE VARCHAR(2000);
```

## Final output of the ETL phase

The result of the ETL process is the `clean_data_table`:

* containing only valid data
* semantically consistent
* ready for star schema modeling

*Back to the [README](/README.md)*
