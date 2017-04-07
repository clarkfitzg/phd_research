source("predictY_iotools.R")

n = as.integer(c(100, 200, 500, 1000, 3000, 10000, 100000))

# Do the faster ones first :)
n = rev(n)

nprocs = 2

# Write as we go in case of crashing
lapply(n, function(n_i){
    time = system.time({predictY(n_i, nprocs)})
    output = data.frame(n = n_i, nprocs = nprocs, time = time["elapsed"])
    write.table(output, "timings_iotools.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", n_i)
})
