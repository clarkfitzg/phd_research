#!/usr/bin/env Rscript

# {{{gen_time}}}
# Automatically generated from R by makeParallel version {{{version}}}

library(parallel)

nworkers = {{{nworkers}}}


assignments = splitIndices({{{nchunks}}}, nworkers)

cls = makeCluster(nworkers)

clusterExport(cls, c("assignments", "fnames"))
parLapply(cls, seq(nworkers), function(i) assign("workerID", i, globalenv()))

clusterEvalQ(cls, {
    fnames = fnames[assignments[[workerID]]]
    chunks = lapply(fnames, {{{read_func}}})
    {{{data_varname}}} = do.call({{{combine_func}}}, chunks)

    {{{vector_body}}}

    # We can parameterize this saving function later.
    saveRDS({{{save_var}}}, file = paste0("{{{save_var}}}_", workerID, ".rds"))
})

{{{remainder}}}
