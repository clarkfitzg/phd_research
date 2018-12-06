library(bigmemory)

n = 1e6
p = 1e3

y = big.matrix(n, p, init = 1, backingfile = "y.bin", descriptorfile = "y.bin.desc")

# After this y.bin is still a tiny file.

y[1, 1] = pi
# Ditto

y[1, ] = pi
# Ditto

y[, 1] = pi
# Ditto

object.size(x)
# tiny

y[, 1] = rnorm(nrow(x))

# Aha, but when I quit my R session it took several seconds.
# And now y.bin is 7.5 GB, as it should be.

# Restarting
y = attach.big.matrix("y.bin.desc")

library(microbenchmark)

# Takes about 3 ms.
microbenchmark(y[, 1:2])

top_part = y[1:2e3, ]

# About 4 ms
microbenchmark(y[1:2e3, ])

# How about to just grab a little piece that we need?
set.seed(824)
nbr = 100L
ind1 = seq(as.integer(round(n*runif(1))), length.out = nbr)
ind2 = seq(as.integer(round(p*runif(1))), length.out = nbr)

some_chunk = y[ind1, ind2]

microbenchmark(y[ind1, ind2])

# Run this after evicting the backing file from memory:
# vmtouch -e y.bin
gc()
microbenchmark(y[ind1, ind2], times = 1L)

# Around 20 milliseconds to get the first one, and around 50 _micro_seconds
# after that.
# This shows that bigmemory is caching appropriately.

ind1b = ind1 - 100L
ind2b = ind2 - 100L
tmp = y[c(ind1b, ind1), c(ind2b, ind2)]

ind1c = ind1 - 50L
ind2c = ind2 - 50L

gc()

microbenchmark(y[ind1c, ind2c], times = 10L)

# This shows that bigmemory is caching in a very efficient way for this use
# case.

ym = as.matrix(y)

# Indeed, it's as fast as a matrix in memory.
microbenchmark(ym[ind1c, ind2c], times = 10L)
