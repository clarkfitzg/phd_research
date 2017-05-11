parallelize = function(...)
{
    # Follow Hadley's Advanced R
    call = substitute(ex, list(lapply = parallel::mclapply))

}


e1 = quote(xmeans <- lapply(x, mean))

parallelize(e1)
