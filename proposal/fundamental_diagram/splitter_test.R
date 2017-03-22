library(traffic)

d1 = read30sec("~/data/pems/d04_text_station_raw_2016_04_13.txt.gz")
d2 = read30sec("~/data/pems/d04_text_station_raw_2016_05_10.txt.gz")

dname = "~/data/pems/stationID"

split_write(d1, d1$ID, dname)
split_write(d2, d2$ID, dname)
