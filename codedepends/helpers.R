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

    edges = lapply(info, function(x) {
        list(edges = getPropagateChanges(getVariables(x), info,
            index = TRUE))
    })

    nd = as.character(seq(length(info)))

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
