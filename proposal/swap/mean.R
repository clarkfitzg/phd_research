# Tue Mar 28 11:10:33 PDT 2017
# Gather timings for when data approaches or exceeds memory bounds

MEMORY_GB = 8
SIZE_DOUBLE = 8

frac_memory = c(0.1, 

for (n_i in alln){
    frac_memory = n_i * SIZE_DOUBLE / (MEMORY_GB * 1e9)
    # Triggers garbage collection
    time = system.time({x <- rnorm(n); xbar <- mean(x)})
    output = data.frame(n = n_i, frac_memory, time)
    write.table(output, "timings.csv", append = TRUE)
}
