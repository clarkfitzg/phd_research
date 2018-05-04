source("utils.R")


# Can't do more than 1 slave on my 2 core machine!
mpi.spawn.Rslaves(nslaves = 2)

# From docs:
# ‘mpi.bcast.Rfun2slave’ transmits all master's functions to slaves and
# returns no value. 
mpi.bcast.Rfun2slave()

mpi.remote.exec(ls())
# The worker now has the functions in utils

# Now we can write the actual program.
############################################################

evaluate(1, quote(x <- "funstuff"))

mpi.bcast.cmd(evaluate, expr = , dest = 1)

# Identifies this particular transmission of data, so should be fine if
# this is just a counter.
tag = 1

# Send x to worker 1.
mpi.send.Robj(x, 1, tag)
# This returns immediately, before I execute the receive command on the
# worker. I'm not sure what the non blocking version mpi.isend.Robj does.

# Receive x on worker 1
mpi.remote.exec(receive, name = "x", tag = tag, source = 0, dest = 1
                , ret = FALSE)

mpi.remote.exec(ls())
# The worker has both `receive` and `x`

mpi.bcast.cmd(z <- 20)

mpi.remote.exec(z)

mpi.close.Rslaves()
