# Thu Mar  2 16:52:31 PST 2017
#
# Playing around with parallel low level functions to see how I can manage
# an event loop.

library(parallel)

#child = parallel:::mcfork()

# So this could be the selector in the event loop
# parallel:::selectChildren()

job1 = mcparallel({Sys.sleep(5); 1})
job2 = mcparallel({Sys.sleep(10); 2})

# But better to stay with the higher level constructs
mccollect(wait = FALSE)

# Then have to handle all different cases here, also multiple results
# available on mccollect.

# > mccollect(wait = FALSE)
# NULL
# 
# > mccollect(wait = FALSE)
# $`25958`
# [1] 1
# 
# > mccollect(wait = FALSE)
# $`25958`
# NULL
# 
# > mccollect(wait = FALSE)
# NULL
# 
# > mccollect(wait = FALSE)
# $`25959`
# [1] 2
# 
# > mccollect(wait = FALSE)
# $`25959`
# NULL
# 
# > mccollect(wait = FALSE)
# NULL
# 
