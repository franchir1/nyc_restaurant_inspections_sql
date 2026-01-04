/* ============================================================
   Q6 — Analysis of non-improved establishments
   ============================================================

   Definition
   An establishment is classified as NON-IMPROVED if:
   - it has at least 2 inspection-days, AND
   - last inspection-day score >= first inspection-day score

   Notes
   - Grain: inspection-day (fact_inspection)
   - Lower score = better outcome
   - Single inspection-day establishments are excluded
*/

/* ----------------------------
   Derive first / last scores
   ---------------------------- */

WITH establishment_scores AS (
    SELECT
        establishment_key,
        date_key,
        score_assigned,

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
        ) AS inspection_days
    FROM fact_inspection
),

/* ----------------------------
   Identify non-improved establishments
   ---------------------------- */

non_improved_establishments AS (
    SELECT DISTINCT
        establishment_key
    FROM establishment_scores
    WHERE
        inspection_days >= 2
        AND last_score >= first_score
)

/* ============================================================
   Q6A — Most frequent violation codes
   among non-improved establishments
   ============================================================ */

SELECT
    vd.violation_code,
    COUNT(*) AS total_violations,
    vd.violation_description
FROM non_improved_establishments AS nie
JOIN fact_inspection AS fi
    ON nie.establishment_key = fi.establishment_key
JOIN fact_inspection_violation AS fiv
    ON fi.inspection_key = fiv.inspection_key
JOIN violation_dim AS vd
    ON fiv.violation_key = vd.violation_key
GROUP BY
    vd.violation_code,
    vd.violation_description
ORDER BY
    total_violations DESC
LIMIT 10;

/*
Results — Q6A (Top 10 Violation Codes)

violation_code | total_violations | description (shortened)
------------------------------------------------------------
10F | 15329 | Non-food contact surfaces improperly maintained
08A | 9663  | Conditions conducive to vermin
06D | 7044  | Food contact surface not sanitized
10B | 6597  | Plumbing / sewage issues
02G | 6402  | Cold TCS food held above temperature
06C | 6079  | Food/equipment exposed to contamination
04L | 5401  | Evidence of mice
02B | 5314  | Hot food not held at required temperature
04N | 4406  | Flies / nuisance pests
04A | 2748  | Missing Food Protection Certificate

Insight
Non-improved establishments are dominated by structural,
hygiene, temperature control and pest-related violations,
indicating persistent facility and management issues
rather than isolated procedural errors.
*/

/* ============================================================
   Q6B — Geographic distribution
   of non-improved establishments
   ============================================================ */

SELECT
    ad.area_name,
    COUNT(DISTINCT nie.establishment_key) AS total_establishments
FROM non_improved_establishments AS nie
JOIN fact_inspection AS fi
    ON nie.establishment_key = fi.establishment_key
JOIN area_dim AS ad
    ON fi.area_key = ad.area_key
GROUP BY
    ad.area_name
ORDER BY
    total_establishments DESC;

/*
Results — Q6B (Geographic Distribution)

area_name       | non_improved_establishments
--------------------------------------------
MANHATTAN       | 3767
BROOKLYN        | 2366
QUEENS          | 2182
BRONX           | 811
STATEN ISLAND   | 341

Insight
The distribution closely mirrors overall establishment
density, suggesting that non-improvement is a systemic
phenomenon rather than a borough-specific anomaly.
*/
