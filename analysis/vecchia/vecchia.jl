# Mon Dec 12 14:01:50 PST 2016

using Distributions
using PDMats

# Debugger
using Gallium

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
l_true = logpdf(bigmv, x)

# Side note:
# Disappointing that I can't write this: Sigma[1:3, 1:3]

# Tue Dec 13 10:55:32 PST 2016

# Vecchia's in block form.
# Write it naively first, then come back and optimize for speed,
# parallelism, and numerical precision.
#
# Idea: Given an observation x of length n, split it into subvectors x_i
# 1) Compute the likelihood for x_1
# 2) For x_i compute the conditional likelihood given x_i-1
#
# This means that the permutation of indices has already happened and Sigma
# reflects this.
# I think Guinness's approach is more sophisticated than this.

function logpdf_conditional(x1, x2, Sigma11, Sigma22, Sigma12)
    # log(p(x1|x2)) Straight out of Wikipedia
    Sigma21 = transpose(Sigma12)
    Sigma22inv = inv(Sigma22)
    mu_cond = Sigma12 * Sigma22inv * x2
    Sigma_cond = PDMat(Sigma11 - Sigma12 * Sigma22inv * Sigma21)
    dist_cond = MvNormal(mu_cond, Sigma_cond)
    return logpdf(dist_cond, x1)
end


function logpdf_from_slice(x, Sigma, s1, s2)
    # Helper to use slices on larger x, Sigma
    x1 = x[s1]
    x2 = x[s2]
    S11 = Sigma_float[s1, s1]
    S22 = Sigma_float[s2, s2]
    S12 = Sigma_float[s1, s2]
    logpdf_conditional(x1, x2, S11, S22, S12)
end


function vecchia_blockwise(x, Sigma, blocksize = 7)
    # blocksize is the number of elements per block

    n = length(x)
    nblocks = div(n, blocksize)

    # The first block may be smaller than the others
    n1 = rem(n, blocksize)
    if n1 != 0
        x0 = MvNormal(PDMat(Sigma[1:n1, 1:n1]))
        logpdf1 = logpdf(x0, x[1:n1])
    else
        logpdf1 = 0
    end

    stops = n1 + blocksize * collect(0:nblocks)

    # TODO
    # Something strange happens here. Originally I defined this
    # incorrectly, then I fixed it and ran the code again. Yet the original
    # remains in the REPL?
    # slicer(i) = max(1, i - blocksize):i
    slicer(i) = max(1, i - blocksize + 1):i
    slices = map(slicer, stops)

    zipped = zip(slices[1:nblocks], slices[2:(nblocks+1)])

    # Is there a more idiomatic way to apply partial args aka curry?
    # Also I baked in the tuple unpacking...
    function lpdf(ss)
        logpdf_from_slice(x, Sigma, ss[1], ss[2])
    end

    logpdfs = map(lpdf, zipped)
    return logpdf1 + sum(logpdfs)

end


# Testing
l2 = logpdf_from_slice(x, Sigma_float, 1:3, 4:7)

l_approx = vecchia_blockwise(x, Sigma_float)
