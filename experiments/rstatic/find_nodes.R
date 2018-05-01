# Mon Apr 30 09:27:43 PDT 2018

# Working from Nick's latest commits

library(rstatic)

e = quote_ast(x[i] <- f(y[i -1]))

find_nodes(e, function(node) is(node, "Symbol") && node$name == "i")

