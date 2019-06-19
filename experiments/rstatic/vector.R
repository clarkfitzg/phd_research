source("propagate.R")

pems_id = namer()
name_resource[["pems"]] = pems_id
resources[[pems_id]] = list(chunked_object = TRUE)

ast = quote_ast({
    stn = pems[, "station"]
    foo = exp(stn) + 3
    result = by(pems, stn, npbin)
})

# Does all the inference
propagate(ast, name_resource, resources, namer, vector_funcs = c("exp", "+"))

# Should be a chunked object
get_resource(ast[[2]], resources)
