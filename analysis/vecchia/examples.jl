include("vecchia.jl")

using PyPlot

# Debugger
using Gallium


# Seed RNG
srand(37)
n = 100

# Create covariance matrix to simulate from
# More typically this might be a Matérn covariance matrix
Sigma = eye(n) + ones(n, n)
mu = zeros(n)

bigmv = MvNormal(mu, Sigma)

bigmv2 = MvNormal(mu, Sigma_float)

x = rand(n)

# Side note:
# Disappointing that I can't write this: Sigma[1:3, 1:3]
# Because not for end 

# Testing
l2 = logpdf_from_slice(x, Sigma_float, 1:3, 4:7)

# Evaluate log likelihood
l_true = logpdf(bigmv, x)

l_approx = vecchia_blockwise(x, Sigma_float)

# P. 6 of paper:
# when working with small covariance matrices, the computational demand is
# often dominated by filling in the entries of the covariance matrix rather
# than factoring the matrix.

# Wed Dec 14 14:52:19 PST 2016
# Working with Ethan

srand(37)
# Covariance function where closely related points are more correlated
ac(dx, rho) = exp(-rho * abs(dx)^1.4)
# Seems important to have regular sequence here for numerical reasons
# index = -2:0.0002:2 Mac can handle this, desktop can't
index = -2:0.01:2
n = length(index)
rhotrue = 50.

# Broadcast vectors up to matrix
distances = abs(index .- index')

Sigma = ac.(distances, rhotrue)
# Even simulating from a large multivariate normal with a covariance matrix
# like this is difficult because we need to do a large Cholesky
ch = chol(Sigma)'
data = ch * randn(n)

plot(index, data, ".")


logpdf_from_slice(data, Sigma, 1:10, 11:20)


ltrue = logpdf(MvNormal(Sigma), data)
lvb = vecchia_blockwise(data, Sigma)
lve = vecchia_elementwise(data, Sigma)


lltrue = Float64[]
llvblock = Float64[]
llvelem = Float64[]
rhotest = 40:60
for r in rhotest
    Sigma_r = ac.(distances, r)
    mvn = MvNormal(Sigma_r)
    push!(lltrue, logpdf(mvn, data))
    push!(llvblock, vecchia_blockwise(data, Sigma_r))
    push!(llvelem, vecchia_elementwise(data, Sigma_r))
end

plot(rhotest - rhotrue, lltrue - maximum(lltrue))
plot(rhotest - rhotrue, llvblock - maximum(llvblock))
plot(rhotest - rhotrue, llvelem - maximum(llvelem))
title("True value at 0")

@time logpdf(MvNormal(Sigma), data)

@time vecchia_blockwise(data, Sigma)

# Cholesky also numerically unstable, Vecchia can help here
