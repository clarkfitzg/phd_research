s = socketConnection(port = 33000, open = "rb", timeout = 60L, blocking = TRUE)

system.time(out <- unserialize(s))

object.size(out)


f = fifo("test.fifo", open = "rb", blocking = TRUE)

system.time(out <- unserialize(f))
