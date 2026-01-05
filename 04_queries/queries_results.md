# NYC Health Inspections – Analytical Questions & Results

## Table of Contents
- [NYC Health Inspections – Analytical Questions \& Results](#nyc-health-inspections--analytical-questions--results)
  - [Table of Contents](#table-of-contents)
  - [Analytical scope and assumptions](#analytical-scope-and-assumptions)
  - [Q1 – Data quality and proportionality of inspections by area](#q1--data-quality-and-proportionality-of-inspections-by-area)
    - [Q1A – Average inspection score by area](#q1a--average-inspection-score-by-area)
    - [Q1C – Inspections per establishment](#q1c--inspections-per-establishment)
  - [Q2 – Critical violation events](#q2--critical-violation-events)
    - [Q2A – Critical violation events by area](#q2a--critical-violation-events-by-area)
  - [Q3 – Temporal evolution of inspection outcomes](#q3--temporal-evolution-of-inspection-outcomes)
    - [Q3A – Average inspection score (post-filtered)](#q3a--average-inspection-score-post-filtered)
  - [Q4 – Inspection scheduling: weekdays vs weekends](#q4--inspection-scheduling-weekdays-vs-weekends)
  - [Q5 – Establishment improvement over time](#q5--establishment-improvement-over-time)
  - [Q6 – Analysis of non-improved establishments](#q6--analysis-of-non-improved-establishments)
    - [Q6A – Most frequent violations (Top 10)](#q6a--most-frequent-violations-top-10)
    - [Q6B – Geographic distribution](#q6b--geographic-distribution)
  - [Overall conclusions](#overall-conclusions)
  - [Queries and SQL reference](#queries-and-sql-reference)

---

## Analytical scope and assumptions

This analysis focuses on **system behavior and long-term dynamics** of the NYC health inspection process rather than on individual inspection outcomes.

The following assumptions apply across all queries:

- Analyses are performed on a **star-schema data model** that separates inspection events, violation events, establishments, time, and geography.
- Results are interpreted at the **appropriate grain** (inspection-day, violation-event, or establishment level), depending on the analytical question.
- Normalized metrics (e.g. per establishment, per inspection) are preferred over absolute counts when comparing areas.
- Inspection scores are interpreted directionally: **lower scores indicate better outcomes**.
- Temporal analyses account for structural breaks in inspection coverage; early years with sparse data are interpreted cautiously.

Detailed modeling choices, data cleaning steps, and schema design decisions are documented separately in the **data modeling section**.

---

## Q1 – Data quality and proportionality of inspections by area

**Analytical question**  
Are health inspections in New York City:
1. associated with different average sanitary quality levels across areas?
2. distributed proportionally to the number of establishments in each area?

### Q1A – Average inspection score by area

| Area | Average score |
|------|---------------|
| Queens | 18.26 |
| Brooklyn | 16.97 |
| Bronx | 16.82 |
| Manhattan | 16.48 |
| Staten Island | 16.38 |

### Q1C – Inspections per establishment

| Area | Inspections | Establishments | Inspections / Establishment |
|------|-------------|----------------|-----------------------------|
| Manhattan | 31,520 | 10,610 | 2.97 |
| Brooklyn | 21,585 | 6,983 | 3.09 |
| Queens | 19,328 | 6,278 | 3.08 |
| Bronx | 7,631 | 2,401 | 3.18 |
| Staten Island | 3,031 | 994 | 3.05 |

**Conclusion**  
Inspection coverage is proportional across areas; quality differences are moderate and structural.

---

## Q2 – Critical violation events

**Analytical question**  
Where are critical hygiene violation events concentrated?

### Q2A – Critical violation events by area

| Area          | Critical events | Establishments | Critical events / Establishment |
| ------------- | --------------- | -------------- | ------------------------------- |
| Manhattan     | 56,770          | 10,610         | **5.35**                        |
| Brooklyn      | 40,429          | 6,983          | **5.79**                        |
| Queens        | 39,149          | 6,278          | **6.24**                        |
| Bronx         | 14,244          | 2,401          | **5.93**                        |
| Staten Island | 5,489           | 994            | **5.52**                        |

**Conclusion**  
Critical violation events scale with inspection and establishment density. After normalization, critical-event rates are very similar across boroughs.

---

## Q3 – Temporal evolution of inspection outcomes

**Analytical question**  
How have inspection scores and volumes evolved over time?

### Q3A – Average inspection score (post-filtered)

| Year | Manhattan | Brooklyn | Queens | Bronx | Staten Island |
|------|-----------|----------|--------|-------|---------------|
| 2022 | 14.98 | 15.63 | 15.83 | 15.15 | 14.83 |
| 2023 | 16.67 | 17.38 | 18.36 | 17.20 | 16.59 |
| 2024 | 17.16 | 18.39 | 18.98 | 17.54 | 17.06 |
| 2025 | 18.18 | 18.59 | 20.85 | 18.36 | 17.72 |

**Conclusion**  
Inspection coverage increases sharply from 2022 onward, marking a structural break. Score trends reflect both broader inspection coverage and underlying quality dynamics.

---

## Q4 – Inspection scheduling: weekdays vs weekends

**Analytical question**  
When are inspections conducted?

| Day type | Inspections | Percentage |
|---------|-------------|------------|
| Weekday | 81,603 | 96.78% |
| Weekend | 2,714 | 3.22% |

**Conclusion**  
Inspection activity is overwhelmingly concentrated on weekdays.

---

## Q5 – Establishment improvement over time

**Analytical question**  
Do establishments improve their inspection scores?

| Metric | Value |
|------|-------|
| Improved establishments | 58.63% |

**Conclusion**  
Most establishments improve over time, but a substantial minority does not. This highlights heterogeneous responses to corrective actions at establishment level.

---

## Q6 – Analysis of non-improved establishments

### Q6A – Most frequent violations (Top 10)

| Violation code | Total violations | Violation category (summary) |
| -------------- | ---------------- | ----------------------------- |
| **10F** | 15,530 | Non-food contact surface maintenance |
| **08A** | 9,884 | Conditions conducive to vermin |
| **06D** | 7,157 | Food contact surface sanitation |
| **10B** | 6,693 | Plumbing and sewage deficiencies |
| **02G** | 6,527 | Cold food temperature control |
| **06C** | 6,173 | Contamination exposure |
| **04L** | 5,538 | Evidence of mice |
| **02B** | 5,441 | Hot food temperature control |
| **04N** | 4,492 | Nuisance pests |
| **04A** | 2,806 | Missing Food Protection Certificate |

### Q6B – Geographic distribution

| Area | Establishments | Non-improved | Non-improved / Establishment |
|------|----------------|--------------|------------------------------|
| Manhattan | 10,610 | 3,819 | **0.36** |
| Brooklyn | 6,983 | 2,386 | **0.34** |
| Queens | 6,278 | 2,211 | **0.35** |
| Bronx | 2,401 | 826 | **0.34** |
| Staten Island | 994 | 344 | **0.35** |

**Conclusion**  
Non-improved establishments form a stable minority. Their distribution is geographically balanced, while persistent violations point to structural and management-related issues.

---

## Overall conclusions

Across all analyses, the NYC health inspection system appears **structurally balanced** and **proportionally deployed**.  
Inspection coverage scales with establishment density, and critical violations do not show geographic bias once normalized.

Over time, inspection activity expands significantly, and most establishments improve their outcomes.  
However, a consistent minority fails to improve, driven primarily by persistent structural, hygiene, and facility-related issues.

**Long-term improvement depends largely on establishment-level characteristics** rather than location or inspection intensity.

---

## Queries and SQL reference

The analyses above are based on the following SQL files:
- `Q1.sql`
- `Q2.sql`
- `Q3.sql`
- `Q4.sql`
- `Q5.sql`
- `Q6.sql`
