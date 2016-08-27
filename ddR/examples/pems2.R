# Sat Aug 27 15:53:11 KST 2016

# Goal: Read this table into a ddR dframe
#
# My machine has 4 physical cores and 16 GB memory. The full objects will be
# 1.3 GB each, which is a little too big for comfort. Better just read the
# first two lanes in to cut this size in half.

# There are 4 gzipped files here
station_files = list.files("~/data/pems/", full.names = TRUE)

# Takes 47 seconds to read a single gzipped file.
system.time({
station <- read.table(station_files[1]
    , header = FALSE, sep = ","
    , col.names = c("timestamp", "station", "flow1", "occupancy1", "speed1"
                    , "flow2", "occupancy2", "speed2" , rep("NULL", 18))
    , colClasses = c("character", "factor", "integer", "numeric", "integer"
                    , "integer", "numeric", "integer", rep("NULL", 18))
    )
})

print(object.size(station), units="MB")

dim(station)

sapply(station, class)


# Now try it with ddR
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
system.time({
# Distributed station dataframe:
ds <- dmapply(read1, station_files, output.type = "dframe"
              , nparts = c(1, 4),  combine = "rbind"
              )
})

# Doesn't work due to bug in ddR. Come back and look into it.
testds <- dmapply(function(x) data.frame(a = 1, b = 2), 1:4, output.type = "dframe"
              , nparts = c(1, 4),  combine = "rbind"
        )
