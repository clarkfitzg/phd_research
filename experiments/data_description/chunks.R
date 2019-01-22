chunk_size = 1e3

set.seed(130)
x1 = runif(chunk_size)
x2 = runif(chunk_size)

saveRDS(x1, "x1.rds")
saveRDS(x2, "x2.rds")
