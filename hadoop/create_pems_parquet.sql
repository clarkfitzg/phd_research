--SET hive.exec.dynamic.partition=true;
--SET hive.exec.dynamic.partition.mode=nonstrict;
--SET hive.exec.max.dynamic.partitions=100000;
--SET hive.exec.max.dynamic.partitions.pernode=10000;

DROP TABLE pems_parquet;

CREATE EXTERNAL TABLE pems_parquet (
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
CLUSTERED BY (station) INTO 256 BUCKETS
STORED AS PARQUET
LOCATION '/user/clarkf/pems_parquet';

INSERT INTO TABLE pems_parquet
SELECT * FROM pems;
