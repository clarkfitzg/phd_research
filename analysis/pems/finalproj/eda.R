# Tue Nov  1 16:33:13 PDT 2016
#
# Exploring PeMS data again. This time for a final project.
# Goals:
#
# - Interesting analysis
# - Use all data on server
# - R parallel programming
# - Use C/C++ for speed

# TODO - move to package once complete
source("helpers.R")

# Basic cleaning steps
############################################################

d = read30sec("~/data/pems/district3/d03_text_station_raw_2016_04_06.txt.gz")

vals = d[, !(colnames(d) %in% c("timestamp", "ID"))]

badvals = (vals == 0) | is.na(vals)

badrows = apply(badvals, 1, all)

d = d[-badrows, ]

# The distribution of occupancy 1 and 2
############################################################

occ1 = d$occupancy1[!is.na(d$occupancy1)
                    & d$occupancy1 != 0
                    ]

occ2 = d$occupancy2[!is.na(d$occupancy2)
                    & d$occupancy2 != 0
                    ]

# Shows that occupancy is distributed about like a mixture of an
# exponential and a point mass near 1. Could also maybe use beta instead of
# exponential to get it to stay in [0, 1].

par(mfrow=c(1, 2))
hist(occ1)
hist(occ2)


# Merge in station metadata
############################################################

station = read.table("~/data/pems/district3/d03_text_meta_2016_03_18.txt"
                     , sep = "\t", header = TRUE)

d = merge(d, station[, c("ID", "Abs_PM", "Fwy", "Dir")])


# Check for bottlenecks
# Starting with the simplest things that I can possibly do.
############################################################

time_thresh = 5  # Units in minutes
low_occ_thresh = 0.2
high_occ_thresh = 0.3

occ = d[, grep("occupancy", colnames(d), value = TRUE)]
mean_occ = rowMeans(occ, na.rm = TRUE)

d$low_occ = mean_occ < low_occ_thresh
d$high_occ = mean_occ > high_occ_thresh

d$minute = extract_minutes(d$timestamp)

# Absolute Postmiles `Abs_PM` start at 0 on the South and West border,
# increasing when traveling North and East- just like a 2d plot!

# Start out with one Fwy and Direction, then generalize
I5N = d[(d$Fwy == 5) & (d$Dir == "N"), ]
