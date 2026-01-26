# STAGING Layer — Data Landing

## Purpose of the STAGING layer

The STAGING layer represents the raw data landing area of the analytical pipeline. Its sole responsibility is to persist an administrative copy of the source dataset while preserving original structure, naming, and semantics. Only minimal, deterministic technical standardization required for database ingestion is applied.

This layer guarantees full traceability to the source files and reproducible downstream processing. It is not designed for analytical querying, aggregation, or KPI computation.

---

## Data source and analytical scope

The data originates from the **NYC Department of Health and Mental Hygiene (DOHMH) Restaurant Inspection Results** public dataset. Records describe inspection outcomes and associated sanitary violations as reported by the health authority.

The dataset spans multiple years, with uneven historical coverage, particularly in earlier periods. The analytical scope is strictly limited to inspection- and violation-level information explicitly encoded in the source fields. No external enrichments, inferred business rules, or domain reinterpretations are introduced at this stage.

---

## Design principles

The STAGING layer follows a strict preservation-first approach.

* No business logic or analytical interpretation is applied
* Source field names and value representations are retained
* Transformations are limited to deterministic technical normalization, including:

  * trimming and casing standardization
  * deterministic type casting
  * NULL derivation from empty strings or invalid source representations

Any denormalization present in the source dataset is intentionally preserved to maintain fidelity to the original structure and to support flexible downstream modeling.

---

## Schemas and naming conventions

All raw landing tables reside in a dedicated `staging` schema, fully isolated from analytical layers.

* Table names reflect the source dataset and processing stage
* Column names remain closely aligned with source terminology

This convention ensures semantic transparency and supports unambiguous lineage tracking from analytical outputs back to raw source fields.

---

## Raw table definition

The primary staging table represents **inspection–violation level records**.

**Declared grain**

* One row represents one violation recorded during one inspection
* A single inspection may therefore appear across multiple rows, one per violation

The source dataset does **not** expose a stable inspection identifier. As a result, inspection-level uniqueness cannot be enforced in STAGING and must be reconstructed downstream using deterministic modeling rules.

No primary keys or uniqueness constraints are enforced at this layer.

---

## Ingestion assumptions

Source data is ingested from CSV extracts with headers and UTF-8 encoding.

* All fields are initially loaded as text to prevent ingestion failures
* NULL values are derived deterministically from empty strings, placeholder values, or invalid representations
* No filtering, deduplication, or semantic correction is applied at ingestion time

These assumptions define the technical ingestion contract between the source files and the database and are treated as fixed constraints.

---

## Applied data quality checks

Data quality checks at the STAGING layer validate **structural coherence**, not business correctness.

The applied checks include:

* Row counts to confirm complete dataset ingestion
* Inspection multiplicity checks to confirm violation-level grain consistency
* Assessment of missing inspection dates due to their impact on temporal modeling
* Validation of the optional nature of inspection scores
* Proxy-based duplication checks to assess feasibility of collapsing to a restaurant–day grain
* Evaluation of variability of inspection-level attributes across violations

No KPI-oriented, causal, or outcome-based validation is performed at this layer.

---

## Summary of data quality outcomes

The dataset is structurally consistent with a violation-level grain. Multiple violations per inspection are common and expected. Inspection dates and inspection scores are not mandatory fields and exhibit partial nullability, requiring explicit safeguards in downstream layers.

Several inspection-level attributes vary within the same restaurant–day proxy. This confirms that not all source fields can be safely promoted to inspection-grain facts without deterministic resolution logic.

---

## Implications for downstream layers

Observed STAGING characteristics directly constrain and inform ANALYSIS-layer design.

* Inspection grain must be approximated at a restaurant–day level
* Inspection scores and actions require deterministic resolution rules
* Critical flags must remain violation-level attributes
* Records without inspection dates cannot participate in inspection-level fact tables

These constraints shape fact table grain, bridge design, and semantic rules applied downstream.

---

## Known limitations

The STAGING layer preserves source-imposed constraints without remediation.

* Absence of a stable inspection identifier
* Partial nullability of inspection dates and inspection scores
* Inconsistent inspection-level attributes across violation records
* Uneven historical coverage across years

These limitations are intentionally retained and addressed, where required, in downstream analytical layers rather than corrected at ingestion time.
