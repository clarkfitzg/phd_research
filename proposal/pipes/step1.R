source("readargs.R")

fX = file(INFILE)
open(fX)

s = socketConnection(port = 33000, open = "wb", server = TRUE, timeout = 10, blocking = TRUE)

while(N > 0){

    X_i = scan(fX, what = colclasses, nlines = CHUNKSIZE, quiet = TRUE)
    X_i = data.frame(X_i)
    serialize(X_i, s)
    N = N - CHUNKSIZE

}

close(fX)
close(s)
