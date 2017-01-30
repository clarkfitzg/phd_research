# Can we put this in a data structure representing the parallel blocks of
# computation?

library(CodeDepends)
library(Rgraphviz)

fname = "simple3.R"

tg = makeTaskGraph(fname)


methods(class = class(script))


