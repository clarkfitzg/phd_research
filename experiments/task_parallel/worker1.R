source("utils.R")

id = 1

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

to = list()

to[[2]] = socketConnection(port = PORTS[id, 2], open = "wb"
        , server = TRUE, blocking = TRUE)

from = list()

from[[2]] = from_socket(port = PORTS[2, id], open = "rb"
        , server = FALSE, blocking = TRUE)

message(sprintf("Worker %d ready.", id))


# Program begins
############################################################

datadir <- '~/data'            # A worker 1
serialize(datadir, to[[2]])
x <- paste0(datadir, 'x.csv')  # B worker 1
y <- serialize(from[[2]])
xy <- paste0(x, y)             # D worker 1

############################################################
# Program ends


lapply(from, close)
lapply(to, close)

message(sprintf("Worker %d finished.", id))
