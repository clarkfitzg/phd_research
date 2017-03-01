source("../print_to_char.R")
source("../depend_graph.R")

#igraph_options(plot.layout=layout_as_tree)

s = readScript("traffic_sim2.R")

g2 = depend_graph(s)

# TODO: see if the code runs after a topological sort!!
# It should :)
# Wait, but 1:n should also be a valid topological sort... so is this
# helping at all? Probably not.
graph_order = topo_sort(g2)

sg = s[graph_order]

sorted_code = sapply(sg, print_to_char)

writeLines(sorted_code, "traffic_sim2_sorted.R")
