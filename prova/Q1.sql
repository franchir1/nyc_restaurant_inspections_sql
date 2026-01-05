Di seguito trovi il codice **riscritto, riorganizzato e uniformato in inglese**, con:

* struttura chiara (Q1A / Q1B / Q1C)
* commenti professionali stile **data project / GitHub**
* linguaggio analitico pulito
* SQL **identico nella logica**, solo migliorato nella presentazione

/* ============================================================
Q1A – Average inspection score by area
============================================================

Objective:
Evaluate average sanitary inspection quality across areas
over the full time period, considering only open establishments.

Notes:
- Inspection score: higher values indicate worse outcomes.
- Inspections with a "Closed" action are excluded to avoid
    administrative edge cases.
- Each inspection contributes exactly once to the average.

Interpretation:
- Queens shows the highest average score (worst performance).
- Staten Island shows the lowest average score (best performance).
- Results are consistent with differences in urban density
    and inspection pressure across areas.
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

Notes:
- An establishment is considered active if it appears in
    at least one inspection with a non-"Closed" action.
- Each establishment is counted once per area.

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
============================================================

Objective:
Compare inspection volume across areas over the full period.

Notes:
- Inspections are collapsed at inspection level
    (establishment + inspection date).
- Each inspection is counted exactly once.
- Inspections with a "Closed" action are excluded.

Interpretation:
- Manhattan concentrates the highest absolute number of inspections.
- Inspection volume broadly follows establishment density,
    suggesting a proportional inspection coverage across areas.
*/

WITH inspection_level AS (
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
)

SELECT
a.area_name,
COUNT(*) AS total_inspections
FROM inspection_level il
JOIN area_dim a
ON il.area_key = a.area_key
GROUP BY a.area_name
ORDER BY total_inspections DESC;


/* Expected result:
area_name        | total_inspections
-----------------|------------------
MANHATTAN        | 31520
BROOKLYN         | 21585
QUEENS           | 19328
BRONX            | 7631
STATEN ISLAND    | 3031
*/
