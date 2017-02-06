# Fri Jan 27 10:07:16 PST 2017
# Not obvious yet how to handle a real script. Better start with something
# simple. Linear model!

n = 10

y = rnorm(n)
x = 1:n

# Will this formula object be correctly handled?
# Doesn't look like it, because fit is not a descendant of x and y in the
# variable graph
fit = lm(y ~ x)

plot(x, residuals(fit))
