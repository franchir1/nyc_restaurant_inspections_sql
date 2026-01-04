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

/* ----------------------------
   Main query (star schema)
   ---------------------------- */

WITH critical_events AS (
    SELECT
        fi.area_key
    FROM fact_inspection AS fi
    JOIN fact_inspection_violation AS fiv
        ON fi.inspection_key = fiv.inspection_key
    WHERE
        fi.action_taken LIKE '%closed%'
        OR fiv.critical_flag LIKE '%critical%'
)

SELECT
    a.area_name,
    COUNT(*) AS critical_events_count
FROM critical_events AS ce
JOIN area_dim AS a
    ON ce.area_key = a.area_key
GROUP BY
    a.area_name
ORDER BY
    critical_events_count ASC;

/*
Output (star schema):

area_name        | critical_events_count
---------------------------------------
STATEN ISLAND    | 11
BRONX            | 91
QUEENS           | 347
BROOKLYN         | 377
MANHATTAN        | 496
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
    OR critical_flag LIKE '%Critical%'
GROUP BY
    area_name
ORDER BY
    critical_events_count ASC;

/*
Output (clean_data_table):

area_name        | critical_events_count
---------------------------------------
STATEN ISLAND    | 163
BRONX            | 916
QUEENS           | 2615
MANHATTAN        | 3185
BROOKLYN         | 3519
*/

/*
Warning
- The large discrepancy suggests filtering or join-level loss
  in the star schema query (likely inspection–violation linkage
  or area_key coverage).
*/
