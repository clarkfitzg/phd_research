# Wed Feb  7 09:29:02 PST 2018
#
# What happens when data gets too big, but we can chunk it and get
# parallelism? For example here's something I did at Lulus:

# Generate some data:

# Actually 1e7
n = 1e5
x = runif(n)
true_beta_x = 0.5
true_intercept = 0

prob1 = 1 / (1 + exp(-true_intercept -true_beta * x))
probs = cbind(prob1, 1 - prob1)

y = apply(probs, 1, function(p) sample(c(TRUE, FALSE), size = 1, prob = p))


# High level task to do in parallel:
############################################################

# But y, x are really big so this line takes forever.
fit = glm(y ~ x, family = binomial())

estimates = coef(summary(fit))

# This large size is a real problem. We need to be reducing the size of the
# data.
object.size(fit)


# Then instead we can do something like this:
############################################################

# First should permute to get iid.
nc = 5
chunksize = n / nc
# Will need a more efficient implementation of this
grps = rep(seq(nc), times = chunksize)
yc = split(y, grps)
xc = split(x, grps)

# TODO: Haven't in any way made this work as a glm, but that's not
# important now.
glmlite = function(x, y)
{
    fit = glm(y ~ x, family = binomial())
    s = summary(fit)
    # Just return everything that's relatively small
    toobig = 1e6 < sapply(s, object.size)
    s[toobig] = NULL
    class(s) = c("glmlite", class(s))
    s$N = length(x)
    s
}

# Can happen in parallel
fits = Map(glmlite, xc, yc)

# Here's the crucial part. Need a way to reduce arbitrary objects.  I'm not
# sure to what extent this can be done. In some sense it's the most
# interesting part, since the mapping part is relatively simple. Like Norm
# said :) We can do basic ones, but with more stats this may not be
# trivial.
Reduce.glmlite = function(fit1, fit2)
{
    # Suppose we're only interested in the coefficients
}
