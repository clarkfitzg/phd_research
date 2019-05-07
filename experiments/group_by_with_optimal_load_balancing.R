# Mon May  6 07:26:37 PDT 2019
#
# Trying to use ROI package to solve a mixed integer programming problem
# on how to optimally balance the load among workers for a GROUP BY computation

library(ROI)

# for triple_simple_matrix
library(slam)


# number of groups
g = 5L
# number of workers
w = 2L
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

L13 = simple_triplet_zero_matrix(nrow = w, ncol = 1L)

L1 = cbind(L11, L12, L13)


# Could write this as cbind of w gxg identity matrices.
# But I'll leave it because this pattern may be valuable later.
make_L21_row = function(i)
{
    j = seq(from = i, by = g, length.out = w)
    ones = rep(1L, length(j))
    simple_triplet_matrix(i = ones, j = j, v = ones, ncol = gw)
}
L21_rows = lapply(seq(g), make_L21_row)
L21 = do.call(rbind, L21_rows)

L22 = simple_triplet_zero_matrix(nrow = g, ncol = w)

L23 = simple_triplet_zero_matrix(nrow = g, ncol = 1L)

L2 = cbind(L21, L22, L23)


L31 = simple_triplet_zero_matrix(nrow = w, ncol = gw)

L32 = Iw

L33 = simple_triplet_matrix(i = seq(w), j = rep(1L, w), v = rep(-1L, w))

L3 = cbind(L31, L32, L33)


L = rbind(L1, L2, L3)
rows_per_block = c(w, g, w)
stopifnot(nrow(L) == sum(rows_per_block), ncol(L) == (g*w + w + 1L))


############################################################
# The actual optimization
############################################################


dir = rep(c("==", ">=", "<="), times = rows_per_block)
rhs = rep(c(0, 1, 0), times = rows_per_block)
obj_var_sizes = c(gw, w, 1L)
types = rep(c("B", "C", "C"), times = obj_var_sizes)
obj = c(rep(c(0, 0, 1), times = obj_var_sizes))

Lc = L_constraint(L = L, dir = dir, rhs = rhs)

problem = OP(objective = obj, constraints = Lc, types = types)

# Cool - looks at repos and finds out what's out there that I can use.
ROI_available_solvers(problem)

# Try the first one
install.packages("ROI.plugin.ecos")
library(ROI.plugin.ecos)

sol = ROI_solve(problem)

solution(sol)


# Does it match the load balancing I would do based on a glance?
g1_index = c(1, 4)
t1 = sum(p[g1_index])
t2 = sum(p[-g1_index])
# Yes.
# It also matches the "assign the next biggest task to the most available worker" heuristic.
