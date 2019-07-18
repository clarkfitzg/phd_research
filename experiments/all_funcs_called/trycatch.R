library(CodeDepends)

# The problem in tryCatch is that the function `tryCatchList` calls itself- it's recursive.
# But we can figure this out and test for it, because `tryCatchList` is an output.
info = getInputs(tryCatch)
info[[3]]

# Let's make it a minimally reproducible example:

add_123 = function(x){
    add = function(y, ...){
        if(!missing(y)){
            y + add(...)
            #y + Recall(...)  # Alternatively
        } else 0
    }
    add(x, 1, 2, 3)
}

add_123(2)

info = getInputs(add_123)

info[[3]]@functions["add"]  # FALSE, should be TRUE

info[[4]]@functions["add"]  # TRUE, as expected

