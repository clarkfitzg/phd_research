# Fri Feb 17 08:57:20 PST 2017
#
# When do we get self referential loops with the $ operator?

source("../helpers.R")

tg = makeNumberTaskGraph("dollars.R")

tg = CodeDepends::makeTaskGraph("dollars.R")

plot(tg)

frags = readScript("dollars.R")
info = as(frags, "ScriptInfo")

# Isolating the issues
# l is used as a variable in each place
# This just gets the 2nd

# These both get l
getVariables(info[[1]])
getVariables(info[[2]])

getPropagateChanges("l", info, index = TRUE)
