-- Q4 — Percentage of hygiene violations during weekends (Sat–Sun)
-- compared to weekdays (Mon–Fri)
--
-- Hypothesis:
-- Higher customer traffic during weekends may increase the likelihood
-- of hygiene violations, indicating potential management issues.

WITH violations_counts AS (
    SELECT
        COUNT(id.violation_code) AS total_violations,
        COUNT(
            CASE
                WHEN dd.is_weekend = TRUE
                THEN id.violation_code
            END
        ) AS weekend_violations
    FROM inspection_events_table AS iet
    JOIN inspection_dim AS id
        ON iet.inspection_key = id.inspection_key
    JOIN date_dim AS dd
        ON iet.date_key = dd.date_key
    WHERE id.violation_code IS NOT NULL
)

SELECT
    weekend_violations,
    total_violations - weekend_violations AS weekday_violations,
    ROUND(
        weekend_violations::NUMERIC / total_violations * 100,
        2
    ) AS weekend_violation_percentage
FROM violations_counts;


/*

weekend_violations | weekday_violations | weekend_violation_percentage
------------------ | ------------------ | ----------------------------
29903              | 74708              | 28.58

*/