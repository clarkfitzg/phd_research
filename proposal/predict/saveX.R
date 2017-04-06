# Rscript saveX.R 1e6
#
# 1e6 will make chunks ~ 24 MB in size
#
# Fast IO is important here
library(data.table)
Rprof("saveX.out")

NCHUNK = commandArgs(trailingOnly = TRUE)
NCHUNK = as.integer(NCHUNK)

set.seed(312)
ntotal = 1e9
nleft = ntotal
p = 3L
xfile = "/ssd/clarkf/X.csv"

if(file.exists(xfile)){
    stop("X.csv is already there.")
}

while(nleft > 0){
    n_i = min(NCHUNK, nleft)
    nleft = nleft - n_i

    X = rnorm(n_i * p)
    # Sneaky matrix coercian
    dim(X) = c(n_i, p)
    Xdt = data.table(X)
    fwrite(Xdt, xfile, append = TRUE, col.names = FALSE)

    message(sprintf("%.4g percent remaining", 100 * nleft / ntotal))
}
