-- Q3A

-- Evolution of the avg_score

WITH inspection_level AS (
    SELECT
    area_key,
    establishment_key,
    date_key,
    MAX(score_assigned) As score
FROM
    inspection_events_table AS iet
GROUP BY
    area_key, establishment_key, date_key
) 
SELECT
    ad.area_name,
    ROUND(AVG(il.score), 2) AS avg_score
FROM
    inspection_level AS il
JOIN
    area_dim AS ad ON ad.area_key = il.area_key
GROUP BY
    ad.area_name
ORDER BY
    avg_score ASC

/*

"area_name","avg_score"
"Staten Island","16.78"
"Manhattan","17.24"
"Bronx","17.85"
"Brooklyn","18.02"
"Queens","19.23"

*/

-- Objective: analyze the evolution of the number of inspections by area

WITH inspection_level AS (
    SELECT
    area_key,
    establishment_key,
    date_key
FROM
    inspection_events_table AS iet
GROUP BY
    area_key, establishment_key, date_key
) 
SELECT
    ad.area_name,
    dd.inspection_year,
    COUNT(*) AS inspection_count
FROM
    inspection_level AS il
JOIN
    area_dim AS ad ON ad.area_key = il.area_key
JOIN
    date_dim AS dd ON dd.date_key = il.date_key
GROUP BY
    ad.area_name, dd.inspection_year
ORDER BY
    ad.area_name, dd.inspection_year ASC

SELECT
    dd.inspection_year,
    ad.area_name,
    COUNT(iet.event_key) AS inspection_count
FROM
    inspection_events_table AS iet
JOIN
    area_dim AS ad ON ad.area_key = iet.area_key
JOIN
    date_dim AS dd ON dd.date_key = iet.date_key
GROUP BY
    ad.area_name,
    dd.inspection_year
ORDER BY
    dd.inspection_year ASC,
    ad.area_name ASC;
