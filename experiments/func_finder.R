# Tue Apr  3 12:07:04 PDT 2018
#
# I need a function that looks at a function inside a package and returns
# the name and package of all other functions that it calls. Then I can
# call this recursively.
#
# There are several namespace related functions that make this easy.

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

base_funcs = data.frame(name = names(getNamespace("base")))
base_funcs$package = "base"

all_funcs = package_funcs("stats")

# Ideally I'd like to do some kind of chained lookups here. I can probably
# accomplish this with the right kind of joins.

# TODO: Pop these from func_names
common = intersect(func_names, all_funcs$name)

keepers = func_names %in% base_funcs$name

resolved = base_funcs[base_funcs$name %in% func_names, ]
