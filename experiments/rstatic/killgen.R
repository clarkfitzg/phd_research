library(rstatic)

e = quote_ast(x <- f(y, 200, z))

empty = list(kill = character(0), gen = character(0))

# This is what I want
kg = rstatic:::live_variables_killgen(e, empty)


e2 = quote_ast({
    x[i] <- f(y[i], 200, z)
    a[i+1] <- g(b)
})

# This is not what I want, because x and a are in both sets.
# Happens because of the dispatch to the assignment operator, as I
# described in assign_class.R
kg2 = rstatic:::live_variables_killgen(e2, empty)
