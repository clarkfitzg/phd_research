# Mon May  6 07:26:37 PDT 2019
#
# Trying to use ROI package to solve some integer programming problems
# for how to split data for a group by computation

library(ROI)


# Here's for the single GROUP BY
nworkers = 2L
ngroups = 5L

L = L_constraint(L = 
)

problem = OP(objective = c(rep(0, ngroups), 1L)
    , constraints = L
    , types = c(rep("B", ngroups), "C")
)


