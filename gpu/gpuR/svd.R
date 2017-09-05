
library(gpuR)

n = 100
X = vclMatrix(rnorm(n * n), nrow = n, ncol = n, type = "float")
X


s = svd(X)
s
