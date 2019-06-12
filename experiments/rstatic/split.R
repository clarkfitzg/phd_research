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
resources = new.env()
resources[["pems"]] = list(details = "Is a large chunked data object", uses = list())

record_use = function(use, varname, .resources = resources)
{
    .resources[[varname]][["uses"]] = c(.resources[[varname]][["uses"]], use)
}




code = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})$contents


# Directly annotate them by hand.
############################################################
# This is the order in which the algorithm will do it.

# The first `pems`
record_use(code[[1]]$read$args$contents[[1]], "pems")

# This is the call, the rhs of the assignment.
# This should actually be unnamed.
# We can use integers to lookup the resources, along with a map of names.
record_use(code[[1]]$read, "stn")

# Infer that the subset is a known column.
resources[["stn"]][["details"]] = "Is a column of pems"

code[[2]]$read$args$contents[[1]]

code[[2]]$read$args$contents[[1]]

# Now we can analyze the call to `by`

as.list(resources)
