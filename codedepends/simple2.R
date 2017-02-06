# Fri Jan 27 10:28:50 PST 2017
# Simple script as test case

n = 10

y = rnorm(n)
x = 1:n
# Never used
z = runif(n)

df_xy = data.frame(x = x , y = y)

fit = lm(y ~ x, data = df_xy)

plot(x, residuals(fit))
