# Mon Feb 13 16:58:24 PST 2017
#
# Goal: plot the AST

# DiagrammeR is pretty but otherwise unappealing

library(igraph)

ex = parse(text = "
           # Hey dude
           a <- 10
           b <- a + 5
           plot(a)
           fit <- lm(a ~ b)
")

p = getParseData(ex)

p2 = p[, c("parent", "id", "text")]
colnames(p2) = c("from", "to", "label")

g = igraph::graph_from_data_frame(p2)

