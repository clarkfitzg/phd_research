# Fri Jan 27 11:17:59 PST 2017
# This is all the apparent parallelism available.
# Useful only for understanding since data so small. Large data might not
# be good either since should be serialized.

# to inject:
library(future)
plan("multisession")

n = 10

# to inject: future asynchronous assignment
y %<-% rnorm(n)
x %<-% 1:n

# to inject: Remove unused variable
#z = runif(n)

df_xy = data.frame(x = x , y = y)

fit = lm(y ~ x, data = df_xy)

plot(x, residuals(fit))
