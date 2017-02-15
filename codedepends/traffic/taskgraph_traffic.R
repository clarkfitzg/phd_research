source("../helpers.R")

fname = "traffic_sim.R"

g = makeNumberTaskGraph(fname)

png("traffic_sim.png", width = 1500, height = 1500)

plot(g)

dev.off()

frags = readScript(fname)

charfrags = unlist(sapply(frags, as.character))
grep("fd", charfrags)

# at index 20
# fd() is a user defined function called within the supply() function,
# among other places. So the result from below should not be
# empty
coll = inputCollector(funcsAsInputs = TRUE)
info = lapply(frags, getInputs, collector = coll)
getPropagateChanges("fd", frags, info, recursive = TRUE)

# What is the meaning of the outputs slot in this object:
info[[20]]
# Is it all the variables that have been used until now? Strange.

# Important inputs
frags[c(1, 6, 9, 10, 14)]

# Final results
frags[c(48, 49, 61)]

# Won't work because it's not a DAG
# RBGL::tsort(g)


fname2 = "traffic_sim2.R"

g2 = makeNumberTaskGraph(fname2)

png("traffic_sim2.png", width = 1500, height = 1500)
plot(g2)
dev.off()


frags2 = readScript(fname2)

frags2[[47]]

