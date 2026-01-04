-- Q6 — Analysis of non-improved establishments
--
-- Objective:
-- Identify recurring patterns among establishments whose inspection score
-- did NOT improve between the first and last inspection.
--
-- Focus:
--   Q6A → most frequent violation codes
--   Q6B → geographic distribution
--
-- Interpretation:
-- Lower score = better outcome → non-improved means last_score >= first_score

WITH establishment_scores AS (
    SELECT
        establishment_key,

        -- oldest inspection score
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key ASC
        ) AS first_score,

        -- most recent inspection score
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key DESC
        ) AS last_score
    FROM inspection_events_table
),

non_improved_establishments AS (
    SELECT DISTINCT
        establishment_key
    FROM establishment_scores
    WHERE last_score >= first_score
)

--------------------------------------------------
-- Q6A — Most frequent violation codes
-- among non-improved establishments
--------------------------------------------------

SELECT
    id.violation_code,
    COUNT(*) AS total_violations,
    id.violation_description
FROM non_improved_establishments AS nie
JOIN inspection_events_table AS iet
    ON nie.establishment_key = iet.establishment_key
JOIN inspection_dim AS id
    ON iet.inspection_key = id.inspection_key
WHERE id.violation_code IS NOT NULL
GROUP BY
    id.violation_code,
    id.violation_description
ORDER BY
    total_violations DESC
LIMIT 10;

/*
RESULTS — Q6A (Top 10 Violation Codes)

| Rank | Code | Total Violations | Description (shortened)                         |
|-----:|------|------------------|-------------------------------------------------|
| 1    | 10F  | 10 377           | Non-food contact surfaces improperly maintained |
| 2    | 08A  | 6 597            | Conditions conducive to pests                   |
| 3    | 06D  | 4 811            | Food contact surface not sanitized              |
| 4    | 10B  | 4 709            | Drainage / sewage disposal issues               |
| 5    | 02G  | 4 459            | Cold TCS food held above required temperature   |
| 6    | 06C  | 4 421            | Food/equipment exposed to contamination         |
| 7    | 02B  | 3 780            | Hot food not held at ≥ 140°F                    |
| 8    | 04L  | 3 761            | Evidence of mice                                |
| 9    | 04N  | 2 941            | Flies / nuisance pests                          |
| 10   | 04A  | 1 950            | Missing Food Protection Certificate             |

Insight:
Non-improved establishments are dominated by
STRUCTURAL, HYGIENE and PEST-RELATED violations,
suggesting persistent management and facility issues
rather than occasional procedural errors.
*/

--------------------------------------------------
-- Q6B — Geographic distribution
-- of non-improved establishments
--------------------------------------------------

SELECT
    ad.area_name,
    COUNT(DISTINCT nie.establishment_key) AS total_establishments
FROM non_improved_establishments AS nie
JOIN inspection_events_table AS iet
    ON nie.establishment_key = iet.establishment_key
JOIN area_dim AS ad
    ON iet.area_key = ad.area_key
GROUP BY
    ad.area_name
ORDER BY
    total_establishments DESC;

/*
RESULTS — Q6B (Geographic Distribution)

| Area           | Non-Improved Establishments |
|----------------|-----------------------------|
| Manhattan      | 5 675                       |
| Brooklyn       | 3 900                       |
| Queens         | 3 343                       |
| Bronx          | 1 313                       |
| Staten Island  |   557                       |

Insight:
The distribution closely mirrors the overall density
of establishments, indicating that non-improvement
is a systemic issue rather than a borough-specific anomaly.
*/

