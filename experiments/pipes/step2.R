source("readargs.R")

fY = file(OUTFILE)
open(fY, "w")

while(TRUE){
    try({
        s <- socketConnection(port = 33000, open = "rb", timeout = TIMEOUT, blocking = TRUE)
        break
    })
    Sys.sleep(0.01)
}

while(N > 0){

    X_i = unserialize(s)
    y = predict(fit, X_i)
    cat(y, file = fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(s)
close(fY)
