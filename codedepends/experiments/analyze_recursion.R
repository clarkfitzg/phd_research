# Tue Feb 14 13:45:47 PST 2017

library(CodeDepends)
library(Rgraphviz)


cg = makeCallGraph("recursion.R")

# Neither of these have any edges because the function itself isn't handled
# like a newly defined variable.
tg = makeTaskGraph("recursion.R")
vg = makeVariableGraph("recursion.R")
