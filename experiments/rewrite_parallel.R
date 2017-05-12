lapply_to_mclapply = function(expr)
{
    # Changes lapply to parallel::mclapply
    #
    lapply = quote(parallel::mclapply)
    expr = force(expr)
    # Following Wickham's Advanced R book
    call = substitute(substitute(expr))
    eval(call)
}

############################################################

e1 = quote(xmeans <- lapply(x, mean))

lapply_to_mclapply(e1)

e2 = quote({
    xmeans <- lapply(x, mean)
    lapply(x, median)
})

lapply_to_mclapply(e2)


############################################################
# Swap out functions more generally

func_swap = function(expr, ...)
{
    expr = force(expr)
    # Following Wickham's Advanced R book
    call = substitute(substitute(expr, list(...)))
    eval(call)
}

func_swap(e1, lapply = quote(parallel::mclapply))
