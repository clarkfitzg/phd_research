# Propagate Resources
#
# Thu Jun 13 08:55:57 PDT 2019

library(rstatic)


resource_id = function(node) node$.data[["resource_id"]]

`resource_id<-` = function(node, value){
    node$.data[["resource_id"]] = value
    node
}

new_resource = function(chunked_object = FALSE, ...) list(chunked_object = chunked_object, ...)


# Propagate resource identifiers through an ast
#
# @param ast rstatic language object
# @param name_resource environment mapping symbol names to resource identifiers.
#       Think of this as the evaluation environment of the code.
# @param resources environment mapping resource identifiers to the actual resource descriptions
# @ value list containing updated ast and resource.
#       ast is the original ast except that the nodes \code{x.data$resource_id} have values to look up the resources
#       resources is the orginal resource plus any new distributed resources
propagate = function(ast, name_resource, resources)
{
    # To simulate evaluation we need to walk up from the leaf nodes of the tree.
    # This is different from the conventional DFS / BFS.
    # We can implement this by making sure all the children have their resource_id's set
}


update_resource = function(node, name_resource, resources, namer, ...) UseMethod("update_resource")


update_resource.Subset = function(node, name_resource, resources, namer)
{
    if(node$fn$value == "["
       && resource(node$args[[1]], resources)$chunked_object
       && is(node$args[[2]], "EmptyArgument")
       && is(node$args[[3]], "Character")
    ){
        # Record the object of interest
        new_name = namer()
        resource_id(node) = new_name
        r = new_resource(chunked_object = TRUE, column_subset = TRUE, column_names = node$args[[3]]$value)
        assign(new_name, value = r, pos = resources)
    } else {
        NextMethod()
    }
}


update_resource.Symbol = function(node, name_resource, resources, namer)
{
}


update_resource.default = function(node, name_resource, resources)
{
}


namer_factory = function(basename = "r"){
    cnt = Counter$new()
    function() next_name(cnt, basename)
}


# Actually use it
############################################################



ast = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})


