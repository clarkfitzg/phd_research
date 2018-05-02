source("utils.R")

id = 1

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

workers = list()

workers[[2]] = socketConnection(port = PORTS[id, 2], open = "w+"
        , server = TRUE, blocking = TRUE)

message(sprintf("Worker %d ready.", id))


# Program begins
############################################################

datadir <- '~/data'            # A worker 1
serialize(datadir, workers[[2]])
x <- paste0(datadir, 'x.csv')  # B worker 1
y <- unserialize(workers[[2]])
xy <- paste0(x, y)             # D worker 1

############################################################
# Program ends


lapply(workers, close)

message(sprintf("Worker %d finished.", id))
