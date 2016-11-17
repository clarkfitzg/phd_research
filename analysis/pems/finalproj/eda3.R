# Thu Nov 17 14:21:25 PST 2016
#
# Goal: Compute the "average" delays on each freeway

source("helpers.R")



station = read.table("~/data/pems/d04_text_meta_2016_10_05.txt"
                     , sep = "\t"
                     , header = TRUE
                     , quote = ""
                     )


d5 = read.csv("~/data/pems/d04_text_station_5min_2016_05_10.txt.gz"
              , header = FALSE)

d5_2 = data.frame(timestamp = d5[, 1]
                  , ID = d5[, 2]
                  , mean_occ = d5[, 11]
                  )

d5_2 = merge(d5_2, station[, c("ID", "Abs_PM", "Fwy", "Dir", "Type")])

hwy2 = d5_2[(d5_2$Fwy == 80)
        & (d5_2$Dir == "E")
        & (d5_2$Type == "ML")
        , ]

hwy2$timestamp = as.POSIXct(hwy2$timestamp, format = "%m/%d/%Y %H:%M:%S")


