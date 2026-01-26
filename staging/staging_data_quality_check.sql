/* ============================================================
   STAGING — DATA QUALITY & COHERENCE CHECKS
   Target table: staging.clean_dohmh_inspections
   ============================================================

   Scope
   Validation queries used to assess structural consistency
   and semantic reliability of the staging dataset prior to
   dimensional modeling.

   Intent
   - Verify assumptions about grain and optional fields
   - Expose data limitations relevant to downstream design

   Constraints
   - Read-only checks
   - No data mutation or remediation performed
   ============================================================ */


/* ------------------------------------------------------------
   CHECK 1 — Row volume
   Validates overall dataset size against expectations
------------------------------------------------------------ */
SELECT
    COUNT(*) AS total_rows
FROM staging.clean_dohmh_inspections;

/* ------------------------------------------------------------
   CHECK 2 — Inspection multiplicity
   Confirms that multiple violations can occur within
   the same inspection event, consistent with the
   violation-level grain
------------------------------------------------------------ */
SELECT
    camis_code,
    inspection_date,
    COUNT(*) AS violations_per_inspection
FROM staging.clean_dohmh_inspections
GROUP BY
    camis_code,
    inspection_date
HAVING COUNT(*) > 1
ORDER BY violations_per_inspection DESC
LIMIT
    10;


/* ------------------------------------------------------------
   CHECK 3 — Missing inspection dates
   Records without an inspection_date cannot be linked
   to date_dim or included in inspection-level facts
------------------------------------------------------------ */
SELECT
    COUNT(*) AS missing_inspection_date
FROM staging.clean_dohmh_inspections
WHERE inspection_date IS NULL;


/* ------------------------------------------------------------
   CHECK 4 — Missing inspection scores
   Inspection score is not mandatory in the source data
   and must be treated as nullable downstream
------------------------------------------------------------ */
SELECT
    COUNT(*) AS missing_score
FROM staging.clean_dohmh_inspections
WHERE score_assigned IS NULL;


/* ------------------------------------------------------------
   CHECK 5 — Duplicate inspection proxies
   Inspection proxy definition:
     (camis_code + inspection_date + action_taken + score_assigned)

   Purpose
   - Validate collapsing inspections to restaurant-day grain
   - Support aggregation of violations via a bridge fact
------------------------------------------------------------ */
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(*) AS row_count
FROM staging.clean_dohmh_inspections
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT
    10;


/* ------------------------------------------------------------
   CHECK 6 — Critical flag variability
   Shows that critical_flag is not stable at the
   inspection-proxy level and therefore unsuitable
   for inclusion in fact_inspection
------------------------------------------------------------ */
SELECT
    camis_code,
    inspection_date,
    action_taken,
    score_assigned,
    COUNT(DISTINCT critical_flag) AS distinct_critical_flags
FROM staging.clean_dohmh_inspections
WHERE critical_flag IS NOT NULL
GROUP BY
    camis_code,
    inspection_date,
    action_taken,
    score_assigned
HAVING COUNT(DISTINCT critical_flag) > 1
ORDER BY distinct_critical_flags DESC
LIMIT
    10;
