# ANALYSIS Layer — Data Model

## Purpose of the ANALYSIS layer

This layer sits between STAGING and MART and exposes validated fact tables and conformed dimensions intended exclusively for KPI computation and analytical consumption.

---

## Data model overview

The model follows a star schema optimized for inspection-level analysis with explicit support for violation-level detail. A central inspection fact table represents reconstructed inspection events, while a dedicated bridge table preserves violation-level granularity. Conformed dimensions provide temporal, geographic, establishment, and violation context.

---

## Declared analytical grains

Two analytical grains are explicitly declared and enforced:

* **Inspection grain**: one restaurant on one inspection date
* **Violation grain**: one violation recorded during one inspection

All facts, joins, and aggregations respect these grains. Any deviation from these units of analysis is treated as a documented modeling constraint rather than an implicit assumption.

---

## Dimension tables

Dimensions provide descriptive context and stable slicing paths for analytical queries.

* All dimensions are sourced exclusively from cleaned STAGING data
* Surrogate keys are generated at this layer
* Only deterministic shaping and standardization is applied

---

## Date dimension

The date dimension defines the authoritative temporal framework for all analysis.

* One row per calendar date
* Continuous coverage across the full inspection date range
* Standard calendar attributes including calendar year and ISO weekday

The date dimension supports consistent temporal aggregation and ordering.

---

## Context dimensions

The model includes the following conformed context dimensions:

* **Establishment dimension**
  Represents unique restaurants using the stable CAMIS business key.

* **Area dimension**
  Represents NYC boroughs.

* **Violation dimension**
  Represents unique violation codes with descriptions.

---

## Fact tables

### fact_inspection

The inspection fact table represents reconstructed inspection events.

* One row per restaurant per inspection date (camis_code, inspection_date, action_taken, score_assigned)
* Stores inspection score and  selected inspection action
* Grain reconstructed due to absence of a stable inspection identifier

---

### fact_inspection_violation

The inspection–violation bridge table preserves violation-level detail.

* Resolves the many-to-many relationship between inspections and violations
* One row per inspection–violation pairing
* Preserves violation-level attributes, as critical flags

---

## Semantic rules and assumptions

The model enforces the following global semantic rules:

* Inspection score represents the **worst observed score** for a restaurant on a given inspection date
* Inspection action is **deterministically selected** when multiple source values exist
* Violations are associated to inspections exclusively via the bridge table
* Critical flags remain **violation-level attributes** and are never promoted to inspection-level facts

---

## Model validation

Validation focuses on grain correctness and semantic stability.

* No duplicate inspection grains detected
* Full coverage between staging restaurant–day combinations and inspection facts
* Unique inspection–violation pairs enforced in the bridge table
* Known source ambiguities quantified and explicitly contained (action_taken)

The validated model is structurally sound and reliable for analytical consumption.
