-- udaf.sql
DROP TABLE udaf
;

CREATE TABLE udaf (
  userid INT,
  movieid INT,
  count INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
;

add FILE udaf.R
;

INSERT OVERWRITE TABLE udaf
SELECT
TRANSFORM (userid)
USING "Rscript udaf.R"
AS (userid, movieid, count)
FROM (
    SELECT userid, movieid
    FROM u_data 
    CLUSTER BY userid
) AS tmp  -- Seems that it's necessary to add this alias here. Why?
;

SELECT COUNT(*)
FROM udaf
;

SELECT *
FROM udaf
LIMIT 10
;


--SELECT userid, movieid FROM u_data CLUSTER BY userid limit 10;
