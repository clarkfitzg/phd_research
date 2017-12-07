# Thu Dec  7 11:34:39 PST 2017
# Three strategies for a sort:
# - serial
# - parallel given existing workers
# - parallel using fork

# If transfer rate is 400 MB/s then it will take 20 ms to transfer a
# million points. Ouch.

library(microbenchmark)

n = 1e6

x = rnorm(n)

# About 80 ms for 1 million pts
microbenchmark(sort(x), times = 10L)


# Produce the breaks for cut based on a sample
find_cut_pts = function(samp, nworkers)
{
    step = 1 / nworkers
    qpts = seq(from = step, to = 1 - step, by = step)
    q = quantile(samp, probs = qpts)
    c(-Inf, q, Inf)
}


sort2_docall = function(x, nworkers = 2L)
{
    samp = sample(x, size = 1000L)
    cutpts = find_cut_pts(samp, nworkers = nworkers)
    xc = cut(x, cutpts)
    # Still need a parallel version of `tapply` to drop in here.
    xs = tapply(x, xc, sort, simplify = FALSE)
    #browser()
    do.call(c, xs)          # TODO: Why the huge performance diff
}


sort2_c = function(x, nworkers = 2L)
{
    samp = sample(x, size = 1000L)
    cutpts = find_cut_pts(samp, nworkers = nworkers)
    xc = cut(x, cutpts)
    # Still need a parallel version of `tapply` to drop in here.
    xs = tapply(x, xc, sort, simplify = FALSE)
    #browser()
    #do.call(c, xs)          # TODO: Why the huge performance diff
    c(xs[[1]], xs[[2]])    # and this line?
    #unlist(xs)
}



xs2 = sort2(x)


# Matches, but...
all(sort2(x) == sort(x))


# Takes 600ms!! Ouch.
Rprof()

microbenchmark(sort2_c(x), times = 5L)

# Only saw one call to gc() during this.
microbenchmark(sort2_docall(x), times = 5L)

Rprof(NULL)

# sort2 doesn't call as.character(), yet this profiling shows that it's
# quite expensive. Must be catching the result from somewhere else
summaryRprof()

n = 1e6L
x1 = rnorm(n)
x2 = rnorm(n)
l = list(x1, x2)

# But these are about the same...

microbenchmark(c(x1, x2), times = 10L)
microbenchmark(c(l[[1]], l[[2]]), times = 10L)
microbenchmark(do.call(c, l), times = 10L)

