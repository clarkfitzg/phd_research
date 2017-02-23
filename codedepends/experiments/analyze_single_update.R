# Wed Feb 22 17:40:38 PST 2017
# One way to get around this may be to loop over indices and examine the
# code after a certain loop index.
library(CodeDepends)

fname = "single_update.R"

tg = CodeDepends::makeTaskGraph(fname)

plot(tg)

frags = readScript(fname)
info = as(frags, "ScriptInfo")

# Isolating the issues
# l is used as a variable in each place
# This just gets the 2nd

# These both return x, 
getVariables(info[[1]])
getVariables(info[[2]])

getPropagateChanges("x", info[2], index = TRUE)
