# Thu Mar 30 16:46:00 PDT 2017
# Gather timings for when data approaches or exceeds memory bounds
#
# Running this on "fingers" server, which has an entire SSD for
# swap. Lets not use the whole thing!!

MEMORY_GB = 32
SIZE_DOUBLE = 8

frac_memory = seq(from = 0.1, to = 2, by = 0.1)
frac_memory = rep(frac_memory, each = 3)
n = frac_memory * MEMORY_GB * 1e9 / SIZE_DOUBLE

# Write as we go in case of crashing
for (i in seq_along(frac_memory)){
    # Triggers garbage collection
    time = system.time({x <- rnorm(n[i]); xbar <- mean(x)}, gcFirst = TRUE)
    output = data.frame(n = n[i], frac_memory = frac_memory[i], time = time["elapsed"])
    write.table(output, "timings_ssd.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", frac_memory[i])
    rm(x)
}
