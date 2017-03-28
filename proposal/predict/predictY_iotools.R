# Tue Mar 28 13:14:23 PDT 2017
# Take 2, using iotools
#
# Given a huge matrix in X.csv file, create a prediction vector and save to
# Y.csv

# Some example model
set.seed(37)
train = data.frame(matrix(rnorm(30), nrow = 10))
train$y = train[, 1] + train[, 2] + train[, 3] + rnorm(10)
fit = lm(y ~ ., train)

# For in memory data we can do this, which is exactly what we want:
############################################################
X = read.csv("X.csv", nrows = 10)
colnames(X) = c("X1", "X2", "X3")
y = data.frame(predict(fit, X))
write.table(y, "Y.csv", row.names = FALSE, col.names = FALSE)


# Instead we have to do this, and it's hard to know what the "right" chunk
# size is.
############################################################

# Start fresh
unlink("Y.csv")
Rprof("Y_iotools.out")

library(iotools)

reader = chunk.reader("Xsmall.csv")
binchunk = read.chunk(reader)
cols = rep("numeric", 3)
names(cols) = c("X1", "X2", "X3")

y = predict(fit, X)

# Can't seem to get the row names out of here... Oh well.
write.csv.raw(y, "Ysmall.csv", append = TRUE, sep = ",", nsep = ",", col.names = FALSE)


chunk.apply("Xsmall.csv", function(Xraw)
