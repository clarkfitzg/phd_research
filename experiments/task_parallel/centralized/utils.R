library(Rmpi)


#' Evaluate expression on worker dest
evaluate = function(expr, dest)
{
    id = mpi.comm.rank()
    if(id == worker){
        eval(expr, envir = .GlobalEnv)
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
