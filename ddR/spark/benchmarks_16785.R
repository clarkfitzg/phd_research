# Fri Aug 19 08:07:10 KST 2016
# Benchmarking performance before and after dapplyCollect patch

# Downloaded data here:
# https://s3-us-west-2.amazonaws.com/sparkr-data/nycflights13.csv

library(SparkR, lib.loc = "~/dev/spark/R/lib")

sparkR.session()

sdf = createDataFrame(iris)

df <- read.csv("~/data/nycflights13.csv")
microbenchmark::microbenchmark(createDataFrame(sqlContext, df), times=3)
