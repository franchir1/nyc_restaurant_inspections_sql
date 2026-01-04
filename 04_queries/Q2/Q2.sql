
/* ============================================================
   Q2A – Critical EVENTS count by area
   ============================================================

   Objective:
   Measure the intensity of critical issues across areas
   at violation (event) level.

   Definition:
   - One row = one violation (critical event).
   - Includes:
     • violations explicitly marked as Critical
     • violations associated with closure actions

   Notes:
   - A single inspection may generate multiple critical events.
   - This metric captures severity, not inspection distribution.

   Interpretation:
   - Manhattan and Brooklyn show the highest concentration
     of critical events.
   - Staten Island exhibits the lowest absolute volume.
*/

SELECT
    a.area_name,
    COUNT(*) AS critical_events_count
FROM fact_inspection fi
JOIN fact_inspection_violation fiv
    ON fi.inspection_key = fiv.inspection_key
JOIN violation_dim v
    ON fiv.violation_key = v.violation_key
JOIN area_dim a
    ON fi.area_key = a.area_key
WHERE
    fi.action_taken LIKE '%Closed%'
    OR v.critical_flag LIKE '%Critical%'
GROUP BY a.area_name
ORDER BY critical_events_count ASC;


/* Expected result:
   area_name        | critical_events_count
   -----------------|-----------------------
   STATEN ISLAND    | 3764
   BRONX            | 9341
   QUEENS           | 25756
   BROOKLYN         | 27478
   MANHATTAN        | 38272
*/


---


/* ============================================================
   Q2B – Critical INSPECTIONS count by area
   ============================================================

   Objective:
   Measure the distribution of critical inspections
   across areas at inspection level.

   Definition:
   - One inspection = one establishment + one inspection date.
   - An inspection is considered critical if it includes
     at least one critical violation or a closure action.

   Notes:
   - Collapsing to inspection level avoids duplicates
     caused by multiple violations in the same inspection.
   - Each inspection contributes exactly once.

   Interpretation:
   - Manhattan has the highest number of critical inspections.
   - The ranking reflects both establishment density
     and enforcement pressure.
*/

WITH critical_inspections AS (
    SELECT
        fi.establishment_key,
        fi.area_key,
        fi.date_key
    FROM fact_inspection fi
    LEFT JOIN fact_inspection_violation fiv
        ON fi.inspection_key = fiv.inspection_key
    LEFT JOIN violation_dim v
        ON fiv.violation_key = v.violation_key
    WHERE
        fi.action_taken LIKE '%Closed%'
        OR v.critical_flag LIKE '%Critical%'
    GROUP BY
        fi.establishment_key,
        fi.area_key,
        fi.date_key
)

SELECT
    a.area_name,
    COUNT(*) AS critical_inspection_events
FROM critical_inspections ci
JOIN area_dim a
    ON ci.area_key = a.area_key
GROUP BY a.area_name
ORDER BY critical_inspection_events ASC;


/* Expected result:
   area_name        | critical_inspection_events
   -----------------|----------------------------
   STATEN ISLAND    | 1186
   BRONX            | 2726
   QUEENS           | 7148
   BROOKLYN         | 8199
   MANHATTAN        | 11601
*/

