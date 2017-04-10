# Tue Mar 28 13:14:23 PDT 2017
# Take 2, using iotools
#
# Given a huge matrix in X.csv file, create a prediction vector and save to
# Y.csv

# $ time Rscript predictY_iotools.R
# NULL
# 
# real    27m9.552s
# user    19m52.780s
# sys     0m45.928s
# $by.total
#                             total.time total.pct self.time self.pct
# ".Call"                        1231.48     99.96    782.50    63.51
# "chunk.apply"                  1230.52     99.88      0.00     0.00
# "<Anonymous>"                  1198.84     97.31      0.02     0.00
# "write.csv.raw"                 465.36     37.77      0.02     0.00
# "as.output.default"             444.30     36.06      0.02     0.00
# "as.output"                     444.30     36.06      0.00     0.00
# "predict"                       427.92     34.73      0.02     0.00
# "predict.lm"                    427.90     34.73    166.86    13.54
# "dstrsplit"                     306.92     24.91      0.10     0.01
# "model.matrix"                  253.32     20.56      0.04     0.00
# "model.matrix.default"          253.28     20.56      0.04     0.00
# ".External2"                    252.92     20.53    252.92    20.53
# "writeBin"                       20.94      1.70     20.94     1.70

library(iotools)

# Spends about one third of this time predicting from the model. Not much that the IO
# libraries can do about this.
# dstrsplit instantiates the data.frame and reads the data, so the rest of
# the time must be spent writing.


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

predictY = function(n_i, nprocs = 1L, xfile = "/ssd/clarkf/X.csv", yfile = "/ssd/clarkf/Y.csv")
{
    # Start fresh
    unlink(yfile)

    # In bytes
    bytes_per_row = 51
    chunksize = n_i * bytes_per_row

    # There are three floating point numbers. Conservatively, each is no
    # more than 25 characters. Docs say that this determines size of read
    # buffer, not sure how changing this will affect performance
    max.line = 256L

    cols = rep("numeric", 3)
    names(cols) = c("X1", "X2", "X3")

    reader = chunk.reader(xfile, max.line = max.line)

    chunk.apply(reader, function(Xraw){
        X = dstrsplit(Xraw, col_types = cols, sep = ",")
        y = predict(fit, X)
        # Can't seem to get the row names out of here... Oh well.
        write.csv.raw(y, yfile, append = TRUE, sep = ",", nsep = ",", col.names = FALSE)
    }, CH.MAX.SIZE = chunksize, parallel = nprocs)
}
