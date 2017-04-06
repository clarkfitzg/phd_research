# Wed Apr  5 16:06:52 PDT 2017
# Program to run on server with SSD


# Some example model
set.seed(37)
train = data.frame(matrix(rnorm(30), nrow = 10))
train$y = train[, 1] + train[, 2] + train[, 3] + rnorm(10)
fit = lm(y ~ ., train)

# For in memory data we can do this, which is exactly what we want:
############################################################
#X = read.csv("X.csv", nrows = 10)
#colnames(X) = c("X1", "X2", "X3")
#y = data.frame(predict(fit, X))
#write.table(y, "Y.csv", row.names = FALSE, col.names = FALSE)


# Instead we have to do this, and it's hard to know what the "right" chunk
# size is.
############################################################

predictY = function(n_i, Xfile = "/ssd/clarkf/X.csv", yfile = "/ssd/clarkf/Y.csv"){

    # Start fresh
    unlink(yfile)

    Xfile = file(Xfile)
    open(Xfile)

    lines = readLines(Xfile, n = n_i)

    while(length(lines) > 0){
        X_i = read.table(text = lines, sep = ",", colClasses = rep("numeric", 3))
        colnames(X_i) = c("X1", "X2", "X3")
        y_i = predict(fit, X_i)
        y_i = data.frame(y_i)
        write.table(y_i, yfile, append = TRUE, col.names = FALSE, row.names = FALSE)
        lines = readLines(Xfile, n = n_i)
    }

    close(Xfile)
}


# Test
#predictY(5, "Xsmall.csv", "Ysmall.csv")
