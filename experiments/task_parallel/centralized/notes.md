# Thu May  3 11:55:21 PDT 2018

What do I need to make this work?

Execute a single command on a single worker. 

From what I can tell Rmpi
doesn't give that to me directly. The closest things look like:
`mpi.bcast.cmd`, which executes on all workers. I could bend it to my
needs, but it's not ideal. `mpi.remote.exec` is similar but worse because
it returns the result.

Then it's better to look at the implementation for `mpi.bcast.cmd` to see
what needs to happen under the hood. It does the following:

On the sender:
1. Serialize the command
2. Loops through and sends to specific workers using 
    `mpi.send(... type = 4, dest = i, tag = 4e4 + i)`

On the receiver:
1. Probes for messages, either with or without blocking
2. Receives the message with `mpi.receive`
2. Unserializes the message
3. Prepares the code for evaluation

On the daemon:
1. Loops through and attempts to evaluate the code produced by `mpi.bcast.cmd`

The daemon calls `mpi.bcast.cmd` constantly. So maybe it's fine to
rely on it to implement everything.

One thing to look out for: Make sure the commands come in order and are all
executed, even if it takes time.
