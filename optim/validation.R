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


# What I really want is a macro that evaluates this function body exactly
# as if I had typed it out. Right now it's causing me all kinds of
# headaches. For example, I thought this version would work, but looks like
# it could be trying to use dynamic rather than lexical scoping. Ack.

# debug at validation.R#56: bm = microbenchmark(list = list(e), times = times, ...)
# Browse[2]> e
# fx1 <- wrapper(x[1])
# Browse[2]> x
# Error: object 'x' not found
# Browse[2]> ls(parent.frame())
# [1] "p" "x"

seconds = function(expr, times = 1L, ...)
{
    e = substitute(expr)
    bm = microbenchmark(list = list(e), times = times, ...)
    median(bm$time) / 1e9
}

mb = microbenchmark
# Post process
ppmb = function(x) median(x$time) / 1e9

infer_params = function(f, x)
{
    p = list()
    # How long does it take to execute f(x[i])?
    # Assume this doesn't depend on x[i]
    p$one_func_time = ppmb(mb(fx1 <- f(x[[1]]), times = 10L))
    p$one_func_memory = as.numeric(object.size(fx1))
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

    out$sertime = ppmb(mb(lapply(x, wrapper), times = 1L))
    out$partime = ppmb(mb(parallel::mclapply(x, wrapper), times = 1L))
    out
}

mclapply_overhead_time = 5e-3
lapply_overhead_time = 2e-6
transfer_rate = 400e6
nprocs = 2

nobs = seq(from = 50, by = 50, length.out = 20)
nx = c(20, 50, 100)
params = expand.grid(nobs, nx)

rawtimings = Map(one_experiment, params[, 1], params[, 2])

timings = do.call(rbind, rawtimings)

# Intercepts correspond to mclapply and lapply overhead.

sermodel = lm(sertime ~ I(one_func_time * n), timings)

# The intercept is about 0, and the slope is about 1, so the model of
# runtime for the serial case is reasonable.
summary(sermodel)

parmodel = lm(partime ~ I(one_func_time * ceiling(n / nprocs))
                      + I(one_func_memory * n / transfer_rate), timings)

# The last coefficient is difficult to estimate in this case because we're only
# transferring single scalars back- the cost is negligible.
summary(parmodel)

# The residuals have a long right tail, so in some few exceptional cases it
# takes much longer than expected. I've observed this phenomenon before
# with microbenchmarks involving mclapply, and I don't know the exact
# reason for it.

# The parallel model has R2 = 0.825, and the serial has R2 = 0.997, so the
# serial fits much better.

# Looking at Faraway's Linear Model book now:

mm = model.matrix(parmodel)
r = residuals(parmodel)

plot(mm[, 2], r)

var.test(r[mm[, 2] >= 0.1], r[mm[, 2] < 0.1])
# Strong evidence that variance is larger if the one function call takes
# longer. Totally reasonable!

# Suggests a log transform of the response.
MASS::boxcox(parmodel)

logparmodel = lm(log(partime) ~ I(one_func_time * ceiling(n / nprocs))
                      + I(one_func_memory * n / transfer_rate), timings)

plot(logparmodel)
