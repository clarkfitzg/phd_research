# Tue Mar 21 14:06:21 PDT 2017
#
# Goal: Fit a piecwise linear fundamental diagram for each station ID using 30 second
# data. Fit using robust regression to limit the effect of outliers.
# Each file is around 1 GB when loaded in R, and there are several hundred
# files (we could actually take as many as we like).
#
# This can't be easily done in a database because robust regression is
# a relatively specialized method, yet available in MASS::rlm.
# Ideally we could combine the best of both worlds.
#
# This is difficult because the data files are split by day, yet we
# need to group by station ID, which shows up in every day.

library(traffic)

dfile = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

d = read30sec(dfile)

# Let's look at the fundamental diagram for the 2nd lane
d2 = d[(d$speed2 > 0)
       & (d$occupancy2 > 0)
       & !(is.na(d$speed2))
       & !(is.na(d$occupancy2))
       , c("occupancy2", "speed2")]

s = sample(nrow(d2), 100)

# These look too crazy. Think I need to go with 5 minute data to see a more
# reasonable fundamental diagram.
with(d2[s, ], plot(occupancy2, speed2))

# Now I'm thinking about how to do this split. The ff package looks
# appealing, but unmaintained for a little while. iotools and data.table
# are also appealing to get high performance read / write. Let's see if I
# can do this split with iotools pipeline parallelism

library(iotools)




chunk.apply(dfile, function(chunk)
)

     chunk.apply("input.file.txt",
                 function(o) {
                   m = mstrsplit(o)
                   quantile(as.numeric(m[,1]), c(0.25, 0.5, 0.75))
                 }, CH.MAX.SIZE=1e5)
     ## End(Not run)


