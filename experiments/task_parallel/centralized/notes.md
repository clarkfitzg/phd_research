# Thu May  3 11:55:21 PDT 2018

What do I need to make this work?

Execute a single command on a single worker. 

From what I can tell Rmpi
doesn't give that to me directly. The closest things look like:
`mpi.bcast.cmd`, which executes on all workers. I could bend it to my
needs, but it's not ideal. `mpi.remote.exec` is similar but worse because
it returns the result.

Then it's better to look at the implementation for `mpi.bcast.cmd` to see
what needs to happen under the hood.
