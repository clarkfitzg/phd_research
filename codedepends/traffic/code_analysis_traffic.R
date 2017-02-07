source("../helpers.R")

fname = "traffic_sim.R"

g = makeNumberTaskGraph(fname)

png("traffic_sim.png", width = 1500, height = 1500)
plot(g)
dev.off()

frags = readScript(fname)

# Important inputs
frags[c(1, 6, 9, 10, 14)]

# Final results
frags[c(48, 49, 61)]
