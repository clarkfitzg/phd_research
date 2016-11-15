# Tue Nov  1 16:33:13 PDT 2016
#
# Exploring PeMS data again. This time for a final project.
# Goals:
#
# - Interesting analysis
# - Use all data on server
# - R parallel programming
# - Use C/C++ for speed

library(lattice)

# TODO - move to package once complete
source("helpers.R")

# Basic cleaning step:
# Want at least one nonzero value for both flow and occupancy
############################################################

#d = read30sec("~/data/pems/district3/d03_text_station_raw_2016_04_06.txt.gz")
d = read30sec("~/data/pems/d04_text_station_raw_2016_05_10.txt.gz")

# This step is a little heavy handed, but previous experience suggests that it's
# necessary, and it simplifies things later
d[d == 0] = NA

occ = d[, grep("occupancy", colnames(d), value = TRUE)]
badocc_rows = apply(is.na(occ), 1, all)

flow = d[, grep("flow", colnames(d), value = TRUE)]
badflow_rows = apply(is.na(flow), 1, all)

badrows = badocc_rows | badflow_rows

d = d[!badrows, ]

# The distribution of occupancy 1 and 2
############################################################
#
#occ1 = d$occupancy1[!is.na(d$occupancy1)
#                    & d$occupancy1 != 0
#                    ]
#
#occ2 = d$occupancy2[!is.na(d$occupancy2)
#                    & d$occupancy2 != 0
#                    ]
#
## Shows that occupancy is distributed about like a mixture of an
## exponential and a point mass near 1. Could also maybe use beta instead of
## exponential to get it to stay in [0, 1].
#
#par(mfrow=c(1, 2))
#hist(occ1)
#hist(occ2)


# Merge in station metadata
############################################################

station = read.table("~/data/pems/d04_text_meta_2016_10_05.txt"
                     , sep = "\t"
                     , header = TRUE
                     , quote = ""
                     )

d = merge(d, station[, c("ID", "Abs_PM", "Fwy", "Dir", "Type")])


# Check for bottlenecks
# Starting with the simplest things that I can possibly do.
############################################################

#time_thresh = 5  # Units in minutes
#low_occ_thresh = 0.2
#high_occ_thresh = 0.3

occ = d[, grep("occupancy", colnames(d), value = TRUE)]
d$mean_occ = rowMeans(occ, na.rm = TRUE)

d$minute = extract_minutes(d$timestamp)
d$hour = d$minute / 60

#d$low_occ = mean_occ < low_occ_thresh
#d$high_occ = mean_occ > high_occ_thresh

# Absolute Postmiles `Abs_PM` start at 0 on the South and West border,
# increasing when traveling North and East- just like a 2d plot!

# Start out with one highway and direction, then generalize
hwy = d[(d$Fwy == 80)
        & (d$Dir == "E")
        & (d$Type == "ML")
        , ]

save(hwy, file = "hwy.rda")

# Plot this as an image
hwy_long = hwy[, c("mean_occ", "Abs_PM", "hour")]

# Cheater way to scale
hwy_long$mean_occ[hwy_long$mean_occ > 0.5] = 0.5

# Interesting how diagonal lines appear that look like this: /
# I wonder if they are the same slope as the speed limit? that would mean
# traffic moves somewhat like a convoy.

trellis.device("png"
               , file = "I80_occupancy.png"
               , width = 1080
               , height = 1080
               , color = FALSE
               )

levelplot(mean_occ ~ hour * Abs_PM
          , data = hwy_long
          , main = "Occupancy across first two lanes\nI80 East on Tuesday, May 10th\nfrom raw 30 second readings"
          )

dev.off()

# TODO - Refactor this and run it on more days.

# How does this compare with the 5 minute aggregate? Can we observe the
# same features?
############################################################

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

# Doing this now so that plots are directly comparable
hwy2$mean_occ[hwy2$mean_occ > 0.5] = 0.5

trellis.device("png"
               , file = "I80_occupancy_5min.png"
               , width = 1080
               , height = 1080
               , color = FALSE
               )

levelplot(mean_occ ~ timestamp * Abs_PM
          , data = hwy2
          , main = "Occupancy across first two lanes\nI80 East on Tuesday, May 10th\nFrom cleaned 5 minute aggregate"
          )

dev.off()

# Comparing these two graphs we see that the 5 minute data mistakenly
# "believes" the 0's in the data and even uses them to impute. This is
# evident in the afternoon at mile 65.


# Do we see any CHP incidents around mile 18?
############################################################

chp = read.csv("~/data/pems/all_text_chp_incident_day_2016_05_10.txt"
               , header = FALSE)

chp2 = data.frame(incident_id = chp[, 1]
                  , timestamp = chp[, 4]
                  , Fwy = chp[, 15]
                  , Dir = chp[, 16]
                  , Abs_PM = chp[, 18]
                  )

chp80 = chp2[(chp2$Fwy == 80)
             & (chp2$Dir == "E")
             , ]

# Find the one around mile 18
# This is incident id 16418691
focus = chp80[abs(chp80$Abs_PM - 18) < 2, ]

details = read.csv("~/data/pems/all_text_chp_incident_det_day_2016_05_10.txt.gz"
               , header = FALSE)

details = details[details[, 1] %in% focus$incident_id, ]

# Description says "CZP- Assist with Construction"
# Duration says 91 minutes - consistent with what we see in graphs.
chp[chp[, 1] %in% focus$incident_id, ]
