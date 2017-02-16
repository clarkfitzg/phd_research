# Tue Feb 14 13:45:47 PST 2017

source("../helpers.R")

tg = makeNumberTaskGraph("recursion.R")

plot(tg)

# Why is there no edge between 1 and 2?
# Because the function `factorial` that I've defined is also in the base
# package. This is related to the arguments for
# CodeDepends::inputCollector()
# Probably wouldn't be too bad to add it in.

s = readScript("recursion.R")
