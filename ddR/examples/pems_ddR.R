# Sat Aug 27 15:53:11 KST 2016

# Goal: Read this table into a ddR dframe
#
# My machine has 4 physical cores and 16 GB memory. The full objects will be
# 1.3 GB each, which is a little too big for comfort. Better just read the
# first two lanes in to cut this size in half.

library(ddR)

# There are 4 gzipped files here
station_files = list.files("~/data/pems/", full.names = TRUE)

read1 <- function(file){
    read.table(file, header = FALSE, sep = ",", row.names = NULL
        , col.names = c("timestamp", "station", "flow1", "occupancy1", "speed1"
                        , "flow2", "occupancy2", "speed2" , rep("NULL", 18))
        , colClasses = c("character", "factor", "integer", "numeric", "integer"
                        , "integer", "numeric", "integer", rep("NULL", 18))
    )
}

station <- read1(station_files[1])

# Interesting observation- the master R process seems to be working for a
# lot longer than it needs after all the workers have finished. Why? What
# is it doing? It doesn't really need to do anything.
#
# 1st: 168 sec
# 2nd: Hung, had to restart
# 3rd: 175 sec
#
# It should only take the time for the longest read.table (~50 seconds) plus
# some minimal overhead time.
#
# Note: Why are all these args necessary in this case? In particular nparts
# can be inferred from the others
#
system.time({
# Distributed station dataframe:
ds <- dmapply(read1, station_files, output.type = "dframe"
              , nparts = c(4, 1),  combine = "rbind"
              )
})

# Takes on the order of 5 minutes??
system.time({
colnames(ds)
})

# About 15 seconds
system.time({
ds1 = collect(ds, 1)
})

# Wait, why is this 2 GB?? It should be around 400 MB
print(object.size(ds1), units="GB")

# From previous
print(object.size(station), units="GB")

dim(ds1)

sapply(ds1, class)

sapply(station, class)

identical(station, ds1)
# No

all.equal(station, ds1)

# Now translate the base R workflow into ddR

# Suppose the traffic is between 50 and 90 mph. Then is one lane faster than the
# other?
in50_90 <- with(ds, 50 <= speed1 & speed1 <= 90
                  & 50 <= speed2 & speed2 <= 90
                  & !is.na(speed1) & !is.na(speed2))

s <- s2[in50_90, ]

# Down to 2.1 million
dim(s)

median(s$speed1)
median(s$speed2)

# So the average speed for fast traffic is about 4.1 mph faster in the 1st
# lane.
delta <- s$speed1 - s$speed2

t.test(delta)

hist(delta)

# Leave out the long tails
d2 <- delta[abs(delta) < 17]
length(d2)

plot(density(d2, bw = 1))

breaks = 2 * seq.int(-9, 8) + 1

# This one is my favorite plot
hist(d2, freq = FALSE, breaks = breaks)

breaks = c(-Inf, 3 * seq.int(-5, 5), Inf)
# Too bad hist() doesn't do this...
plot(cut(delta, breaks))


