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

deque = readScript(txt = "x = 10")
actual = assign_catcher(deque[[1]])
expected = list(x = 10)
testthat::expect_identical(actual, expected)

y <- FALSE
update_env(list(y = TRUE))
testthat::expect_true(y)

})


# Setup
############################################################

# Expressions that have not yet been evaluated
unevaluated = readScript(txt = "
x = 1
y = x + 1
z = x + 2
")


# Event loop logic
############################################################
SLEEP = 0.01
MAX_TIME = 3

t0 = Sys.time()


# Base case:
job = mcparallel(assign_catcher(unevaluated[[1]]))
active = job$pid
unevaluated = unevaluated[-1]


while(TRUE){
    # The ordering of code in this block is important.
    if(length(unevaluated) == 0 && length(active) == 0){
        message("All done.")
        break
    }

    if(Sys.time() - t0 > MAX_TIME){
        stop("Timed out.")
    }

    Sys.sleep(SLEEP)

    collected = mccollect(wait = FALSE)

    if(is.null(collected)){
        next
    }

    # Update global variables in master
    lapply(collected, update_env, env = .GlobalEnv)

    # update active list
    completed = as.integer(names(collected))
    active = setdiff(active, completed)

    # Set up next evaluation
    if(length(unevaluated) > 0){
        job = mcparallel(assign_catcher(unevaluated[[1]]))
        active = c(active, job$pid)
        unevaluated = unevaluated[-1]
    }
}
