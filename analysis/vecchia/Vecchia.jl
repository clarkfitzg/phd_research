using Distributions


"""
log(p(x1|x2)) Straight out of Wikipedia
"""
function logpdf_conditional(x1, x2, Sigma11, Sigma22, Sigma12)
    Sigma21 = transpose(Sigma12)
    mu_cond = Sigma12 * (Sigma22 \ x2)
    Sigma_cond = Sigma11 - Sigma12 * (Sigma22 \ Sigma21)
    # Dirty hacking for actual numerical symmetry
    Sigma_cond = 0.5 * (Sigma_cond + Sigma_cond')
    dist_cond = MvNormal(mu_cond, Sigma_cond)
    return logpdf(dist_cond, x1)
end


"""
Helper to use slices on larger x, Sigma
"""
function logpdf_from_slice(x, Sigma, s1, s2)
    x1 = x[s1]
    x2 = x[s2]
    S11 = Sigma[s1, s1]
    S22 = Sigma[s2, s2]
    S12 = Sigma[s1, s2]
    logpdf_conditional(x1, x2, S11, S22, S12)
end


"""
Vecchia's approximatation of the log likelihood of x ~ N(0, Sigma)

Blocksize is the number of elements per block.
Write it naively first, then come back and optimize for speed,
parallelism, and numerical precision.

Idea: Given an observation x of length n, split it into subvectors x_i
1) Compute the likelihood for x_1
2) For x_i compute the conditional likelihood given x_i-1

This means that the permutation of indices has already happened and Sigma
reflects this.
"""
function vecchia_blockwise(x, Sigma, blocksize = 7)

    n = length(x)
    nblocks = div(n, blocksize)

    # The first block may be smaller than the others
    n1 = rem(n, blocksize)
    if n1 != 0
        x0 = MvNormal(Sigma[1:n1, 1:n1])
        logpdf1 = logpdf(x0, x[1:n1])
    else
        logpdf1 = 0
    end

    # Last index of every block
    stops = n1:blocksize:n

    # Used to index into x and Sigma
    slices = map(i -> max(1, i - blocksize + 1):i, stops)

    zipped = zip(slices[1:nblocks], slices[2:(nblocks+1)])

    # Written with `map` since parallelism should happen here
    logpdfs = map(ss -> logpdf_from_slice(x, Sigma, ss[1], ss[2]), zipped)

    return logpdf1 + sum(logpdfs)
end


"""
Calculate the loglikelihood of the last value in x given all previous
values. ll(x_n | x_n-1 ... x_1) for vector x ~ N(0, Sigma)

Uses method described in Sec 3.1 of Guinness' paper.

Likely ways to do this more efficiently by updating Cholesky or reusing
calculation of Sigma here.
"""
function logpdf_cond(x, Sigma)
    n = length(x)
    L = chol(Sigma)'
    Ltilde = inv(L)
    z = Ltilde * x
    log(L[n, n]) - 0.5 * (log(2*pi) - z[n]^2)
end


"""
Vecchia's approximatation of the log likelihood of x ~ N(0, Sigma)

neighbors is the number of points to condition on.
"""
function vecchia_elementwise(x, Sigma, neighbors = 7)

    n = length(x)
    if n <= neighbors
        error("Too many neighbors")
    end

    # Exact likelihood for first points
    mv1 = MvNormal(Sigma[1:neighbors, 1:neighbors])
    ll = logpdf(mv1, x[1:neighbors])

    # Add in the contribution to log likelihood for each point
    for i in (neighbors + 1):n
        slice_i = (i - neighbors):i
        x_i = x[slice_i]
        Sigma_i = Sigma[slice_i, slice_i]
        ll += logpdf_cond(x_i, Sigma_i)
    end
    return ll
end
