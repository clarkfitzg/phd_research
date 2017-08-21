# Mon Aug 21 10:55:19 PDT 2017
#
# Considering a different approach to calculating the covariance as in the
# autoparallel package. Most of the overhead there comes from splitting the
# data into units amenable to parallel computing. But if the data is
# already split then perhaps this overhead can be avoided. Thus we split
# the data into a list of chunks and run the algorithm with this input.
# This will only work if we can access the elements of a list without
# unnecesarily copying them. Can we do this in R?

library(microbenchmark)

x = rnorm(1e7)
l = list(1:10, x)

# These should be fast, and approximately equal speed.
# A necessary, but not sufficient condition.
microbenchmark(l[[1]], l[[2]])
# Great, they are about the same

# If these are about the same this is good. YES.
microbenchmark(head(x), head(l[[2]]))

# Compare to a function that forces a copy
f = function(x){
    head(x[-1])
}

microbenchmark(head(x), f(x), times = 5L)
