# Tue Aug 14 16:15:48 PDT 2018
# Henrik Bengtsson's question on R-devel

library(microbenchmark)


# Here's how I thought to do it.
dots5 = function(...) as.list(sys.call())[-1]

f = function(...) ...()

f(100)


dots1 <- function(...) as.list(substitute(list(...)))[-1L]
dots2 <- function(...) as.list(substitute(...()))
dots2b <- function(...) as.list(substitute(...))
dots3 <- function(...) match.call(expand.dots = FALSE)[["..."]]


dots2b(1+2, "a", rnorm(3), stop("bang!"))

microbenchmark(
dots2(1+2, "a", rnorm(3), stop("bang!")),
dots3(1+2, "a", rnorm(3), stop("bang!")),
dots5(1+2, "a", rnorm(3), stop("bang!"))
)

a = 1

microbenchmark(a, 1)
