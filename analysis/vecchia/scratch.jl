
"""
log(p(x1|x2)) Straight out of Wikipedia
"""
function logpdf_conditional(x1, x2, Sigma11, Sigma22, Sigma12)
    Sigma21 = transpose(Sigma12)
    mu_cond = Sigma12 * (Sigma22 \ x2)
    Sigma_cond = Sigma11 - Sigma12 * (Sigma22 \ Sigma21)
    return logpdf_normal(x1, Sigma_cond, mu_cond)
end


include("Vecchia.jl")

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
index = -1:0.001:1
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
llvelem1 = Float64[]
rhotest = 40:60
for r in rhotest
    Sigma_r = ac.(distances, r)
    mvn = MvNormal(Sigma_r)
    push!(lltrue, logpdf(mvn, data))
    push!(llvblock, vecchia_blockwise(data, Sigma_r))
    push!(llvelem, vecchia_elementwise(data, Sigma_r))
    push!(llvelem1, vecchia_elementwise(data, Sigma_r, 1))
end

plot(rhotest - rhotrue, lltrue - maximum(lltrue))
title("True value at 0")

plot(rhotest - rhotrue, llvblock - maximum(llvblock))
plot(rhotest - rhotrue, llvelem - maximum(llvelem))

# Conditioning on only one neighbor is not as good as 7
plot(rhotest - rhotrue, llvelem1 - maximum(llvelem1))

@time logpdf(MvNormal(Sigma), data)

# On old Lenovo desktop:
# Both around 0.002 seconds for n = 401
# Both around 0.010 seconds for n = 2001
# Makes sense, expecting linear scaling in n
@time vecchia_blockwise(data, Sigma)

@time vecchia_elementwise(data, Sigma)

# Runtime increases with the number of neighbors
@time vecchia_elementwise(data, Sigma, 5)

# Cholesky also numerically unstable, Vecchia can help here

# Runtime looks reasonably linear
times = Float64[]
nseq = 100:300:3000
for n in nseq
    vec = 1:n
    index = (vec - mean(vec)) / std(vec)
    distances = abs(index .- index')
    Sigma = ac.(distances, rhotrue)
    ch = chol(Sigma)'
    data = ch * randn(n)
    tm = @elapsed vecchia_elementwise(data, Sigma)
    push!(times, tm)
end

plot(nseq, times, ".")
