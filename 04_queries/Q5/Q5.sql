-- QUERY 5: CALCULATE THE PERCENTAGE OF ESTABLISHMENTS THAT IMPROVED THEIR SCORE OVER INSPECTIONS
-- Objective: measure the effectiveness of corrective actions.

WITH scores_list AS (
    -- CTE 1: defines the first and last score assigned to each establishment using the FIRST_VALUE function
    SELECT DISTINCT
        establishment_key,
        -- initial score (oldest)
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key ASC -- ascending date order selects the first value, i.e. the oldest
        ) AS first_score,
        -- final score (most recent)
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key DESC  -- descending date order selects the first value, i.e. the most recent
        ) AS last_score
    FROM
        inspection_events_table
), 
final_counts AS (
    -- CTE 2: calculates the numerator (improved) and the denominator (total)
    SELECT
        COUNT(DISTINCT(establishment_key)) AS total,
        COUNT(
            CASE
                WHEN last_score < first_score -- improved establishments reduced their score
                THEN 1
            END
        ) AS improved
    FROM
        scores_list
)

SELECT -- final calculation of the percentage of establishments that improved their score
    ROUND(CAST(improved AS DECIMAL) / total, 2) * 100 AS improved_percentage
FROM
    final_counts;
