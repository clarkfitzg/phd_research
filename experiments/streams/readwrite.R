fname = "data.binary"

f = file(fname)

open(f, "wb")

open(f, "r+b")

serialize(1:10, f)
serialize(NULL, f)
serialize(1:20, f)

close(f)


