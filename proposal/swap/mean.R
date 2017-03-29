# Tue Mar 28 11:10:33 PDT 2017
# Gather timings for when data approaches or exceeds memory bounds

MEMORY_GB = 8
SIZE_DOUBLE = 8

frac_memory = seq(from = 0.1, to = 1.5, by = 0.1)
frac_memory = rep(frac_memory, each = 3)
n = frac_memory * MEMORY_GB * 1e9 / SIZE_DOUBLE

# Write as we go in case of crashing
for (i in seq_along(frac_memory)){
    # Triggers garbage collection
    time = system.time({x <- rnorm(n[i]); xbar <- mean(x)}, gcFirst = TRUE)
    output = data.frame(n = n[i], frac_memory = frac_memory[i], time = time["elapsed"])
    write.table(output, "timings.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", frac_memory[i])
}
