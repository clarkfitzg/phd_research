
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
