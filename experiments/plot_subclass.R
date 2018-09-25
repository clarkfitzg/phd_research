# Tue Sep 25 11:23:33 PDT 2018
#
# I need to know when an expression plots.
# A robust way to do this is to recursively explore the code.
# A more immediate way is to specify a list of functions that do plotting,
# and check if they are called.

library(CodeDepends)

plotfuncs = c("plot", "lines", "points")

code = quote(graphics::lines(x, y))

cd = getInputs(code)

# We can just pull it right out of the ScriptNodeInfo object
any(plotfuncs %in% names(cd@functions))

# I'm interested in 4 cases:
#   1. None
#   2. Opens device     ex: pdf
#   3. Plots            ex: lines
#   4. Closes device    ex: dev.off

plotUse = function(node
    , openFuncs = c("pdf", "bmp", "jpeg", "png", "tiff")
    , plotFuncs = c("plot", "lines", "points")
    , closeFuncs = c("dev.off", "graphics.off")
    )
{
    funcs = names(node@functions)

    out = "none"

    if(any(closeFuncs %in% funcs)) out = "close"
    if(any(plotFuncs %in% funcs)) out = "plot"
    # When in doubt about an edge we can err on the side of correctness by
    # adding it in. This is guaranteed to happen if the last value to occur
    # is "open"
    if(any(openFuncs %in% funcs)) out = "open"
    out
}


# Experiments:

lapply_node = getInputs(quote(lapply(x, lines)))

# Good, this does the right thing.
plotUse(lapply_node)


# One issue is the ordering of statements. For example, how do we deal with
# this in one node:
close_open = quote({
    dev.off()
    pdf("newplot.pdf")
})
# We can always start out by recursing into the brace.

plotUse(getInputs(close_open))
