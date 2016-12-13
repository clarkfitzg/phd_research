# Mon Dec 12 14:01:50 PST 2016

using Distributions
using PDMats


# Seed RNG
srand(37)
n = 100

# Create covariance matrix to simulate from
# More typically this might be a Matérn covariance matrix
Sigma = eye(n) + ones(n, n)
Sigma = PDMat(Sigma)
mu = zeros(n)

bigmv = MvNormal(mu, Sigma)

x = rand(n)

# Evaluate log likelihood
logpdf(bigmv, x)
