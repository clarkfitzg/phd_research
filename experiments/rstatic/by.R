library(rstatic)


ast = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})



# The approach I'm considering associates each node of the AST with a resource which is an R object.
# Directly add the resources to the AST by hand.
############################################################
# This is the order in which the algorithm will do it.
