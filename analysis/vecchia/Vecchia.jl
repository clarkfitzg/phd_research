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
Vecchia's in block form.
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


#function vecchia_elementwise(x, Sigma, ncondition
