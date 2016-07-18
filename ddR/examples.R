library(ddR)

m = matrix(1:4, nrow=2)

da = dmapply(function(x) matrix(x, nrow=3, ncol=3)^2, m, output.type = "darray"
, nparts = c(2, 2), combine = "rbind")

a = collect(da)

class(da)

head(da, 1)

# Doesn't work:
da[1, ]

da[1, 3:6]

collect(dmapply(mean, parts(da)))

colSums(da)

# What is this?
parts(da, c(1, 1))

psize(da)

# Seems strange that this isn't a submatrix
# That's because it's not using the matrix structure of the partitions
collect(da, c(1, 1))

collect(da, 1)

# Would be nicer to write something like
# da[[2, 1]]
# Instead we write:
collect(da, 3)
# This is row major order!! Unlike R which is column major!

# Doesn't work:
da2 = cbind(da, da)

da3 = darray(dim = c(4, 10), psize = c(2, 4), data = 1:3)

dim(da3)

# Recycling is a little weird here.
a3 = collect(da3)

# Common group by operation introduces a natural splitting
# It would be nice to do this in ddR.
# Could just add a split method into the dataframe
data(Orange)
s = split(Orange, Orange$Tree)
l = sapply(s, function(df) mean(df$circumference[-1]))

n = 10
d = data.frame(a = 1:n, b = rnorm(n), c = runif(n), d = rnorm(n))

dd = as.dframe(d, psize = c(n, 2))

# Lets put a more informative error message on this.
dd = as.dframe(d, psize = 2)

# Why are these the same?
collect(parts(dd)[[1]])
collect(parts(dd)[[2]])

collect(dd, 2)
