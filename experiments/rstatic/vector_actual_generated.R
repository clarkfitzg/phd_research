library(parallel)
nworkers = 2
assignments = list(1:2, 3:4)
cls = makeCluster(nworkers)
clusterExport(cls, c("assignments", "fnames"))
parLapply(cls, seq(nworkers), function(i) assign("workerID", i, globalenv()))
clusterEvalQ(cls, {
    fnames = fnames[assignments[[workerID]]]
    chunks = lapply(fnames, readRDS)
    x = do.call(rbind, chunks)
    y = x[, "y"]
    y2 = 2 * y
    saveRDS(y2, file = paste0("y2_", workerID, ".rds"))
})
2 * 3
