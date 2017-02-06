source("helpers.R")

fname = "2blocks.R"

s = readScript(fname)

tg = makeTaskGraph(fname)

tg = makeTaskGraph2(fname)

nodes(tg2)

png("2blocks.png")
plot_big(tg)
dev.off()



