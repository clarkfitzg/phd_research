# Propagate Resources
#
# Thu Jun 13 08:55:57 PDT 2019

library(rstatic)


resource_id = function(node) node$.data[["resource_id"]]

`resource_id<-` = function(node, value){
    node$.data[["resource_id"]] = value
    node
}

# Modifies the node and resources.
# Returns the name of the added resource
new_named_resource = function(node, resources, namer, chunked_object = FALSE, ...) 
{
    new_name = namer()
    r = list(chunked_object = chunked_object, ...)

    # All based on side effects
    assign(new_name, value = r, pos = resources)
    resource_id(node) = new_name

    new_name
}


# Propagate resource identifiers through an ast
#
# Must be called from the root of the AST, which is probably a Brace
#
# @param ast rstatic language object
# @param name_resource environment mapping symbol names to resource identifiers.
#       Think of this as the evaluation environment of the code.
# @param resources environment mapping resource identifiers to the actual resource descriptions
# @ value list containing updated ast and resource.
#       ast is the original ast except that the nodes \code{x.data$resource_id} have values to look up the resources
#       resources is the orginal resource plus any new distributed resources

propagate = function(node, name_resource, resources, namer)
{
    # To simulate evaluation we need to walk up from the leaf nodes of the tree.
    # This is different from the conventional DFS / BFS.
    # We can implement this by making sure all the children have their resource_id's set
    for(child in children(node)){
        Recall(child, name_resource, resources, namer)
    }
    # This guarantees the children all have resources, so we can proceed to this node.
    update_resource(node, name_resource, resources, namer)
}


update_resource = function(node, name_resource, resources, namer, ...) UseMethod("update_resource")


update_resource.Subset = function(node, name_resource, resources, namer)
{
    if(node$fn$value == "["
       && resources[[resource_id(node$args[[1]])]]$chunked_object
       && is(node$args[[2]], "EmptyArgument")
       && is(node$args[[3]], "Character")
    ){
        new_named_resource(node, resources, namer,
            chunked_object = TRUE, column_subset = TRUE, column_names = node$args[[3]]$value)
    } else {
        NextMethod()
    }
}


update_resource.Symbol = function(node, name_resource, resources, namer)
{
    nm = node$value 
    if(nm %in% names(name_resource)){
        resource_id(node) = name_resource[[nm]]
    } else {
        NextMethod()
    }
}


update_resource.default = function(node, name_resource, resources, namer)
{
    new_named_resource(node, resources, namer)
}


update_resource.Assign = function(node, name_resource, resources, namer)
{
    r_id = resource_id(node$read) 
    # This will write over an existing value for that symbol, which is what we want.
    resource_id(node$write) = r_id
    name_resource[[node$write$value]] = r_id
}


namer_factory = function(basename = "r"){
    cnt = Counter$new()
    function() next_name(cnt, basename)
}


# The resource that corresponds to a node, or NULL if none exists
get_resource = function(node, resources)
{
    resource_id = node$.data[["resource_id"]]
    if(is.null(resource_id)){
        NULL
    } else {
        resources[[resource_id]]
    }
}


# Returns the name of the column that the call splits by if it can find it, and FALSE otherwise
splits_by_known_column = function(bycall, resources)
{
    # bycall a call to `by`
    # resources descriptions that act like an evaluation environment for the call to `by`
    
    # Check that:
    # 1. data_arg is a large chunked data object
    # 2. index_arg is a known column

    # For now I'm not thinking about whether the chunking schemes match up or if they inherit from the same object.

    data_arg = get_resource(bycall$args$contents[[1]], resources)
    index_arg = get_resource(bycall$args$contents[[2]], resources)

    if(!data_arg[["chunked_object"]]){
        return(FALSE)
    }

    cs = index_arg[["column_subset"]]
    if(!is.null(cs) && cs){
        index_arg[["column_names"]]
    } else {
        FALSE
    }
}


# Actually use it
############################################################

name_resource = new.env()
resources = new.env()
namer = namer_factory()

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
