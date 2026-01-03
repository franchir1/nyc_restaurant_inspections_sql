-- Q3A

-- Evolution of the avg_score

WITH inspection_level AS (
    SELECT
    area_key,
    establishment_key,
    date_key,
    MAX(score_assigned) As score
FROM
    inspection_events_table AS iet
GROUP BY
    area_key, establishment_key, date_key
) 
SELECT
    ad.area_name,
    dd.inspection_year,
    ROUND(AVG(il.score), 2) AS avg_score
FROM
    inspection_level AS il
JOIN
    area_dim AS ad ON ad.area_key = il.area_key
JOIN
    date_dim AS dd ON dd.date_key = il.date_key
GROUP BY
    ad.area_name, dd.inspection_year
ORDER BY
    ad.area_name, dd.inspection_year ASC

/*

"area_name","inspection_year","avg_score"
"Bronx",2016,"12.50"
"Bronx",2017,"10.50"
"Bronx",2018,"21.00"
"Bronx",2019,"40.50"
"Bronx",2020,"9.00"
"Bronx",2021,"11.29"
"Bronx",2022,"14.74"
"Bronx",2023,"17.47"
"Bronx",2024,"18.74"
"Bronx",2025,"18.60"
"Brooklyn",2016,"8.20"
"Brooklyn",2017,"15.71"
"Brooklyn",2018,"11.56"
"Brooklyn",2019,"16.24"
"Brooklyn",2020,"12.00"
"Brooklyn",2021,"14.94"
"Brooklyn",2022,"15.50"
"Brooklyn",2023,"17.83"
"Brooklyn",2024,"18.57"
"Brooklyn",2025,"19.29"
"Manhattan",2016,"10.86"
"Manhattan",2017,"10.19"
"Manhattan",2018,"9.08"
"Manhattan",2019,"12.29"
"Manhattan",2020,"16.20"
"Manhattan",2021,"14.14"
"Manhattan",2022,"14.95"
"Manhattan",2023,"16.72"
"Manhattan",2024,"17.61"
"Manhattan",2025,"19.02"
"Queens",2015,"21.00"
"Queens",2016,"10.44"
"Queens",2017,"9.22"
"Queens",2018,"13.53"
"Queens",2019,"15.31"
"Queens",2020,"10.57"
"Queens",2021,"16.72"
"Queens",2022,"15.37"
"Queens",2023,"18.80"
"Queens",2024,"19.70"
"Queens",2025,"21.24"
"Staten Island",2016,"10.67"
"Staten Island",2017,"18.00"
"Staten Island",2018,"15.14"
"Staten Island",2021,"16.40"
"Staten Island",2022,"15.09"
"Staten Island",2023,"16.18"
"Staten Island",2024,"16.84"
"Staten Island",2025,"18.59"

*/

-- Objective: analyze the evolution of the number of inspections by area

WITH inspection_level AS (
    SELECT
    area_key,
    establishment_key,
    date_key
FROM
    inspection_events_table AS iet
GROUP BY
    area_key, establishment_key, date_key
) 
SELECT
    ad.area_name,
    dd.inspection_year,
    COUNT(*) AS inspection_count
FROM
    inspection_level AS il
JOIN
    area_dim AS ad ON ad.area_key = il.area_key
JOIN
    date_dim AS dd ON dd.date_key = il.date_key
GROUP BY
    ad.area_name, dd.inspection_year
ORDER BY
    ad.area_name, dd.inspection_year ASC

/*

"area_name","inspection_year","inspection_count"
"Bronx",2016,"2"
"Bronx",2017,"2"
"Bronx",2018,"1"
"Bronx",2019,"4"
"Bronx",2020,"1"
"Bronx",2021,"14"
"Bronx",2022,"367"
"Bronx",2023,"630"
"Bronx",2024,"876"
"Bronx",2025,"829"
"Brooklyn",2016,"5"
"Brooklyn",2017,"7"
"Brooklyn",2018,"9"
"Brooklyn",2019,"29"
"Brooklyn",2020,"4"
"Brooklyn",2021,"88"
"Brooklyn",2022,"1344"
"Brooklyn",2023,"1904"
"Brooklyn",2024,"2589"
"Brooklyn",2025,"2220"
"Manhattan",2016,"14"
"Manhattan",2017,"27"
"Manhattan",2018,"26"
"Manhattan",2019,"42"
"Manhattan",2020,"15"
"Manhattan",2021,"122"
"Manhattan",2022,"1958"
"Manhattan",2023,"2812"
"Manhattan",2024,"3368"
"Manhattan",2025,"3217"
"Queens",2015,"1"
"Queens",2016,"9"
"Queens",2017,"18"
"Queens",2018,"19"
"Queens",2019,"26"
"Queens",2020,"7"
"Queens",2021,"58"
"Queens",2022,"1082"
"Queens",2023,"1543"
"Queens",2024,"2125"
"Queens",2025,"2260"
"Staten Island",2016,"3"
"Staten Island",2017,"3"
"Staten Island",2018,"7"
"Staten Island",2021,"15"
"Staten Island",2022,"207"
"Staten Island",2023,"298"
"Staten Island",2024,"353"
"Staten Island",2025,"300"


*/