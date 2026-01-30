/* ============================================================
   MART — KPI VISUAL QUERIES
   ============================================================

   Scope
   Read-only consumer queries used for reporting,
   presentation, and documentation tables.

   Rules
   - SELECT only
   - Presentation logic allowed (ORDER BY, LIMIT)
   ============================================================ */


/* ============================================================
   V1 — Average inspection score by area
   ============================================================ */

SELECT
    area_name,
    avg_score
FROM mart.avg_inspection_score_by_area
ORDER BY avg_score DESC;

/* ============================================================
   V2 — Score distribution by area (median & tail risk)
   ============================================================ */

SELECT
    area_name,
    median_score,
    p90_score,
    inspection_count
FROM mart.score_distribution_by_area
ORDER BY p90_score DESC;


/* ============================================================
   V3 — High-risk inspections by area
   ============================================================ */

SELECT
    area_name,
    high_risk_inspections,
    total_inspections,
    high_risk_pct
FROM mart.high_risk_inspections_by_area
ORDER BY high_risk_pct DESC;


/* ============================================================
   V4 — 3-Year Rolling Average Score Trend by Area
   ============================================================ */

SELECT
    area_name,
    year,
    avg_score_3y_rolling AS score_trend_3y
FROM mart.avg_score_trend_3y
ORDER BY
    area_name,
    year;


/* ============================================================
   V5 — Impact of critical violations on inspection score
   ============================================================ */

SELECT
    has_critical_violation,
    inspection_count,
    avg_score
FROM mart.score_by_critical_violation_presence
ORDER BY has_critical_violation DESC;


/* ============================================================
   V6 — Closure rate/critical rate by inspection score bucket
   ============================================================ */

SELECT
    score_bucket,
    total_inspections,
    closed_inspections,
    closure_rate_pct
FROM mart.closure_rate_by_score_bucket
ORDER BY score_bucket;

SELECT
    score_bucket,
    total_inspections,
    critical_inspections,
    critical_inspections_rate_pct
FROM mart.critical_violation_rate_by_score_bucket
ORDER BY score_bucket;


/* ============================================================
   V7 — Best performing cuisines
   ============================================================ */

SELECT
    cuisine_description,
    inspection_count,
    avg_score
FROM mart.cuisine_score_ranking
ORDER BY cuisine_rank ASC
LIMIT 10;


/* ============================================================
   V8 — Worst performing cuisines
   ============================================================ */

SELECT
    cuisine_description,
    inspection_count,
    avg_score
FROM mart.cuisine_score_ranking
ORDER BY cuisine_rank DESC
LIMIT 10;
