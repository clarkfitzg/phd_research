source("utils.R")

script = parse(text = "
    datadir <- '~/data'            # A worker 1
    x <- paste0(datadir, 'x.csv')  # B worker 1
    y <- paste0(datadir, 'y.csv')  # C worker 2
    xy <- paste0(x, y)             # D worker 1
    print('all done')              # E worker 2
")


mpi.spawn.Rslaves(nslaves = 2)


mpi.bcast.Rfun2slave()
mpi.remote.exec(ls())
# both workers have the receive() function



mpi.close.Rslaves()


# Send x to worker 1.
mpi.send.Robj(x, 1, tag)
# This returns immediately, before I execute the receive command on the
# worker. I'm not sure what the non blocking version mpi.isend.Robj does.

# Receive x on worker 1
mpi.remote.exec(receive, name = "x", tag = tag, source = 0, dest = 1
                , ret = FALSE)

mpi.remote.exec(ls())
# The worker has both `receive` and `x`

mpi.close.Rslaves()
