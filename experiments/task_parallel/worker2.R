source("utils.R")

id = 2

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

send_sockets = list()

send[[1]] = socketConnection(port = PORTS[id, 1], open = "wb"
        , server = TRUE, blocking = TRUE)

receive = list()

receive[[1]] = receive_sockets(port = PORTS[1, id], open = "rb"
        , server = FALSE, blocking = TRUE)

message(sprintf("Worker %d connected", id))


# Program begins
############################################################

datadir <- unserialize

datadir <- '~/data'            # A worker 1
x <- paste0(datadir, 'x.csv')  # B worker 1
y <- paste0(datadir, 'y.csv')  # C worker 2
xy <- paste0(x, y)             # D worker 1
print("all done")              # E worker 2

datadir <- '~/data'            # A worker 1
serialize(datadir, send[[2]])
x <- paste0(datadir, 'x.csv')  # B worker 1
y <- serialize(receive[[2]])
xy <- paste0(x, y)             # D worker 1

############################################################
# Program ends


lapply(receive, close)
lapply(send, close)

message(sprintf("Worker %d successful", id))
