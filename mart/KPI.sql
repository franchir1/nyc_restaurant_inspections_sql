/* ============================================================
   MART — KPI DEFINITIONS (STABLE VIEWS)
   ============================================================

   Scope
   Defines the KPI layer. Each KPI is implemented as a reusable, read-only SQL view.

   Design rules
   - One view = one KPI
   - No presentation logic (ORDER BY, LIMIT)
   - No BI-specific assumptions
   - Consumption is handled downstream (KPI_visuals.sql)
   ============================================================ */


/* ============================================================
   KPI 1 — Average score distribution by area
   ============================================================ */

CREATE OR REPLACE VIEW mart.avg_inspection_score_by_area AS
SELECT
    a.area_name,
    ROUND(AVG(fi.score_assigned), 2) AS avg_score
FROM analysis.fact_inspection AS fi
JOIN analysis.area_dim AS a
    ON a.area_key = fi.area_key
WHERE fi.score_assigned IS NOT NULL
GROUP BY a.area_name;


/* ============================================================
   KPI 2 — Score distribution by area (median & P90)
   ============================================================ */

CREATE OR REPLACE VIEW mart.score_distribution_by_area AS
SELECT
    a.area_name,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fi.score_assigned) AS median_score,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY fi.score_assigned) AS p90_score,
    COUNT(*) AS inspection_count
FROM analysis.fact_inspection AS fi
JOIN analysis.area_dim AS a
    ON a.area_key = fi.area_key
WHERE fi.score_assigned IS NOT NULL
GROUP BY a.area_name;


/* ============================================================
   KPI 3 — High-risk inspections by area
   High risk defined as score >= 28
   ============================================================ */

CREATE OR REPLACE VIEW mart.high_risk_inspections_by_area AS
SELECT
    a.area_name,
    COUNT(*) FILTER (WHERE fi.score_assigned >= 28) AS high_risk_inspections,
    COUNT(*) AS total_inspections,
    ROUND(
        COUNT(*) FILTER (WHERE fi.score_assigned >= 28)::numeric
        / COUNT(*) * 100, 2
    ) AS high_risk_pct
FROM analysis.fact_inspection AS fi
JOIN analysis.area_dim AS a
    ON a.area_key = fi.area_key
WHERE fi.score_assigned IS NOT NULL
GROUP BY a.area_name;

/* ============================================================
   KPI 4 — Average Inspection Score Trend (3-Year Rolling Average)

   Purpose:
   Expose a stable, multi-year trend of inspection scores
   by area using a 3-year rolling average.

   Notes:
   - Rolling average smooths annual volatility
   - Trend is meaningful only where historical continuity exists
   ============================================================ */

CREATE OR REPLACE VIEW mart.avg_score_trend_3y AS
WITH yearly_scores AS (
    /* ------------------------------------------------------------
       Step 1: Compute yearly average inspection score per area
       ------------------------------------------------------------ */
    SELECT
        a.area_name,
        d.year,
        AVG(fi.score_assigned) AS avg_score
    FROM analysis.fact_inspection AS fi
    JOIN analysis.area_dim AS a
        ON a.area_key = fi.area_key
    JOIN analysis.date_dim AS d
        ON d.date_key = fi.date_key
    WHERE fi.score_assigned IS NOT NULL
    GROUP BY a.area_name, d.year
),
rolling_scores AS (
    /* ------------------------------------------------------------
       Step 2: Apply 3-year rolling average per area
       The value is valid only starting from the 3rd available year
       ------------------------------------------------------------ */
    SELECT
        area_name,
        year,
        ROUND(avg_score, 2) AS avg_score,
        ROUND(
            AVG(avg_score) OVER ( -- window
                PARTITION BY area_name -- the average is calculated for each area
                ORDER BY year
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -- for each year and area, it calculates the 3 years rolling average (between the 2 preceding years and the current one) 
            ),
            2
        ) AS avg_score_3y_rolling
    FROM yearly_scores
)
SELECT
    area_name,
    year,
    avg_score,
    avg_score_3y_rolling
FROM rolling_scores
WHERE avg_score_3y_rolling IS NOT NULL;


/* ============================================================
   KPI 5 — Impact of critical violations on inspection score
   ============================================================ */

CREATE OR REPLACE VIEW mart.score_by_critical_violation_presence AS
WITH inspection_critical_flag AS (
    SELECT
        fv.inspection_key,
        BOOL_OR(fv.critical_flag = 'CRITICAL') AS has_critical_violation
    FROM analysis.fact_inspection_violation AS fv
    GROUP BY
        fv.inspection_key
)
SELECT
    ic.has_critical_violation,
    COUNT(*) AS inspection_count,
    ROUND(AVG(fi.score_assigned), 2) AS avg_score
FROM analysis.fact_inspection AS fi
JOIN inspection_critical_flag AS ic
    ON ic.inspection_key = fi.inspection_key
WHERE fi.score_assigned IS NOT NULL
GROUP BY
    ic.has_critical_violation;

/* ================================================================
   KPI 6 — Closure rate and critical rate by inspection score bucket
   =============================================================== */

-- KPI 6A (closure rate by score bucket)

CREATE OR REPLACE VIEW mart.closure_rate_by_score_bucket AS
SELECT
    CASE
        WHEN fi.score_assigned < 10 THEN '00–09'
        WHEN fi.score_assigned BETWEEN 10 AND 19 THEN '10–19'
        WHEN fi.score_assigned BETWEEN 20 AND 27 THEN '20–27'
        ELSE '28+'
    END AS score_bucket,
    COUNT(*) AS total_inspections,
    COUNT(*) FILTER (
        WHERE fi.action_taken ILIKE '%Closed%'
    ) AS closed_inspections,
    ROUND(
        COUNT(*) FILTER (WHERE fi.action_taken ILIKE '%Closed%')::numeric
        / COUNT(*) * 100, 2
    ) AS closure_rate_pct
FROM analysis.fact_inspection AS fi
WHERE fi.score_assigned IS NOT NULL
GROUP BY score_bucket;

-- KPI 6B (critical rate by score bucket)

CREATE OR REPLACE VIEW mart.critical_violation_rate_by_score_bucket AS

WITH inspection_critical_flag AS (

    SELECT
        fv.inspection_key,
        BOOL_OR(fv.critical_flag = 'CRITICAL') AS has_critical
    FROM analysis.fact_inspection_violation AS fv
    GROUP BY fv.inspection_key
)

SELECT
    CASE
        WHEN fi.score_assigned < 10 THEN '00–09'
        WHEN fi.score_assigned BETWEEN 10 AND 19 THEN '10–19'
        WHEN fi.score_assigned BETWEEN 20 AND 27 THEN '20–27'
        ELSE '28+'
    END AS score_bucket,
    COUNT(*) AS total_inspections,
    COUNT(*) FILTER (WHERE ic.has_critical) AS critical_inspections,
    ROUND(
        COUNT(*) FILTER (WHERE ic.has_critical)::numeric
        / COUNT(*) * 100, 2) AS critical_inspections_rate_pct
FROM
    analysis.fact_inspection AS fi
JOIN
    inspection_critical_flag AS ic ON fi.inspection_key = ic.inspection_key
GROUP BY
    score_bucket;

/* ============================================================
   KPI 7 — Cuisine ranking by inspection score
   ============================================================ */

CREATE OR REPLACE VIEW mart.cuisine_score_ranking AS
SELECT
    ed.cuisine_description,
    COUNT(*) AS inspection_count,
    ROUND(AVG(fi.score_assigned), 2) AS avg_score,
    RANK() OVER (
        ORDER BY AVG(fi.score_assigned) ASC
    ) AS cuisine_rank
FROM analysis.fact_inspection AS fi
JOIN analysis.establishment_dim AS ed
    ON ed.establishment_key = fi.establishment_key
WHERE
    fi.score_assigned IS NOT NULL
    AND ed.cuisine_description IS NOT NULL
GROUP BY ed.cuisine_description
HAVING COUNT(*) >= 50;