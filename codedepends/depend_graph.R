# Thu Feb 23 09:56:02 PST 2017

library(CodeDepends)
library(igraph)


#" Create a single edge from the most recent output less than i, to i
one_edge = function(i, output)
{
    if(i == output[1]){
        # Don't count the first one
        return(integer())
    }
    src = tail(output[i > output], 1)
    c(src, i)
}


#" Variable Use Edge Graph
#" 
#" A vector of edges specifying constraints on evaluation order.
#" Output is suitable for use with \code{\link[igraph]{make_graph}}.
#" 
#" @param varname variable name
#" @param used_vars list containing variable names used in each expression
#" @param out_vars list containing variable names defined in each expression
vargraph = function(varname, used_vars, out_vars)
{
    used = which(sapply(used_vars, function(used) varname %in% used))
    output = which(sapply(out_vars, function(out) varname %in% out))

    n = length(used)

    edges = integer()

    # No edges
    if(n <= 1){
        return(edges)
    }

    # Build edges up iteratively
    # This could be more efficient. Fix when it becomes a problem.
    for(i in used){
        edges = c(edges, one_edge(i, output))
    }
    edges
}


#" c(1, 2, 3) becomes c(1, 1, 1, 2, 1, 3)
shuffle = function(x, y)
{
    as.vector(rbind(x, y))
}


#" Add Source Node To Graph
#"
#" Add a source node with index 0 for each node without parents, return resulting graph.
add_source_node = function(g)
{
    incoming = as_adj_list(g, "in")
    noparents = which(sapply(incoming, function(x) length(x) == 0))
    edges = shuffle(1, noparents)
    add_edges(g, edges)
}


#" Expression Dependency Graph
#"
#" Create a DAG representing a set of expression dependencies.
#" I'm not yet trying to take the minimal set of such dependencies, because
#" it's not clear that this is necessary.
#"
#" @param script as returned from \code{\link[CodeDepends]{readScript}}
depend_graph = function(script, add_source = FALSE)
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
    update_vars = lapply(info, slot, "updates")

    assign_vars = mapply(c, out_vars, update_vars)
    used_vars = mapply(c, in_vars, out_vars, update_vars)
    vars = unique(unlist(out_vars))

    edges = lapply(vars, vargraph, used_vars, assign_vars)

    edges = unlist(edges)

    if(add_source){
        g = make_graph(edges + 1, n = n + 1)
        g = add_source_node(g)
    } else {
        g = make_graph(edges, n = n)
    }

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


test_that("Chains not too long", {

    s = readScript(txt = "
    x = 1:10
    plot(x)
    y = 2 * x
    ")

    desired = make_graph(c(1, 2, 1, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})



test_that("updates count as dependencies", {

    s = readScript(txt = "
    x = list()
    x$a = 1
    x$b = 2
    ")

    desired = make_graph(c(1, 2, 2, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Can add source node", {

    s = readScript(txt = "
    x = 1
    plot(1:10)
    ")

    desired = make_graph(c(1, 2, 1, 3))
    actual = depend_graph(s, add_source = TRUE)

    expect_samegraph(desired, actual)

})


# Want edge from 37 -> 38
#    [[37]]
#    shock2 = linefactory(slope2, x2, firstcar(x2))
#
#    [[38]]
#    x3 = optimize(function(x) abs(shock2(x) - nojam(x)), interval = c(0.03,
test_that("Anonymous user functions ", {

    s = readScript(txt = "
    f = function(
    plot(1:10)
    ")

    desired = make_graph(c(1, 2, 1, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})




} # end tests
