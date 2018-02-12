sl = readRDS("data/iris/Sepal.Length.rds")

l2 = 2 * iris[, "Sepal.Length"]

saveRDS(l2, "data/l2.rds")
