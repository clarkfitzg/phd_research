# Tue Aug  8 10:03:02 PDT 2017
#
# Bernstein's conditions for loop parallelism are essentially:
# 1) iterations don't read what another iteration wrote
# 2) iterations don't write into the same place
#
# R's apply family of funcs can violate the Bernstein conditions, since an
# apply function can be used as a for loop. 

# Violate 1st condition
x = 1:10
sapply(seq_along(x), function(i){
    x[i] <<- x[i] + x[i + 1]
})

# Violate 2nd condition
x = 1:10
sapply(x, function(xi) n <<- xi)

# These are a little contrived- most people know it's bad practice to do
# global assignment within a function. More realistically a function might
# be appending to a file. In this case the order matters, so it violates
# the 2nd condition.

# Then what conditions guarantee the Bernstein conditions
# are met for R's apply family?
#
# - No global assignment to the same place
# - External writes must be to unique files
# - Order of code execution can't affect result => No graphics device updates


# Tue Aug 15 13:19:17 PDT 2017
#
# Reading the vignette for `rlang`, attempting to understand 'quosures'.
# How do they differ from promises?
#
# TODO: Read more on FEXPR's
# https://en.wikipedia.org/wiki/Fexpr
# Claims that they are not as good for static analysis when mixing standard
# function evaluation with FEXPR's. But FEXPR's based on the definition
# look just 

f = function(x)
{
    y = 20
    print(x)
}

# This should fail to find y, because the expression "10 + y" should be
# evaluated in the global environment.
# Indeed that is the case.
f(10 + y)

# We can find out when and where an argument is called
options(error = recover)

f1 = function(x) f2(x)
f2 = function(x) f3(x)
f3 = function(x) mean(x)

f1(stop())
# This stops inside the mean function.

g1 = function(x) g2(x)
g2 = function(x) g3(x)
g3 = function(x) 20

# While this works perfectly fine because the arg is never evaluated.
g1(stop())
