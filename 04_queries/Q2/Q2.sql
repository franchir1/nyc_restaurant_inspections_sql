--------------------------------------------------
-- Q2A — Critical EVENTS count per area
--------------------------------------------------
-- Definition:
-- - Counts CRITICAL EVENTS at violation level.
-- - One row = one violation.
-- - Includes:
--   • violations marked as Critical
--   • violations associated with closure actions
--
-- Interpretation:
-- - Measures the INTENSITY of critical issues.
-- - A single inspection may generate multiple critical events.

SELECT
    ad.area_name,
    COUNT(*) AS critical_events_count
FROM
    inspection_events_table AS iet
JOIN
    inspection_dim AS id
        ON id.inspection_key = iet.inspection_key
JOIN
    area_dim AS ad
        ON ad.area_key = iet.area_key
WHERE
    id.action_taken LIKE '%Closed%'
    OR id.critical_flag LIKE '%Critical%'
GROUP BY
    ad.area_name
ORDER BY
    critical_events_count ASC;

-- Result:
--
-- "area_name","critical_events_count"
-- "Staten Island","3764"
-- "Bronx","9341"
-- "Queens","25756"
-- "Brooklyn","27478"
-- "Manhattan","38272"


--------------------------------------------------
-- Q2B — Critical INSPECTIONS count per area
--------------------------------------------------
-- Definition:
-- - Counts CRITICAL INSPECTIONS at inspection level.
-- - One inspection = one restaurant + one inspection date.
-- - An inspection is considered critical if it includes
--   at least one critical violation or a closure action.
--
-- Interpretation:
-- - Measures the DISTRIBUTION of critical inspections.
-- - Avoids duplicates caused by multiple violations
--   within the same inspection.

WITH critical_inspections AS (
    SELECT
        iet.establishment_key,
        iet.area_key,
        iet.date_key
    FROM
        inspection_events_table AS iet
    JOIN
        inspection_dim AS id
            ON id.inspection_key = iet.inspection_key
    WHERE
        id.action_taken LIKE '%Closed%'
        OR id.critical_flag LIKE '%Critical%'
    GROUP BY
        iet.establishment_key,
        iet.area_key,
        iet.date_key
)
SELECT
    ad.area_name,
    COUNT(*) AS critical_inspection_events
FROM
    critical_inspections AS ci
JOIN
    area_dim AS ad
        ON ad.area_key = ci.area_key
GROUP BY
    ad.area_name
ORDER BY
    critical_inspection_events ASC;

-- Result:
--
-- "area_name","critical_inspection_events"
-- "Staten Island","1186"
-- "Bronx","2726"
-- "Queens","7148"
-- "Brooklyn","8199"
-- "Manhattan","11601"
