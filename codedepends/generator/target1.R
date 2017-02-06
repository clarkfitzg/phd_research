# This does the "right" thing because both cat statements go immediately to
# the screen.
# But unlike normal R this doesn't produce the intermediate variables x1,
# x2, y1, y2. 
# This is good since there's no need to call rm().
# It's bad if the code dependency is more complex, ie. x2 is needed later
# for some operation.

library(future)

plan("multicore")

# start point
n = 10

x3 %<-% {
    cat("1st block\n")
    Sys.sleep(3)
    x1 = rnorm(n)
    x2 = x1 + 5
    x2 + 10
}

y3 %<-% {
    cat("2nd block\n")
    Sys.sleep(3)
    y1 = runif(n)
    y2 = y1 + 7
    y2 - 6
}

# Barrier- code must finish before here.
z = x3 + y3
