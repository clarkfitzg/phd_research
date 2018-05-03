source("utils.R")

id = 1

# Order of opening sockets is very important here. Server sockets must be
# open before the clients can connect.

workers = list()

workers[[2]] = socketConnection(port = PORTS[id, 2], open = "w+"
        , server = TRUE, blocking = TRUE)

# Nope, this won't work, since previous line has to return first.
# system2("Rscript", c("--vanilla", "worker2.R"))

message(sprintf("Worker %d ready.", id))


# Program begins
############################################################

datadir <- '~/data'            # A worker 1

# Returns immediately
serialize(datadir, workers[[2]])

x <- paste0(datadir, 'x.csv')  # B worker 1

# unserialize waits until it gets something.
# If the other process has closed the connection it's still delivered.
# If the other process completes and disappears it's still delivered.
y <- unserialize(workers[[2]])

xy <- paste0(x, y)             # D worker 1

############################################################
# Program ends


lapply(workers, close)

message(sprintf("Worker %d finished.", id))
