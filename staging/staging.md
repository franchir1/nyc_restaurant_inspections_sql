# STAGING Layer — Data Landing

## Purpose of the STAGING layer

The STAGING layer represents the raw data landing area of the analytical pipeline. Its sole responsibility is to persist an administrative copy of the source dataset while preserving original structure, naming, and semantics. Only minimal, deterministic technical standardization required for database ingestion is applied.

---

## Data source and analytical scope

The data originates from the **NYC Department of Health and Mental Hygiene (DOHMH) Restaurant Inspection Results** public dataset. Records describe inspection outcomes and associated sanitary violations as reported by the health authority. The dataset spans multiple years, with uneven historical coverage, particularly in earlier periods. The analytical scope is strictly limited to inspection- and violation-level.

---

## Design principles

The STAGING layer follows a strict preservation-first approach.

* No business logic or analytical interpretation is applied
* Source field names and value representations are retained
* Transformations are limited to deterministic technical normalization, including:

  * trimming and casing standardization
  * deterministic type casting
  * NULL derivation from empty strings or invalid source representations

All raw landing tables reside in a dedicated `staging` schema, fully isolated from analytical layers.

---

## Raw table definition

The primary staging table represents **inspection–violation level records**.

**Declared grain**

* One row represents one violation recorded during one inspection
* A single inspection may therefore appear across multiple rows, one per violation

The source dataset does not provide a **stable inspection identifier**. As a result, inspection-level uniqueness cannot be enforced in STAGING and must be reconstructed downstream.

---

## Applied data quality checks

Data quality checks at the STAGING layer validate **structural coherence**, not business correctness.

The applied checks include:

* Row counts to confirm complete dataset ingestion
* Inspection multiplicity checks to confirm violation-level grain consistency
* Assessment of missing inspection dates/scores due to their impact on temporal modeling
* Proxy-based duplication checks to assess feasibility of collapsing to a restaurant–day grain
* Evaluation of variability of inspection-level attributes across violations (critical_flag)

---

## Summary of data quality outcomes

The dataset is structurally consistent with a violation-level grain. Multiple violations per inspection are common and expected. Inspection dates and inspection scores are not mandatory fields and may appear as NULL, requiring explicit filters downstream.

Several inspection-level attributes vary within the same restaurant–day proxy. This confirms that not all source fields can be safely promoted to inspection-grain facts without deterministic resolution logic.

---

## Implications for downstream layers

Observed STAGING characteristics directly constrain and inform ANALYSIS-layer design.

* Inspection grain must be approximated at a restaurant–day level
* Critical flags must remain violation-level attributes
* Records without inspection dates/scores are kept out of the fact table

---

## Known limitations

The STAGING layer preserves source-imposed constraints without remediation.

* Absence of a stable inspection identifier
* Partial nullability of inspection dates and inspection scores
* Uneven historical coverage across years
