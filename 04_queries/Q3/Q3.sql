-- QUERY 3: SCORE TRENDS OVER TIME BY AREA (TREND ANALYSIS)
-- Objective: analyze the evolution of the average scores ('score_assigned')
-- over the years (inspection_year) by area, to detect long-term improvements or deteriorations.

SELECT
    dd.inspection_year,
    ad.area_name,
    ROUND(AVG(iet.score_assigned), 0) AS avg_score
FROM
    inspection_events_table AS iet
JOIN
    area_dim AS ad ON ad.area_key = iet.area_key
JOIN
    date_dim AS dd ON dd.date_key = iet.date_key
GROUP BY
    dd.inspection_year,
    ad.area_name
ORDER BY
    dd.inspection_year ASC,
    ad.area_name ASC;

-- Objective: analyze the evolution of the number of inspections by area
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
