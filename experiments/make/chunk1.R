iris = read.csv("iris.csv")

saveRDS(iris[, "Sepal.Length"], "data/iris/Sepal.Length.rds")
