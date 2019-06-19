# Actually use it
############################################################

source("propagate.R")

pems_id = namer()
name_resource[["pems"]] = pems_id
resources[[pems_id]] = list(chunked_object = TRUE)

ast = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})

# Does all the inference
propagate(ast, name_resource, resources, namer)

# Should see a column subset in here after this is done.
out = as.list(resources)

# Find the call to `by`
bc = find_nodes(ast, function(node) is(node, "Call") && node$fn$value == "by")[[1]]
bc = ast[[bc]]

s = splits_by_known_column(bc, resources)
