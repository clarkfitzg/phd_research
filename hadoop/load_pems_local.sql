-- Loading from the local file system directly to hdfs
-- Doing a single file to debug

LOAD DATA LOCAL INPATH '/home/clarkf/pems/d04_text_station_raw_2016_01_01.txt.gz'
INTO TABLE pems;
