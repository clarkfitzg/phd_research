# Tue Apr  3 12:07:04 PDT 2018
#
# I need a function that looks at a function inside a package and returns
# the name and package of all other functions that it calls. Then I can
# call this recursively.
#
# There are several namespace related functions that make this easy.
#
# This would be useful to explore the package ecosystem- it can show which
# are the most and least used functions in packages.

# Which functions in the stats package have the fewest expressions?

p = "stats"

ns = getNamespace(p)

funs = sapply(ns, is.function)

funs = names(funs[funs])

len = sapply(funs, function(x) length(body(get(x, ns))))

len = sort(len)

tail(len[len > 3])



############################################################

library(CodeDepends)

# Eventually we'll need to cache all this for performance reasons.
#
# Ignoring the following issues for the moment:
#
# - symbols which aren't functions
# - functions defined in the bodies of functions
# - Explicit use of base::func in package code


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


base_funcs = data.frame(name = names(getNamespace("base")))
base_funcs$package = "base"


# Helper to combine package and base functions
package_and_base_funcs = function(pkg, .base_funcs = base_funcs)
{
    pkgfuncs = package_funcs(pkg)

    # It's possible for a package to override a base function internally.
    bfuncs = .base_funcs[!(.base_funcs$name %in% pkgfuncs$name), ]

    rbind(pkgfuncs, bfuncs)
}


# Which functions in which packages does fun use directly?
used_funcs = function(fun, pkg)
{
    used = data.frame(name = names(getInputs(body(fun))@functions))

    possible = package_and_base_funcs(pkg)

    merge(used, possible, by = "name", all.x = TRUE)
}


# ad hoc tests
############################################################

names(getInputs(body(mad))@functions)

f2 = used_funcs("mad", "stats")


names(getInputs(body(arima))@functions)

# Interesting. What is this function?
# 27           %+%<-    <NA>
f1 = used_funcs("arima", "stats")
