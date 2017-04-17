args = commandArgs(trailingOnly=TRUE)
CHUNKSIZE = args[1]
N = args[2]
NCOL = 5


# Create the server first, then bind to it.
#s = socketConnection(port = 33000, server = TRUE, timeout = 100)

# Dummy model
set.seed(37)
train = data.frame(matrix(rnorm(50), nrow = 10))
train$y = rnorm(10)
fit = lm(y ~ ., train)

colclasses = list(X1 = 0, X2 = 0, X3 = 0, X4 = 0, X5 = 0)

fX = file("X.txt")
fY = file("Y.txt")
open(fX)
open(fY, "w")

while(N > 0){

    X_i = scan(fX, what = colclasses, n = CHUNKSIZE)
    X_i = data.frame(X_i)
    y = predict(fit, X_i)
    cat(y, fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(fX)
close(fY)
