library(CodeDepends)
library(testthat)


source("eventloop.R")

test_that("Event loop helpers",{

y <- 20
actual = assign_catcher(quote(x <- 10))
expected = list(x = 10)
expect_identical(actual, expected)

deque = readScript(txt = "x = 10")
actual = assign_catcher(deque[[1]])
expected = list(x = 10)
expect_identical(actual, expected)

y <- FALSE
update_env(list(y = TRUE))
expect_true(y)

})


# Expressions that have not yet been evaluated
unevaluated = readScript(txt = "
x = 1
y = x + 1
z = x + 2
")


eventloop(unevaluated)
