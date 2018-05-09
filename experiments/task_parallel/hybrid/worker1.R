logfile = file("worker1.log", open = "a")

writeLines("Worker 1 starting.", con = logfile)
############################################################

datadir <- '~/data'            # A worker 1

serialize(datadir, workers[[2]])

x <- paste0(datadir, 'x.csv')  # B worker 1

y <- unserialize(workers[[2]])

xy <- paste0(x, y)             # D worker 1

############################################################
writeLines("Worker 1 finished.", con = logfile)

close(logfile)
