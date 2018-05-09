library(microbenchmark)

con = socketConnection(port = 33000, server = FALSE, blocking = TRUE, open = "w+")

# About 90 microseconds to serialize
microbenchmark(serialize(1L, con))

# About 54 microseconds
microbenchmark(serialize(1L, con, xdr = FALSE))

onemb = seq(2^20/4)
print(object.size(onemb), units = "MB")

serialize(onemb, con, xdr = TRUE)

# Takes about 4 seconds to serialize 1MB? That seems crazy.
microbenchmark(serialize(onemb, con, xdr = FALSE), times = 10L)

# Does it take that long for parallel package?
library(parallel)

cls = makeCluster(2L, "PSOCK")

# No, takes 5 ms to send to both of them.
# I don't get it. SNOW uses this same method under the hood.
# Could it be the range of ports and some underlying issue in the system?
system.time(clusterExport(cls, "onemb"))

clusterEvalQ(cls, print(object.size(onemb)))
