-- Distribution of the number of establishments by area
SELECT
    ad.area_name,
    COUNT(DISTINCT ed.establishment_key) AS total_establishments_area -- counts each establishment only once
FROM
    establishment_dim AS ed
JOIN
    inspection_events_table AS iet ON iet.establishment_key = ed.establishment_key
JOIN
    area_dim AS ad ON ad.area_key = iet.area_key
GROUP BY
    ad.area_name
ORDER BY
    total_establishments_area;

-- Distribution of the total number of inspections performed per area between 2015 and 2025
SELECT
    ad.area_name AS area_name,
    COUNT(event_key) AS total_events
FROM
    inspection_events_table AS iet
LEFT JOIN
    area_dim AS ad ON ad.area_key = iet.area_key
GROUP BY
    area_name
ORDER BY
    total_events DESC;

-- Distribution of the average number of annual inspections per area

WITH area_inspection_year_count AS (
    SELECT
        ad.area_name AS area_name,
        dd.inspection_year AS inspection_year,
        COUNT(iet.event_key) AS total_count_year
    FROM
        inspection_events_table AS iet
    JOIN
        area_dim AS ad ON iet.area_key = ad.area_key
    JOIN    
        date_dim AS dd ON iet.date_key = dd.date_key
    GROUP BY
        area_name,
        inspection_year
    ORDER BY
        area_name,
        inspection_year
),
step2 AS (
    SELECT
        area_name,
        inspection_year,
        AVG(total_count_year) AS avg_year
    FROM
        area_inspection_year_count
    GROUP BY
        area_name,
        inspection_year
)

SELECT
    area_name,
    ROUND(AVG(avg_year), 0) AS avg_area
FROM
    step2
GROUP BY
    area_name
ORDER BY
    avg_area DESC;

-- the result is the same
