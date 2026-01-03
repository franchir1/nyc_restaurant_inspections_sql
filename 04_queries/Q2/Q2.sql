-- Q2 Critical events count (critical violations or closure-related descriptions)

SELECT
    ad.area_name AS area,
    COUNT(event_key) AS total_critical_events
FROM
    inspection_events_table AS iet
JOIN
    area_dim AS ad ON iet.area_key = ad.area_key
JOIN
    inspection_dim AS id ON iet.inspection_key = id.inspection_key
WHERE
    (id.critical_flag = 'Critical' OR id.action_taken LIKE '%Closed%') 
    -- filters only records containing the term 'Closed' in "violation_description"
    -- and 'Critical' in "critical_flag"
GROUP BY
    area
ORDER BY
    total_critical_events ASC;
