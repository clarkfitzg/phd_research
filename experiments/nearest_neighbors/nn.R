# Wed Jun  7 09:37:49 PDT 2017

# 141C last homework was to parallelize a version of nearest neighbors
# Let's see what it would take to do it automatically in R


distance = function(a, b)
    # The Euclidean distance between vectors a and b
{
    sqrt(sum((a - b)^2))
}


nn = function(z, x)
    # Finds the nearest neighbor in x for each row in z
    # Returns a vector of indices
{

    # Nested apply could probably be more clearly expressed as a for loop
    d = apply(z, 1, function(zrow){
            apply(x, 1, function(xrow){
                      distance(xrow, zrow)
    })})

    apply(d, 2, which.min)
}


# Test it with the same dimensions as the homework problem
############################################################

set.seed(2793)
dims = c(10000, 109)
x = matrix(rnorm(prod(dims)), ncol = dims[2])
z = matrix(rnorm(prod(1000, dims[2])), ncol = dims[2])

# Takes 60 seconds. Much better than naive Python version
system.time(nbrs <- nn(z, x))
