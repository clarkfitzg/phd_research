# Fri Dec  8 14:12:27 PST 2017
#
# DAG for execution graph

library(igraph)


# The running time for maps can be thought of as a function of the number
# of processors.

gdf = read.csv("sample_graph.csv")

g = graph.data.frame(gdf)


plot(g, layout = layout_as_tree)

sp = shortest_paths(g, from = V(g)[1], to = V(g)[length(V(g))])
sp = sp$vpath[[1]]
