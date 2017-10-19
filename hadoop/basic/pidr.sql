DROP TABLE movie_r_pid
;

CREATE TABLE movie_r_pid (
  userid INT,
  movieid INT,
  rating INT,
  pid INT,
  nrow INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
;

ADD FILE pid.R
;

INSERT OVERWRITE TABLE movie_r_pid
SELECT
  TRANSFORM (userid, movieid, rating)
  USING 'pid.R'
  AS (userid, movieid, rating, pid, nrow)
FROM u_data
;

SELECT DISTINCT pid
FROM movie_r_pid
--GROUP BY pid
;
