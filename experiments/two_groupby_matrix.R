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

lattice::levelplot(m2)


