library(Rmpi)


#' Evaluate expression on worker
evaluate = function(code, worker)
{
    id = mpi.comm.rank()
    if(id == worker){
        mpi.bcast.cmd(code)
    }
    NULL
}


#' Send Object
send = function(obj, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == source){
        mpi.send.Robj(obj, dest, tag, comm)
    }
    NULL
}


#' Receive Object
receive = function(name, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == dest){
        value = mpi.recv.Robj(source, tag)
        assign(name, value, .GlobalEnv)
    }
    NULL
}
