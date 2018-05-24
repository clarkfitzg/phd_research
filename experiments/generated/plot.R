library(autoparallel)

# One I diagrammed and wrote about. Actually the greedy algorithm can't
# handle this for ex.R, so I'll modify it to remove the first node.

ex = autoparallel("ex2.R", maxworkers = 2L, expr_times = c(1, 1, 0.5, 0.8))
ex2 = autoparallel("ex2.R", runfirst = TRUE)

# Why does the 2nd CSV read go faster than the first? It must be because
# the text for the integers are already in R's internal table. If I run it
# again they take around the same time.

par(mfrow = c(1, 2))
plot(ex$schedule)
plot(ex2$schedule)



ex4 = autoparallel("ex4.R", runfirst = TRUE)

ex4$schedule

# Interesting what dominates the computations. I would like to design
# something that spends more time sending / receiving.
plot(ex4$schedule)


