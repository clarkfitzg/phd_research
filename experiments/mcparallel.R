# Mon May 28 10:07:00 PDT 2018
#
# What does mcparallel do?
# Can we nest calls to it?
#
# Seems like yes, no problem

library(parallel)

hi = function() sprintf("Hello from %i", Sys.getpid())

hi()

j = mcparallel(hi())

mccollect(j)


# Single level of nesting works fine.

job = mcparallel({
    job2 = mcparallel(hi())
    list(hi(), mccollect(job2))
})

mccollect(job)


# Double layer of nesting

job = mcparallel({
    job2 = mcparallel({
        job3 = mcparallel(hi())
        list(hi(), mccollect(job3))
    })
    list(hi(), mccollect(job2))
})

mccollect(job)


# How much overhead?
# About 4 ms on my Mac.
times = microbenchmark::microbenchmark({job = mcparallel("hi")
    mccollect(job)}, times = 10L)


# What happens if we nest calls to mclapply?

f = function(...) mclapply(1:3, function(...) Sys.getpid())

# We see two distinct PID's each time this is called, as expected.
f()

# To avoid nested parallelism we only want to see one unique PID in each
# list. Therefore I should only replace the outermost lapply.
nested = mclapply(1:4, f)

# How feasible is defining
# lapply = parallel::mclapply?
# The issue is nested parallelism
mclapply(1:3, function(...) getOption("mc.cores"))
