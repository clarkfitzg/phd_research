library(globals)

loop = quote(for (i in seq(n)){
        tmp = foo()
        y[[i]] = tmp
})

# I want to see the variable `y` as a global variable, but not `tmp`

names(globalsOf(loop, method = "ordered", mustExist = FALSE))

names(globalsOf(loop, method = "conservative", mustExist = FALSE))

names(globalsOf(loop, method = "liberal", mustExist = FALSE))
