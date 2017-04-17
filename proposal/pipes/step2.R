source("readargs.R")

fY = file(OUTFILE)
open(fY, "w")

s = socketConnection(port = 33000, timeout = 100)

while(N > 0){

    X_i = unserialize(s)
    y = predict(fit, X_i)
    cat(y, file = fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(s)
close(fY)
