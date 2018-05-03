library(Rmpi)

# Can't do more than 1 slave on my 2 core machine!
mpi.spawn.Rslaves(nslaves = 1)

# Here's what I need to be using.
mpi.send.Robj


mpi.close.Rslaves()


#' Send Command To Worker
command = function(expr, worker, async = TRUE)
{
}
