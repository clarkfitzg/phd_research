library(microbenchmark)

con = socketConnection(port = 33000, server = TRUE, blocking = TRUE, open = "w+")

x <- unserialize(con)

# 5 microseconds when xdr = TRUE
# 4 microseconds when xdr = FALSE
microbenchmark(x <- unserialize(con), times = 10)
