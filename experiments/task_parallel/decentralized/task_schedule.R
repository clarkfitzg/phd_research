# Tue May  1 12:02:56 PDT 2018
#
# Basic test of task graph

library(autoparallel)

script = parse(text = "
    datadir <- '~/data'            # A
    x <- paste0(datadir, 'x.csv')  # B
    y <- paste0(datadir, 'y.csv')  # C
    xy <- paste0(x, y)             # D
    Sys.sleep(2)
")

ap = autoparallel(script)


# Basically we need to do two things:
# 1. Asynchronously evaluate code on the workers
# 2. Send variables from one worker to another

async_eval = function(cls, code, worker){
}

# Hopefully we won't have to manually manage the queueing too much.

# It should generate something like the following:
############################################################

# Generated by autoparallel on Wed May  2 08:32:05 PDT 2018
script = parse(text = "
    datadir <- '~/data'            # A
    x <- paste0(datadir, 'x.csv')  # B
    y <- paste0(datadir, 'y.csv')  # C
    xy <- paste0(x, y)             # D
    Sys.sleep(2)
    NULL
")

cls = parallel::makeCluster(2L, 'PSOCK')

# I don't know what the `return` argument to `sendCall` does, but it
# returns immediately regardless of it being TRUE or FALSE.
parallel:::sendCall(con = cls[[1]], fun = eval
    , args = script[[1]])

# Testing:
parallel::clusterCall(cls, exists, "datadir")
