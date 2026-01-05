/* ============================================================
CLEAN_DATA_TABLE
============================================================

Purpose
Staging table containing fully cleaned inspection and
violation-level records produced by Power Query ETL.

Grain
- 1 row = 1 violation recorded during an inspection
- Multiple rows may exist for the same inspection
    (one per violation)

Notes
- This table is NOT a fact table
- It serves as the single source for dimensional and
    fact table population
*/

/* ----------------------------
Table definition
---------------------------- */

DROP TABLE IF EXISTS clean_data_table;

CREATE TABLE clean_data_table (

/* Establishment identifiers */
camis_code VARCHAR(10) NOT NULL,
establishment_name VARCHAR(120),
cuisine_description VARCHAR(60),

/* Location */
area_name VARCHAR(15),

/* Inspection attributes */
inspection_date DATE,
action_taken VARCHAR(150),
score_assigned INT,

/* Violation attributes */
violation_code VARCHAR(5),
violation_description VARCHAR(2000),
critical_flag VARCHAR(15)
);

/* ----------------------------
Data loading
---------------------------- */

COPY clean_data_table (
camis_code,
establishment_name,
area_name,
cuisine_description,
inspection_date,
action_taken,
violation_code,
violation_description,
critical_flag,
score_assigned
)
FROM 'C:\Users\Lenovo\Desktop\sql_data_cleaning.csv'
WITH (
FORMAT csv,
DELIMITER ';',
HEADER,
ENCODING 'UTF8',
QUOTE '"'
);

/* ----------------------------
Basic validation checks
---------------------------- */

/* Total row count */
SELECT
COUNT(*) AS total_rows
FROM clean_data_table;

/*
Expected:
~295,000 rows
*/

/* Inspection multiplicity check
(multiple violations per inspection are expected)
*/
SELECT
camis_code,
inspection_date,
COUNT(*) AS violations_per_inspection
FROM clean_data_table
GROUP BY
camis_code,
inspection_date
HAVING COUNT(*) > 1;

/* Missing inspection dates */
SELECT
COUNT(*) AS missing_inspection_date
FROM clean_data_table
WHERE inspection_date IS NULL;

/*
Observed: 3,366
*/

/* Missing inspection scores */
SELECT
COUNT(*) AS missing_score
FROM clean_data_table
WHERE score_assigned IS NULL;

/*
Observed: 16,214
*/


/*

Excel Power Query ETL script

let
    Source = Csv.Document(
        File.Contents("C:\Users\Lenovo\Desktop\DOHMH_New_York_City_Restaurant_Inspection_Results_20260104.csv"),
        [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    ChangedTypes_Text = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"CAMIS", type text},
            {"DBA", type text},
            {"BORO", type text},
            {"CUISINE DESCRIPTION", type text},
            {"INSPECTION DATE", type text},
            {"ACTION", type text},
            {"VIOLATION CODE", type text},
            {"VIOLATION DESCRIPTION", type text},
            {"CRITICAL FLAG", type text},
            {"SCORE", Int64.Type}
        },
        "en-US"
    ),

    RenamedColumns = Table.RenameColumns(
        ChangedTypes_Text,
        {
            {"CAMIS", "camis_code"},
            {"DBA", "restaurant_name"},
            {"BORO", "area_name"},
            {"CUISINE DESCRIPTION", "cuisine_type"},
            {"INSPECTION DATE", "inspection_date"},
            {"ACTION", "action_taken"},
            {"VIOLATION CODE", "violation_code"},
            {"VIOLATION DESCRIPTION", "violation_description"},
            {"CRITICAL FLAG", "critical_flag"},
            {"SCORE", "score_assigned"}
        }
    ),

    RemovedOtherColumns = Table.SelectColumns(
        RenamedColumns,
        {
            "camis_code",
            "restaurant_name",
            "area_name",
            "cuisine_type",
            "inspection_date",
            "action_taken",
            "violation_code",
            "violation_description",
            "critical_flag",
            "score_assigned"
        }
    ),

    ReplaceEmptyWithNull = Table.ReplaceValue(
        RemovedOtherColumns,
        "",
        null,
        Replacer.ReplaceValue,
        {
            "camis_code",
            "restaurant_name",
            "area_name",
            "cuisine_type",
            "inspection_date",
            "action_taken",
            "violation_code",
            "violation_description",
            "critical_flag"
        }
    ),

    ReplaceZeroAreaWithNull = Table.ReplaceValue(
        ReplaceEmptyWithNull,
        "0",
        null,
        Replacer.ReplaceValue,
        {"area_name"}
    ),

    ReplaceFakeDateWithNull = Table.ReplaceValue(
        ReplaceZeroAreaWithNull,
        "01/01/1900",
        null,
        Replacer.ReplaceValue,
        {"inspection_date"}
    ),

    TrimText = Table.TransformColumns(
        ReplaceFakeDateWithNull,
        {
            {"camis_code", Text.Trim},
            {"restaurant_name", Text.Trim},
            {"area_name", Text.Trim},
            {"cuisine_type", Text.Trim},
            {"inspection_date", Text.Trim},
            {"action_taken", Text.Trim},
            {"violation_code", Text.Trim},
            {"violation_description", Text.Trim},
            {"critical_flag", Text.Trim}
        }
    ),

    NormalizeText = Table.TransformColumns(
        TrimText,
        {
            {"restaurant_name", Text.Proper},
            {"area_name", Text.Upper},
            {"cuisine_type", Text.Proper},
            {"critical_flag", Text.Upper}
        }
    ),

    ToDate = Table.TransformColumnTypes(
        NormalizeText,
        {{"inspection_date", type date}},
        "en-US"
    )

in
    ToDate




*/