source("utils.R")

id = 2

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

workers = list()

workers[[1]] = socketConnection(port = PORTS[1, id], open = "w+"
        , server = FALSE, blocking = TRUE)

message(sprintf("Worker %d ready.", id))


# Program begins
############################################################

datadir <- unserialize(workers[[1]])
y <- paste0(datadir, 'y.csv')  # C worker 2
serialize(y, workers[[1]])
print("all done")              # E worker 2

############################################################
# Program ends


lapply(workers, close)

message(sprintf("Worker %d finished.", id))
