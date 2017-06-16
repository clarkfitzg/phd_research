# Fri Jun 16 15:35:27 PDT 2017
# Can I serialize multiple R objects to a single file?

# What I see here is just like the serializiation over sockets. Simpler
# just using the serialize function.

fname = "data.binary"

f = file(fname)

open(f, "wb")

serialize(1:10, f)
serialize(1:20, f)

close(f)


f = file(fname)
open(f, "rb")

# Each call brings one element in, then gives error reading from connection
# when I'm at the end. So how do I tell if I'm at the end? Just check for
# the error I suppose.
unserialize(f)

close(f)


f = file(fname)
open(f, "wb")

x = 1:10
y = 1:20

save(x, file = f)
save(y, file = f)

close(f)


f = file(fname)
open(f, "rb")

# Each call brings one element in
load(f)

close(f)


