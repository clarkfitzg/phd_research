# Chunk 1
iris = read.csv("iris.csv")

# Chunk 2
l2 = 2 * iris[, "Sepal.Length"]

# Chunk 3
png("hist.png")
hist(l2)
dev.off()
