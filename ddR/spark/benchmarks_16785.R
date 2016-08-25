# Wed Aug 24 14:12:12 KST 2016
# Benchmarking performance before and after dapplyCollect patch

# Downloaded data here:
# https://s3-us-west-2.amazonaws.com/sparkr-data/nycflights13.csv

library(microbenchmark)

PATCH = FALSE

if(PATCH){
    # Patch version
    library(SparkR, lib.loc = "~/dev/spark/R/lib")
}else{
    library(SparkR, lib.loc = "~/dev/sparkr_libs/master")
}


sparkR.session()

df <- read.csv("~/data/nycflights13.csv")

sdf <- createDataFrame(df)

# BEFORE: 7.27 seconds
# AFTER: 7.20 seconds
# The patch shouldn't change this at all
microbenchmark({sdf <- createDataFrame(df)}, times=1)

# Without any repartitioning
# BEFORE: 502 seconds
# AFTER: 508 seconds

# With repartitioning to N partitions
N <- 5L
sdfN <- repartition(sdf, numPartitions = N)

# I don't know if this caching does anything?
cache(sdfN)

# BEFORE    N = 5   212 sec
microbenchmark({
    df2 <- dapplyCollect(sdfN, function(x) x)
}, times=1)

