source("predictY.R")

n = as.integer(c(100, 200, 500, 1000, 3000, 10000, 100000))

# Write as we go in case of crashing
lapply(n, function(n_i){
    time = system.time({predictY(n_i)})
    output = data.frame(n = n_i, time = time["elapsed"])
    write.table(output, "chunktimings.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", n_i)
})
