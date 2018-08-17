# Fri Aug 17 09:24:07 PDT 2018
#
# What's the speed difference between evaluating things lazily or eagerly?
#
# Lazy is slightly faster. This makes sense because the eager has 3 extra
# calls to assignment functions.

library(microbenchmark)


foo = function(x) sin(exp(x))

eager = function()
{
    x = foo(5)
    y = foo(6)
    xpy = x + y
    foo(xpy)
}

lazy = function()
{
    foo(foo(5) + foo(6))
}

microbenchmark(eager(), lazy())

microbenchmark(y <- 5)
