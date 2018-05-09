library(microbenchmark)

#con = socketConnection(port = 33000, server = TRUE, blocking = TRUE, open = "w+")

con = socketConnection(port = 33000, server = TRUE, blocking = TRUE, open = "a+b")

x <- unserialize(con)

# 5 microseconds in text mode when xdr = TRUE
# 4 microseconds in text mode when xdr = FALSE
# 1.3 microseconds in binary mode when xdr = FALSE
# 1.3 microseconds in binary mode when xdr = TRUE
microbenchmark(x <- unserialize(con))
