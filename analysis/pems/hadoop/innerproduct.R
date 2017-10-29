# Fri Oct 27 16:41:18 PDT 2017
#
# Thinking about the kernel trick and computing the distance between
# functions.
#
# This is \int_0^1 f(x) g(x) dx

cnames = c("station"
, "n_total"
, "n_middle"
, "n_high"
, "left_slope"
, "left_slope_se"
, "mid_intercept"
, "mid_intercept_se"
, "mid_slope"
, "mid_slope_se"
, "right_slope"
, "right_slope_se"
)

fd = read.table("~/data/pems/fd.tsv"
    , col.names = cnames)
 
# TODO: Clean

sapply(fd, function(x) mean(is.na(x)))

# These points define the fd
fd$leftx = fd$mid_intercept / (fd$left_slope - fd$mid_slope)
fd$lefty = fd$left_slope * fd$leftx

fd$rightx = (fd$mid_intercept + fd$right_slope) /
                    (fd$right_slope - fd$mid_slope)
fd$righty = fd$mid_intercept + fd$mid_slope * fd$rightx

ordered = with(fd, (0 <= leftx) & (leftx <= rightx) & (rightx <= 1))
ordered[is.na(ordered)] = FALSE

# 0.87 have the right order. Good!
mean(ordered)

fd = fd[ordered, ]

fdlines = function(row)
{
    with(row, abline(0, left_slope, col = "blue"))
    with(row, abline(mid_intercept, mid_slope, col = "blue"))
    with(row, abline(-right_slope, right_slope, col = "blue"))
    with(row, lines(c(0, leftx, rightx, 1), c(0, lefty, righty, 0)
                    , lwd = 2))
}

plot(c(0, 1), c(0, 25), type = "n")
fdlines(fd[1, ])

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

x = seq(0, 1, by = 0.01)

f1 = fd_func(fd[1, ])

points(x, f1(x))

?kernlab::kkmeans
