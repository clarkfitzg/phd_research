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
resources[[1L]] = list(details = "Is a large chunked data object", uses = list(), expected_name = "pems")

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
resources[[2L]][["details"]] = "Is a column of pems"
resources[[2L]][["expected_name"]] = "stn"

# The call to by uses 'pems' and 'stn'
record_use(code[[2]]$read$args$contents[[1]], 1L)
record_use(code[[2]]$read$args$contents[[2]], 2L)

# Now we can analyze the call to `by`

