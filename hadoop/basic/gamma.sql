-- gamma.sql
DROP TABLE gamma
;

CREATE TABLE gamma (
  userid INT,
  movieid INT,
  rating INT,
  gamma_col DOUBLE)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
;

add FILE gamma.R
;

INSERT OVERWRITE TABLE gamma
SELECT
  TRANSFORM (userid, movieid, rating)
-- The 3 following the command makes it available from commandArgs within
-- R. Haven't figured out how to pass the tab character though.
  USING "Rscript gamma.R 3"
  AS (userid, movieid, rating, gamma_col)
FROM u_data
;

SELECT *
FROM gamma
LIMIT 10
;
