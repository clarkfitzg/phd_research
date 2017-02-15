source("../helpers.R")

fname = "traffic_sim.R"

g = variable_graph(fname)

png("vargraph.png", width = 1500, height = 1500)

plot_big(g)

dev.off()
