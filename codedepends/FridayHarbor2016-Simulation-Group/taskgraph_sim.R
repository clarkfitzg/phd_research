source("../helpers.R")
fname = "runall.R"
g = makeNumberTaskGraph(fname)

plot(g)

frags = readScript(fname)

# This is similar to the change point- most of the action happens inside
# one function, frags[11].

# Not currently working:
#
#> g = makeNumberTaskGraph(fname)
#Error in find.package(pkgName, lib.loc, verbose = verbose) :
#  there is no package called ‘Matrix (>= 1.1.1)’
#
# I have Matrix_1.2-8
#
# Why? The only two libraries used- lme4 and MASS load up fine. So it must
# be a problem in CodeDepends.
