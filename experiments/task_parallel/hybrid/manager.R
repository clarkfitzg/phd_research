library(parallel)

n = 2L

cls = makeCluster(n, "PSOCK")


workers = vector(n, mode = "list")

close.NULL = function(...) NULL

#' Connect workers as peers
connect = function(from, to, port, sleep = 0.1, timeout = 1000)
{
    if(ID == from){
        con = socketConnection(port = port, server = TRUE
                , blocking = TRUE, open = "w+", timeout = timeout)
        workers[[to]] <<- con
    }
    if(ID == to){
        Sys.sleep(sleep)
        con = socketConnection(port = port, server = FALSE
                , blocking = TRUE, open = "w+", timeout = timeout)
        workers[[from]] <<- con
    }
    NULL
}


clusterExport(cls, c("workers", "connect", "close.NULL"))

# Each worker has an ID
clusterMap(cls, assign, "ID", seq(n)
        , MoreArgs = list(envir = .GlobalEnv))

# Should see a sequence from 1 to n
clusterEvalQ(cls, ID)


# Set up all necessary peer to peer connections
clusterEvalQ(cls, connect(1, 2, 33000))

# Action! Run the scripts
parLapply(cls, c("worker1.R", "worker2.R"), source)

# Shut it all down
clusterEvalQ(cls, lapply(workers, close))
