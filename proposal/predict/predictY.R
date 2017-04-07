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

# So textConnection has killed us here
# 
# > summaryRprof("predictY_prof.out")
# $by.self
#                         self.time self.pct total.time total.pct
# "textConnection"           103.26    98.17     103.26     98.17
# "readLines"                  1.18     1.12       1.18      1.12
# "scan"                       0.30     0.29       0.30      0.29
# ".External2"                 0.26     0.25       0.26      0.25
# "predict.lm"                 0.12     0.11       0.26      0.25
# "data.frame"                 0.04     0.04       0.06      0.06
# "anyDuplicated.default"      0.02     0.02       0.02      0.02
# 
# $by.total
#                         total.time total.pct self.time self.pct
# "predictY"                  105.18    100.00      0.00     0.00
# "read.table"                103.56     98.46      0.00     0.00
# "textConnection"            103.26     98.17    103.26    98.17
# "readLines"                   1.18      1.12      1.18     1.12
# "scan"                        0.30      0.29      0.30     0.29
# ".External2"                  0.26      0.25      0.26     0.25
# "predict.lm"                  0.26      0.25      0.12     0.11
# "predict"                     0.26      0.25      0.00     0.00
# "model.matrix"                0.14      0.13      0.00     0.00
# "model.matrix.default"        0.14      0.13      0.00     0.00
# "write.table"                 0.12      0.11      0.00     0.00
# "data.frame"                  0.06      0.06      0.04     0.04
# "anyDuplicated.default"       0.02      0.02      0.02     0.02
# "anyDuplicated"               0.02      0.02      0.00     0.00
# "as.data.frame"               0.02      0.02      0.00     0.00
# "as.data.frame.numeric"       0.02      0.02      0.00     0.00
# 
# $sample.interval
# [1] 0.02
# 
# $sampling.time
# [1] 105.18
# 
