-- Q4 — Hygiene violations: weekends vs weekdays (normalized)
--
-- Hypothesis:
-- Higher customer traffic during weekends may increase the likelihood
-- of hygiene violations. Since weekends cover fewer days (2 vs 5),
-- violations are normalized by day count.

WITH violation_totals AS (
    SELECT
        COUNT(*) AS total_violations,
        COUNT(
            CASE
                WHEN dd.is_weekend = TRUE
                THEN 1
            END
        ) AS weekend_violations
    FROM inspection_events_table AS iet
    JOIN inspection_dim AS id
        ON iet.inspection_key = id.inspection_key
    JOIN date_dim AS dd
        ON iet.date_key = dd.date_key
    WHERE id.violation_code IS NOT NULL
),

normalized AS (
    SELECT
        total_violations,
        weekend_violations,
        total_violations - weekend_violations AS weekday_violations,

        -- normalize by number of days
        (weekend_violations / 2.0) AS weekend_per_day,
        ((total_violations - weekend_violations) / 5.0) AS weekday_per_day
    FROM violation_totals
)

SELECT
    total_violations,
    weekend_violations,
    weekday_violations,

    ROUND(
        weekend_per_day
        / (weekend_per_day + weekday_per_day)
        * 100,
        2
    ) AS normalized_weekend_percentage,

    ROUND(
        weekday_per_day
        / (weekend_per_day + weekday_per_day)
        * 100,
        2
    ) AS normalized_weekday_percentage
FROM normalized;

/*
RESULTS — Normalized weekend vs weekday violations

total_violations              : 104611
weekend_violations            : 29903
weekday_violations            : 74708
normalized_weekend_percentage : 50.02 %
normalized_weekday_percentage : 49.98 %

Interpretation:
Once normalized by the number of days (2 weekend vs 5 weekdays),
the daily probability of a hygiene violation is effectively identical.
*/
