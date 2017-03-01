library(CodeDepends)


e1 = quote(optimize(function(x) abs(x - sin(x)), c(-1, 1)))

e2 = quote(optimize(function(x) abs(x - sin(x)), c(-1, 1))$minimum)


getInputs(e1)

getInputs(e2)
