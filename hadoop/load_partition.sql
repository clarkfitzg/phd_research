-- Following 'Hadoop in Practice' by Holmes
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

-- This operation should do the file based split on stations.
-- When running on the whole PEMS it fails after 8 minutes with:
-- java.lang.OutOfMemoryError: unable to create new native thread 
--
-- Google leads me to this, which looks correct
-- https://stackoverflow.com/a/19326194/2681019
-- Using too many file descriptors? Certainly possible, since there are
-- several thousand stations to open.

-- When running on a single file it fails at station 401649. 
-- Caused by: org.apache.hadoop.hive.ql.metadata.HiveFatalException: [Error
-- 20004]: Fatal error occurred when node tried to create too many dynamic
-- partitions. The maximum number of dynamic partition s is controlled by
-- hive.exec.max.dynamic.partitions and
-- hive.exec.max.dynamic.partitions.pernode. Maximum was set to: 2000

SET hive.exec.max.dynamic.partitions=11111;
SET hive.exec.max.dynamic.partitions.pernode=10000;

-- I changed the dynamic.partitions as above and it works for a single
-- station. Running the map takes ~11 minutes. Subsequently writing the
-- partitioned data takes probably another 20 minutes (didn't time it exactly)

INSERT INTO TABLE pemsstation
PARTITION (station)
SELECT timeperiod
    , flow1, occupancy1, speed1
    , flow2, occupancy2, speed2
    , flow3, occupancy3, speed3
    , flow4, occupancy4, speed4
    , flow5, occupancy5, speed5
    , flow6, occupancy6, speed6
    , flow7, occupancy7, speed7
    , flow8, occupancy8, speed8
    , station
FROM pems;
