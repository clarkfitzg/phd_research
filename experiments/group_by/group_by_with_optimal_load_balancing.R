# Mon May  6 07:26:37 PDT 2019
#
# Trying to use ROI package to solve a mixed integer programming problem
# on how to optimally statically balance the load among workers for a GROUP BY computation.
# Actually, this solves more generally the problem of how to optimally schedule g independent tasks.
#
# Looking at the CS literature, `load balancing' might not be quite the right term, because that tends to imply a real time system responding to requests.
# This solution minimizes the total time it takes to process g groups on w workers, assuming that we know how long each group takes to run.
# A natural extension is to suppose that the data starts out distributed among workers in some fashion, and subsequently minimize total time = transfer + compute time.



library(ROI)

# for triple_simple_matrix
library(slam)


# number of workers
w = 2L

# Simple example where "assign the next biggest task to the worker who will finish it first" heuristic gets it wrong.
# I'm pretty sure I saw that heuristic in Norm Matloff's Parallel Programming book.
# But I don't see it here: http://heather.cs.ucdavis.edu/~matloff/158/PLN/ParProcBook.pdf
#
# Actually, this heuristic is the same as list scheduling.
p = c(3, 3, 2, 2, 2)


# Possible solvers
#
# Open source general- glpk, lpsolve, symphony
# Commerical general- cplex (IBM), gurobi, mosek
# Other
#   neos - Send the problem off to a server to compute it
#   msbinlp - Not sure what these are, maybe an R implementation?
#   ecos - embedded conic solver

solver = "glpk"

if(TRUE)
{
set.seed(823)

w = 10L
g = 16L

# I let this run for 3 hours with lpsolve before killing it.
# There's only 50 choose 2 = 10 billion different combinations.
# I probably could have exhaustively tried all of them in that time.
# w = 10L
# g = 50L



# lpsolve
############################################################

# with inequality contraints on the second block:
# 8.3 seconds to do 10 groups
# 27 seconds to do 11 groups
# 83 seconds to do 12 groups
# 372 seconds to do 13 groups

# with equality contraints on the second block:
# 6.4 seconds to do 10 groups
# 16 seconds to do 11 groups
# 62 seconds to do 12 groups

# with cutting plane (L4)
# 42 seconds to do 10 groups. That's ridiculously slow.
# I'm surprised that adding the constraint made it slower- that's that's the opposite of what it's supposed to do!

# glpk
############################################################

# 18 seconds to do 11 groups
# 29 seconds to do 12 groups
# 29 seconds to do 13 groups
# 60 seconds to do 14 groups
# 131 seconds to do 15 groups
# Long time to do 16 groups - I killed it after an hour

# symphony
############################################################

# ecos
############################################################
# (embedded conic solver)
# "an interior-point solver for second-order cone programming (SOCP)"
# Claims to be competitive up to tens of thousands of variables
# https://web.stanford.edu/~boyd/papers/pdf/ecos_ecc.pdf
#
# But my application here is not second order, it's just mixed integer programming.
# When I have 500 variables it fails with this message:
# ..$ infostring: chr "Maximum iterations reached with no feasible solution found"
# I attempted to change the maximum number of iterations by passing the `control` argument to `ROI_solve` and setting the max number of iterations, but still I get the same error.
#
# This is frustrating because it's easy to get reasonable feasible solutions- just assign groups to workers randomly.
# I cannot find where in the software I can specify an initial solution for it to iterate on.


p = runif(g)
p = p / sum(p)
}

# number of groups
g = length(p)
gw = g * w

# This will be a linear model more generally.
time_per_group = p

Iw = simple_triplet_diag_matrix(1, nrow = w)


############################################################
# Construct the constraint matrix L using 9 blocks following written notation
############################################################


# L1 defines t_k, the time spent on worker k, as the sum of all the times.

L11 = simple_triplet_matrix(
      i = rep(seq(w), each = g)
    , j = seq(gw)
    , v = rep(time_per_group, times = w)
    )

L12 = -Iw

L13 = simple_triplet_zero_matrix(nrow = w, ncol = 1L)

L1 = cbind(L11, L12, L13)


# L2 says every group gets computed exactly once.

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


# L3 defines t = max(t_k) over k.

L31 = simple_triplet_zero_matrix(nrow = w, ncol = gw)

L32 = Iw

L33 = simple_triplet_matrix(i = seq(w), j = rep(1L, w), v = rep(-1L, w))

L3 = cbind(L31, L32, L33)


# The following constraints are cutting planes.
############################################################
# I'm only adding these constraints so that it can potentially solve faster.


# L4 says every worker gets at least one group.

L41 = simple_triplet_matrix(i = rep(seq(w), each = g), j = seq(gw), v = rep(1L, gw))

L42 = simple_triplet_zero_matrix(nrow = w, ncol = w)

L43 = simple_triplet_zero_matrix(nrow = w, ncol = 1L)

L4 = cbind(L41, L42, L43)


# L5 says that we cannot go faster than the slowest group


L = rbind(L1, L2, L3, L4)
rows_per_block = c(w, g, w, w)
stopifnot(nrow(L) == sum(rows_per_block), ncol(L) == (g*w + w + 1L))


############################################################
# The actual optimization
############################################################

# What happens if I give it equality constraints for block L2?
# This amounts to requiring that each group execute exactly once, rather than more than once.
# Will that help performance at all?

dir = rep(c("==", "==", "<=", ">="), times = rows_per_block)
rhs = rep(c(0, 1, 0, 1), times = rows_per_block)
obj_var_sizes = c(gw, w, 1L)
types = rep(c("B", "C", "C"), times = obj_var_sizes)
obj = c(rep(c(0, 0, 1), times = obj_var_sizes))

Lc = L_constraint(L = L, dir = dir, rhs = rhs)

problem = OP(objective = obj, constraints = Lc, types = types)


# Cool - looks at repos and finds out what's out there that I can use.
ROI_available_solvers(problem)

ROI_installed_solvers()


ROI_registered_solver_control(solver)

#control = list(maxit = Inf)
# It might help to use the heuristic as a starting point.
# Or just do a random assignment, at least that will be feasible

solve_time = system.time(sol <- ROI_solve(problem, solver))

solution(sol)


# Does it match the load balancing I would do based on a glance?
g1_index = c(1, 4)
t1 = sum(p[g1_index])
t2 = sum(p[-g1_index])
# Yes.
