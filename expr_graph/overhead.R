library(microbenchmark)
library(parallel)
n = 1e6
x = rnorm(n)

# Elementwise, return vector of length n
############################################################

# 1.4 ms
microbenchmark(y = x*x)

# 24 ms
microbenchmark({mcparallel(x*x); y = mccollect()[[1]]})

# Dot product, return scalar
############################################################

# 2.3 ms
microbenchmark(y = sum(x*x))

# 7.2 ms
microbenchmark({mcparallel(sum(x*x)); y = mccollect()[[1]]})
