n = 10
nz = 5
x = 1:n
y = rnorm(n)
z = runif(nz)
df_xy = data.frame(x = x, y = y)
fit = lm(y ~ x, data = df_xy)
plot(x, residuals(fit))
plot(z)
