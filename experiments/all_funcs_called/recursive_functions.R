# Fri Jul 12 15:52:38 PDT 2019
#
# I would like an analysis that accepts a function call object, say `quote(f(x))`, and some environment, and recursively does the following:
#
# - Finds every function that is called on `x`.
# - Finds every R function that can possibly be called in the course of evaluating this function.
#
# When I say find, I mean the fully qualified name in a package, or the global function.
#
# It should do this only within the R level, not trying to go into the `.Primitive`, `.Call` C level interfaces.


# recursively get usage of functions
#
# It looks insed
get_funcs = function(closure){
}


f = data.frame
b = body(f)
e = environment(f)


# What's the difference between getExportedValue and get?
# getExportedValue does something with "lazydata"


library(CodeDepends)

# We should be able to use CodeDepends for this.

info = getInputs(b)

func_names = names(info@functions)

funcs = lapply(func_names, get, e)

