Fri Dec  1 11:31:35 PST 2017


## General techniques

Given some existing implementation in code, how can we accelerate it?
To make code fast, I would first profile it, and then take these steps in
this order:

1. Ensure the code doesn't do anything crazy, such as computing the same
   value many times.
1. Use the right algorithm / data structure. For example, a hash table
   works for key value lookups if there is enough data. 
2. Run the code in parallel.
3. Compile / rewrite using a more efficient language.

The first two are in some sense fundamental errors. Some we can detect,
some we can't.

In R, hopefully we're delegating expensive computational tasks to a well
written underlying implementation. This is a common case. Then we don't get
any speed from the last one.

This leaves running the code in parallel as the only option for speedup.


## Parallel techniques

How can we actually make code run in parallel?

__Map Reduce__ means doing the same operation to different data
simultaneously. It is the most common paradigm when programming with large
data sets. It's also simple, which is nice. This is basically R's `lapply`.
Furthermore, most vectorized functions in R can be parallel map operations.

__Task Parallelism__ means doing different operations to different data
simultaneously, ie. we can run `f(x)` and `g(y)` at the same time, and
gather the results together later. There are a few systems based on this
idea, but it can be achieved in R with `parallel::mcparallel()` followed
later by `mccollect()`.

__Pipeline Parallelism__ means something like an assembly line. We pipe the
result of one command into another. The only place I've seen this used
seriously in R is the iotools package. I've done experiments passing binary
data between processes over sockets. This worked surprisingly well, ie. I
got a 2x speedup with two processes. It only works if there is a stream of
the same data, and each step in the pipeline takes about the same time.

The pipeline model may make more sense when we're streaming through data
that's too large to fit in memory. Indeed, I think that's how iotools is
meant to be used. But it could also be used with `stdin` to pipe data between
different programming languages, which is pretty cool.


## Representing these

The three parallel techniques are basically all I'm aware of.
Then how can I identify and use them in code?

Data flow is really the most important concept here.

Pipelines show up naturally in composed functions, ie:

```{R}

n = 10
mean(abs(seq(-n, n)))

# We could even use the pipe in code:
library(magrittr)
seq(-n, n) %>% abs() %>% mean()

```

This can also be written as a map reduce, or as pipeline parallelism nested
inside a map reduce. It can't be written with task parallelism.
