n = 10
y = rnorm(n)
x = 1:n
z = runif(n)
df_xy = data.frame(x = x, y = y)
fit = lm(y ~ x, data = df_xy)
plot(x, residuals(fit))
