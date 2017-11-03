-- This version uses the pre clustered data.

-- real    6m23.290s
-- user    0m44.630s
-- sys     0m3.000s
DROP TABLE fundamental_diagram2
;

-- Removing the EXTERNAL TABLE stopped the temporary file error.
CREATE TABLE fundamental_diagram2 (
  station INT
  , n_total INT
  , n_middle INT
  , n_high INT
  , left_slope DOUBLE
  , left_slope_se DOUBLE
  , mid_intercept DOUBLE
  , mid_intercept_se DOUBLE
  , mid_slope DOUBLE
  , mid_slope_se DOUBLE
  , right_slope DOUBLE
  , right_slope_se DOUBLE
  )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
--STORED AS TEXTFILE
--LOCATION '/user/clarkf/fundamental_diagram2'
;

add FILE piecewise_fd.R
;

INSERT OVERWRITE TABLE fundamental_diagram2
SELECT
TRANSFORM (station, flow2, occupancy2)
USING "Rscript piecewise_fd.R"
-- This AS seems redundant, since the reducers produce these.
AS(station 
  , n_total 
  , n_middle 
  , n_high 
  , left_slope 
  , left_slope_se 
  , mid_intercept 
  , mid_intercept_se 
  , mid_slope 
  , mid_slope_se 
  , right_slope 
  , right_slope_se 
  )
FROM (
    SELECT station, flow2, occupancy2
    FROM pems_clustered
) AS tmp  -- Seems that it's necessary to add this alias here to avoid parsing error.
;

-- 2414 rows
SELECT COUNT(*)
FROM fundamental_diagram2
;

SELECT *
FROM fundamental_diagram2
LIMIT 10
;
