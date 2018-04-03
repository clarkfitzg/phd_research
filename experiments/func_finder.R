# Tue Apr  3 12:07:04 PDT 2018
#
# I need a function that looks at a function inside a package and returns
# the name and package of all other functions that it calls. Then I can
# call this recursively.

# Which functions in the stats package have the fewest expressions?

p = "package:stats"

names = ls(p, all.names = TRUE)

funs = sapply(names, function(x) is.function(get(x, p)))

funs = names[funs]

len = sapply(funs, function(x) length(body(get(x, p))))

len = sort(len)

head(len[len > 2])

# complete.cases is an appealing one- it only calls .External


library(CodeDepends)

# Ignoring the following issues for the moment:
#
# - symbols which aren't functions
# - functions defined in the bodies of functions

fun = stats::dgamma
pkg = "package:stats"

func_names = names(getInputs(body(fun))@functions)


