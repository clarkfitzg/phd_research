# All of these vectorized mathematical operations are map operations.

dnorm2 = function(x, mean = 0, sd = 1)
{
    multiplier = 1 / (sqrt(2*pi) * sd)
    eterm = -(x - mean)^2 / (2 * sd^2)
    multiplier * exp(eterm)
}


# Quick test
a = rnorm(10)
delta = max(zapsmall(dnorm(a) - dnorm2(a)))
stopifnot(delta == 0)


