# Wed Apr 24 16:29:27 PDT 2019
#
# This script demonstrates how to compute on a distributed data set, while keeping
# the data distributed over several parallel workers.

library(parallel)

nworkers = 2L
cls = makeCluster(nworkers)


# Replace this with code that actually loads data
load_data = function(n = 1e6)
{
    assign("data_chunk", rnorm(n), globalenv())
    # Returning NULL saves from transferring large object back
    NULL
}

# Make a different variable `data_chunk` available on each worker.
clusterCall(cls, load_data)

# uses data_chunk, the global variable on each worker
likelihood_per_chunk = function(theta)
{
    sum(dnorm(data_chunk, mean = theta, log = TRUE))
}

likelihood = function(theta, .cls = cls)
{
    message("evaluating likelihood function")
    partial_sums = clusterCall(.cls, likelihood_per_chunk, theta = theta)
    sum(unlist(partial_sums))
}


theta0 = 5
result = optim(theta0, likelihood)

