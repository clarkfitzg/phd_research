hdfs dfs -rm two_stations/*
hive -f two_stations.sql
rm -r ~/data/two_stations
hdfs dfs -get two_stations ~/data
gzip -cd ~/data/two_stations/000014_0.gz | head > ~/data/two_stations/tiny.txt
