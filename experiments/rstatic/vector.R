
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

# Next is the scheduling and code generation.
# Start with the simplest things possible.
# - Each worker will read in a chunk of `x`, doing column selection at the source so that only the column 'y' comes through.
# - Each worker will compute `y2` and save it

# Developing stuff that will go into makeParallel

library(makeParallel)

setOldClass("Brace")

setMethod("inferGraph", signature(code = "Brace", time = "missing"),
    function(code, time, ...){
        expr = lapply(code$contents, as_language)
        expr = as.expression(expr)
        callGeneric(expr, ...)
})

g = inferGraph(ast)

setClass("VectorSchedule", contains = "Schedule")


scheduleVector = function(graph, data)
{
    # The idea is to combine as many nodes in the graph as possible.
    # This means I need to reconcile the dependency graph with the AST.
}
