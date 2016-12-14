# Seed RNG
srand(37)
n = 100

# Create covariance matrix to simulate from
# More typically this might be a Matérn covariance matrix
Sigma_float = eye(n) + ones(n, n)
Sigma = PDMat(Sigma_float)
mu = zeros(n)

bigmv = MvNormal(mu, Sigma)

x = rand(n)

# Side note:
# Disappointing that I can't write this: Sigma[1:3, 1:3]

# Testing
l2 = logpdf_from_slice(x, Sigma_float, 1:3, 4:7)

# Evaluate log likelihood
l_true = logpdf(bigmv, x)

l_approx = vecchia_blockwise(x, Sigma_float)
