DROP TABLE pems;
DROP TABLE pems2;

-- Only can see within hive
CREATE TABLE pems (timeperiod STRING, station INT
    , flow1 INT, occupancy1 DOUBLE, speed1 DOUBLE
    , flow2 INT, occupancy2 DOUBLE, speed2 DOUBLE
    , flow3 INT, occupancy3 DOUBLE, speed3 DOUBLE
    , flow4 INT, occupancy4 DOUBLE, speed4 DOUBLE
    , flow5 INT, occupancy5 DOUBLE, speed5 DOUBLE
    , flow6 INT, occupancy6 DOUBLE, speed6 DOUBLE
    , flow7 INT, occupancy7 DOUBLE, speed7 DOUBLE
    , flow8 INT, occupancy8 DOUBLE, speed8 DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;


-- External should create something on disk
CREATE EXTERNAL TABLE pemsstation (timeperiod STRING
    , flow1 INT, occupancy1 DOUBLE, speed1 DOUBLE
    , flow2 INT, occupancy2 DOUBLE, speed2 DOUBLE
    , flow3 INT, occupancy3 DOUBLE, speed3 DOUBLE
    , flow4 INT, occupancy4 DOUBLE, speed4 DOUBLE
    , flow5 INT, occupancy5 DOUBLE, speed5 DOUBLE
    , flow6 INT, occupancy6 DOUBLE, speed6 DOUBLE
    , flow7 INT, occupancy7 DOUBLE, speed7 DOUBLE
    , flow8 INT, occupancy8 DOUBLE, speed8 DOUBLE
)
PARTITIONED BY (station INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/user/clarkf/pemsstation'
