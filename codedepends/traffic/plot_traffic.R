source("../experiments/depend_graph.R")

igraph_options(plot.layout=layout_as_tree)

s = readScript("traffic_sim2.R")

g = depend_graph(s)

write_graph(g, "traffic.dot", format = "dot")
