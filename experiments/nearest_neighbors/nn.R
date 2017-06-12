# Wed Jun  7 09:37:49 PDT 2017

# 141C last homework was to parallelize a version of nearest neighbors
# Let's see what it would take to do it automatically in R

library(parallel)


distance = function(a, b)
    # The Euclidean distance between vectors a and b
{
    sqrt(sum((a - b)^2))
}


nn = function(z, x)
    # Finds the nearest neighbor in x for each row in z
    # Returns a vector of indices
{

    # Pairwise distances for every row of x and z
    # for loop would probably be more clear.
    d = apply(z, 1, function(zrow){
            apply(x, 1, function(xrow){
                      distance(xrow, zrow)
    })})

    apply(d, 2, which.min)
}


nnpar = function(z, x)
    # Fork Parallel version
    #
{

    # I know I'm on a machine that can fork(), so I only pass the indices
    # in as arguments. This beats passing the entire matrix around.
    indices = parallel::splitIndices(nrow(z), 2)
    #force(x)

    # Translate the apply into mclapply
    dl = parallel::mclapply(indices, function(idx){
        d = apply(z[idx, ], 1, function(zrow){
                apply(x, 1, function(xrow){
                          distance(xrow, zrow)
    })})})
    d = do.call(cbind, dl)

    # Didn't use multiprocessing here because I knew this line was fast
    apply(d, 2, which.min)
}


apply_parallel = function(code)
    # Experiment... how to generalize the above translation?
{
    # Split initial data

    # Evaluate in parallel

    # Recombine result

    # Call remainder of code
}

# Test it with the same dimensions as the homework problem
############################################################

set.seed(2793)
dims = c(10000, 109)
x = matrix(rnorm(prod(dims)), ncol = dims[2])
z = matrix(rnorm(prod(1000, dims[2])), ncol = dims[2])

# Takes 45 seconds. Much better than naive Python version
system.time(nbrs <- nn(z, x))

# 25 seconds
system.time(nbrs2 <- nnpar(z, x))
