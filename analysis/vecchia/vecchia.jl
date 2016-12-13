# Mon Dec 12 14:01:50 PST 2016

using Distributions
using PDMats


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

# Evaluate log likelihood
logpdf(bigmv, x)


# Tue Dec 13 10:55:32 PST 2016

# Vecchia's in block form.
# Write it naively first, then come back and optimize for speed,
# parallelism, and numerical precision.
#
# Idea: Given an observation x of length n, split it into subvectors x_i
# 1) Compute the likelihood for x_1
# 2) For x_i compute the conditional likelihood x_i | x_i-1
#
# I think Guinness's approach is more sophisticated than this.

subvector_length = 9

function logpdf_conditional(x1, x2, Sigma11, Sigma22, Sigma12)
    # log(p(x1|x2)) Straight out of Wikipedia
    Sigma21 = transpose(Sigma12)
    Sigma22inv = inv(Sigma22)
    mu_cond = Sigma12 * Sigma22inv * x2
    Sigma_cond = PDMat(Sigma11 - Sigma12 * Sigma22inv * Sigma21)
    dist_cond = MvNormal(mu_cond, Sigma_cond)
    return logpdf(bigmv, x1)
end

# Disappointing that I can't write this: Sigma[1:3, 1:3]

# Test it out
logpdf_conditional(x[1:3], x[4:7],
                   Sigma_float[1:3, 1:3],
                   Sigma_float[4:7, 4:7],
                   Sigma_float[1:3, 4:7])
