# Auto generated
# Mon Feb  6 16:08:24 2017

library(parallel)

n = 10 

mcparallel({
    x1 = rnorm(n)
    x2 = x1 + 5
    x3 = x2 + 10
    list(x3 = x3)
})

mcparallel({
    y1 = rnorm(n)
    y2 = y1 + 5
    y3 = y2 + 10
    list(y3 = y3)
})

# This block represents boilerplate for a barrier
# Or think of it as a fork / join.
############################################################
    collected = mccollect()
    message("Collected.")

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