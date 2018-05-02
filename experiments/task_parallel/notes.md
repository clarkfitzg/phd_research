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

Sometimes this runs, sometimes it fails.
I'm not sure what's causing this to behave strangely. 

It might be because one worker tries to read/write from socket before the
other one opens it.

But it makes me think
that I need to checkpoint all the workers before and after the program code
starts running.


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
