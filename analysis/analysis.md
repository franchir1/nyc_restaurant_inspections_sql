# ANALYSIS Layer — Data Model

## Purpose of the ANALYSIS layer

The ANALYSIS layer defines the curated analytical data model that acts as the **single semantic reference** for all downstream metrics. Its role is to translate cleaned staging data into a stable dimensional structure while preserving source meaning and enforcing analytical consistency.

This layer sits between STAGING and MART and exposes validated fact tables and conformed dimensions intended exclusively for KPI computation and analytical consumption.

---

## Data model overview

The model follows a star schema optimized for inspection-level analysis with explicit support for violation-level detail. A central inspection fact table represents reconstructed inspection events, while a dedicated bridge table preserves violation-level granularity. Conformed dimensions provide temporal, geographic, establishment, and violation context.

The structure prioritizes explicit grain declaration, deterministic joins, and predictable filtering behavior.

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
* No corrective, inferential, or interpretive business logic is introduced

Dimensions are designed to guarantee full coverage of the fact tables and to support only documented join paths.

---

## Date dimension

The date dimension defines the authoritative temporal framework for all analysis.

* One row per calendar date
* Continuous coverage across the full inspection date range
* Standard calendar attributes including calendar year and ISO weekday

The date dimension supports consistent temporal aggregation and ordering. No analytical logic (such as rolling windows or trend computation) is embedded at this level.

---

## Context dimensions

The model includes the following conformed context dimensions:

* **Establishment dimension**
  Represents unique restaurants using the stable CAMIS business key. Descriptive attributes reflect source-provided establishment information.

* **Area dimension**
  Represents NYC boroughs with low, fully conformed cardinality. Area membership is deterministic and stable.

* **Violation dimension**
  Represents unique violation codes with stabilized descriptions derived directly from source values.

**Cuisine** is modeled as a descriptive attribute of the establishment dimension. While not a standalone dimension, it is explicitly eligible for analytical grouping and ranking in downstream KPI logic.

All mappings from source values are deterministic and documented as model-level assumptions.

---

## Fact tables

### fact_inspection

The inspection fact table represents reconstructed inspection events.

* One row per restaurant per inspection date
* Stores inspection score and a single deterministically selected inspection action
* Grain reconstructed due to absence of a stable inspection identifier in the source data

This table represents the authoritative inspection-level analytical unit.

---

### fact_inspection_violation

The inspection–violation bridge table preserves violation-level detail.

* Resolves the many-to-many relationship between inspections and violations
* One row per inspection–violation pairing
* Preserves violation-level attributes, including critical flags

This table prevents violation duplication in inspection-level facts while retaining full violation granularity.

---

## Primary and foreign keys

Primary keys enforce uniqueness at the declared analytical grains.
Foreign keys define the only supported join paths between facts and dimensions.

Undocumented joins are intentionally unsupported to prevent ambiguous analysis and unintended grain violations.

---

## Semantic rules and assumptions

The model enforces the following global semantic rules:

* Inspection score represents the **worst observed score** for a restaurant on a given inspection date
* Inspection action is **deterministically selected** when multiple source values exist
* Violations are associated to inspections exclusively via the bridge table
* Critical flags remain **violation-level attributes** and are never promoted to inspection-level facts

These rules apply uniformly across all downstream analytical usage.

---

## Referential integrity strategy

Dimensional coverage is enforced through controlled joins from STAGING into conformed dimensions. All fact records are expected to resolve to valid dimension keys.

Orphan records are not permitted by design and are identified through explicit model validation checks.

---

## Notable modeling decisions

Key modeling decisions with analytical impact include:

* Approximation of inspection grain at the restaurant–day level due to source limitations
* Deterministic resolution of multiple inspection actions to preserve grain stability
* Preservation of raw violation semantics without normalization, weighting, or severity scoring

These decisions favor structural consistency and semantic transparency over speculative correction.

---

## Model validation

Validation focuses on grain correctness and semantic stability.

* No duplicate inspection grains detected
* Full coverage between staging restaurant–day combinations and inspection facts
* Unique inspection–violation pairs enforced in the bridge table
* Known source ambiguities quantified and explicitly contained

The validated model is structurally sound and reliable for analytical consumption.

---

## Known limitations

The model reflects constraints imposed by the source data:

* Inspection actions may vary within the same restaurant–day in source records
* Historical coverage is uneven in earlier years
* No temporal snapshotting is implemented for slowly changing descriptive attributes

These limitations bound analytical interpretation but do not compromise model integrity.

---

## Readiness for the MART layer

The ANALYSIS layer provides authoritative facts, conformed dimensions, and explicit semantic rules. Declared grains, validated assumptions, and stable join paths enable consistent KPI definition in the MART layer without reinterpreting source logic or introducing hidden assumptions.
