# Mon Mar 27 15:18:53 PDT 2017
#
# Given a huge matrix in X.csv file, create a prediction vector and save to
# Y.csv
#
# $ time Rscript predictY.R
# Error in fread(lines) :
#   File '-0.367218074389214,1.94459610074338,0.333589661913799' does not exist. Include one or more spaces to consider the input a system command.
# Execution halted
# 
# real    99m9.778s
# user    96m52.428s
# sys     0m29.096s
#
# This error came from the very last line since fread interpreted a
# character vector of length 1 as a filename. Easy to fix.
#
# > summaryRprof("Y.out")
# $by.self
#                         self.time self.pct total.time total.pct
# "readLines"               2665.90    45.65    2665.90     45.65
# "grepl"                    811.98    13.90     811.98     13.90
# ".Call"                    720.88    12.34     720.88     12.34
# "paste0"                   495.44     8.48     495.44      8.48
# "as.data.frame.numeric"    387.18     6.63     419.66      7.19
# "predict.lm"               364.12     6.23     650.84     11.14
# ".External2"               263.68     4.51     263.72      4.52
# "anyDuplicated.default"     81.84     1.40      81.84      1.40
# "%*%"                       10.88     0.19      10.88      0.19
# 
# $by.total
#                         total.time total.pct self.time self.pct
# "readLines"                2665.90     45.65   2665.90    45.65
# "fread"                    1429.28     24.47      1.34     0.02
# "grepl"                     811.98     13.90    811.98    13.90
# ".Call"                     720.88     12.34    720.88    12.34
# "predict"                   650.98     11.15      0.14     0.00
# "predict.lm"                650.84     11.14    364.12     6.23
# "paste0"                    495.44      8.48    495.44     8.48
# "data.frame"                481.64      8.25      0.84     0.01
# "is_url"                    447.46      7.66      0.06     0.00
#
# Most of the time is spent reading data in.
#
# For comparison:
#
# $ time wc Y.csv
#  999983999   999983999 17807568061 Y.csv
#
#  real    3m47.170s
#  user    3m12.840s
#  sys     0m3.668s


library(data.table)

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
Rprof("Y.out")

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
