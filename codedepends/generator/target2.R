# Mon Feb  6 11:39:59 PST 2017
# This only finds n because it forks
#
# We could go in the environments to pick out the variables that we need

library(parallel)

# start point
n = 10


block1 = mcparallel({
    cat("1st block\n")
    Sys.sleep(1)
    x1 = rnorm(n)
    x2 = x1 + 5
    x3 = x2 + 10
    # TODO
    environment()$x3
})


block2 = mcparallel({
    cat("2nd block\n")
    Sys.sleep(1)
    y1 = runif(n)
    y2 = y1 + 7
    y3 = y2 - 6
})


mccollect()


# Barrier- code must finish before here.
z = x3 + y3
