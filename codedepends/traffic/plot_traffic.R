source("../depend_graph.R")

#igraph_options(plot.layout=layout_as_tree)

s = readScript("traffic_sim2.R")

# I see 5 edges coming into 24 on the graph, which corresponds to the 5
# inputs in s[[24]].
info = lapply(s, getInputs)

g = depend_graph(s, add_source = TRUE)

write_graph(g, "traffic.dot", format = "dot")

# 37 and 38 are the lines that are currently failing.
# We should have an edge from 37 -> 38 since 38 uses shock2() created in 37.
