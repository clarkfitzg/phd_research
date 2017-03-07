library(CodeDepends)
library(testthat)


source("eventloop.R")

test_that("Event loop helpers", {

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


test_that("eventloop function", {

unevaluated = readScript(txt = "
x = 1
y = x + 1
z = x + 2
")

eventloop(unevaluated)

expect_equal(x, 1)
expect_equal(y, 2)
expect_equal(z, 3)


failscript1 = readScript(txt = "
print(variable_which_dont_exist)
")

expect_error(eventloop(failscript1))

failscript2 = readScript(txt = "
rnorm('bang!')
")

expect_error(eventloop(failscript2))

})
