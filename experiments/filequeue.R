# Mon Jun 11 11:19:27 PDT 2018
# What is required for a file based queue?
#
# The model below works for both files and sockets.


queue = file("q.rds", "w+b")


push = function(obj, q = queue)
{
    serialize(obj, q, xdr = FALSE)
}


pop = function(q = queue)
{
    unserialize(q)
}


# In practice we would execute these from different processes.

push("hi")

pop()

push(1:10)
push(rnorm)
push("bye")

pop()
