"""
log pdf for multivariate normal x ~ N(0, Sigma)
Same as logpdf(Distributions::MvNormal(Sigma), x), this just removes the
dependency on the Distributions package
"""
function logpdf_normal(x, Sigma, mu = 0)
    L = chol(Sigma)'
    z = L \ (x - mu)
    # Compute it like this to avoid Inf values from det(L)
    logdet = sum(log(diag(L)))
    ll = - logdet - 0.5 * z' * z - 0.5 * n * log(2 * pi)
    # Maybe there's a more robust way to convert to scalar?
    return ll[1, 1]
end


"""
Calculate the loglikelihood of the last value in x given all previous
values. ll(x_n | x_n-1 ... x_1) for vector x ~ N(0, Sigma)

Uses method described in Sec 3.1 of Guinness' paper.

Likely ways to do this more efficiently by updating Cholesky or reusing
calculation of Sigma when computing x_n+1

Probably better to change the function signature so that Sigma is computed
inside this function- this requires sending O(n) data rather than O(n^2)
"""
function logpdf_cond(x, Sigma)
    n = length(x)
    L = chol(Sigma)'
    jn = zeros(n)
    jn[n] = 1.
    a = L \ jn
    b = L \ x
    return log(a[n]) - 0.5 * (log(2*pi) + b[n]^2)
end


"""
Vecchia's approximatation of the log likelihood of x ~ N(0, Sigma)

neighbors is the number of points to condition on.
"""
function vecchia_elementwise(x, Sigma, neighbors = 10)

    n = length(x)
    if n <= neighbors
        error("Too many neighbors")
    end

    # Exact likelihood for first points
    ll = logpdf_normal(x[1:neighbors], Sigma[1:neighbors, 1:neighbors])

    # Add in the contribution to log likelihood for each point
    # This is the computation to potentially put on the GPU
    for i in (neighbors + 1):n
        slice_i = (i - neighbors):i
        x_i = x[slice_i]
        Sigma_i = Sigma[slice_i, slice_i]
        ll += logpdf_cond(x_i, Sigma_i)
    end
    return ll
end
