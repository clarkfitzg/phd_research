# The target code to generate

library(parallel)


# First set up some toy data
gen_one = function(i, fname)
{
    d = data.frame(y = i, z = 0)
    saveRDS(d, file = fname)
}
nchunks = 4L
fnames = paste0("x", seq(nchunks), ".rds")
Map(gen_one, seq(nchunks), fnames)


nworkers = 2L

# The scheduler will be responsible for this step.
assignments = splitIndices(nchunks, nworkers)

cls = makeCluster(nworkers)

clusterExport(cls, c("assignments", "fnames"))
parLapply(cls, seq(nworkers), function(i) assign("workerID", i, globalenv()))

clusterEvalQ(cls, workerID)

# Now we just evaluate the serial version of the code on all the workers.
clusterEvalQ(cls, {
    fnames = fnames[assignments[[workerID]]]
    xchunks = lapply(fnames, readRDS)
    x = do.call(rbind, xchunks)
    y = x[, "y"]
    y2 = 2 * y
    saveRDS(y2, file = paste0("y2_", workerID, ".rds"))
})

2 * 3
