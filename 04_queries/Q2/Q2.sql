/* ============================================================
   Q2A – Critical events count by area
   ============================================================

   Objective
   Count the total number of critical violation events by area.

   Definition
   - One row = one violation event
   - An event is considered critical if:
     • the inspection resulted in a closure action, OR
     • the violation is explicitly marked as critical

   Notes
   - A single inspection can generate multiple critical events
   - This measures severity concentration, not inspection volume
*/

/* ============================================================
Q2A – Critical violation events by area
(grain: violation event)
============================================================ */

SELECT
    a.area_name,
    COUNT(*) AS critical_events
FROM fact_inspection_violation fiv
JOIN fact_inspection fi
    ON fi.inspection_key = fiv.inspection_key
JOIN area_dim a
    ON a.area_key = fi.area_key
WHERE (fiv.critical_flag = 'CRITICAL') OR (fi.action_taken LIKE '%Closed%') 
GROUP BY a.area_name
ORDER BY critical_events;


/*
Output (star schema):
"area_name","critical_events"
"STATEN ISLAND","5543"
"BRONX","14497"
"QUEENS","39963"
"BROOKLYN","41478"
"MANHATTAN","57561"

*/


/* ----------------------------
   Validation query (flat table)
   ---------------------------- */

SELECT
    area_name,
    COUNT(*) AS critical_events_count
FROM clean_data_table
WHERE
    action_taken LIKE '%Closed%'
    OR critical_flag = 'CRITICAL'
GROUP BY
    area_name
ORDER BY
    critical_events_count ASC;

/*
Output (clean_data_table):
"area_name","critical_events_count"
"STATEN ISLAND","5548"
"BRONX","14543"
"QUEENS","40088"
"BROOKLYN","41703"
"MANHATTAN","57883"

*/


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT inspection_key) AS distinct_inspections,
    COUNT(DISTINCT inspection_key, violation_code) AS distinct_inspection_violation_pairs
FROM clean_data_table;

SELECT *
FROM clean_data_table
LIMIT 10;

-- 1 ispezione 1+ ispezioni critiche?

SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS critical_violations
FROM clean_data_table
WHERE critical_flag = 'CRITICAL'
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(*) > 1
ORDER BY critical_violations DESC
LIMIT 20;


/*

"camis_code","inspection_date","critical_violations"
"50166892","2025-05-21","13"
"50041401","2024-09-19","12"
"50134720","2023-08-24","12"
"50139259","2024-07-25","12"
"50097274","2025-09-11","12"
"50147215","2024-09-05","12"
"50106213","2022-09-28","11"
"50127670","2025-08-28","11"
"50145810","2025-06-06","11"
"50042177","2025-07-25","11"
"41362111","2024-07-24","11"
"50147140","2024-03-20","11"
"50163101","2025-09-22","11"
"50157149","2025-02-20","10"
"50167859","2025-12-17","10"
"50120714","2024-12-16","10"
"50150340","2024-12-17","10"
"50128348","2024-07-15","10"
"50123073","2022-07-15","10"
"50146996","2024-08-12","10"


*/

-- crit flag varia all'interno della stessa ispezione?

SELECT
    camis_code,
    inspection_date,
    COUNT(DISTINCT critical_flag) AS distinct_flags
FROM clean_data_table
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(DISTINCT critical_flag) > 1
LIMIT 20;

/*

"camis_code","inspection_date","distinct_flags"
"30075445","2023-01-31","2"
"30075445","2023-02-03","2"
"30075445","2023-08-01","2"
"30075445","2023-08-22","2"
"30075445","2024-11-08","2"
"30191841","2024-11-20","2"
"40356018","2024-04-16","2"
"40356018","2025-09-17","2"
"40356483","2022-01-24","2"
"40356483","2022-08-03","2"
"40356483","2023-11-16","2"
"40356483","2024-04-23","2"
"40356731","2023-01-17","2"
"40356731","2024-04-08","2"
"40357217","2024-05-21","2"
"40357217","2025-10-20","2"
"40359480","2025-12-02","2"
"40359705","2023-04-26","2"
"40359705","2024-07-24","2"
"40360045","2022-01-05","2"


*/


-- critical_flag is a violation-level attribute.
-- It represents the severity of a specific violation observed during an inspection,
-- not a property of the inspection itself.
--
-- A single inspection may generate multiple violations,
-- and multiple critical violations can occur within the same inspection.
--
-- For this reason, critical_flag must NOT be stored in fact_inspection.
-- It must be stored in the fact table representing violation events
-- (fact_inspection_violation), which operates at violation-level grain.
--
-- Any inspection-level critical indicator (e.g. "has_critical_violation")
-- must be derived from violation-level data, not stored as a base attribute.
