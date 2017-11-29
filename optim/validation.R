# Wed Nov 29 10:41:28 PST 2017
# Validating model

library(microbenchmark)

# Given observations of linear functions f and g at points a and b this
# calculates the integral of f * g from a to b.
inner_one_piece = function(a, b, fa, fb, ga, gb)
{
    # Roughly following my notes
    fslope = (fb - fa) / (b - a)
    gslope = (gb - ga) / (b - a)

    fint = fa - fslope * a
    gint = ga - gslope * a

    # polynomial coefficients for integral
    p3 = fslope * gslope / 3
    p2 = (fint * gslope + fslope * gint) / 2
    p1 = fint * gint

    (p3*b^3 + p2*b^2 + p1*b) - (p3*a^3 + p2*a^2 + p1*a)
}


# Compute function inner product on two piecewise linear functions
#
# x1, y1 are vectors of corresponding x and y coordinates that define a
# piecewise linear function on [0, 1].
# Same for x2, y2.
piecewise_inner = function(x1, y1, x2, y2)
{
    x = sort(unique(c(x1, x2)))
    f = approx(x1, y1, xout = x)$y
    g = approx(x2, y2, xout = x)$y

    nm1 = length(x) - 1
    parts = rep(NA, nm1)

    # If inner_one_piece is vectorized then we can replace the for loop
    # with:
    # a = -length(x)
    # b = -1
    # parts = inner_one_piece(x[a], x[b], f[a], f[b], g[a], g[b])
    for(i in seq(nm1)){
        ip1 = i + 1
        parts[i] = inner_one_piece(x[i], x[ip1], f[i], f[ip1], g[i], g[ip1])
    }
    sum(parts)
}


seconds = function(expr, times = 1L, ...)
{
    e = substitute(expr)
    bm = microbenchmark(list = list(e), times = times, ...)
    median(bm$time) / 1e9
}


infer_params = function(f, x)
{
    p = list()
    force(f)
    # How long does it take to execute f(x[i])?
    # Assume this doesn't depend on x[i]
    p$one_func_time = seconds(fx1 <- f(x[1]), times = 10L)
    p$one_func_memory = object.size(fx1)
    p$n = length(x)
    p
}


wrapper = function(xi) do.call(piecewise_inner, xi)

one_experiment = function(nobs = 50, nx = 20)
{
    x = replicate(nx, list(1:nobs, rnorm(nobs), 1:nobs + 0.5, rnorm(nobs))
        , simplify = FALSE)

    p = infer_params(wrapper, x)
    out = as.data.frame(p)

    out$sertime = seconds(lapply(x, wrapper))
    out$partime = seconds(parallel::mclapply(x, wrapper))
    out
}

mclapply_overhead_time = 5e-3
lapply_overhead_time = 2e-6
transfer_rate = 400e6
nprocs = 2

timings = lapply(seq(from = 50, by = 50, length.out = 100), one_experiment)


# Intercepts correspond to mclapply and lapply overhead.

sermodel = lm(sertime ~ I(one_func_time * n), timings)

parmodel = lm(partime ~ I(one_func_time * ceiling(p$n / nprocs))
                      + I(one_func_memory * n / transfer_rate), timings)

