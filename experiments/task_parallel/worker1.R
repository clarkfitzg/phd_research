source("utils.R")

id = 1

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

send_sockets = list()

send[[2]] = socketConnection(port = PORTS[id, 2], open = "wb"
        , server = TRUE, blocking = TRUE)

receive = list()

receive[[2]] = receive_sockets(port = PORTS[2, id], open = "rb"
        , server = FALSE, blocking = TRUE)

message(sprintf("Worker %d connected", id))


# Program begins
############################################################

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
