library(lattice)
trellis.device(color = FALSE)


m = matrix(c(5, 3, 1, 2, 0, 3,
             4, 6, 2, 1, 0.5, 2,
             5, 6, 20, 2, 4, 4,
             1, 0, 2, 7, 4, 4,
             2, 0.5, 3, 1, 1, 2)
, nrow = 5, byrow = TRUE)

# To proportions
p = m / sum(m)


lattice::levelplot(p)
# This plot just shows that we would do well to put both of the third groups on the same worker.

colSums(p)

rowSums(p)

# Suppose we have three workers.
# Let the columns be the first grouping variable and the rows be the second grouping variable.


m2 = matrix(c(5, 3, 1, 2, 0, 3,
             4, 6, 2, 1, 0.5, 2,
             5, 6, 10, 2, 4, 4,
             1, 0, 2, 7, 4, 4,
             2, 0.5, 3, 6, 4, 2)
, nrow = 5, byrow = TRUE)

levelplot(m2)


# Let's show the "ideal case" of data distributions for parallelism.
# A "good algorithm" should be able to get these right.

# epsilon
e = 0.01

m3 = matrix(c(1/4, 1/4, e, e, e,
              1/4, 1/4, e, e, e,
              e, e, 1/6, 1/6, 1/6,
              e, e, 1/6, 1/6, 1/6)
, nrow = 4, byrow = TRUE)
m3 = m3 / sum(m3)

levelplot(m3)


# A little noise, pattern still clear
m4 = m3 + 0.02 * runif(length(m3))
m4 = m4 / sum(m4)
levelplot(m4)


# Pattern fading
m4 = m3 + 0.05 * runif(length(m3))
m4 = m4 / sum(m4)
levelplot(m4)


# With this much noise we can't see the pattern too much with the naked eye.
m5 = m3 + 0.1 * runif(length(m3))
m5 = m5 / sum(m5)
levelplot(m5)
