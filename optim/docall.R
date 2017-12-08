library(microbenchmark)

N = 1e6L

c_do.call = function(n = N, nworkers = 2L)
{
    x = 1:n
    xc = cut(x, 2)
    xs = tapply(x, xc, identity, simplify = FALSE)
    do.call(c, xs)
}

out_do.call = c_do.call()

c_index = function(n = N, nworkers = 2L)
{
    x = 1:n
    xc = cut(x, 2)
    xs = tapply(x, xc, identity, simplify = FALSE)
    c(xs[[1]], xs[[2]])
}

out_index = c_index()


microbenchmark(c_do.call(), times = 5L)

microbenchmark(c_index(), times = 5L)
