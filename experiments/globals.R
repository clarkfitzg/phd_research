library(globals)

#loop_body = quote(for (i in seq(n)){
loop_body = quote({
        tmp = foo()
        y[[i]] = tmp
})

# I want to see the variable `y` as a global variable, but not `tmp`

names(globalsOf(loop_body, method = "ordered", mustExist = FALSE))

names(globalsOf(loop_body, method = "conservative", mustExist = FALSE))

names(globalsOf(loop_body, method = "liberal", mustExist = FALSE))

