# Fri Mar 24 11:06:20 PDT 2017
#
# Write a huge matrix X to disk
#
# $ time Rscript saveX.R
# 
# real    12m3.888s
# user    11m10.472s
# sys     0m26.904s
# 
# > summaryRprof()
# $by.self
#                            self.time self.pct total.time total.pct
# ".Call"                       328.16    47.09     328.16     47.09
# "rnorm"                       254.22    36.48     254.28     36.49
# "as.vector"                    68.44     9.82      68.44      9.82
# "matrix"                       23.74     3.41     278.02     39.89
# "data.table"                    5.36     0.77     365.72     52.48
# "as.data.table.matrix"          2.66     0.38      72.46     10.40
# ...
# $by.total
#                             total.time total.pct self.time self.pct
# "data.table"                    365.72     52.48      5.36     0.77
# "fwrite"                        331.10     47.51      0.38     0.05
# ".Call"                         328.16     47.09    328.16    47.09
# "matrix"                        278.02     39.89     23.74     3.41
# "rnorm"                         254.28     36.49    254.22    36.48
# "as.data.table"                  72.54     10.41      0.08     0.01
# "as.data.table.matrix"           72.46     10.40      2.66     0.38
# "as.vector"                      68.44      9.82     68.44     9.82

# So it seems time is approximately balanced between generating data and
# writing it to disk.

# Fast IO is important here
Rprof()

library(data.table)

n = 1e9
p = 3L
BYTES_PER_NUM = 8L

# Approximate size in memory for R:
totalbytes = BYTES_PER_NUM * n * p

# What we'd like to do:
# X = matrix(rnorm(n * p), ncol = p)

# Instead:

bytes_per_chunk = 1e6
n_i = as.integer(bytes_per_chunk / (p * BYTES_PER_NUM))

nchunks = totalbytes %/% bytes_per_chunk

for(i in seq(nchunks)){
    X_i = data.table(matrix(rnorm(n_i * p), ncol = p))
    fwrite(X_i, "X.csv", append = TRUE)
}
