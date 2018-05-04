Thu May  3 21:11:36 PDT 2018

I am discovering some very appealing things about sockets.

- A socket acts as a FIFO. Every call to unserialize pops the next R
  object out of the queue. So I don't have to directly manage a queue.
- Writes are asynchronous. After writing an object the worker process may
  continue executing code, which is what the scheduling algorithms assume.
- Writes are delivered even if the sending process completes, which is very
  good. If a worker completes it should be free to terminate.
- Reads are synchronous. Reading from a socket waits until something comes
  through or it reaches the timeout.
- Asynchronous writes and synchronous reads implicitly handle the
  checkpoints in the program.
- There's no event loop to complicate things, we're just running scripts so
  logging can potentially be easier.
- There's less nonstandard evaluation because we're just running scripts

The difficult part is initially setting up connections between all workers,
as I saw below.


TODO: With `blocking = TRUE` they implicitly do the checkpoint, 

TODO: `serialize(..., xdr = FALSE)` for performance.

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

Here I'll implement a task parallel program for this script using sockets:

```{r}
datadir <- '~/data'            # A worker 1
x <- paste0(datadir, 'x.csv')  # B worker 1
y <- paste0(datadir, 'y.csv')  # C worker 2
xy <- paste0(x, y)             # D worker 1
print("all done")              # E worker 2
```


## Intermittent Failures

Wed May  2 22:14:51 PDT 2018

update: Think I figured it out. It's caused by the background process:

```
$ Rscript worker1.R &
```

not finishing. Ie. when I repeatedly run make it eventually happens that
the 2nd script fails, as expected. Then the first one continues to run and
messes up the following run. I can reproduce this with the following code:

```
$ Rscript worker1.R &
  Rscript worker1.R
```

If this theory is correct then I should only see the server fail after the
client fails and leaves a running server. Then the next time the server may
run first, which causes the two servers to collide and both fail. Then the
client should also fail. Or the next time the client may run first, in
which case it connects to the previous server.

Yes, confirmed it. If I start fresh with no R processes running then I only
see the error from the client, which I expect because I didn't synchronize
them. Then I don't get my shell prompt back because the server is still
listening, waiting for timeout.

For whatever reason it's not behaving the same on my Mac.

~~There's also a simple way to get around all of these issues. On every
worker, open all the server side connections first. Then pause to make sure
all processes are ready. Then open all the clients. Only requires a single
pause to get all n workers connected.~~ No. That won't work because a
worker can only open one server socket at a time.

============================================================

Sometimes this runs, sometimes it fails.
I'm not sure what's causing this.

It might be because one worker tries to read/write from the socket before
the other one opens it. Yes, this is a problem for the worker that is not
the server, but it doesn't explain the error when `server = TRUE` as below.

~~Another possibility is that one worker closes the
socket before the other is finished.~~ Nope, OS still delivers the packets
even if the sending process is gone.

- If I open the socket with `server = TRUE` then it waits for an incoming
  connection until the timeout (default 60 seconds) and then gives up.
- If I open the socket with `server = FALSE` and a server is open on that
  socket then it works.
- If I open the socket with `server = FALSE` and a server is NOT open on
  that socket then it fails immediately.

This makes me think that I need to checkpoint all the workers before and
after the program code starts running.

Change error options to dump.frames, add PID, write PID before socket
connection.

```
$ make
Rscript --vanilla worker1.R &
Rscript --vanilla worker2.R
Error in socketConnection(port = PORTS[id, 2], open = "w+", server = TRUE,
:
  cannot open the connection
In addition: Warning message:
In socketConnection(port = PORTS[id, 2], open = "w+", server = TRUE,  :
  port 33003 cannot be opened
Execution halted
Worker 2 ready.
Worker 1 ready.
NULL
NULL
[1] "all done"
[[1]]
NULL

[[2]]
NULL

[[1]]
NULL

Worker 1 finished.
Worker 2 finished.
```
