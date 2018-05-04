
# Program begins
############################################################

datadir <- unserialize(workers[[1]])

y <- paste0(datadir, 'y.csv')  # C worker 2

serialize(y, workers[[1]])

print("all done")              # E worker 2

############################################################
# Program ends


lapply(workers, close)

message(sprintf("Worker %d finished.", ID))
