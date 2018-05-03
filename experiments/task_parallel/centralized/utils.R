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
