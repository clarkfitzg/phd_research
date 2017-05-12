substitute_q = function(x, env)
    # Follow Hadley's Advanced R book
{
    call = substitute(substitute(y, env), list(y = x))
    eval(call)
}


parallelize = function(expr)
{
    substitute_q(expr, list(lapply = get("mclapply")))
}


e1 = quote(xmeans <- lapply(x, mean))

parallelize(e1)
