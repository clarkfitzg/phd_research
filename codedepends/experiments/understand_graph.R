library(graph)
library(Rgraphviz)
library(RBGL)


el = function(x) list(edges = unlist(strsplit(x, " ")))

V = unlist(strsplit("B3 A B C D B2 C2 A0", " "))
E = list(A0 = el("A")
         , A = el("B C")
         , B = el("B2 B3")
         , C = el("C2")
         , C2 = el("D")
         , B2 = el("D")
         , D = list()
         , B3 = list()
         )
g = new("graphNEL", nodes = V, edgeL = E, edgemode = "directed")

png("larger_graph.png")
plot(g)
dev.off()

gsimple = new("graphNEL"
              , nodes = unlist(strsplit("A B C D", " "))
              , edgeL = list(A = el("B C"), B = el("D")
                             , C = el("D"), D = list())
              , edgemode = "directed"
              )

png("simple_graph.png")
plot(gsimple)
dev.off()



# Goal: topological sort on this graph, so I can express the general
# pattern. This only works if it's acyclic, which is not the case for code
# in general. Consider recursion.
nd = tsort(g)

# Shows children
e = edges(g)

# They should have multiple children if we're thinking about using
# multiprocessing.


