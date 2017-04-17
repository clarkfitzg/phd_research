args = commandArgs(trailingOnly=TRUE)
CHUNKSIZE = args[1]
N = args[2]


# Create the server first, then bind to it.
s = socketConnection(port = 33000, server = TRUE, timeout = 100)

f = file("X.csv")
open(f)

