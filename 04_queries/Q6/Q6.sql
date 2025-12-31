-- QUERY 6: ANALYSIS OF NON-IMPROVED ESTABLISHMENTS
-- Objective: identify the most recurring parameters among establishments
-- that did not improve between the first and last inspection
-- (geographic data such as area and regulation-related data such as most frequent violation codes),
-- in order to prioritize inspection procedures.

--- QUERY 1 --- most frequent violation codes

WITH score_list AS (
    SELECT DISTINCT
        establishment_key AS est_id,
        date_key AS date_id,
        score_assigned AS score,
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key ASC -- ascending date order selects the first value, i.e. the oldest
        ) AS first_score,
        -- final score (most recent)
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key DESC  -- descending date order selects the first value, i.e. the most recent
        ) AS last_score
    FROM
        inspection_events_table
    GROUP BY
        est_id, date_id, score
    ORDER BY
        est_id, date_id
), improved_list AS (
    SELECT DISTINCT
        est_id,
        first_score,
        last_score,
        CASE
            WHEN last_score < first_score THEN TRUE
            ELSE FALSE
        END AS is_improved
    FROM
        score_list
), non_improved_list AS (

    SELECT
        est_id
    FROM
        improved_list
    WHERE
        is_improved = FALSE
    ORDER BY
        est_id
), non_improved_list_location AS (
    SELECT DISTINCT
        est_id,
        ad.area_name AS area_name
    FROM
        non_improved_list
    JOIN
        inspection_events_table AS iet ON est_id = iet.establishment_key
    JOIN
        area_dim AS ad ON iet.area_key = ad.area_key
    ORDER BY
        est_id
), violations_count_list AS (
    SELECT -- CTE to count the number of violations per establishment
        establishment_key AS est_id,
        id.violation_code AS vio_code,
        id.violation_description AS vio_desc,
        COUNT(id.violation_code) AS violations_count
    FROM
        inspection_events_table AS iet
    JOIN
        inspection_dim AS id ON iet.inspection_key = id.inspection_key
    WHERE
        id.violation_code IS NOT NULL
    GROUP BY
        est_id, vio_code, vio_desc
    ORDER BY
        est_id ASC, violations_count DESC
)

SELECT -- most frequent violated codes among establishments with increased score
    vcl.vio_code,
    SUM(vcl.violations_count) AS total_count,
    vcl.vio_desc
FROM
    non_improved_list AS nil
JOIN
    violations_count_list AS vcl ON vcl.est_id = nil.est_id
GROUP BY
    vcl.vio_code, vcl.vio_desc
ORDER BY
    total_count DESC
LIMIT
    10;

--- QUERY 2 --- geographic distribution of establishments

WITH score_list AS (
    SELECT DISTINCT
        establishment_key AS est_id,
        date_key AS date_id,
        score_assigned AS score,
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key ASC -- ascending date order selects the first value, i.e. the oldest
        ) AS first_score,
        -- final score (most recent)
        FIRST_VALUE(score_assigned) OVER (
            PARTITION BY establishment_key 
            ORDER BY date_key DESC  -- descending date order selects the first value, i.e. the most recent
        ) AS last_score
    FROM
        inspection_events_table
    GROUP BY
        est_id, date_id, score
    ORDER BY
        est_id, date_id
), improved_list AS (
    SELECT DISTINCT
        est_id,
        first_score,
        last_score,
        CASE
            WHEN last_score < first_score THEN TRUE
            ELSE FALSE
        END AS is_improved
    FROM
        score_list
), non_improved_list AS (

    SELECT
        est_id
    FROM
        improved_list
    WHERE
        is_improved = FALSE
    ORDER BY
        est_id
), non_improved_list_location AS (
    SELECT DISTINCT
        est_id,
        ad.area_name AS area_name
    FROM
        non_improved_list
    JOIN
        inspection_events_table AS iet ON est_id = iet.establishment_key
    JOIN
        area_dim AS ad ON iet.area_key = ad.area_key
    ORDER BY
        est_id
), violations_count_list AS (
    SELECT -- CTE to count the number of violations per establishment
        establishment_key AS est_id,
        id.violation_code AS vio_code,
        id.violation_description AS vio_desc,
        COUNT(id.violation_code) AS violations_count
    FROM
        inspection_events_table AS iet
    JOIN
        inspection_dim AS id ON iet.inspection_key = id.inspection_key
    WHERE
        id.violation_code IS NOT NULL
    GROUP BY
        est_id, vio_code, vio_desc
    ORDER BY
        est_id ASC, violations_count DESC
)

SELECT -- geographic distribution of establishments with increased score
    area_name,
    COUNT(est_id) AS total_count
FROM
    non_improved_list_location
GROUP BY
    area_name
ORDER BY
    total_count DESC;
