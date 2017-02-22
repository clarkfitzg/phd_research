# Fri Feb 17 08:57:20 PST 2017
#
# When do we get self referential loops with the $ operator?

source("../helpers.R")

tg = makeNumberTaskGraph("dollars.R")

tg = CodeDepends::makeTaskGraph("dollars.R")

plot(tg)


