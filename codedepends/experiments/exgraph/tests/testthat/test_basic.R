test_that("Basic case with two nodes",
{

    target = graph_from_edgelist(matrix(1:2, nrow = 1), directed = TRUE)
    actual = exgraph("ab.R")

    expect_is(actual, class(target))
    # TODO: check num edges, nodes

})
