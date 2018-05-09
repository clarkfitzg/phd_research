logfile = file("worker2.log", open = "a")

writeLines("Worker 2 starting.", con = logfile)
############################################################

datadir <- unserialize(workers[[1]])

y <- paste0(datadir, 'y.csv')  # C worker 2

serialize(y, workers[[1]])

print("all done")              # E worker 2

############################################################
writeLines("Worker 2 finished.", con = logfile)

close(logfile)
