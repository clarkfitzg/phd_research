-- Following 'Hadoop in Practice' by Holmes
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

-- This operation should do the file based split on stations.
-- When running on the whole PEMS it fails after 8 minutes with:
-- java.lang.OutOfMemoryError: unable to create new native thread 
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
