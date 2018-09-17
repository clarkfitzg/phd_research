library(makeParallel)

codewall = parse("codewall.R")

# Some times are large, some not.
set.seed(8439)
n = length(codewall)
times = runif(n)
epsilon = 1e-4
times[sample.int(n, size = floor(n/2))] = epsilon

g = inferGraph(codewall, time = times)

s = scheduleFork(g)
