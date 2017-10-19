DROP TABLE log
;

CREATE TABLE log (
  message STRING)
;

ADD FILE log.py
;

INSERT OVERWRITE TABLE log
SELECT
  TRANSFORM (userid, movieid, rating)
  USING 'python3 log.py'
  AS (message)
FROM u_data
;

SELECT *
FROM log
;
