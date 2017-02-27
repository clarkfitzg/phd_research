# Thu Feb 23 09:56:02 PST 2017

library(CodeDepends)
library(igraph)


#" Just like a deck of cards
shuffle = function(x, y)
{
    as.vector(mapply(c, x, y))
}

#" Variable Use Edge Chain
#" 
#" A chain of edges corresponding to each time a variable is defined or used,
#" suitable for use with \code{\link[igraph]{make_graph}}
#" 
#" @param varname variable name
#" @param inout_vars list containing vectors of input and output variable
#"      names
usage_chain = function(varname, inout_vars)
{
    uses = sapply(inout_vars, function(used) varname %in% used)

    n = sum(uses)

    # No edges
    if(n <= 1){
        return(integer())
    }

    use_index = which(uses)
    s = seq(n - 1)
    out = shuffle(use_index[s], use_index[s + 1])
    out
}


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

    # A list of ScriptNodeInfo objects. May be useful to do more with
    # these later, so might want to save or return this object.
    info = lapply(script, function(x){
        getInputs(x, collector = inputCollector(checkLibrarySymbols = TRUE))
    })

    n = length(info)

    # Degenerate cases
    if (n == 0){
        return(make_empty_graph())
    }
    if (n == 1){
        # Graph with one node, no edges.
        return(make_graph(numeric(), n = 1))
    }

    in_vars = lapply(info, slot, "inputs")
    out_vars = lapply(info, slot, "outputs")
    inout_vars = mapply(c, in_vars, out_vars)
    vars = unique(unlist(out_vars))

    edges = lapply(vars, usage_chain, inout_vars)

    edges = unlist(edges)

    # Checking if the node labels are correct
    # Problem seems to be that it switches to 0 based indexing when writing
    # to dot
    #edges = as.character(edges)
    #edgemat = matrix(edges, ncol = 2)
    g = make_graph(edges, n = n)
    # Removes multiple edges
    simplify(g)
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


test_that("User defined functions are dependencies", {

    s = readScript(txt = "
    f2 = function() 2
    x = f2()
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

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


test_that("Assignment order respected", {

    s = readScript(txt = "
    x = 1
    x = 2
    y = 2 * x
    ")

    desired = make_graph(c(1, 2, 2, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


} # end tests
