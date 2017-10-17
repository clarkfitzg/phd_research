DROP TABLE movie_py_pid;

CREATE TABLE movie_py_pid (
  userid INT,
  movieid INT,
  rating INT,
  pid INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

add FILE pid.py;

INSERT OVERWRITE TABLE movie_py_pid
SELECT
  TRANSFORM (userid, movieid, rating)
  USING 'python pid.py'
  AS (userid, movieid, rating, pid)
FROM u_data;

-- Tue Oct 17 09:50:28 PDT 2017
-- This shows that it only used one process to handle all 100K rows here.
SELECT pid, COUNT(*)
FROM movie_py_pid
GROUP BY pid;
