# With n = 1 million, based on what I've seen with other code it should
# take somewhere on the order of 3 minutes to do this.
# Indeed, it takes 208 seconds
n = 1e6

dfmaker = function(i)
{
    data.frame(i = i, a = 2.1, b = 3L)
}

d = 1:n

Rprof()
system.time(
out <- lapply(d, dfmaker)
)
Rprof(NULL)

# How long for each call?
# About 200 microseconds
208 / n

library(microbenchmark)

# This is about 125 microseconds
microbenchmark(data.frame(a = 2.3, b = 4L))

# About 140 nanoseconds
microbenchmark(list(a = 2.3, b = 4L))

# 120 nanoseconds
microbenchmark(c(1, 2))

# About 150 microseconds
microbenchmark(data.frame(2.3, 4L))

