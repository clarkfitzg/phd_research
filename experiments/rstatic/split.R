# Wed Jun 12 11:40:35 PDT 2019
#
# My goal is to annotate rstatic objects with semantic meaning.
# Given a set of initial large objects, and a set of vectorized functions, I want to say which values of subexpressions are also large objects.
# An object is large when it is the result of a vectorized function and the vectorized arguments are large.

# It might make more sense to do this with data flow.


library(rstatic)

large_objects = "pems"
vector_funcs = c("[", "sin")

name_resource_lookup = "pems"
resources = list("Details of pems data")


code = quote_ast({
    stn = pems[, "station"]
    result = by(pems, stn, npbin)
})$contents


# Directly annotate them by hand

# The first `pems`
code[[1]]$read$args$contents[[1]]$resource = 1L
