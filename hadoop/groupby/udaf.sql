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
  AS (userid, count)
FROM (SELECT userid FROM foo CLUSTER BY userid)
;

SELECT COUNT(*)
FROM udaf
;

SELECT *
FROM udaf
LIMIT 10
;
