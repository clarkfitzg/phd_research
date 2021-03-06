# Mon Jun 11 11:19:27 PDT 2018
# What is required for a file based queue?
#
# The model below works for both files and sockets.

qfile = "q.rds"
system2("touch", qfile)
queue = file(qfile, "r+b")


push = function(obj, q = queue)
{
    serialize(obj, q, xdr = FALSE)
    flush(q)
}


pop = function(q = queue)
{
    unserialize(q)
}


# In practice we would execute all the pushes from one process and all the
# pops from another.

push("hi")

pop()

push(1:10)
push(rnorm)
push("bye")

pop()
pop()
pop()
