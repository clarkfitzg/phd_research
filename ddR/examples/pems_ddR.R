# Sat Aug 27 15:53:11 KST 2016

# Goal: Read this table into a ddR dframe
#
# My machine has 4 physical cores and 16 GB memory. The full objects will be
# 1.3 GB each, which is a little too big for comfort. Better just read the
# first two lanes in to cut this size in half.

library(ddR)

# Trying old version of ddR:
#useBackend(parallel, type = "PSOCK")

# There are 4 gzipped files here
station_files = list.files("~/data/pems/", full.names = TRUE)

read1 <- function(file){
    read.table(file, header = FALSE, sep = ",", row.names = NULL
        , col.names = c("timestamp", "station", "flow1", "occupancy1", "speed1"
                        , "flow2", "occupancy2", "speed2" , rep("NULL", 18))
        , colClasses = c("character", "factor", "integer", "numeric", "integer"
                        , "integer", "numeric", "integer", rep("NULL", 18))
        , nrows = 1e6L # <- Come back and remove this
    )
}

#station <- read1(station_files[1])

# Interesting observation- the master R process seems to be working for a
# lot longer than it needs after all the workers have finished. Why? What
# is it doing? It doesn't really need to do anything.
#
# 1st: 168 sec
# 2nd: Hung, had to restart
# 3rd: 175 sec
#
# Takes the same amount of time running on SNOW cluster with ddR master
# branch
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

# TODO:
# If these really were distributed data structures then on my activity
# monitor I would only see the 4 slave nodes with large data on them.

# Takes on the order of 5 minutes??
# Driver process is using 20 GB memory, and my Mac has 16 GB of
# physical memory so it uses compressed memory
system.time({
colnames(ds)
})

# About 15 seconds
system.time({
ds1 = collect(ds, 1)
})

# Why is this 2 GB?? It should be around 400 MB
# Looks like row names are to blame.
print(object.size(ds1), units="GB")

# Now translate the base R workflow into ddR

allrows = seq.int(nrow(ds))
speed1 = ds[allrows, 5]
speed2 = ds[allrows, 8]
in50_90 <- 50 <= speed1 & speed1 <= 90 &
           50 <= speed2 & speed2 <= 90 &
           !is.na(speed1) & !is.na(speed2)

# This has been converted to data.frame
s = ds[which(in50_90), seq.int(ncol(ds))]

# So I guess we convert it back.

# These are 1 x n matrices, aka row vectors
s1 = as.darray(matrix(s$speed1), psize = c(50000, 1))
s2 = as.darray(matrix(s$speed2), psize = c(50000, 1))


# More robust version should find its way into ddR
setMethod("-", signature(e1="ParallelObj", e2="ParallelObj"),
function(e1, e2){
    dmapply(`-`, e1, e2, output.type = "darray", combine = "cbind")
})


delta = s1 - s2


# Parallelized binning for histogram like plot
cut.DObject = function(x, breaks, labels = NULL){
    localcut = function(y){
        table(cut(y, breaks = breaks, labels = labels))
    }
    tabs = collect(dlapply(x, localcut))
    Reduce(`+`, tabs)
}


breaks = c(-Inf, 3 * seq.int(-5, 5), Inf)
dtable = cut.DObject(delta, breaks)

# Shows the distribution of speed differences
plot(dtable)
