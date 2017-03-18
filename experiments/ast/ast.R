# Mon Feb 20 11:54:51 PST 2017
# Very weird - this runs fine when I `source()` it from an R prompt, but
# doesn't run with Rscript command line.
# Problem was the default for keep.source

#
# Goal: plot the AST

# DiagrammeR is pretty but otherwise unappealing

library(igraph)

igraph_options(plot.layout=layout_as_tree)

ex = parse("ab.R", keep.source = TRUE)

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
