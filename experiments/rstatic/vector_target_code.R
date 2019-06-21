library(parallel)

nworkers = 2L

# The scheduler will be responsible for this step.
assignments = splitIndices(nchunks, nworkers)

cls = makeCluster(nworkers)

clusterExport(cls, c("assignments", "fnames"))
parLapply(cls, seq(nworkers), function(i) assign("workerID", i, globalenv()))

# Sanity check
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

# An original, non vectorized line
2 * 3
