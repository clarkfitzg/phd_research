# Thu Feb 15 08:33:39 PST 2018
#
# Testing out Nick's SSA

library(rstatic)

# Essentially following one of the tests

node0 = quote_ast({
    x = data.frame(a = 1:10, b = letters[1:10])
    x[, "c"] = rnorm(10)
    sum(x$a)
    head(x)
    x[, "a"]
})

# Can we add arbitrary attributes to the graph?
attr(node0$body[[4]], "time") = Sys.time()

# Yes we can.
attr(node0$body[[4]], "time")

# This works fine
#node0 = quote_ast({
#    x = 1:10
#    x = rnorm(10)
#    sum(x)
#    head(x)
#})

# We can evaluate this.
eval(to_r(node0))

node = to_cfg(node0)

#rstatic:::to_ssa(node)

# Are the attributes still around?
# No, doesn't look like it.
attr(node$body$body[[4]], "time")
attr(node$body$body[[4]]$read, "time")


node$ssa

#nr = to_r(node, use_ssa = TRUE, use_phi = TRUE)
nr = to_r(node)

# Somehow this was converted to a function. I suppose it's fine to think
# about the inside of a brace as a function. But when it goes round trip
# back to R I would expect it to come out as a brace.

f = eval(nr)

f()

# Wed Apr 18 15:03:31 PDT 2018
# How difficult would it be to build the task graph, ie. use-definition
# chains, inside here?

# Well the node for the brace has a slot for ID. It's NA here, and I don't know what
# Nick's plans are for it, but if every object has something that uniquely
# identifies the nodes then I can make a graph out of it.
# I get that "address" in the AST with recursive indexing.

# Can I recursively index into the brace like in the AST?
# No.
#node0[[c(1, 4)]]

node0[[3]]$fn$namespace



# It might be possible to do algebra on these things. Maybe.
node0$body[[3]]$args[[1]]$args

# Might be good to have a missing arg object
node0$body[[5]]$args[[2]]$name


# A simple case of a for loop that should be an apply
forloop = quote_ast(
    for(i in seq_along(x)){
        y[i] = f(x[i])
    }
)

# Essentially I'm going to need a tool like this to infer if a for loop is
# parallel.
forloop$ivar

forloop$body$body
