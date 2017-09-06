fname = "data.binary"

f = file(fname)

open(f, "wb")

serialize(1:10, f)
serialize(NULL, f)
serialize(1:20, f)

close(f)


f = file(fname)
open(f, "rb")

unserialize(f)


