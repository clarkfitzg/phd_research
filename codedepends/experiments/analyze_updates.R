library(CodeDepends)
library(graph)

doc = "updates.R"

tg = CodeDepends::makeTaskGraph(doc)

frags = readScript(doc)
info = as(frags, "ScriptInfo")

nodeIds = if(length(names(info)))
{
             names(info)
} else CodeDepends:::makeScriptNodeNames(info)

names(info) = nodeIds

# The original code pulls the variables out of *each* info object.
# But why do that when one could get all the inputs for the whole script?
# The index of info lets us build the graph, so it's critical to
# preserve it.
# One way to do this is to let getPropagateChanges start at some index.
edges = lapply(info, function(x) {
              list(edges =  getPropagateChanges(getVariables(x), info, index = TRUE))
            })

# So really all we need is for getPropagateChanges to 
