/* ============================================================
   ANALYSIS — FACT TABLES
   ============================================================
   Scope
   Construction of fact tables derived from staging data
   and conformed dimensions.

   Modeling Constraints
   - The original dataset does not expose a stable inspection_id
   - Inspection grain is approximated at restaurant–day level
   - Deterministic aggregation rules are applied to resolve
     multiple records per restaurant per day
   ============================================================ */

/* ============================================================
   FACT TABLE: fact_inspection
   Grain
   - 1 row = 1 restaurant on 1 inspection date
   ============================================================ */

DROP TABLE IF EXISTS analysis.fact_inspection CASCADE;

CREATE TABLE analysis.fact_inspection (
    inspection_key SERIAL PRIMARY KEY,

    establishment_key INT NOT NULL
        REFERENCES analysis.establishment_dim(establishment_key),

    area_key INT NOT NULL
        REFERENCES analysis.area_dim(area_key),

    date_key INT NOT NULL
        REFERENCES analysis.date_dim(date_key),

    score_assigned INT,          -- Worst score observed on that date (MAX)
    action_taken VARCHAR(150)   -- Deterministically selected inspection action
);


INSERT INTO analysis.fact_inspection (
    establishment_key,
    area_key,
    date_key,
    score_assigned,
    action_taken
)
SELECT
    ed.establishment_key,
    ad.area_key            AS area_key,
    dd.date_key,
    MAX(cdt.score_assigned)     AS score_assigned,
    MAX(cdt.action_taken)       AS action_taken
FROM staging.clean_dohmh_inspections AS cdt
JOIN analysis.establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN analysis.area_dim AS ad
    ON cdt.area_name = ad.area_name
JOIN analysis.date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
WHERE cdt.inspection_date IS NOT NULL -- filtering out inspections without date
GROUP BY
    ed.establishment_key,
    dd.date_key;


/* ============================================================
   PERFORMANCE INDEXES
   ============================================================ */

CREATE INDEX idx_fact_inspection_date
    ON analysis.fact_inspection (date_key);

CREATE INDEX idx_fact_inspection_establishment
    ON analysis.fact_inspection (establishment_key);


/* ============================================================
   FACT TABLE: fact_inspection_violation (BRIDGE)
   Purpose
   - Resolve the many-to-many relationship between
     inspections and violations

   Grain
   - 1 row = 1 violation recorded during 1 inspection
   ============================================================ */

DROP TABLE IF EXISTS analysis.fact_inspection_violation CASCADE;

CREATE TABLE analysis.fact_inspection_violation (
    inspection_violation_key SERIAL PRIMARY KEY,

    inspection_key INT NOT NULL
        REFERENCES analysis.fact_inspection(inspection_key),

    violation_key INT NOT NULL
        REFERENCES analysis.violation_dim(violation_key),

    critical_flag VARCHAR(15) NOT NULL
);


INSERT INTO analysis.fact_inspection_violation (
    inspection_key,
    violation_key,
    critical_flag
)
SELECT DISTINCT
    fi.inspection_key,
    vd.violation_key,
    cdt.critical_flag
FROM staging.clean_dohmh_inspections AS cdt
JOIN analysis.establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN analysis.date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
JOIN analysis.fact_inspection AS fi
    ON fi.establishment_key = ed.establishment_key
   AND fi.date_key = dd.date_key
JOIN analysis.violation_dim AS vd
    ON cdt.violation_code = vd.violation_code
WHERE cdt.violation_code IS NOT NULL;


/* ============================================================
   PERFORMANCE INDEXES
   ============================================================ */

CREATE INDEX idx_fact_iv_inspection
    ON analysis.fact_inspection_violation (inspection_key);

CREATE INDEX idx_fact_iv_violation
    ON analysis.fact_inspection_violation (violation_key);
