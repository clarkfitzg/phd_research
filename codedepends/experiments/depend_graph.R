# Thu Feb 23 09:56:02 PST 2017

library(CodeDepends)
library(igraph)


#" Index Of Most Recently Defined Varname
#"
#" @param varname variable name
#" @param info object of class \code{CodeDepends::ScriptInfo}
most_recent_update = function(varname, info)
{
    outputs = sapply(info, function(x) varname %in% x@outputs)
    tail(which(outputs), 1)
}


#" Expression Dependency Graph
#"
#" Create a DAG representing a set of expression dependencies.
#" I'm not yet trying to take the minimal set of such dependencies, because
#" it's not clear that this is necessary.
#"
#" @param script as returned from \code{\link[CodeDepends]{readScript}}
depend_graph = function(script)
{

    info = as(script, "ScriptInfo")
    n = length(info)

    # Degenerate cases
    if (n == 0){
        return(make_empty_graph())
    }
    if (n == 1){
        # Graph with one node, no edges.
        return(make_graph(numeric(), n = 1))
    }

    edges = numeric()
    for(i in 2:n){
        for(varname in info[[i]]@inputs){
            # Only check the previous uses in info
            usage = most_recent_update(varname, info[seq(i-1)])
            if(length(usage) == 1){
                edges = append(edges, c(usage, i))
            }
        }
    }

    edgemat = matrix(edges, ncol = 2)
    graph_from_edgelist(edgemat)
}


# Tests
############################################################
if(TRUE)
{

library(testthat)

# Could define Ops to get ==, but this is sufficient
expect_samegraph = function(g1, g2)
{
    expect_true(isomorphic(g1, g2))
}


test_that("Degenerate cases, 0 or 1 nodes", {

    s0 = readScript(txt = "
    ")
    g0 = make_empty_graph()
    gd0 = depend_graph(s0)
    expect_samegraph(g0, gd0)

    s1 = readScript(txt = "
    x = 1
    ")
    g1 = make_graph(numeric(), n = 1)
    gd1 = depend_graph(s1)

    expect_samegraph(g1, gd1)

})


test_that("Self referring node does not appear", {

    s = readScript(txt = "
    x = 1
    x = x + 2
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)
    expect_samegraph(desired, actual)

})


} # end tests
