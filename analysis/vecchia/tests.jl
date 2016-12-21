"""
Tests for Vecchia.jl
"""

using Distributions


include("Vecchia.jl")


srand(37)
n = 100
A = reshape(randn(n^2), (n, n))
Sigma = A * A'

x = randn(n)

ll_true = logpdf(MvNormal(Sigma), x)

ll_local = logpdf_normal(Sigma, x)

@test_approx_eq ll_true ll_local
