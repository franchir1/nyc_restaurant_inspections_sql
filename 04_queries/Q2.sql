/* ============================================================
Q2A – Critical violation events by area
============================================================

Objective:
Count the total number of critical violation events by area.

Grain:
- One row = one violation event

Definition:
- A violation event is considered critical if
  its severity flag is explicitly marked as 'CRITICAL'.

Notes:
- A single inspection can generate multiple violation events.
- Multiple critical violations may occur within the same inspection.
- This analysis measures severity concentration,
  not inspection volume or administrative outcomes.
*/


/* ============================================================
Q2A – Star schema query (violation-level fact)
============================================================ */

SELECT
    a.area_name,
    COUNT(*) AS critical_events
FROM fact_inspection_violation fiv
JOIN fact_inspection fi
    ON fi.inspection_key = fiv.inspection_key
JOIN area_dim a
    ON a.area_key = fi.area_key
WHERE
    fiv.critical_flag = 'CRITICAL'
GROUP BY
    a.area_name
ORDER BY
    critical_events;


/*
Expected output (star schema):

area_name        | critical_events
-----------------|----------------
STATEN ISLAND    | 5489
BRONX            | 14244
QUEENS           | 39149
BROOKLYN         | 40429
MANHATTAN        | 56770
*/


/* ============================================================
Validation query – Clean data table
============================================================

Purpose:
Validate that the star schema reproduces the same
violation-level critical event counts as the clean table.
*/

SELECT
    area_name,
    COUNT(*) AS critical_events
FROM clean_data_table
WHERE
    critical_flag = 'CRITICAL'
GROUP BY
    area_name
ORDER BY
    critical_events;


/*
Expected output (clean_data_table):

area_name        | critical_events
-----------------|----------------
STATEN ISLAND    | 5489
BRONX            | 14244
QUEENS           | 39153
BROOKLYN         | 40429
MANHATTAN        | 56772
*/


/* ============================================================
Data grain diagnostics – Clean table
============================================================

Purpose:
Confirm that the clean table operates at violation-level grain.
*/

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT (camis_code, inspection_date)) AS distinct_inspections,
  COUNT(DISTINCT (camis_code, inspection_date, violation_code)) AS distinct_inspection_violation_pairs
FROM clean_data_table;

-- Expected output (clean data table):

-- tot rows |  distinct_inspections  | distinct_inspection_violation_pairs
----------------------------------------------------------------------------
-- 295K     |  87K                   |  295K


/* ============================================================
Diagnostic – Multiple critical violations per inspection
============================================================

Purpose:
Verify that a single inspection can generate
multiple critical violation events.
*/

SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS critical_violations
FROM clean_data_table
WHERE
    critical_flag = 'CRITICAL'
GROUP BY
    camis_code,
    inspection_date
HAVING
    COUNT(*) > 1
ORDER BY
    critical_violations DESC
LIMIT 20;


/*
Sample output:

camis_code | inspection_date | critical_violations
-----------|-----------------|--------------------
50166892   | 2025-05-21      | 13
50041401   | 2024-09-19      | 12
...
*/


/* ============================================================
Diagnostic – critical_flag variability within inspections
============================================================

Purpose:
Confirm that critical_flag varies within the same inspection,
proving it is a violation-level attribute.
*/

SELECT
    camis_code,
    inspection_date,
    COUNT(DISTINCT critical_flag) AS distinct_flags
FROM clean_data_table
GROUP BY
    camis_code,
    inspection_date
HAVING
    COUNT(DISTINCT critical_flag) > 1
LIMIT 20;


/*
Sample output:

camis_code | inspection_date | distinct_flags
-----------|-----------------|---------------
30075445   | 2023-01-31      | 2
30075445   | 2023-02-03      | 2
...
*/


/* ============================================================
Modeling statement – Critical flag
============================================================

critical_flag is a violation-level attribute.
It represents the severity of a specific violation
observed during an inspection, not a property of the inspection.

A single inspection may generate multiple violations,
and multiple critical violations can occur within the same inspection.

For this reason:
- critical_flag must NOT be stored in fact_inspection.
- It must be stored in the violation-level fact table
  (fact_inspection_violation).

Any inspection-level critical indicator
(e.g. has_critical_violation)
must be derived from violation-level data,
not stored as a base attribute.
*/
