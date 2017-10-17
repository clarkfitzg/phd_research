-- Tue Oct 17 09:59:22 PDT 2017
-- Uses the same process once again. Probably need to use aggregation
-- function to force it to use a different process.

DROP TABLE movie_py_pid;

CREATE TABLE movie_py_pid (
  rating INT,
  pid INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
;

add FILE pid.py
;

INSERT OVERWRITE TABLE movie_py_pid
SELECT
  TRANSFORM (rating)
  USING 'python pid.py'
  AS (rating, pid)
FROM u_data
GROUP BY rating
;

SELECT *
FROM movie_py_pid
;
