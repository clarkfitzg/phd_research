Wed May  2 09:46:37 PDT 2018

To do task parallel stuff I need two essential capabilities:

1. Evaluate code asynchronously on a single worker
2. Send a variable from one worker to another

SNOW's user facing API doesn't allow for these, which means I'll need to
use the undocumented, unexported lower level functions in SNOW. Actually, I
don't think this will work at all because SNOW doesn't have a primitive
mechanism in place for worker to worker communication. Only the manager
can communicate with the workers. See the `slaveLoop` function inside the
parallel package. Norm Matloff has set up peer to peer communication in
`partools/R/ptME.R`, ptME stands for "partools message exchange". I read
through the code- just over 100 lines, not a big deal. But it's adding
complexity when all I'm trying to do is static scheduling.

Maybe the easiest way forward is to just use sockets directly. One
advantage of this is that I can open and close the sockets between the
workers as I need them.
