ast = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})


# 
############################################################


# Returns the name of the column that the call splits by if it can find it, and FALSE otherwise
splits_by_known_column = function(bycall, env)
{
    # bycall a call to `by`
    # env resource descriptions that act like an evaluation environment for the call to `by`
    
    # Check that:
    # 1. data_arg is a large chunked data object
    # 2. index_arg is a known column

    # For now I'm not thinking about whether the chunking schemes match up or if they inherit from the same object.
    data_arg_name = bycall$args$contents[[1]]$value
    index_arg_name = bycall$args$contents[[2]]$value

    # TODO: Find a more robust / general way to lookup resources.
    # This assumes they are names.
    data_arg = env[[data_arg_name]]
    index_arg = env[[index_arg_name]]

    if(is.null(data_arg) || is.null(index_arg) || !data_arg[["chunked_object"]]){
        return(FALSE)
    }

    if("known_columns" %in% index_arg[["details"]]){
        index_arg[["columns"]]
    } else {
        FALSE
    }
}


call = code[[2]]$read

find_nodes(ast, function(node) is(node, "Symbol") && node$value == "x")


