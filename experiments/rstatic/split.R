# Wed Jun 12 11:40:35 PDT 2019
#
# My goal is to annotate rstatic objects with semantic meaning.
# Given a set of initial large objects, and a set of vectorized functions, I want to say which values of subexpressions are also large objects.
# An object is large when it is the result of a vectorized function and the vectorized arguments are large.

# It might make more sense to do this with data flow.


library(rstatic)

vector_funcs = c("[", "sin")

# Only including the large named data objects at this time.
# Could extend it to include all the resources we care about- constants, files, etc.
resources = list()
resources[[1L]] = list(chunkedObject = TRUE, details = "Is a large chunked data object", uses = list(), expected_name = "pems")

record_use = function(use, index)
{
    tryCatch(resources[[index]][["uses"]] <<- c(resources[[index]][["uses"]], use),
             error = function(...){
                resources[[index]] <<- list(uses = list(use))
             })
}

code = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})$contents


# Directly annotate them by hand.
############################################################
# This is the order in which the algorithm will do it.

# The first `pems`
record_use(code[[1]]$read$args$contents[[1]], 1L)

# This is the call, the rhs of the assignment.
record_use(code[[1]]$read, 2L)

# Infer from the subset that this is a known column.
resources[[2L]][["details"]] = list("Is a column of pems", colname = "station")
resources[[2L]][["expected_name"]] = "stn"

# The call to by uses 'pems' and 'stn'
record_use(code[[2]]$read$args$contents[[1]], 1L)
record_use(code[[2]]$read$args$contents[[2]], 2L)


# Now we can analyze the call to `by`
############################################################

call = code[[2]]$read

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
