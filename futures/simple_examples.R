# Mon Jan 16 11:03:39 PST 2017
# Experiments with the futures package

library("future")

slow_add = function(x, sleep = 2)
{
    Sys.sleep(sleep)
    x + 1
}


plan(multicore, workers = 3)

# Both blocks can execute at the same time.
# Let's check to see if they do.

a1 %<-% slow_add(1)
b1 %<-% slow_add(a1)
c1 %<-% slow_add(b1)

a2 %<-% slow_add(1)
b2 %<-% slow_add(a2)
c2 %<-% slow_add(b2)

# Hmmm sourcing this script takes 9 seconds. I expected it to take either 6
# or 12.
