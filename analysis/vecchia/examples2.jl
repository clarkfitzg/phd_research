#=
Tue Dec 20 14:32:46 PST 2016

Regularly spaced observations with a highly structured covariance matrix
may warrant a different estimation / computational approach.
=#

include("Vecchia.jl")

# In general observations won't be spaced regularly, so we have something
# like this:

srand(37)
n = 1000
index = 2 * (1:n)
# Add noise to remove regularity
index = index + rand(n)
# Permuting at this step is equivalent to choosing random neighbor sets
shuffle!(index)

ac(dx, rho) = exp(-rho * abs(dx)^1.4)

rhotrue = 50.

# Broadcast vectors up to matrix
distances = abs(index .- index')

Sigma = ac.(distances, rhotrue)
# Even simulating from a large multivariate normal with a covariance matrix
# like this is difficult because we need to do a large Cholesky
ch = chol(Sigma)'
data = ch * randn(n)


