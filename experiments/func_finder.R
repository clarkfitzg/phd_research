# Tue Apr  3 12:07:04 PDT 2018
#
# I need a function that looks at a function inside a package and returns
# the name and package of all other functions that it calls. Then I can
# call this recursively.
#
# It appears that I need to be looking through the namespace internals.

# Which functions in the stats package have the fewest expressions?

p = "package:stats"


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

# Return a data frame of objects imported into a package
package_funcs = function(pkg_name)
{

    # Inferring the class of objects would be very nice to have here because
    # then I know which method will be called.
    ns = getNamespace(pkg_name)

    this_package = data.frame(name = names(ns))
    this_package$package = pkg_name

    imports = getNamespaceImports(pkg_name)
    imports = imports[names(imports) != "base"]
    package_names = names(imports)

    each_package = vector(length(imports), mode = "list")

    for(i in seq_along(imports)){
        tmp = data.frame(name = names(imports[[i]]))
        tmp$package = package_names[i]
        each_package[[i]] = tmp
    }

    each_package = c(list(this_package), each_package)

    do.call(rbind, each_package)

}

fun = stats::dgamma
pkg = "stats"

func_names = names(getInputs(body(fun))@functions)


common = intersect(func_names, names(ns))
