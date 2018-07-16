# A little experiment. Does mclapply actually know when nesting
# happens?

f = function(...) lapply(1:2, function(...) Sys.getpid())

# same PID
f()

# same PID
lapply(1:2, f)


# Default
############################################################
lapply = parallel::mclapply

# 2 different PID's
f()

# 4 different PID's
lapply(1:2, f)


# Set recursive to FALSE
############################################################
lapply = function(...) parallel::mclapply(..., mc.allow.recursive = FALSE)

# 2 different PID's
f()

# Only the outermost one is parallelized- good!
lapply(1:2, f)
