
#devtools::install_github("rstudio/sparkapi", ref = "feature/spark_lapply")

library(sparkapi)

sc <- start_shell(master = "local")
rdd <- spark_parallelize(sc, 1:10, 2L)
newrdd <- spark_lapply(rdd, function(x) x + 1)

a = spark_collect(newrdd)

n = 10
b = spark_parallelize(sc, list(1:n, rnorm(2 * n)), 2L)
b2 <- spark_lapply(b, function(x) mean(x) + pi)

spark_collect(b)

stop_shell(sc)
