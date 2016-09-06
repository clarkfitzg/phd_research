# Sat Aug 27 15:53:11 KST 2016

# Goal: Read this table into a ddR dframe
#
# My machine has 4 physical cores and 16 GB memory. The full objects will be
# 1.3 GB each, which is a little too big for comfort. Better just read the
# first two lanes in to cut this size in half.

library(ddR)

read1 <- function(file){
    read.table(file, header = FALSE, sep = ","
        , col.names = c("timestamp", "station", "flow1", "occupancy1", "speed1"
                        , "flow2", "occupancy2", "speed2" , rep("NULL", 18))
        , colClasses = c("character", "factor", "integer", "numeric", "integer"
                        , "integer", "numeric", "integer", rep("NULL", 18))
    )
}

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

# Now translate the base R workflow into ddR

# Suppose the traffic is between 50 and 90 mph. Then is one lane faster than the
# other?
in50_90 <- with(s2, 50 <= speed1 & speed1 <= 90
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


