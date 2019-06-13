library(rstatic)


ast = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})


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

    if(is.null(data_arg) || is.null(index_arg) || !data_arg[["chunked_object"]]){
        return(FALSE)
    }

    if("known_columns" %in% index_arg[["details"]]){
        index_arg[["columns"]]
    } else {
        FALSE
    }
}


# Find the call to `by`
bc = find_nodes(ast, function(node) is(node, "Call") && node$fn$value == "by")[[1]]
bc = ast[[bc]]


# The approach I'm considering associates each node of the AST with a resource which is an R object.
# Directly add the resources to the AST by hand.
############################################################
# This is the order in which the algorithm will do it.
