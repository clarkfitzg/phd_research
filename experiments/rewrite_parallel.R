substitute_q = function(x, env)
    # Follow Hadley's Advanced R book
{
    call = substitute(substitute(y, env), list(y = x))
    eval(call)
}


parallelize = function(expr)
{
    lapply = quote(parallel::mclapply)
    #inner_expr = expr
    expr = force(expr)
    call = substitute(substitute(expr))
    eval(call)
}


# All I want to do is change lapply to parallel::mclapply
e1 = quote(xmeans <- lapply(x, mean))

parallelize(e1)
