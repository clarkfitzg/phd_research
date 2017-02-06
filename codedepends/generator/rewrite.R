source("../helpers.R")

fname = "simple4.R"

tg = makeTaskGraph2(fname)

nodes(tg)

plot_big(tg)

# Not sure how to generally detect where the possibilities for
# parallel are. In this case there are some obvious options:
# 
# 1. 
