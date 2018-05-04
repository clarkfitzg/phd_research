library(Rmpi)


_evaluate = function(dest, expr)
{
    id = mpi.comm.rank()
    if(id == dest){
       _eval(expr, envir = .GlobalEnv)
    }
    NULL
}


#' Evaluate expression on worker dest
evaluate = function(dest, expr)
{
    mpi.bcast.cmd(_evaluate, dest = dest, expr = expr)
}


#' Send Object
_send = function(varname, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == source){
        obj = get(varname, .GlobalEnv)
        mpi_send.Robj(obj, dest, tag, comm)
    }
    NULL
}


#' Receive Object
_receive = function(varname, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == dest){
        value = mpi.recv.Robj(source, tag)
        assign(varname, value, .GlobalEnv)
    }
    NULL
}


#' Wraps_send and_receive.
transfer = function(...)
{
    mpi.bcast.cmd(_send, ...)
    mpi.bcast.cmd(_receive, ...)
}
