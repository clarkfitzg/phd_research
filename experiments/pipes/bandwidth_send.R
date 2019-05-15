# What is the bandwidth for communicating between two R processes on the same machine?

s = socketConnection(port = 33000, open = "wb", server = TRUE, timeout = 60, blocking = TRUE)

serialize("hello", s, xdr = FALSE)


oneGB = as.numeric(seq(as.integer(2^30/8)))

print(object.size(oneGB), units = "GB")


# It takes 2.4 seconds to get to the other process.
# Interesting observation - the communication is not asynchronous once the data is beyond a certain size.
# That is, the sending process does not return from `serialize` until the receiving worker begins to consume the data.
# This means that there is some limit to how much data I can put in the networking buffer, as I expected.

# The bandwidth is around 0.4 GB / second on my Mac.
# I wonder if this is for the whole machine, or just a pair of processes?
# I wonder if it uses TCP/IP, or the more efficient UNIX domain sockets?
# https://lists.freebsd.org/pipermail/freebsd-performance/2005-February/001143.html
1 / 2.4

# The xdr option doesn't change the time it takes

system.time(
    serialize(oneGB, s, xdr = FALSE)
)

# Just for kicks, how long does a copy take?
system.time(
    oneGB[1] <- pi
)


