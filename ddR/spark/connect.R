# Mon Aug 29 11:47:09 KST 2016
#
# Attempting to connect to a running cluster to get benchmarks which can be
# compared directly.

library(SparkR, lib.loc = "~/dev/spark/R/lib")


# Start a local cluster from the shell, copy the URL from
# http://localhost:8080/, paste it in here and
# try to connect.
sc <- sparkR.session("spark://localhost:7077")

df <- createDataFrame(iris)

df2 <- dapplyCollect(df, function(x) x)
