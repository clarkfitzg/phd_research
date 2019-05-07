# Mon May  6 07:26:37 PDT 2019
#
# Trying to use ROI package to solve some integer programming problems
# for how to split data for a group by computation

library(ROI)

# for triple_simple_matrix
library(slam)


# Here's for the single GROUP BY
w = 2L
g = 5L
gw = g * w

set.seed(823)
p = runif(g)
p = p / sum(p)
# This will be a linear model more generally
time_per_group = p

Iw = simple_triplet_diag_matrix(1, nrow = w)


############################################################
# Construct the constraint matrix L using 9 blocks following written notation
############################################################

L11 = simple_triplet_matrix(
      i = rep(seq(w), each = g)
    , j = seq(gw)
    , v = rep(time_per_group, times = w)
    )

L12 = -Iw

L13 = simple_triplet_zero_matrix(nrow = w, ncol = 1)


make_L21_row = function(i)
{
    j = seq(from = i, by = g, length.out = w)
    ones = rep(1L, length(j))
    simple_triplet_matrix(i = ones, j = j, v = ones, ncol = gw)
}

L21_rows = lapply(seq(g), make_L21_row)
L21 = do.call(rbind, L21_rows)



Lc = L_constraint(L = 
)

simple_triplet_matrix

problem = OP(objective = c(rep(0, ngroups), 1L)
    , constraints = Lc
    , types = c(rep("B", ngroups), "C")
)


