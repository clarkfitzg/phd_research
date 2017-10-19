DROP TABLE gamma
;

CREATE TABLE gamma (
  userid INT,
  movieid INT,
  rating INT,
  gamma_col INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
;

add FILE gamma.R
;

INSERT OVERWRITE TABLE gamma
SELECT
  TRANSFORM (userid, movieid, rating)
-- The tab and 3 following the command makes them available from commandArgs within R
  USING "Rscript gamma.R $'\t' 3"
  AS (userid, movieid, rating, gamma_col)
FROM u_data
;

SELECT rating, gamma_col, COUNT(*)
FROM gamma
GROUP BY rating, gamma
;
