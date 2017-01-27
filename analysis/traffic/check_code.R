# Thu Jan 26 08:34:41 PST 2017

# Analyzing code in the traffic simulation script
# Going through the docs here:
# http://www.omegahat.net/CodeDepends/design.pdf

library(CodeDepends)
library(Rgraphviz)

fname = "simple1.R"

script = readScript(fname)

#g = makeCallGraph(script)
#Error in makeUsageCollector(fun, ...) : only works for closures
#plot(g)

methods(class = class(script))

# Looks reasonable
unique(getVariables(script))

tg = makeTaskGraph(fname)
vg = makeVariableGraph(fname)

# Hmmm, this isn't what I expected. Thought there would be 
plot(vg)


tg_edges = edges(tg)

