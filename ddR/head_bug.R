# Reproducing https://github.com/vertica/ddR/issues/12

library(ddR)

a = darray(dim = c(10, 10), psize = c(10, 5))
head(a)
