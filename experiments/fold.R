# Fri Feb  9 14:33:51 PST 2018
#
# Comparing the performance for an alternate implementation of Reduce()

library(future)

library(microbenchmark)

fold = future:::fold


n = 1e5
x = rnorm(n)

# Naive

# 35 ms
microbenchmark(
    t1 <- Reduce(`+`, x)
, times = 10L)

# 105 ms
microbenchmark(
    t2 <- fold(x, `+`)
, times = 10L)
