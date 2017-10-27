-- Fri Oct 27 11:07:09 PDT 2017
DROP TABLE fundamental_diagram
;

-- Removing the EXTERNAL TABLE stopped the temporary file error.
CREATE TABLE fundamental_diagram (
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
--LOCATION '/user/clarkf/fundamental_diagram'
;

add FILE piecewise_fd.R
;

INSERT OVERWRITE TABLE fundamental_diagram
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
    FROM pems 
    CLUSTER BY station
) AS tmp  -- Seems that it's necessary to add this alias here to avoid parsing error.
;

SELECT COUNT(*)
FROM fundamental_diagram
;

SELECT *
FROM fundamental_diagram
LIMIT 10
;
