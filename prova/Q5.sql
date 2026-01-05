/* ============================================================
   Q5 — Percentage of establishments that improved
        their inspection score (inspection-day level)
   ============================================================

   Objective
   Measure the effectiveness of corrective actions by checking
   whether establishments reduced their inspection score between
   the first and last observed inspection-day.

   Notes
   - Grain: 1 row = 1 establishment × 1 inspection date
   - Establishments with only one inspection-day are excluded
   - Lower score = better outcome
*/

/* ----------------------------
   First and last inspection-day
   ---------------------------- */

WITH establishment_scores AS (
    SELECT
        establishment_key,
        date_key,
        score_assigned,

        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key ASC
        ) AS first_score,

        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key DESC
        ) AS last_score,

        COUNT(*) OVER (
            PARTITION BY establishment_key
        ) AS inspection_days
    FROM fact_inspection
),

/* ----------------------------
   Aggregate at establishment level
   ---------------------------- */

aggregated AS (
    SELECT
        COUNT(*) AS total_establishments,
        COUNT(
            CASE
                WHEN last_score < first_score THEN 1
            END
        ) AS improved_establishments
    FROM (
        SELECT DISTINCT
            establishment_key,
            first_score,
            last_score
        FROM establishment_scores
        WHERE inspection_days >= 2
    ) t
)

/* ----------------------------
   Final metric
   ---------------------------- */

SELECT
    ROUND(
        improved_establishments::NUMERIC
        / total_establishments * 100,
        2
    ) AS improved_percentage
FROM aggregated;
