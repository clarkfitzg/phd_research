# Thu Feb 23 09:56:02 PST 2017

library(CodeDepends)
library(igraph)


#" Expression Dependency Graph
#"
#" Create a DAG representing minimal set of expression dependencies
#"
#" @param script as returned from \code{\link[CodeDepends]{readScript}}
depend_graph = function(script)
{

    info = as(script, "ScriptInfo")
    n = length(info)

    # TODO: Add real code
    make_graph(numeric(), n = 1)
}


# Tests
############################################################
if(TRUE)
{

library(testthat)

# Could define Ops to get ==, but this is sufficient
expect_samegraph = function(g1, g2)
{
    diff = g1 %m% g2
    expect_equal(gsize(diff), 0)
    expect_equal(gorder(diff), 0)
}


test_that("Degenerate cases, 0 or 1 nodes", {

    s0 = readScript(txt = "
    ")
    g0 = make_graph(numeric(), n = 0)
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
