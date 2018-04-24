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

# Can I add an attribute?
# Yes. Good.
node0[[1]]$read

attr(node0[[1]]$read, "time") = 500

attr(node0[[1]]$read, "time")

# Will the attribute be there after serialization?
# Yes. Good.
saveRDS(node0, "node0.rds")

node0_fromdisk = readRDS("node0.rds")

attr(node0_fromdisk[[1]]$read, "time")

# How will I represent an edge between arbitrary ASTNode objects?
# First of all, it should be possible, because it's implemented as a 
# tree. Let's check the implementation for $parent

# For example, suppose I want an edge from statement 1 to 3.
#add_edge = function(from, to, ...) list(from = from, to = to, ...)

e = list(from = node0[[1]], to = node0[[3]]$args, type = "def-use", value = "x")


# Can we go in and modify the AST and preserve the graph?
# Basically we would need an update method for each AST node.
# I need to read the R6 docs to get a better idea of the programming model
# here.

# How do I replace this function with a new one?
node0[[3]]$fn

# Doesn't work
#node0[[3]]$fn$name = "foo"


# This shouldn't work, because it doesn't make any sense. Could potentially
# cause trouble if we go to navigate the tree.
childfunc = Symbol$new("min", parent = node0[[3]]$fn)

# I think the missing causes the issue here.
node_apply(node0, print)



# What's this namespace? Presumably to identify symbols inside a namespace
node0[[3]]$fn$namespace

# It might be possible to do algebra on these things. Maybe.
node0$body[[3]]$args[[1]]$args

# Suggestion- represent missing arg object
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


