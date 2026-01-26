/* ============================================================
   MART — KPI VISUAL QUERIES
   ============================================================

   Scope
   Read-only consumer queries used for reporting,
   presentation, and documentation tables.

   Rules
   - SELECT only
   - Built exclusively on MART views
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

"area_name","avg_score"
"QUEENS","18.92"
"BROOKLYN","17.76"
"BRONX","17.42"
"MANHATTAN","16.93"
"STATEN ISLAND","16.73"



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

"area_name","median_score","p90_score","inspection_count"
"QUEENS",13,39,"19429"
"BROOKLYN",12,37,"21857"
"MANHATTAN",12,34,"31469"
"BRONX",13,33,"7641"
"STATEN ISLAND",13,31,"3036"



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

"area_name","high_risk_inspections","total_inspections","high_risk_pct"
"QUEENS","4042","19429","20.80"
"BROOKLYN","4082","21857","18.68"
"MANHATTAN","5234","31469","16.63"
"BRONX","1245","7641","16.29"
"STATEN ISLAND","419","3036","13.80"


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

"area_name","year","score_trend_3y"
"BRONX",2008,"0.00"
"BRONX",2016,"6.25"
"BRONX",2017,"8.47"
"BRONX",2018,"12.33"
"BRONX",2019,"14.72"
"BRONX",2020,"18.09"
"BRONX",2021,"18.65"
"BRONX",2022,"17.15"
"BRONX",2023,"15.22"
"BRONX",2024,"16.63"
"BRONX",2025,"17.70"
"BROOKLYN",2013,"4.00"
"BROOKLYN",2014,"14.86"
"BROOKLYN",2015,"14.32"
"BROOKLYN",2016,"17.27"
"BROOKLYN",2017,"13.67"
"BROOKLYN",2018,"14.99"
"BROOKLYN",2019,"16.85"
"BROOKLYN",2020,"17.45"
"BROOKLYN",2021,"16.88"
"BROOKLYN",2022,"15.95"
"BROOKLYN",2023,"16.17"
"BROOKLYN",2024,"17.13"
"BROOKLYN",2025,"18.12"
"MANHATTAN",2015,"15.17"
"MANHATTAN",2016,"13.27"
"MANHATTAN",2017,"12.63"
"MANHATTAN",2018,"11.18"
"MANHATTAN",2019,"11.42"
"MANHATTAN",2020,"12.43"
"MANHATTAN",2021,"13.68"
"MANHATTAN",2022,"14.64"
"MANHATTAN",2023,"15.41"
"MANHATTAN",2024,"16.27"
"MANHATTAN",2025,"17.34"
"QUEENS",2015,"18.25"
"QUEENS",2016,"13.40"
"QUEENS",2017,"11.80"
"QUEENS",2018,"10.32"
"QUEENS",2019,"12.31"
"QUEENS",2020,"15.49"
"QUEENS",2021,"15.87"
"QUEENS",2022,"16.30"
"QUEENS",2023,"16.37"
"QUEENS",2024,"17.72"
"QUEENS",2025,"19.40"
"STATEN ISLAND",2016,"10.75"
"STATEN ISLAND",2017,"14.63"
"STATEN ISLAND",2018,"15.47"
"STATEN ISLAND",2019,"14.98"
"STATEN ISLAND",2020,"11.81"
"STATEN ISLAND",2021,"11.50"
"STATEN ISLAND",2022,"13.35"
"STATEN ISLAND",2023,"15.88"
"STATEN ISLAND",2024,"16.16"
"STATEN ISLAND",2025,"17.12"


/* ============================================================
   V5 — Impact of critical violations on inspection score
   ============================================================ */

SELECT
    has_critical_violation,
    inspection_count,
    avg_score
FROM mart.score_by_critical_violation_presence
ORDER BY has_critical_violation DESC;

"has_critical_violation","inspection_count","avg_score"
"Yes","72525","19.75"
"No","9420","4.22"


/* ============================================================
   V6 — Closure rate by inspection score bucket
   ============================================================ */

SELECT
    score_bucket,
    total_inspections,
    closed_inspections,
    closure_rate_pct
FROM mart.closure_rate_by_score_bucket
ORDER BY score_bucket;

"score_bucket","total_inspections","closed_inspections","closure_rate_pct"
"00–09","22458","45","0.20"
"10–19","33542","241","0.72"
"20–27","12410","62","0.50"
"28+","15022","1222","8.13"


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

"cuisine_description","inspection_count","avg_score"
"Donuts","2046","10.90"
"Hotdogs","83","11.46"
"Hamburgers","1609","12.04"
"Salads","354","12.53"
"Bottled Beverages","338","12.73"
"Tex-Mex","1048","13.75"
"Hotdogs/Pretzels","77","13.78"
"Soups/Salads/Sandwiches","116","13.83"
"German","87","14.78"
"Coffee/Tea","6772","15.02"



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

"cuisine_description","inspection_count","avg_score"
"Bangladeshi","336","31.18"
"Creole","99","26.27"
"Filipino","139","25.22"
"African","317","25.03"
"Pakistani","136","24.88"
"Indian","1043","23.11"
"Chinese/Japanese","135","22.74"
"Soul Food","205","21.87"
"Eastern European","347","21.36"
"Caribbean","2744","21.17"
