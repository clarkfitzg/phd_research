source("../helpers.R")

fname = "simple4.R"

tg = makeTaskGraph2(fname)

nodes(tg)

plot_big(tg)

# Remove first and last elements
# TODO: generalize beyond this extremely simple case of literally taking
# first and last
lines = nodes(tg)
component_graph = subGraph(lines[-c(1, length(lines))], tg)

# take connected components
components = connComp(component_graph)


# Here's what we're going for:
#mcparallel({
#    x1 = rnorm(n)
#    x2 = x1 + 5
#    x3 = x2 + 10
#    list(x3 = x3)
#})
catcomp = function(comp, keeper)
{
    cat("\nmcparallel({\n    ")
    cat(comp, sep = "\n    ")
    # TODO: Keep more variables and probably automate this
    cat(sprintf("    list(%s = %s)\n", keeper, keeper))
    cat("})\n")
}


############################################################
# Write to file here:
sink("shot1_target2.R")

cat("# Auto generated\n")
cat("#", date())
cat("\n\nlibrary(parallel)\n\n")

cat(c(lines[1], "\n"))

catcomp(components[[1]], "x3")
catcomp(components[[2]], "y3")

cat('\n# This block represents boilerplate for a barrier
# Or think of it as a fork / join.
############################################################
    collected = mccollect()
    message("Collected.")

    # Pull these objects into the global environment
    for(process in collected)
    {
        for(varname in names(process))
        {
            assign(varname, process[[varname]], envir = .GlobalEnv)
        }
    }
############################################################
\n')

cat(lines[length(lines)])
sink()
