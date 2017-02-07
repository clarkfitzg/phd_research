library(graph)
library(Rgraphviz)


V = c("A", "B", "C")
E = list(A = list()
         , B = list(edges = 3)
         , C = list(edges = 1)
         )
g = new("graphNEL", nodes = V, edgeL = E, edgemode = "directed")
plot(g)

# I need a way to "sort" this graph, pulling out the first and last
# elements.

nodes(g)
