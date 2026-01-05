
/* ============================================================
Q6 – Analysis of non-improved establishments
============================================================

Objective:
Analyze establishments that did not improve their inspection
score over time and identify:
- the most frequent violation types associated with them
- their geographic distribution

Definition:
An establishment is classified as NON-IMPROVED if:
- it has at least two inspection-days with a valid score, AND
- its last inspection score is greater than or equal to
  its first inspection score.

Grain:
- One row = one establishment

Notes:
- Lower score values indicate better inspection outcomes.
- Only inspections with a valid (non-NULL) score are considered.
- Establishments with a single inspection-day are excluded.
*/


/* ============================================================
Step 1 – Select inspections with a valid score
============================================================

Purpose:
Exclude inspection-days without an assigned score to avoid
misclassification caused by NULL values.
*/

WITH scored_inspections AS (
    SELECT
        establishment_key,
        inspection_key,
        date_key,
        score_assigned
    FROM fact_inspection
    WHERE score_assigned IS NOT NULL
),


/* ============================================================
Step 2 – Derive first and last inspection score per establishment
============================================================

Purpose:
- Identify the initial and final inspection score
  for each establishment.
- Count the number of scored inspection-days to
  exclude single-observation cases.
*/

establishment_scores AS (
    SELECT
        establishment_key,

        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key ASC, inspection_key ASC
        ) AS first_score,

        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key
            ORDER BY date_key DESC, inspection_key DESC
        ) AS last_score,

        COUNT(*) OVER (
            PARTITION BY establishment_key
        ) AS inspection_days
    FROM scored_inspections
),


/* ============================================================
Step 3 – Identify non-improved establishments
============================================================

Purpose:
Select establishments that did not improve their score
between the first and last inspection.
*/

non_improved_establishments AS (
    SELECT DISTINCT
        establishment_key
    FROM establishment_scores
    WHERE
        inspection_days >= 2
        AND last_score >= first_score
)


/* ============================================================
Q6A – Most frequent violation codes
      among non-improved establishments
============================================================

Objective:
Identify the most common violation types associated with
establishments that failed to improve over time.

Grain:
- One row = one violation event
*/

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
Output – Q6A (Top 10 violation codes)

violation_code | total_violations | violation_description
---------------|------------------|----------------------
10F            | 15,530           | Non-food contact surfaces improperly maintained
08A            | 9,884            | Conditions conducive to vermin / lack of vermin proofing
06D            | 7,157            | Food contact surfaces not properly sanitized
10B            | 6,693            | Plumbing / sewage system deficiencies
02G            | 6,527            | Cold TCS food held above required temperature
06C            | 6,173            | Food or equipment exposed to contamination
04L            | 5,538            | Evidence of mice in food or non-food areas
02B            | 5,441            | Hot food not held at required temperature
04N            | 4,492            | Flies or nuisance pests present
04A            | 2,806            | Missing Food Protection Certificate

Interpretation – Q6A:
- Non-improved establishments are dominated by recurring
  structural, hygiene, temperature-control, and pest-related
  violations.
- These patterns indicate persistent facility and management
  issues rather than isolated procedural failures.
*/


/* ============================================================
Q6B – Geographic distribution of non-improved establishments
============================================================

Objective:
Assess whether non-improved establishments are concentrated
in specific areas or follow overall establishment density.

Grain:
- One row = one area
*/

SELECT
    ad.area_name,
    COUNT(DISTINCT nie.establishment_key) AS non_improved_establishments
FROM non_improved_establishments AS nie
JOIN fact_inspection AS fi
    ON nie.establishment_key = fi.establishment_key
JOIN area_dim AS ad
    ON fi.area_key = ad.area_key
GROUP BY
    ad.area_name
ORDER BY
    non_improved_establishments DESC;


/*
Output – Q6B (Geographic distribution)

area_name       | non_improved_establishments
----------------|----------------------------
MANHATTAN       | 3,819
BROOKLYN        | 2,386
QUEENS          | 2,211
BRONX           | 826
STATEN ISLAND   | 344

Interpretation – Q6B:
- The geographic distribution of non-improved establishments
  closely mirrors overall establishment density.
- Non-improvement appears to be a systemic issue rather than
  a borough-specific anomaly.
*/

