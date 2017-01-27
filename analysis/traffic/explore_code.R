# Thu Jan 26 08:34:41 PST 2017

library(CodeDepends)
library(Rgraphviz)

fname = "simple2.R"

script = readScript(fname)

#g = makeCallGraph(script)
#Error in makeUsageCollector(fun, ...) : only works for closures
#plot(g)

methods(class = class(script))

# Looks reasonable
unique(getVariables(script))

# And what about makeCallGraph?
tg = makeTaskGraph(fname)

# Looks like the global variables, ie. not builtin or funcs from packages
glb = getInputs(script)

#vg = makeVariableGraph(fname, vars)
vg = makeVariableGraph(fname)

pdf("simple2.pdf")
par(mfrow = c(1, 2))
plot(vg, main = "Variables")
plot(tg, main = "Tasks")
dev.off()

# Shows when we can remove the variables
timelines = getDetailedTimelines(script)
