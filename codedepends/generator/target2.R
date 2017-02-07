# Mon Feb  6 11:39:59 PST 2017
# This only finds n because it forks
#
# From the forked environments we can pull out just the variables that we
# need. I don't see how `future` can help us if we need to pull out more
# than a single variable.
#
# This probably resembles what `future` does internally.
#
# This way of writing the code shows that it may be beneficial to keep
# these processes around, along with their intermediate variables. If we
# can refer back to x1 in the original process for a later computation this
# may be very handy.


library(parallel)

# start point
n = 10


mcparallel({
    cat("1st block\n")
    Sys.sleep(1)
    x1 = rnorm(n)
    x2 = x1 + 5
    x3 = x2 + 10
    # The variables that we wanted in the global scope
    # Generalization keeping multiple variables:
    #list(x1 = x1, x3 = x3)
    list(x3 = x3)
})


mcparallel({
    cat("2nd block\n")
    Sys.sleep(1)
    y1 = runif(n)
    y2 = y1 + 7
    y3 = y2 - 6
    list(y3 = y3)
})


# This block represents boilerplate for a barrier
# Or think of it as a fork / join.
############################################################
    collected = mccollect()
    message("Collected.\n")

    # Pull these objects into the global environment
    for(process in collected)
    {
        for(varname in names(process))
        {
            assign(varname, process[[varname]], envir = .GlobalEnv)
        }
    }
############################################################


z = x3 + y3
