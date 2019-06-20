# Thu Jun 20 11:37:30 PDT 2019
# I can get this working incrementally by starting with the simplest things possible.
# The simplest thing is to see the system working for a completely vectorized program.

# Here's what we can do on further refinements:
# 1. column selection
# 2. force a 'collect', say with median
# 3. 'reduce' functions, as in the z score example. 


# Developing stuff that should make its way into makeParallel
library(makeParallel)

source("propagate.R")



x_id = namer()
name_resource[["x"]] = x_id
resources[[x_id]] = list(chunked_object = TRUE)

ast = quote_ast({
    y = x[, "y"]
    y2 = 2 * y
})

# Mark everything with whether it's a chunked object or not.
propagate(ast, name_resource, resources, namer, vector_funcs = c("exp", "+", "*"))

# Should be a chunked object
get_resource(ast[[2]], resources)


setOldClass("Brace")

setMethod("inferGraph", signature(code = "Brace", time = "missing"),
    function(code, time, ...){
        expr = lapply(code$contents, as_language)
        expr = as.expression(expr)
        callGeneric(expr, ...)
})

g = inferGraph(ast)
gdf = g@graph

chunk_obj = sapply(ast$contents, is_chunked, resources = resources)

# Find the largest set of vector blocks possible, working forward.
findVectorBlocks = function(gdf, chunk_obj)
{
    smallest = min(gdf$from, gdf$to)
}



setClass("VectorSchedule", contains = "Schedule")

scheduleVector = function(graph, data)
{
    # The idea is to combine as many nodes in the graph as possible.
    # This means I need to reconcile the dependency graph with the AST.
}
