# Mon Jan 30 11:49:52 PST 2017
# Two threaded case

n = 10
nz = 5

x = 1:n
y = rnorm(n)
z = runif(nz)

df_xy = data.frame(x = x , y = y)

fit = lm(y ~ x, data = df_xy)

plot(x, residuals(fit))

plot(z)
