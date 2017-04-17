source("readargs.R")

s = socketConnection(port = 33000, timeout = 100)

fY = file(OUTFILE)
open(fY, "w")

while(N > 0){

    X_i = unserialize(s)
    y = predict(fit, X_i)
    cat(y, file = fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(s)
close(fY)
