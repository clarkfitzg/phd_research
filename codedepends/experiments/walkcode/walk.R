library(codetools)

ab = parse("ab.R")

# Following Chambers' Extending R example
w = makeCodeWalker(call = function(e, w) 
    lapply(e, 
           function(ee) walkCode(ee, w)
    ),
    leaf = function(e, w) "works"
)

# Hmm, doesn't seem to descend where I'd expect it.
walkCode(ab, w)
