# Mon Mar  6 12:00:20 PST 2017
# All of this probably only works with simple global assignment, not fancier
# things like <<-


library(CodeDepends)
library(parallel)


#" Return Assignments Made In Expression As List
assign_catcher = function(expr)
{
    output = new.env()
    eval(expr, envir = output)
    as.list(output)
}


#" Update Environment Variables With Named List
update_env = function(updates, env = parent.frame()){
    for(varname in names(updates))
    {
        assign(varname, updates[[varname]], envir = env)
    }
}


testthat::test_that("Event loop helpers",{

y <- 20
actual = assign_catcher(quote(x <- 10))
expected = list(x = 10)
testthat::expect_identical(actual, expected)

y <- FALSE
update_env(list(y = TRUE))
testthat::expect_true(y)

})


############################################################


s = readScript(txt = "
x = 2
y = x + 3
")

for(expr in s){
    mcparallel(assign_catcher(expr))
}


job1 = mcparallel(ls())

#job2 = mcparallel({Sys.sleep(10); 2})

mccollect(wait = FALSE)


