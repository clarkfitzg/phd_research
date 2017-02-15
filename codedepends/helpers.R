library(CodeDepends)
library(graph)
library(Rgraphviz)


# Capture printed output through a temporary file.
# Hopefully there's a better way to do this!
print_to_char = function(x, nchars = 10000L)
{
    f = tempfile()
    sink(f)
    print(x)
    sink()
    out = readChar(f, nchars)
    unlink(f)
    # Drop the trailing newline
    gsub("\n$", "", out)
}


# Convoluted since we're going from
# code text -> parsed expression -> code text
# Would likely be better just to pull in code text directly.
# One advantage of this approach is normalization of syntax, but probably
# want to verify, ie. = becomes <-
makeTaskGraph2 = function(doc, frags = readScript(doc), info = as(frags, "ScriptInfo"))
{
    #TODO: looks weird in here

    nm = sapply(frags, print_to_char)
    # Causes warning since invalid object
    names(info) = nm

    edges = lapply(info, function(x) {
        list(edges = getPropagateChanges(getVariables(x), info,
            index = TRUE))
    })

    new("graphNEL", nodes = nm, edgeL = edges, edgemode = "directed")
}


# Label the nodes with just the number of the expression. This is easier to
# print, and we can easily use numbers to pull the index back out.
makeNumberTaskGraph = function(doc)
{

    frags = readScript(doc)
    info = as(frags, "ScriptInfo")

    # WHERE to pass this arg to inputCollector?? Doesn't seem to be any top
    # level way.
    # , funcsAsInputs = TRUE

    # x is of class ScriptNodeInfo, so it calls that method for
    # getVariables
    edges = lapply(info, function(x) {
        list(edges = getPropagateChanges(getVariables(x, ), info,
            recursive = FALSE, index = TRUE))
    })
    # With recursive the graph is huge.

    nd = as.character(seq(length(info)))

    names(edges) = nd

    new("graphNEL", nodes = nd, edgeL = edges, edgemode = "directed")
}


# Label the nodes with just the number of the expression. This is easier to
# print, and we can easily use numbers to pull the index back out.
# Wed Feb 15 11:18:24 PST 2017
# Another crack at it. Trying to get the function dependencies to show.
makeNumberTaskGraph2 = function(doc)
{

    frags = readScript(doc)
    info = as(frags, "ScriptInfo")

    # None of these contained the UDF's. Which is probably why it fails!!
    allinputs = lapply(info, function(x) x@inputs)



    getPropagateChanges("fd", info, index = TRUE)

    edges = lapply(info, function(x) {
        list(edges = getPropagateChanges(getVariables(x, ), info,
            recursive = FALSE, index = TRUE))
    })

    nd = as.character(seq_along(info))

    names(edges) = nd

    new("graphNEL", nodes = nd, edgeL = edges, edgemode = "directed")
}



# Hacking to get the fontsize legible for code graph.
plot_big = function(g, fontsize = 40)
{
    lg = layoutGraph(g)
    nodeRenderInfo(lg) = list(fontsize = fontsize, lty = 0)
    renderGraph(lg)
}

# Pulling out of CodeDepends to reason through this.
getDependsOn = function(var, info, vars = character())
{
	# Where does var appear as an input?
    w = sapply(info, function(x) var %in% x@inputs)
	# All the variables
    ans = unique(unlist(c(lapply(info[w], getVariables))))
    if (length(vars)) {
        # Can't do match here, because it makes NA's which you can't build
        # a graph of later.
        #list(edges = match(ans, vars))
        list(edges = intersect(ans, vars))
    }
    else ans
}

# Really only care about the variables that are defined in this script.
# Reading through the docs, it seems that this may be the intended
# behavior?
# TODO: Ask Duncan - I don't know what's going on with these functions,
# they seem to be computing everything in the signature.
variable_graph = function(doc)
{

    frags = readScript(doc)
    info = as(frags, "ScriptInfo")
    inputs = getInputs(frags)
    vars = unlist(lapply(inputs, function(x) x@outputs))
    vars = unique(vars)
    edges = lapply(vars, getDependsOn, info = info, vars = vars)

    #vars = makeNodeLabs(vars)
    names(edges) = vars
    new("graphNEL", nodes = vars, edgeL = edges, edgemode = "directed")
}
