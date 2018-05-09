library(microbenchmark)

con = socketConnection(port = 33000, server = FALSE, blocking = TRUE, open = "w+")

# 90 microseconds in text mode
# 12 microseconds in binary mode
microbenchmark(serialize(1L, con))

# 54 microseconds in text mode
# 8 microseconds in binary mode
microbenchmark(serialize(1L, con, xdr = FALSE))

onemb = seq(2^20/4)
print(object.size(onemb), units = "MB")

serialize(onemb, con, xdr = TRUE)




# Takes about 4 seconds to serialize 1MB? That seems crazy.
microbenchmark(serialize(onemb, con, xdr = FALSE), times = 10L)
# And the result is the same for generated code- about 44 seconds to
# serialize 10 MB.

# Does it take that long for parallel package?
library(parallel)

cls = makeCluster(2L, "PSOCK")

# No, takes 5 ms to send to both of them.
# I don't get it. SNOW uses this same method under the hood.
# Could it be the range of ports and some underlying issue in the system?
system.time(clusterExport(cls, "onemb"))

clusterEvalQ(cls, print(object.size(onemb)))

# Here's the difference between the two:

# SNOW:

# > cls[[1]]$con
# A connection with
# description "<-localhost:11540"
# class       "sockconn"
# mode        "a+b"
# text        "binary"
# opened      "opened"
# can read    "yes"
# can write   "yes"

# Mine:

# > con
# A connection with
# description "->localhost:33000"
# class       "sockconn"
# mode        "w+"
# text        "text"
# opened      "opened"
# can read    "yes"
# can write   "yes"

# So mine is text mode. Which is crazy.

con = socketConnection(port = 33000, server = FALSE, blocking = TRUE, open = "a+b")

microbenchmark(serialize(onemb, con, xdr = FALSE))
