"""
Tests for Vecchia.jl
"""

using Base.Test
using Distributions


include("Vecchia.jl")


srand(37)
n = 1000
A = reshape(randn(n^2), (n, n))
Sigma = A * A'

x = randn(n)

# This one is faster and more robust
@time ll_true = logpdf(MvNormal(Sigma), x)

@time ll_local = logpdf_normal(Sigma, x)

@test_approx_eq ll_true ll_local
