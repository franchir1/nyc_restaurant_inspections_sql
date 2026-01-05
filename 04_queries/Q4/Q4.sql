/* ============================================================
Q4 – Distribution of inspections: weekdays vs weekends
============================================================

Objective:
Determine whether health inspections are predominantly
conducted on weekdays or during weekends.

Correct analytical question:
- This analysis focuses on WHEN inspections are performed,
  not on hygiene outcomes or violation severity.

Grain:
- One row = one inspection

Metric:
- Number of inspections by day type
- Percentage of inspections by day type

Interpretation guide:
- Weekend days account for 2 out of 7 calendar days (~28.6%).
- A much lower percentage indicates weekday-oriented scheduling.
*/


/* ============================================================
Step 1 – Count inspections by day type
============================================================ */

WITH inspections_by_day_type AS (
    SELECT
        dd.is_weekend,
        COUNT(*) AS inspection_count
    FROM fact_inspection fi
    JOIN date_dim dd
        ON dd.date_key = fi.date_key
    GROUP BY
        dd.is_weekend
),

/* ============================================================
Step 2 – Compute total inspections
============================================================ */

total_inspections AS (
    SELECT
        SUM(inspection_count) AS total_count
    FROM inspections_by_day_type
)

/* ============================================================
Step 3 – Calculate percentage
============================================================ */

SELECT
    i.is_weekend,
    i.inspection_count,
    ROUND(
        (i.inspection_count * 100.0) / t.total_count,
        2
    ) AS inspection_percentage
FROM inspections_by_day_type i,
     total_inspections t
ORDER BY
    i.is_weekend;

/*
Output – Q4 (Inspections by day type)

is_weekend | inspection_count | inspection_percentage
-----------|------------------|----------------------
0          | 81,603           | 96.78%
1          | 2,714            | 3.22%

Interpretation:
- The vast majority of inspections are conducted on weekdays.
- Weekend inspections account for only 3.22% of the total,
  well below the calendar proportion of weekend days (~28.6%).
- This indicates a strongly weekday-oriented inspection system.
*/

/*
Final notes:
- This query uses only basic SQL constructs:
  SELECT, JOIN, GROUP BY, and simple arithmetic.
- No advanced SQL features (window functions or CROSS JOIN)
  are required to understand or maintain it.
- The result cleanly answers the scheduling question:
  whether inspections are concentrated on weekdays or weekends.
*/
