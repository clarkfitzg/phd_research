# Testing

library(JuliaCall)

# Initialize the Julia interpreter alongside the R one
julia_setup()

# Like R's source(), makes the functions we've defined in test.jl available
# in this session.
julia_source("test.jl")

# Call the julia function named "jfunc" on the vector c(0, 1, 2), and
# return it as an R object.
julia_call("jfunc", c(0, 1, 2), need_return = "R")
