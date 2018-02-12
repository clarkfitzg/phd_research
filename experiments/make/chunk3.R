l2 = readRDS("data/l2.rds")

# Chunk 3
png("hist.png")
hist(l2)
dev.off()
