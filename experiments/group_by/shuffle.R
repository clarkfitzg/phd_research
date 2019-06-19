# Tue Jun 18 15:37:55 PDT 2019
#
# Do an actual experiment, how long does it take before we're ready to compute on the groups?

library(parallel)
library(partools)

# Shuffles data to put groups on the same worker
#
# split_col_name is a column that exists in the data frames and identifies the group
# This is just the implementation for an arbitrary schedule.
# Indeed, it takes the schedule in through two parameters: load_workers and group_workers
# The actual scheduling logic is elsewhere.
#
# @param data_files character, names of the files containing the data frames
# @param split_col_name name of the column to split by
# @param load_workers integer, assignments of the data_files to workers, same length as data_files
# @param groups vector of unique values of split_col_name
# @param group_workers integer, assignments of the groups to workers, same length as split_col_name
# @param load_func function to read in one data file.
# @param data_name name of the variable to save that holds the data files
# @return time it takes to perform the shuffle
shuffle = function(data_files, split_col_name, load_workers, groups, group_workers, load_func = readRDS, data_name = "DATA")
{

    nworkers = max(load_workers, group_workers)

    cls = makeCluster(nworkers, type = "FORK")

    setclsinfo(cls)
    ptMEinit(cls)

    clusterExport(cls, varlist = c(names(formals()), "nworkers"))

    # Each worker loads up their own data and partitions it according to which worker it will go to.
    clusterEvalQ(cls, {
        id = partoolsenv$myid
        files_to_load = data_files[load_workers == id]
        alldata = lapply(files_to_load, load_func)
        alldata = do.call(rbind, pieces)

        # Create a column assigning each row to the worker it will go to.
        # There must be a better way to do this.
        assignments = rep(NA, nrow(alldata))
        split_col = alldata[, split_col_name]
        for(w in seq(nworkers)){
            w_group = groups[group_workers == w]
            assignments[split_col %in% w_group] = w
        }
        alldata$assignments = assignments

        assign(data_name, value = alldata, pos = globalenv())
        NULL
    })

    # Now each worker sends data to every other worker, beginning with the next highest worker.
    clusterEvalQ(cls, {
        next_send_id = partoolsenv$myid
        next_receive_id = partoolsenv$myid

        for(i in seq(nworkers - 1)){
            # No, this isn't right.
            next_send_id = ((next_send_id + 1L) %% nworkers) + 1L
            next_receive_id = ((next_receive_id - 1L) %% nworkers) + 1L
        }
    })

}



if(FALSE){

    data_files = c("1.rds", "2.rds", "3.rds", "4.rds")
    for(f in data_files) saveRDS(iris, f)
    split_col_name = "Species"
    load_workers = c(1, 1, 2, 3)
    groups = unique(iris$Species)
    group_workers = c(1, 2, 2, 3)
    load_func = readRDS
    data_name = "DATA"

}
