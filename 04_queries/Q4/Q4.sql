/* ============================================================
   Q4 — Hygiene violations per inspection-day:
        weekends vs weekdays
   ============================================================

   Objective
   Compare the average number of hygiene violations per inspection
   between weekends and weekdays.

   Rationale
   - The inspection fact table is modeled at:
       1 row = 1 establishment × 1 inspection date
   - Inspection activity is not evenly distributed across the week
   - Therefore, normalization is performed

   Metric
   - Average violations per inspection-day
*/

/* ----------------------------
   Violations per inspection
   ---------------------------- */

WITH inspection_violations AS (
    SELECT
        fi.inspection_key,
        dd.is_weekend,
        COUNT(fiv.violation_key) AS violations_per_inspection
    FROM fact_inspection AS fi
    JOIN date_dim AS dd
        ON fi.date_key = dd.date_key
    LEFT JOIN fact_inspection_violation AS fiv
        ON fi.inspection_key = fiv.inspection_key
    GROUP BY
        fi.inspection_key,
        dd.is_weekend
)

/* ----------------------------
   Weekend vs weekday comparison
   ---------------------------- */

SELECT
    is_weekend,
    COUNT(*) AS inspections,
    ROUND(AVG(violations_per_inspection), 2) AS avg_violations_per_inspection
FROM inspection_violations
GROUP BY
    is_weekend
ORDER BY
    is_weekend;

/*
Expected interpretation:

- Weekdays show a higher average number of violations per inspection
- Weekends have:
    • far fewer inspections
    • slightly fewer violations per inspection
- The difference is driven by inspection scheduling,
  not by increased weekend hygiene compliance
*/
