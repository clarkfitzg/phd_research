include("vecchia.jl")

using PyPlot

# Seed RNG
srand(37)
n = 100

# Create covariance matrix to simulate from
# More typically this might be a Matérn covariance matrix
Sigma_float = eye(n) + ones(n, n)
Sigma = PDMat(Sigma_float)  # Not needed
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
ac(dx, rho) = exp(-rho * abs(dx))
x = -1:0.001:1
n = length(x)
rhotrue = 100.
Sigma = ac.(x .- x', rhotrue)
ch = chol(Sigma)'
data = ch * randn(n)

plot(x, data, ".")

testSigma = Symmetric(ac.(x .- x', 100))

logpdf_from_slice(data, testSigma, 1:10, 11:20)

vecchia_blockwise(data, testSigma)


lltrue = Float64[]
llapprox = Float64[]
rhotest = 80:120

for r in rhotest
    Sigma_r = ac.(x .- x', r)
    mvn = MvNormal(Sigma_r)
    push!(lltrue, logpdf(mvn, data))
    push!(llapprox, vecchia_blockwise(data, Sigma_r))
end

plot(lltrue - maximum(lltrue))

plot(llapprox - maximum(llapprox))
