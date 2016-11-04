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

# Basic cleaning step:
# Want at least one nonzero value for both flow and occupancy
############################################################

d = read30sec("~/data/pems/district3/d03_text_station_raw_2016_04_06.txt.gz")

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
d$mean_occ = rowMeans(occ, na.rm = TRUE)

d$low_occ = mean_occ < low_occ_thresh
d$high_occ = mean_occ > high_occ_thresh

d$minute = extract_minutes(d$timestamp)

# Absolute Postmiles `Abs_PM` start at 0 on the South and West border,
# increasing when traveling North and East- just like a 2d plot!

# Start out with one Fwy and Direction, then generalize
I5N = d[(d$Fwy == 5) & (d$Dir == "N"), ]

# Plot this as an image
I5long = I5N[, c("mean_occ", "Abs_PM", "minute")]

# Warnings come from 2 observations per minute. Better way would be to take
# a larger mean.
I5wide = reshape(I5long
                 , timevar = "Abs_PM"
                 , idvar = "minute"
                 , direction = "wide"
                 )

rownames(I5wide) = I5wide$minute

# Take this out and sort it to prepare plotting matrix
# 1's are necessary since `minute` gets stuck in as the first variable
miles = as.numeric(gsub("mean_occ\\.", "",  colnames(I5wide)[-1]))
I5matrix = as.matrix(I5wide[order(I5wide$minute), 1L + order(miles)])

xmile = sort(miles)
yminute = sort(I5wide$minute)
milemarker = c(xmile, tail(xmile, 1) + diff(tail(xmile, 2)))
hour = c(yminute, tail(yminute, 1) + diff(tail(yminute, 2))) / 60

image(x = hour
      , y = milemarker
      , z = I5matrix
      )
