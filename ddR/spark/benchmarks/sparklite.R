# Comparing with SparkR

# Downloaded data here:
# https://s3-us-west-2.amazonaws.com/sparkr-data/nycflights13.csv

library(microbenchmark)
library(sparkapi)
library(sparklite)

# Just a string like "2.0.0". Don't think it's used anywhere.
spark_version_from_home("/Users/clark/Library/Caches/spark/spark-2.0.0-preview-bin-hadoop2.6")

# Connect to already running local cluster
master <- "spark://Clarks-MacBook-Pro.local:7077"
master <- "Clarks-MacBook-Pro.local:7077"
master <- "localhost:7077"
master <- "sparklocalhost:7077"
master <- "spark://Clarks-MacBook-Pro.local:7077"
# master <- "local"  # Not what I want since this doesn't use the one I
# started locally
sc <- start_shell(master, spark_version = "2.1.0")

#sc <- start_shell(master = "local", 
#        spark_home = "/Users/clark/Library/Caches/spark/spark-2.0.0-preview-bin-hadoop2.6/")

df <- read.csv("~/data/nycflights13.csv")

# I imagine that tuning this matters:
N <- 5
splits <- sort(rep(1:N, length.out = nrow(df)))
dflist <- split(df, splits)

# Local takes 10 - 40 MICROSECONDS
#
microbenchmark({
    dflist2 <- lapply(dflist, function(x) x)
}, times=10)



# SparkR
# BEFORE: 502 seconds
# AFTER: 508 seconds
#
# SimpleSpark
# N = 5     2.98 seconds
# N = 20    7.52 seconds
# N = 100   39.5 seconds
# N = 500   320 seconds
#
# Here N corresponds to the number of partitions in the data, and also the
# number of R processes that Spark needs to spin up. 
#
# So we may just be measuring the overhead of spinning up R processes,
# which isn't really that interesting.
#
microbenchmark({
    dflist2 <- clusterApply(sc, dflist, function(x) x)
}, times=1)

stop_shell(sc)
