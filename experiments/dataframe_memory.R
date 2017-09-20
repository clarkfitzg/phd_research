# Wed Sep 20 07:36:58 PDT 2017

# Do copy on write semantics mean that the whole data frame is copied, or
# just the columns which are modified?

n = 20000
p = 1000

d = do.call(data.frame, replicate(p, rnorm(n), simplify = FALSE))

MB = as.numeric(object.size(d)) / 1e6

# This does not require a full copy of x for a data.frame, since only the
# 1st column is changed.
change_first_col = function(x)
{
    x[, 1] = 0
    x
}

# If the process memory usage grows to where it can fit 2 * MB objects then
# the argument was deeply copied. Otherwise the columns in d and d2
# reference the same underlying objects.
d2 = change_first_col(d)

# This increases the memory usage only slightly, which means R does the
# smart thing here.
