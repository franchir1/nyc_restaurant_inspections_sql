-- QUERY 4: CHECK THE PERCENTAGE OF HYGIENE VIOLATIONS DURING WEEKENDS (SAT–SUN)
-- COMPARED TO WEEKDAYS (MON–FR)

-- Objective: during weekends, high customer traffic may cause negligence
-- in complying with hygiene regulations, potentially indicating poor management issues

WITH violations_count_list AS (
    -- CTE: calculates total violations and violations occurring only on weekends
    SELECT
        COUNT(
            CASE 
                WHEN id.violation_code IS NOT NULL 
                THEN 1 
            END
        ) AS total_violations,
        COUNT(
            CASE 
                WHEN (id.violation_code IS NOT NULL AND dd.is_weekend = TRUE) 
                THEN 1 
            END
        ) AS total_wknd_violations
    FROM
        inspection_events_table AS iet
    JOIN
        inspection_dim AS id ON iet.inspection_key = id.inspection_key
    JOIN
        date_dim AS dd ON iet.date_key = dd.date_key
)
SELECT -- display the percentage of weekend violations over total violations
    total_wknd_violations,
    (total_violations - total_wknd_violations) AS total_weekdays
FROM
    violations_count_list;
