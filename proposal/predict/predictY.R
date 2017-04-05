# Wed Apr  5 16:06:52 PDT 2017
# Program to run on server with SSD

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

BYTES_PER_NUM = 8L
p = 3L
bytes_per_chunk = 1e6
n_i = as.integer(bytes_per_chunk / (p * BYTES_PER_NUM))

# Testing
#n_i = 5L
#Xfile = file("Xsmall.csv")

Xfile = file("X.csv")
open(Xfile)

# Drop the first line (header)
lines = readLines(Xfile, n = n_i)[-1]

while(length(lines) > 0){
    lines = paste0(lines, collapse = "\n")
    # Inefficient to collapse into one string, but this is most obvious
    # way.
    X_i = fread(lines)
    colnames(X_i) = c("X1", "X2", "X3")
    y_i = predict(fit, X_i)
    y_i = data.frame(y_i)
    fwrite(y_i, "Y.csv", append = TRUE, col.names = FALSE)
    lines = readLines(Xfile, n = n_i)
}

close(Xfile)
