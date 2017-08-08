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
