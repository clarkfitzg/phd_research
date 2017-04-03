# Mon Apr  3 09:40:55 PDT 2017
#
# Trying the same experiment with memory mapping

library(bigmemory)

MEMORY_GB = 8
SIZE_DOUBLE = 8

frac_memory = seq(from = 0.1, to = 2, by = 0.1)
frac_memory = rep(frac_memory, each = 3)
n = frac_memory * MEMORY_GB * 1e9 / SIZE_DOUBLE

# We could try to tune this chunk size, but because this operation is
# linear it won't matter.
n_chunk = n[1]

# Write as we go in case of crashing
for (i in seq_along(frac_memory)){
    # Triggers garbage collection
    time = system.time({
        # Probably could do this in parallel.
        ncol = n[i] / n_chunk
        x = filebacked.big.matrix(nrow = n_chunk, ncol = ncol, backingfile = "")
        for (j in seq(ncol)){
            x[, j] = rnorm(n_chunk)
        }
        xbar = biganalytics::mean(x)
    }, gcFirst = TRUE)
    output = data.frame(n = n[i], frac_memory = frac_memory[i], time = time["elapsed"])
    write.table(output, "timings_bigmemory.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", frac_memory[i])
    rm(x)
}
