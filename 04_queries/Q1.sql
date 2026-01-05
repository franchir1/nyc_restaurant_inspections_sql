/* ============================================================
Q1 – Data Quality and Inspection Proportionality by Area
============================================================

This SQL file contains three analytical blocks:

- Q1A: Average inspection score by area
- Q1B: Number of active establishments by area
- Q1C: Number of inspections by area and
       inspections per establishment

The queries are designed to be documented one-to-one
(Q1.sql → Q1.it.md) with results reported as Markdown tables.

Global conventions:
- Higher inspection score = worse sanitary conditions
- Inspections with a "Closed" action are excluded
- Area color mapping must be consistent across all queries:
    Manhattan     → Red
    Brooklyn      → Green
    Queens        → Blue
    Bronx         → Orange
    Staten Island → Purple
============================================================ */


/* ============================================================
Q1A – Average inspection score by area
============================================================

Objective:
Evaluate average sanitary inspection quality across areas
over the full time period, considering only open establishments.

Notes:
- Each inspection contributes exactly once to the average.
- Inspections with NULL scores are excluded.
- Inspections with a "Closed" action are excluded to avoid
  administrative edge cases.

Interpretation:
- Higher average score = worse overall inspection outcomes.
- Differences are expected to reflect structural and
  density-related factors rather than inspection bias.
*/

WITH inspection_scores AS (
    SELECT
        fi.inspection_key,
        fi.establishment_key,
        fi.date_key,
        fi.area_key,
        fi.score_assigned
    FROM fact_inspection fi
    WHERE fi.score_assigned IS NOT NULL
      AND fi.action_taken NOT LIKE '%Closed%'
)

SELECT
    a.area_name,
    ROUND(AVG(i.score_assigned), 2) AS avg_score
FROM inspection_scores i
JOIN establishment_dim e
    ON i.establishment_key = e.establishment_key
JOIN area_dim a
    ON i.area_key = a.area_key
GROUP BY a.area_name
ORDER BY avg_score DESC;


/* Expected result:
area_name        | avg_score
-----------------|----------
QUEENS           | 18.26
BROOKLYN         | 16.97
BRONX            | 16.82
MANHATTAN        | 16.48
STATEN ISLAND    | 16.38
*/


/* ============================================================
Q1B – Number of active establishments by area
============================================================

Objective:
Measure the number of active establishments in each area.

Definition:
An establishment is considered active if it appears in
at least one inspection with a non-"Closed" action.

Notes:
- Each establishment is counted once per area.
- Uses inspection data to ensure alignment with Q1A and Q1C.

Interpretation:
- Manhattan hosts the highest number of active establishments.
- Staten Island has the lowest commercial density.
*/

SELECT
    a.area_name,
    COUNT(DISTINCT fi.establishment_key) AS total_establishments_area
FROM fact_inspection fi
JOIN area_dim a
    ON fi.area_key = a.area_key
WHERE fi.action_taken NOT LIKE '%Closed%'
GROUP BY a.area_name
ORDER BY total_establishments_area;


/* Expected result:
area_name        | total_establishments_area
-----------------|--------------------------
STATEN ISLAND    | 994
BRONX            | 2401
QUEENS           | 6278
BROOKLYN         | 6983
MANHATTAN        | 10610
*/


/* ============================================================
Q1C – Number of inspections by area
     + inspections per establishment
============================================================

Objective:
Compare inspection volume across areas and evaluate
inspection coverage relative to the number of establishments.

Notes:
- Inspections are aggregated at inspection-day level
  (establishment + inspection date).
- Each inspection is counted exactly once.
- Inspections with a "Closed" action are excluded.
- Establishment counts are derived from the same inspection
  universe to ensure full consistency with Q1B.

Interpretation:
- Absolute inspection volume follows establishment density.
- The inspections / establishment ratio is expected to be
  similar across areas if the inspection system is proportional.
*/

WITH inspection_level AS (
    -- Collapse data at inspection-day level
    SELECT
        fi.establishment_key,
        fi.area_key,
        fi.date_key
    FROM fact_inspection fi
    WHERE fi.action_taken NOT LIKE '%Closed%'
    GROUP BY
        fi.establishment_key,
        fi.area_key,
        fi.date_key
),
establishments_by_area AS (
    -- Count active establishments per area
    SELECT
        area_key,
        COUNT(DISTINCT establishment_key) AS total_establishments
    FROM inspection_level
    GROUP BY area_key
),
inspections_by_area AS (
    -- Count total inspections per area
    SELECT
        area_key,
        COUNT(*) AS total_inspections
    FROM inspection_level
    GROUP BY area_key
)

SELECT
    a.area_name,
    i.total_inspections,
    e.total_establishments,
    ROUND(
        CAST(i.total_inspections AS DECIMAL)
        / e.total_establishments,
        2
    ) AS inspections_per_establishment
FROM inspections_by_area i
JOIN establishments_by_area e
    ON i.area_key = e.area_key
JOIN area_dim a
    ON i.area_key = a.area_key
ORDER BY inspections_per_establishment DESC;


/* Expected result:
area_name        | total_inspections | total_establishments | inspections_per_establishment
-----------------|-------------------|----------------------|-------------------------------
MANHATTAN        | 31520             | 10610                | 2.97
BROOKLYN         | 21585             | 6983                 | 3.09
QUEENS           | 19328             | 6278                 | 3.08
BRONX            | 7631              | 2401                 | 3.18
STATEN ISLAND    | 3031              | 994                  | 3.05
*/
