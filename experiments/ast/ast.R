# Mon Feb 13 16:58:24 PST 2017
#
# Goal: plot the AST

# DiagrammeR is pretty but otherwise unappealing

library(igraph)

igraph_options(plot.layout=layout_as_tree)

ex = parse("ab.R")

# What is the meaning of these ID numbers?
# They don't seem to be numbered in the order that the parser encounters
# them, which seems strange. They're also not sequential.
p = getParseData(ex)

p2 = p[, c("parent", "id", "text")]
colnames(p2) = c("from", "to", "label")

g = igraph::graph_from_data_frame(p2)

pdf("ast.pdf")
plot(g, vertex.color = "white")
dev.off()
