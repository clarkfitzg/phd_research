library(autoparallel)

tp = task_parallel("getZL.R", runfirst = TRUE)

plot(tp$schedule)

# A single statement is the bottleneck

tp$input_code[[which.max(tp$expr_times)]]

# But this statement executes outside of the function. So I can run it
# before hand.

source("prepare_getZL.R")

b = task_parallel("body_getZL.R", runfirst = TRUE)

plot(b$schedule)

# Now we see statements 3 and 30 are the expensive ones.
# The only way to really speed things up here with task parallelism is to
# run these two simulataneously. And we can't run them simultaneously since
# 3 defines `A` and 30 uses `A`, which makes it a true dependence, 
#
# It might be useful to have a function that says there is no way to get
# anything from task parallelism then.

b$input_code[[3]]

b$input_code[[30]]

# Note gen_getZL.R runs and appears to do the right thing, but
# gen_body_getZL.R does not run, because it
# uses some variables that are defined earlier.
