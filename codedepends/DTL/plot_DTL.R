source("../depend_graph.R")

#igraph_options(plot.layout=layout_as_tree)

s = readScript("~/Downloads/DTL.R")

# I see 5 edges coming into 24 on the graph, which corresponds to the 5
# inputs in s[[24]].
info = lapply(s, getInputs)

g = depend_graph(s, add_source = TRUE)

write_graph(g, "graph.dot", format = "dot")

# 167 edges
