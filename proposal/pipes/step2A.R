source("readargs.R")


# Order of opening sockets is very important here- else the program will
# hang.

while(TRUE){
    try({
        s_in <- socketConnection(port = 33000, open = "rb", timeout = TIMEOUT, blocking = TRUE)
        break
    })
    Sys.sleep(0.01)
}

s_out = socketConnection(port = 33001, open = "wb", server = TRUE, timeout = TIMEOUT, blocking = TRUE)

message("Worker 2 connected")

while(N > 0){

    X_i = unserialize(s_in)
    y_i = predict(fit, X_i)
    serialize(y_i, s_out)
    N = N - CHUNKSIZE

}

close(s_in)
close(s_out)
