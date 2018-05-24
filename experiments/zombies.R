library(parallel)
cl <- makeCluster(2, type = "PSOCK")
ids <- clusterCall(cl, Sys.getpid)

# The worker PID's are listed, as expected.
system2("ps", as.character(ids))

# You might think this would remove them...
stopCluster(cl)

# And it does, for both fork and psock clusters. Hmmm.
system2("ps", as.character(ids))
