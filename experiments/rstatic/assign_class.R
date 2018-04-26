# Feedback for Nick- I actually prefer the way R's AST represents this.
# rstatic does the dispatching that makes it more difficult to do what I
# want:

e = quote(x[i] <- f(4))
# > a[[1]]
# `<-`
# > a[[2]]
# x[1]
# > a[[3]]
# f(4)

names(e) = c("class", "lhs", "rhs")

# This behavior is kind of nice.
e$lhs

# How difficult is it to apply some of rstatic's extraction operators to
# objects in the language?
`$.<-` = function(x, name)
{
    i = switch(name, write = 2, read = 3)
    x[[i]]
}

#`$<-.<-` = function(x, name)

e[[2]]

# fails to dispatch on class
e$write

# TRUE
class(e) == "<-"

# Explicitly assign
class(e) = class(e)

# Now it works
e$write



