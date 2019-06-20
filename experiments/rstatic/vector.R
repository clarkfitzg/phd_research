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
    2 * 3
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


# Recursively find descendants of a node.
# gdf should be a dag or this will recurse infinitely.
descendants = function(node, gdf)
{
    children = gdf$to[gdf$from == node]
    cplus = lapply(children, descendants, gdf = gdf)
    cplus = do.call(c, cplus)
    unique(c(children, cplus))
}

chunk_obj = sapply(ast$contents, is_chunked, resources = resources)

# Find the largest connected set of vector blocks possible
# This will only pick up those nodes that are connected through dependencies- we could include siblings as well.
# One way to do that is to have a node for the initial load of the large data object, and gather all of its descendants.
findVectorBlocks = function(gdf, chunk_obj)
{
    not_chunked = which(!chunk_obj)

    # Drop nodes that are descendants of non chunked nodes.
    d2 = lapply(not_chunked, descendants, gdf = gdf)
    d2 = do.call(c, d2)
    exclude = c(not_chunked, d2)

    # This graph contains only the ones we need
    pruned = gdf[!(gdf$from %in% exclude) & !(gdf$to %in% exclude), ]

    # Picking the smallest index is somewhat arbitrary.
    d0 = min(pruned$from)
    d = descendants(d0, pruned)
    c(d0, d)
}



setClass("VectorSchedule", contains = "Schedule")

scheduleVector = function(graph, data)
{
    # The idea is to combine as many nodes in the graph as possible.
    # This means I need to reconcile the dependency graph with the AST.
}
