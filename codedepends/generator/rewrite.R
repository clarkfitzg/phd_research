source("../helpers.R")

fname = "simple4.R"

tg = makeTaskGraph2(fname)

nodes(tg)

plot_big(tg)
