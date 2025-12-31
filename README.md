English | [Italiano](README.it.md)

# NYC Restaurant Inspections – Data Analysis with SQL

This project analyzes the **Department of Health and Mental Hygiene (DOHMH)** dataset related to the results of **health inspections of restaurants and university cafeterias** in New York City.

## Dataset

The dataset includes information on:

* health inspections
* assigned scores
* detected violations, including critical violations
* geographic area (borough)
* cuisine type
* inspection date

The original granularity is **inspection–violation**, with potential duplication of the score for a single inspection. This aspect requires explicit analytical modeling.

The raw dataset requires a cleaning and transformation process before it can be used in an analytical model.

## Project objective

The objective is to answer, in a structured and reproducible way, key questions about NYC’s health inspection system:

* What is the **average level of hygienic and sanitary quality** across different areas of the city?
* Are inspections **distributed proportionally** across boroughs and types of establishments?
* How do **scores and inspections evolve over time**, and are there structural discontinuities?
* How **widespread is critical health risk**, and how does it vary over time?
* Do corrective actions lead to **measurable long-term improvements**, or do issues tend to recur?

The adopted approach is **KPI-driven** and oriented toward **decision support**.

## Data cleaning and transformation

The data preparation phase includes:

* preliminary cleaning via **Power Query**
* loading into **PostgreSQL**
* creation of the `clean_data_table`
* removal of records not suitable for analysis

This phase ensures **consistency and reliability** of the data used in subsequent SQL analyses.

## Data model

The model uses a **star schema**, composed of:

* a **fact table** containing the inspection score
* dimensional tables for:

  * geographic context
  * temporal context
  * cuisine type
  * restaurant
  * violation

<p align="center">
  <img src="03_data_model/star_scheme_sql.png" alt="Star schema of the data model" width="600"><br>
  <em>Star schema of the data model</em>
</p>

Relationships are:

* one-to-many
* single-direction

## SQL analysis

SQL analyses are organized by **business questions** and include:

* aggregation of average scores by area and cuisine type
* time-based analyses using **window functions**
* comparison between first and last inspections of establishments
* identification of improvement or deterioration patterns
* analysis of the frequency and persistence of critical violations

## Methodological choices

* an inspection score is treated as **unitary**, even when multiple violations are present
* analyses prioritize **structural trends and comparisons**, not isolated events
* temporal trends are presented as the result of year-over-year fluctuations

These choices aim to ensure **semantic consistency** and interpretability of the results.

## Key findings

* The inspection system appears **structurally balanced** across NYC areas
* The **2019–2020** period represents a significant discontinuity in the data
* Only about **22%** of establishments show a clear improvement over time
* **77–78%** maintain or worsen their level
* The most recurring violations are:

  * structural
  * hygienic-operational
  * difficult to permanently resolve

## Tools used

* **Database administration:** pgAdmin 4
* **Query language:** PostgreSQL (CTEs, window functions, advanced aggregations)
* **Data visualization:** Python (`pandas`, `matplotlib`)
* **Preliminary data cleaning:** Excel Power Query
* **IDE:** Visual Studio Code
* **Version control and documentation:** Git / GitHub

## Skills demonstrated

* data modeling with star schema
* use of surrogate keys
* multiple JOINs
* complex CTEs
* window functions (`FIRST_VALUE`)
* time series analysis
* business-oriented interpretation of results
* structured technical documentation

## Technical documentation

* [Data loading and transformation](/02_etl/etl.md)
* [Model overview](/03_data_model/data_model.md)
* [SQL analysis](/04_queries/queries.md)
* [Original dataset](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data)
