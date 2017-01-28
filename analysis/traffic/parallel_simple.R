# Fri Jan 27 11:17:59 PST 2017
# This is all the apparent parallelism available.
# Useful only for understanding since data so small. Not totally sure how
# forking can handle larger data sets. Maybe shared memory?

# to inject:
library(future)
plan("multisession")

n = 10

# to inject: future asynchronous assignment where it can actually help the
# code.
y %<-% rnorm(n)
x %<-% 1:n

# to inject: Remove dead code creating unused variable
#z = runif(n)

df_xy = data.frame(x = x , y = y)

# possibility to inject:
#
# rm(y)
#
# Similarly, n could be removed above. This only makes sense if 
# these are large. Otherwise it's just extra overhead.

fit = lm(y ~ x, data = df_xy)

plot(x, residuals(fit))
