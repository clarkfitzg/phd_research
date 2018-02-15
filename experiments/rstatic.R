# Thu Feb 15 08:33:39 PST 2018
#
# Testing out Nick's SSA

library(rstatic)

# Essentially following one of the tests

node0 = quote_ast({
    x = data.frame(a = 1:10, b = letters[1:10])
    x[, "c"] = rnorm(10)
    sum(x$a)
    head(x)
})

# This works fine
#node0 = quote_ast({
#    x = 1:10
#    x = rnorm(10)
#    sum(x)
#    head(x)
#})

# We can evaluate this.
eval(to_r(node0))

node = to_cfg(node0)

#rstatic:::to_ssa(node)

node$ssa

#nr = to_r(node, use_ssa = TRUE, use_phi = TRUE)
nr = to_r(node)

# Somehow this was converted to a function. I suppose it's fine to think
# about the inside of a brace as a function. But when it goes round trip
# back to R I would expect it to come out as a brace.

f = eval(nr)

f()
