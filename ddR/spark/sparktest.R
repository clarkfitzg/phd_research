# Start with the most basic things
library(ddR)

library(Spark.ddR)
useBackend(Spark)

a = dlist(1:10, rnorm(5))

b = dlapply(a, mean)

collect(a)

collect(b)

# This all runs. Which is extremely encouraging :)

n = 10
d = data.frame(a = 1:n, b = rnorm(n))
# Doesn't work
#dd = as.dframe(d)
