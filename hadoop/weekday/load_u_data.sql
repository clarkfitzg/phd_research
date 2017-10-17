-- Example from https://cwiki.apache.org/confluence/display/Hive/GettingStarted

CREATE TABLE u_data (
  userid INT,
  movieid INT,
  rating INT,
  unixtime STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
--STORED AS TEXTFILE
;

--LOAD DATA LOCAL INPATH '/home/clarkf/ml-100k/u.data'
LOAD DATA LOCAL INPATH '/Users/clark/data/ml-100k/u.data'
OVERWRITE INTO TABLE u_data;

SELECT COUNT(*) FROM u_data;
