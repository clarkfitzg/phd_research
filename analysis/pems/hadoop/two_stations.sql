-- Thu Oct 26 08:49:00 PDT 2017
-- Runs nice and quick:

-- Loading data to table default.two_stations
-- Table default.two_stations stats: [numFiles=2, totalSize=169979736]
-- OK
-- Time taken: 90.233 seconds
-- 
-- real    1m43.807s
-- user    0m41.116s
-- sys     0m2.474s
 
DROP TABLE two_stations;

CREATE EXTERNAL TABLE two_stations (
    timeperiod STRING, station INT
    , flow1 INT, occupancy1 DOUBLE, speed1 DOUBLE
    , flow2 INT, occupancy2 DOUBLE, speed2 DOUBLE
    , flow3 INT, occupancy3 DOUBLE, speed3 DOUBLE
    , flow4 INT, occupancy4 DOUBLE, speed4 DOUBLE
    , flow5 INT, occupancy5 DOUBLE, speed5 DOUBLE
    , flow6 INT, occupancy6 DOUBLE, speed6 DOUBLE
    , flow7 INT, occupancy7 DOUBLE, speed7 DOUBLE
    , flow8 INT, occupancy8 DOUBLE, speed8 DOUBLE
)
COMMENT "Two stations worth of data. Used for developing a script locally before running as UDAF in hive"
LOCATION '/user/clarkf/two_stations'
;

INSERT INTO TABLE two_stations
SELECT *
FROM pems
WHERE station IN (404401, 401793)
CLUSTER BY station
;
