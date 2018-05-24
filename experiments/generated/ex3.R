# Linear regression simulation
n = 1e5
x = rnorm(n)
epsilon = rnorm(n)
y = 3 + 10 * x + epsilon
d = data.frame(y, x)
fit = lm(y ~ x, data = d)
# Doesn't work because of NSE:
#fit = lm(y ~ x)
hist(residuals(fit))
