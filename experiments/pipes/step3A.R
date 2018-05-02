source("readargs.R")

fY = file(OUTFILE)

open(fY, "w")


while(TRUE){
    try({
        s_in <- socketConnection(port = 33001, open = "rb", timeout = TIMEOUT, blocking = TRUE)
        break
    })
    Sys.sleep(0.01)
}

message("Worker 3 connected")

while(N > 0){

    y_i = unserialize(s_in)
    cat(y_i, file = fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(s_in)
close(fY)
