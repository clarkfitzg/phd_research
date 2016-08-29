# Wed Aug 24 14:12:12 KST 2016
# Benchmarking performance before and after dapplyCollect patch

# Downloaded data here:
# https://s3-us-west-2.amazonaws.com/sparkr-data/nycflights13.csv



library(microbenchmark)

PATCH = TRUE
if(PATCH){
    # Patch version
    library(SparkR, lib.loc = "~/dev/spark/R/lib")
}else{
    library(SparkR, lib.loc = "~/dev/sparkr_libs/master")
}

# Fails? Can't parse URL?
#sc <- sparkR.session("localhost:7077")
# But this works fine
sc <- sparkR.session("spark://Clarks-MacBook-Pro.local:7077"
                    , spark.executor.memory = "4g")

                    , spark.executor.memory = "4g")
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
N <- 10L
sdfN <- repartition(sdf, numPartitions = N)
# I don't know if this caching does anything?
sdfN <- cache(sdfN)

# BEFORE    N = 5   212 sec
# BEFORE    N = 10  208 sec
# AFTER     N = 10  206 sec
microbenchmark({
    df2 <- dapplyCollect(sdfN, function(x) x)
}, times=1)

