# Fast IO is important here
library(data.table)
Rprof("saveX.out")

NCHUNK = commandArgs(trailingOnly = TRUE)
NCHUNK = as.integer(NCHUNK)

set.seed(312)
nleft = 1e9
p = 3L

while(nleft > 0){
    n_i = max(NCHUNK, nleft)
    nleft = nleft - n_i

    X = rnorm(n_i * p)
    # Sneaky matrix coercian
    dim(X) = c(n, p)
    Xdt = data.table(X)
    fwrite(Xdt, "/ssd/X.csv", append = TRUE, col.names = FALSE)
}
