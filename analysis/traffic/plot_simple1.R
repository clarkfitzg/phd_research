library(CodeDepends)
library(Rgraphviz)

vg = makeVariableGraph("simple1.R")

png("simple1.png")
plot(vg, main = "fit = lm(y~x), but not shown in graph")
dev.off()
