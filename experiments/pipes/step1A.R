source("readargs.R")

fX = file(INFILE)
open(fX)

s_out = socketConnection(port = 33000, open = "wb", server = TRUE, timeout = TIMEOUT, blocking = TRUE)

message("Worker 1 connected")

while(N > 0){

    X_i = scan(fX, what = colclasses, nlines = CHUNKSIZE, quiet = TRUE)
    X_i = data.frame(X_i)
    serialize(X_i, s_out)
    N = N - CHUNKSIZE

}

close(fX)
close(s_out)
