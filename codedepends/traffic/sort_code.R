source("../print_to_char.R")
source("../depend_graph.R")

#igraph_options(plot.layout=layout_as_tree)

s = readScript("traffic_sim2.R")

g2 = depend_graph(s)

# This is the length of the longest path. From the picture this should be
# 13.
#longest_path(g2)

# TODO: see if the code runs after a topological sort!!
# It should :)
# Wait, but 1:n should also be a valid topological sort... so is this
# helping at all? Probably not.
graph_order = topo_sort(g2)

sg = s[graph_order]

sorted_code = sapply(sg, print_to_char)

writeLines(sorted_code, "generated/traffic_sim2_sorted.R")
