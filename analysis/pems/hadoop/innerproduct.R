# Fri Oct 27 16:41:18 PDT 2017
#
# Run this after clean.R
#
# Thinking about the kernel trick and computing the distance between
# functions.
#
# This is \int_0^1 f(x) g(x) dx

fd = read.table("~/data/pems/fdclean.tsv", header = TRUE)

# Return a vectorized function
fd_func = function(row)
{
    function(x)
    {
        ans = rep(NA, length(x))

        # Just assume x is between 0 and 1
        left = x < row$leftx
        right = x >= row$rightx
        mid = !(left | right)

        ans[left] = x[left] * row$left_slope
        ans[mid] = row$mid_intercept + row$mid_slope * x[mid]
        ans[right] = -row$right_slope + x[right] * row$right_slope
        ans
    }
}

fd_inner = function(f1, f2 = f1)
{
    f1f2 = function(x) f1(x) * f2(x)
    integrate(f1f2, lower = 0, upper = 1)$value
}
class(fd_inner) = c("kernel", class(fd_inner))

f_1 = fd_func(fd[1, ])

fd_inner(f_1)

x = seq(0, 1, by = 0.01)

# All looks reasonable
points(x, f_1(x))

fd$funcs = by(fd, fd$station, fd_func, simplify = FALSE)
fd$funcs = do.call(list, fd$funcs)


# Works fine
fd_inner(fd$funcs[[1]], fd$funcs[[2]])


# Build the kernel matrix

library(kernlab)

m = as.matrix(fd$funcs)

# Not working
km = kernelMatrix(fd_inner, as.matrix(fd$funcs))

?kernlab::kkmeans

# Do it the dumb way.
# No, this produces the same error
# Maybe it's the list that causes the issue?
d = outer(fd$funcs, fd$funcs, fd_inner)

