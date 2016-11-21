# Mon Nov 21 11:49:04 PST 2016
#
# Write the total occupancies into datadir so that we can compute the mean.

fname = "/home/clark/data/pems/d04_text_station_5min_2016_05_10.txt.gz"

fname = "d04_text_station_5min_2016_05_10.txt.gz"

date = sub(".*([0-9]{4}_[0-9]{2}_[0-9]{2}).*", "\\1", fname)

wkday = weekdays(as.Date(date, "%m_%d_%Y"))
