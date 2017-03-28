# Mon Mar 27 15:18:53 PDT 2017
#
# Given a huge matrix in X.csv file, create a prediction vector and save to
# Y.csv

library(data.table)

# Some example model
set.seed(37)
train = data.frame(matrix(rnorm(30), nrow = 10))
train$y = train[, 1] + train[, 2] + train[, 3] + rnorm(10)
fit = lm(y ~ ., train)

# For in memory data we can do this, which is exactly what we want:
X = read.csv("X.csv", nrows = 10)
colnames(X) = c("X1", "X2", "X3")
y = data.frame(predict(fit, X))
write.table(y, "Y.csv", row.names = FALSE, col.names = FALSE)


# Instead we have to do this:

# Start fresh
unlink("Y.csv")
Rprof("Y.out")

BYTES_PER_NUM = 8L
p = 3L
bytes_per_chunk = 1e6
n_i = as.integer(bytes_per_chunk / (p * BYTES_PER_NUM))

# Just testing: TODO: currently isn't doing correct thing!
# Reading from a file and keeping the connection open. I'll bet that
# iotools works better for this.
f = file("Y.csv")
l1 = paste0(readLines(f, n = 5), collapse = "\n")
y1 = fread(l1)
l2 = paste0(readLines(f, n = 5), collapse = "\n")
y2 = fread(l2)
close(f)
