SET hive.enforce.bucketing = true
;

DROP TABLE pems_clustered
;

CREATE EXTERNAL TABLE pems_clustered (
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
COMMENT "Used for R transformation script that requires station clustering."
CLUSTERED BY (station) INTO 256 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/clarkf/pems_clustered'
;

INSERT INTO TABLE pems_clustered
SELECT * FROM pems
CLUSTER BY station
;
