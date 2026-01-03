----------------------------------------------
-- Q1A
----------------------------------------------

-- Average scores per area (whole period, open establishments only)
--
-- Notes:
-- - Score: higher values indicate worse inspection outcomes.
-- - Closed establishments are excluded to avoid extreme administrative cases.
-- - Violations are first collapsed at inspection level (restaurant + day),
--   so that each inspection contributes exactly once to the average.
--
-- Interpretation:
-- - Queens shows the highest average inspection score (worst average performance).
-- - Staten Island shows the lowest average score (best average performance).
-- - The ranking is consistent with urban density and inspection pressure.

WITH inspection_level AS ( 
    SELECT
        iet.establishment_key,
        iet.date_key,
        iet.area_key,
        MAX(iet.score_assigned) AS inspection_score
    FROM
        inspection_events_table AS iet
    JOIN
        inspection_dim AS id
            ON id.inspection_key = iet.inspection_key
    WHERE
        id.action_taken NOT LIKE '%Closed%'
    GROUP BY
        iet.establishment_key,
        iet.date_key,
        iet.area_key
)
SELECT
    ad.area_name,
    ROUND(AVG(il.inspection_score), 2) AS average_score
FROM
    inspection_level AS il
JOIN
    area_dim AS ad
        ON ad.area_key = il.area_key
GROUP BY
    ad.area_name
ORDER BY
    average_score ASC;

-- Expected result:
-- Staten Island  16.84
-- Manhattan     17.31
-- Bronx         17.87
-- Brooklyn      18.10
-- Queens        19.29


----------------------------------------------
-- Q1B
----------------------------------------------

-- Establishments count per area (open establishments only)
--
-- Notes:
-- - Each establishment is counted once per area.
-- - An establishment is considered "open" if it appears
--   in at least one inspection with a non-Closed action.
--
-- Interpretation:
-- - Manhattan hosts the largest number of active establishments.
-- - Staten Island has the smallest commercial density.

SELECT
    ad.area_name,
    COUNT(DISTINCT ed.establishment_key) AS total_establishments_area
FROM
    establishment_dim AS ed
JOIN
    inspection_events_table AS iet
        ON iet.establishment_key = ed.establishment_key
JOIN
    area_dim AS ad
        ON ad.area_key = iet.area_key
JOIN
    inspection_dim AS id
        ON id.inspection_key = iet.inspection_key
WHERE
    id.action_taken NOT LIKE '%Closed%'
GROUP BY
    ad.area_name
ORDER BY
    total_establishments_area;

-- Expected result:
-- Staten Island   720
-- Bronx          1681
-- Queens         4305
-- Brooklyn       4977
-- Manhattan      7223


-- Inspections count per area (whole period, open establishments only)
--
-- Notes:
-- - Violations are collapsed to inspection level
--   (restaurant + inspection date).
-- - Each inspection is counted exactly once.
-- - Closed inspections are excluded.
--
-- Interpretation:
-- - Manhattan concentrates the highest absolute number of inspections.
-- - Inspection volume broadly follows establishment density,
--   suggesting proportional inspection coverage across areas.

WITH inspection_level AS (
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
        id.action_taken NOT LIKE '%Closed%'
    GROUP BY
        iet.establishment_key,
        iet.area_key,
        iet.date_key
)
SELECT
    ad.area_name,
    COUNT(*) AS total_inspections
FROM
    inspection_level AS il
JOIN
    area_dim AS ad
        ON ad.area_key = il.area_key
GROUP BY
    ad.area_name
ORDER BY
    total_inspections DESC;

-- Expected result:
-- Manhattan      11502
-- Brooklyn        8132
-- Queens          7115
-- Bronx           2719
-- Staten Island   1179
