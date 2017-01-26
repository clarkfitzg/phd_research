# Thu Jan 26 08:34:41 PST 2017

# Analyzing code in the traffic simulation script
# Going through the docs here:
# http://www.omegahat.net/CodeDepends/design.pdf

library(CodeDepends)
library(Rgraphviz)

fname = "traffic_sim.R"

script = readScript(fname)

#g = makeCallGraph(script)
#Error in makeUsageCollector(fun, ...) : only works for closures
#plot(g)

methods(class = class(script))

# Looks reasonable
unique(getVariables(script))

tg = makeTaskGraph(fname)

# This is nice, but labels should be visible
pdf("taskgraph.pdf", width = 20, height = 12)

gv_attrs = list(graph = list()
                , node = list(fontsize = 12, width = 1)
                , edge = list()
                )
plot(tg, attrs = gv_attrs)

dev.off()


