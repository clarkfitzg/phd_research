#args = commandArgs(trailingOnly=TRUE)
args = strsplit("1000 2000000 5 X.txt Y2.txt", " ")[[1]]

CHUNKSIZE = as.integer(args[1])
N =         as.integer(args[2])
NCOL =      as.integer(args[3])
INFILE =    args[4]
OUTFILE =   args[5]


# Dummy model
set.seed(37)
train = data.frame(matrix(rnorm(NCOL * NCOL * 2), nrow = NCOL * 2))
train$y = rnorm(NCOL * 2)
fit = lm(y ~ ., train)

colclasses = as.list(rep(0.0, NCOL))
names(colclasses) = paste0("X", seq.int(NCOL))
