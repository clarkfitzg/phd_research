source("propagate.R")

x_id = namer()
name_resource[["x"]] = x_id
resources[[x_id]] = list(chunked_object = TRUE)

ast = quote_ast({
    y = x[, "y"]
    ybar = mean(y)
    ysd = sd(y)
    z = (y - ybar) / ysd
})

# Mark everything with whether it's a chunked object or not.
propagate(ast, name_resource, resources, namer, vector_funcs = c("exp", "+"))

# Should be a chunked object
get_resource(ast[[2]], resources)

# Next is the code generation.
# A good implementation should do the following:
# - Each worker will read in a chunk of `x`, doing column selection at the source so that only the column 'y' comes through.
# - Each worker will compute the parts necessary for `ybar` and `ysd` on their chunks of the data.

