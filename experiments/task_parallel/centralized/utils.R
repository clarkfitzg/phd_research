library(Rmpi)


#' Receive Object
receive = function(name, tag, source, dest)
{
    id = mpi.comm.rank()
    if(id == dest){
        value = mpi.recv.Robj(source, tag)
        assign(name, value, .GlobalEnv)
    }
    NULL
}


# Program
############################################################

# Can't do more than 1 slave on my 2 core machine!
mpi.spawn.Rslaves(nslaves = 1)


# From docs:
# ‘mpi.bcast.Rfun2slave’ transmits all master's functions to slaves and
# returns no value. 
mpi.bcast.Rfun2slave()

mpi.remote.exec(ls())
# The worker now has the receive() function


x = "funstuff"

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

mpi.close.Rslaves()
