source("../helpers.R")
fname = "runall.R"
g = makeNumberTaskGraph(fname)

plot(g)

frags = readScript(fname)

# This is similar to the change point- most of the action happens inside
# one function, frags[11].
