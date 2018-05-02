source("utils.R")

id = 2

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

to = list()

to[[1]] = socketConnection(port = PORTS[id, 1], open = "wb"
        , server = TRUE, blocking = TRUE)

from = list()

from[[1]] = from_socket(port = PORTS[1, id], open = "rb"
        , server = FALSE, blocking = TRUE)

message(sprintf("Worker %d ready.", id))


# Program begins
############################################################

datadir <- unserialize(from[[1]])
y <- paste0(datadir, 'y.csv')  # C worker 2
serialize(y, to[[1]])
print("all done")              # E worker 2

############################################################
# Program ends


lapply(from, close)
lapply(to, close)

message(sprintf("Worker %d finished.", id))
