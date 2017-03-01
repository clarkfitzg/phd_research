library(CodeDepends)

e1 = quote(optimize(function(x) abs(x - sin(x)), c(-1, 1)))
getInputs(e1)

e2 = quote(optimize(function(x) abs(x - sin(x)), c(-1, 1))$minimum)
getInputs(e2)


e1 = quote(optimize(cos, c(-1, 1), maximum = TRUE))
getInputs(e1)


