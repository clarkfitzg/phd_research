# Wed Oct  3 16:13:07 PDT 2018
# Motivated by Rinaldo in DSI

library(cluster)

# Setup
x = matrix(0, nrow = 40e3, ncol = 10)
n = length(x)
sparsity = 0.1
nonzero = sample(n, size = round(sparsity * n))
set.seed(380)
x[nonzero] = rnorm(length(nonzero))

Rprof()
# Careful, this locked up my computer.
fit = pam(x, 3)

