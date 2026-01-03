----------------------------------------------
-- Q1A
----------------------------------------------

-- Average scores per area

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

----------------------------------------------
-- Q1B
----------------------------------------------

-- Establishments counts per area
SELECT
    ad.area_name,
    COUNT(DISTINCT ed.establishment_key) AS total_establishments_area -- counts each establishment only once
FROM
    establishment_dim AS ed
JOIN
    inspection_events_table AS iet ON iet.establishment_key = ed.establishment_key
JOIN
    area_dim AS ad ON ad.area_key = iet.area_key
JOIN
    inspection_dim AS id ON id.inspection_key = iet.inspection_key
WHERE
    id.action_taken NOT LIKE '%Closed%'
GROUP BY
    ad.area_name
ORDER BY
    total_establishments_area;

-- Inspections counts per area (whole period)
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

