/* ============================================================
Q5 – Percentage of establishments that improved
     their inspection score over time
============================================================

Objective:
Measure the effectiveness of corrective actions by evaluating
whether establishments improved their inspection score between
their first and last observed inspection.

Grain:
- One row = one establishment

Definition:
- An establishment is considered "improved" if its last
  inspection score is lower than its first inspection score.

Notes:
- Only inspections with a valid (non-NULL) score are considered.
- Establishments with fewer than two inspection-days
  are excluded from the analysis.
- Lower score values indicate better inspection outcomes.
*/


/* ============================================================
Step 1 – Select scored inspections
============================================================

Purpose:
Isolate inspection-days with a valid score to avoid
NULL-related distortions in trend evaluation.
*/

WITH scored_inspections AS (
    SELECT
        establishment_key,
        date_key,
        score_assigned
    FROM fact_inspection
    WHERE score_assigned IS NOT NULL
),


/* ============================================================
Step 2 – Identify first and last inspection score
           per establishment
============================================================

Purpose:
- Capture the initial and final inspection score
  for each establishment.
- Count the number of scored inspections per establishment
  to exclude single-observation cases.
*/

establishment_first_last AS (
    SELECT
        establishment_key,

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
        ) AS inspection_count
    FROM scored_inspections
),


/* ============================================================
Step 3 – Aggregate at establishment level
============================================================

Purpose:
- Retain one row per establishment.
- Count total establishments considered.
- Count establishments that improved over time.
*/

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
        FROM establishment_first_last
        WHERE inspection_count >= 2
    ) t
)


/* ============================================================
Step 4 – Final metric
============================================================

Output:
- Percentage of establishments that improved
  their inspection score over time.
*/

SELECT
    ROUND(
        improved_establishments::NUMERIC
        / total_establishments * 100,
        2
    ) AS improved_percentage
FROM aggregated;


/*
Output – Q5

improved_percentage
-------------------
58.63

Interpretation:
- Approximately 58.6% of establishments show an improvement
  in inspection score between their first and last inspection.
- This suggests that corrective actions and follow-up
  inspections are generally effective.
- Intermediate fluctuations are intentionally ignored
  to focus on long-term outcomes.
*/
