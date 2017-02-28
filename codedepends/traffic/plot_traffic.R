source("../depend_graph.R")

#igraph_options(plot.layout=layout_as_tree)

s = readScript("traffic_sim2.R")

# I see 5 edges coming into 23 on the graph, which corresponds to the 5
# inputs in s[[24]].
info = lapply(s, getInputs)

g = depend_graph(s, add_source = TRUE)

g2 = depend_graph(s)

# TODO: see if the code runs after a topological sort!!
# It should :)
# Wait, but 1:n should also be a valid topological sort... so is this
# helping at all? Probably not.
graph_order = topo_sort(g2)

s[graph_order]


write_graph(g, "traffic.dot", format = "dot")
