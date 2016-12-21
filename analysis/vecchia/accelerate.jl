#=
Tue Dec 20 14:32:46 PST 2016

Here is the code we would like to make as fast as possible

Regularly spaced observations with a highly structured covariance matrix
may warrant a different estimation / computational approach.
=#

using Distributions
using PyPlot

include("Vecchia.jl")


# Setting up test data
############################################################
# In general observations won't be spaced regularly, so we have something
# like this:
srand(37)
n = 1000
index = 2 * (1:n)
# Add noise to remove regularity
index = index + rand(n)
# Permuting at this step is equivalent to choosing random neighbor sets
shuffle!(index)
rhotrue = 20.
# Broadcast vectors to create a distance matrix
distances = abs(index .- index')

# Simple case: correlation decays exponentially with distance with
# parameter rho
corr_sigma = function(rho, dist = distances)
    dist = abs(dist)
    exp(-rho * dist / maximum(dist))
end

Sigma = corr_sigma(rhotrue)
ch = chol(Sigma)'
data = ch * randn(n)


lltrue = Float64[]
llv_default = Float64[]
llv_100 = Float64[]
rhotest = 10:30
for r in rhotest
    Sigma_r = corr_sigma(r)
    mvn = MvNormal(Sigma_r)
    push!(lltrue, logpdf(mvn, data))
    push!(llv_default, vecchia_elementwise(data, Sigma_r))
    push!(llv_default, vecchia_elementwise(data, Sigma_r, 100))
end

plot(rhotest - rhotrue, lltrue - maximum(lltrue))
plot(rhotest - rhotrue, llv_default - maximum(llv_default))
plot(rhotest - rhotrue, llv_100 - maximum(llv_100))
title("True value at 0")
