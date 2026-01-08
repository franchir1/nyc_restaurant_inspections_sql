let
    /* ============================================================
       SOURCE
       ============================================================ */
    Source =
        Csv.Document(
            File.Contents(
                "C:\Users\Lenovo\Desktop\DOHMH_New_York_City_Restaurant_Inspection_Results_20260104.csv"
            ),
            [
                Delimiter = ",",
                Encoding = 65001,
                QuoteStyle = QuoteStyle.None
            ]
        ),

    /* Promote first row to column headers */
    PromotedHeaders =
        Table.PromoteHeaders(
            Source,
            [PromoteAllScalars = true]
        ),

    /* ============================================================
       TYPE CASTING (RAW)
       ============================================================ */
    ChangedTypes_Text =
        Table.TransformColumnTypes(
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

    /* ============================================================
       COLUMN RENAMING (CANONICAL NAMES)
       ============================================================ */
    RenamedColumns =
        Table.RenameColumns(
            ChangedTypes_Text,
            {
                {"CAMIS", "camis_code"},
                {"DBA", "establishment_name"},
                {"BORO", "area_name"},
                {"CUISINE DESCRIPTION", "cuisine_description"},
                {"INSPECTION DATE", "inspection_date"},
                {"ACTION", "action_taken"},
                {"VIOLATION CODE", "violation_code"},
                {"VIOLATION DESCRIPTION", "violation_description"},
                {"CRITICAL FLAG", "critical_flag"},
                {"SCORE", "score_assigned"}
            }
        ),

    /* ============================================================
       COLUMN SELECTION
       ============================================================ */
    RemovedOtherColumns =
        Table.SelectColumns(
            RenamedColumns,
            {
                "camis_code",
                "establishment_name",
                "area_name",
                "cuisine_description",
                "inspection_date",
                "action_taken",
                "violation_code",
                "violation_description",
                "critical_flag",
                "score_assigned"
            }
        ),

    /* ============================================================
       NULL NORMALIZATION
       ============================================================ */
    ReplaceEmptyWithNull =
        Table.ReplaceValue(
            RemovedOtherColumns,
            "",
            null,
            Replacer.ReplaceValue,
            {
                "camis_code",
                "establishment_name",
                "area_name",
                "cuisine_description",
                "inspection_date",
                "action_taken",
                "violation_code",
                "violation_description",
                "critical_flag"
            }
        ),

    /* Replace invalid area placeholder */
    ReplaceZeroAreaWithNull =
        Table.ReplaceValue(
            ReplaceEmptyWithNull,
            "0",
            null,
            Replacer.ReplaceValue,
            {"area_name"}
        ),

    /* Replace fake inspection date */
    ReplaceFakeDateWithNull =
        Table.ReplaceValue(
            ReplaceZeroAreaWithNull,
            "01/01/1900",
            null,
            Replacer.ReplaceValue,
            {"inspection_date"}
        ),

    /* ============================================================
       TEXT CLEANING & STANDARDIZATION
       ============================================================ */
    TrimText =
        Table.TransformColumns(
            ReplaceFakeDateWithNull,
            {
                {"camis_code", Text.Trim},
                {"establishment_name", Text.Trim},
                {"area_name", Text.Trim},
                {"cuisine_description", Text.Trim},
                {"inspection_date", Text.Trim},
                {"action_taken", Text.Trim},
                {"violation_code", Text.Trim},
                {"violation_description", Text.Trim},
                {"critical_flag", Text.Trim}
            }
        ),

    NormalizeText =
        Table.TransformColumns(
            TrimText,
            {
                {"establishment_name", Text.Proper},
                {"area_name", Text.Upper},
                {"cuisine_description", Text.Proper},
                {"critical_flag", Text.Upper}
            }
        ),

    /* ============================================================
       FINAL TYPE CASTING
       ============================================================ */
    ToDate =
        Table.TransformColumnTypes(
            NormalizeText,
            {{"inspection_date", type date}},
            "en-US"
        )

in
    ToDate
