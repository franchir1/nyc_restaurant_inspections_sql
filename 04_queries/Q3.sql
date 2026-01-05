/* ============================================================
Q3 – Temporal trends by area
============================================================ */


/* ============================================================
Q3A – Evolution of average inspection score by area and year
============================================================

Objective:
Analyze how the average inspection score evolves over time
for each area.

Grain:
- One row = one inspection

Notes:
- Higher score values indicate worse inspection outcomes.
- Early years in the dataset contain very few inspections
  and can produce unstable averages.
- To avoid misleading results, years with insufficient
  inspection volume are excluded.

Methodological choice:
- Only (area, year) combinations with a minimum number
  of inspections are retained.
- This query focuses on score evolution, not inspection intensity.
*/


/* ============================================================
Q3A – Average inspection score by area and year
(filtered for statistical robustness)
============================================================ */

SELECT
    ad.area_name,
    dd.inspection_year,
    ROUND(AVG(fi.score_assigned), 2) AS avg_score,
    COUNT(*) AS inspection_count
FROM fact_inspection AS fi
JOIN area_dim AS ad
    ON ad.area_key = fi.area_key
JOIN date_dim AS dd
    ON dd.date_key = fi.date_key
WHERE
    fi.score_assigned IS NOT NULL
GROUP BY
    ad.area_name,
    dd.inspection_year
HAVING
    COUNT(*) >= 30          -- minimum sample size threshold
ORDER BY
    dd.inspection_year,
    ad.area_name;


/* ------------------------------------------------------------
Output – Q3A (filtered)
------------------------------------------------------------

area_name        | inspection_year | avg_score | inspection_count
-----------------|-----------------|-----------|------------------
MANHATTAN        | 2016            | 11.37     | 49
QUEENS           | 2016            | 8.55      | 33

BROOKLYN         | 2017            | 14.92     | 38
MANHATTAN        | 2017            | 11.34     | 82
QUEENS           | 2017            | 8.61      | 64

BROOKLYN         | 2018            | 17.21     | 57
MANHATTAN        | 2018            | 10.84     | 101
QUEENS           | 2018            | 13.81     | 96

BROOKLYN         | 2019            | 18.42     | 81
MANHATTAN        | 2019            | 12.07     | 108
QUEENS           | 2019            | 14.52     | 95

MANHATTAN        | 2020            | 14.36     | 36
QUEENS           | 2020            | 18.15     | 39

BRONX            | 2021            | 13.29     | 34
BROOKLYN         | 2021            | 15.51     | 182
MANHATTAN        | 2021            | 14.59     | 249
QUEENS           | 2021            | 14.93     | 135

BRONX            | 2022            | 15.15     | 929
BROOKLYN         | 2022            | 15.63     | 3315
MANHATTAN        | 2022            | 14.98     | 4751
QUEENS           | 2022            | 15.83     | 2565
STATEN ISLAND    | 2022            | 14.83     | 449

BRONX            | 2023            | 17.20     | 1751
BROOKLYN         | 2023            | 17.38     | 5078
MANHATTAN        | 2023            | 16.67     | 7640
QUEENS           | 2023            | 18.36     | 4297
STATEN ISLAND    | 2023            | 16.59     | 826

BRONX            | 2024            | 17.54     | 2311
BROOKLYN         | 2024            | 18.39     | 6618
MANHATTAN        | 2024            | 17.16     | 8926
QUEENS           | 2024            | 18.98     | 5629
STATEN ISLAND    | 2024            | 17.06     | 908

BRONX            | 2025            | 18.36     | 2569
BROOKLYN         | 2025            | 18.59     | 6444
MANHATTAN        | 2025            | 18.18     | 9521
QUEENS           | 2025            | 20.85     | 6472
STATEN ISLAND    | 2025            | 17.72     | 789
*/


/* ============================================================
Interpretation notes – Q3A
============================================================

- Pre-2022 results should be interpreted with caution,
  as inspection coverage is limited and uneven.
- From 2022 onward, inspection volumes increase sharply
  across all areas, indicating full operational coverage.
- Changes in average score reflect both true quality trends
  and changes in inspection intensity and coverage.
*/


/* ============================================================
Q3B – Evolution of inspection volume by area and year
============================================================

Objective:
Track how the number of inspections changes over time
for each area.

Grain:
- One row = one inspection

Notes:
- This query provides the necessary context required
  to correctly interpret Q3A results.
- Sharp discontinuities may indicate structural or
  administrative changes in the inspection system.
*/


SELECT
    ad.area_name,
    dd.inspection_year,
    COUNT(*) AS inspection_count
FROM fact_inspection AS fi
JOIN area_dim AS ad
    ON ad.area_key = fi.area_key
JOIN date_dim AS dd
    ON dd.date_key = fi.date_key
GROUP BY
    ad.area_name,
    dd.inspection_year
ORDER BY
    dd.inspection_year,
    ad.area_name;


/* ------------------------------------------------------------
Output – Q3B
------------------------------------------------------------

(area_name, inspection_year, inspection_count)
*/


/* ============================================================
Modeling statement – Q3
============================================================

- Q3A and Q3B must always be interpreted together.
- Average inspection scores are strongly influenced
  by inspection volume and coverage.
- Score trends without inspection-count context
  may lead to incorrect conclusions about
  sanitary quality evolution.
*/
