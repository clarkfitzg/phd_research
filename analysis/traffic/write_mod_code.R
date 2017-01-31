library(CodeDepends)
library(graph)


fname = "simple3.R"

s = readScript(fname)

# Can I cat this right back into a file now?

# It's just a list
selectSuperClasses("Script")

# Of language objects
typeof(s[[1]])

# Maybe just hijack the print method?
print(s[[1]])

sink(paste0("mod_", fname))
for(expression in s){
    print(expression)
}
sink()

# The above only works if it's in the right order and essentially converted
# back to a list. I need to figure out how to go from the task graph back
# to a list of language expressions. I know it's the task graph because
# the number of nodes should be the number of lines (expressions) in the
# script.


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


tg = makeTaskGraph(fname)

nodes(tg) = as.list(frags)

makeTaskGraph2 = function(doc, frags = readScript(doc), info = as(frags, "ScriptInfo"))
{
    doc = fname
    frags = readScript(doc)
    info = as(frags, "ScriptInfo")
    nm = sapply(frags, print_to_char)
    # Causes warning since invalid object
    names(info) = nm

    edges = lapply(info, function(x) {
        list(edges = getPropagateChanges(getVariables(x), info,
            index = TRUE))
    })

    new("graphNEL", nodes = nm, edgeL = edges, edgemode = "directed")
}


tg2 = makeTaskGraph2(fname)

nodes(tg2)

# FINALLY figured out how to change the fontsize. Ack.
x = layoutGraph(tg2)
nodeRenderInfo(x) = list(fontsize = 40, lty = 0)
png("code_graph.png", width = 1080, height = 1500)
renderGraph(x)
dev.off()


# Another thing to do here is to just use a table mapping integers to
# expressions
expr_int = data.frame(int = as.character(seq_along(frags)))
expr_int$expr = as(frags, "list")
