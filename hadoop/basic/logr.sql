DROP TABLE logr
;

CREATE TABLE logr (
  message STRING)
;

ADD FILE log.R
;

INSERT OVERWRITE TABLE logr
SELECT
  TRANSFORM (userid, movieid, rating)
  USING 'Rscript log.R'
  AS (message)
FROM u_data
;

SELECT *
FROM logr
;
