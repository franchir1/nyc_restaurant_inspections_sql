-- Q5 — Percentage of establishments that improved their inspection score
--
-- Objective:
-- Measure the effectiveness of corrective actions by checking whether
-- establishments reduced their score between the first and last inspection.
-- (Lower score = better outcome)

WITH establishment_scores AS (
    SELECT
        establishment_key,

        -- oldest inspection score
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key ASC
        ) AS first_score,

        -- most recent inspection score
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key DESC
        ) AS last_score

    FROM inspection_events_table
),

aggregated AS (
    SELECT
        COUNT(*) AS total_establishments,
        COUNT(
            CASE
                WHEN last_score < first_score
                THEN 1
            END
        ) AS improved_establishments
    FROM (
        -- DISTINCT guarantees one row per establishment
        SELECT DISTINCT
            establishment_key,
            first_score,
            last_score
        FROM establishment_scores
    ) t
)

SELECT
    ROUND(
        improved_establishments::NUMERIC / total_establishments * 100,
        2
    ) AS improved_percentage
FROM aggregated;

-- improved_percentage
------------------
-- 22.09
