library(Rmpi)


do_evaluate = function(dest, expr)
{
    id = mpi.comm.rank()
    if(id == dest){
       eval(expr, envir = .GlobalEnv)
    }
    NULL
}


#' Evaluate expression on worker dest
evaluate = function(dest, expr)
{
    mpi.bcast.cmd(do_evaluate, dest = dest, expr = expr)
}


#' Send Object
send = function(varname, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == source){
        obj = get(varname, .GlobalEnv)
        mpisend.Robj(obj, dest, tag, comm)
    }
    NULL
}


#' Receive Object
receive = function(varname, source, dest, tag, comm = 1)
{
    id = mpi.comm.rank()
    if(id == dest){
        value = mpi.recv.Robj(source, tag, comm)
        assign(varname, value, .GlobalEnv)
    }
    NULL
}


#' Wraps send and receive.
transfer = function(...)
{
    mpi.bcast.cmd(send, ...)
    mpi.bcast.cmd(receive, ...)
}
