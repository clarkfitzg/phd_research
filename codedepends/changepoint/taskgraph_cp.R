source("../helpers.R")

fname = "LongRunCovMatrix.R"

g = makeNumberTaskGraph(fname)

plot(g)

frags = readScript(fname)
