Wed Jan 25 15:09:47 PST 2017

Goal: focus in on a research topic.

In the end it's most likely going to be R based. Julia and Python are
already pretty far ahead with the code acceleration type things.

The general problem that I keep running into is how to split and move
computations and data. This is a hard problem in general, and it's
generally depends on architecture.

## Vecchia

For the Vecchia problem there are a couple tradeoffs to be made. Using more
data points can only possibly improve the statistical error. But using more
points also makes it run slower. So there's speed / accuracy.

There's the problem of the heterogeneous architecture. The CPU and GPU 
can be used simultaneously. So which operations should run on each system?
It depends on the problem. Can I tease out a general pattern from our
experiments? My goal is to pose it as something like an optimization
problem.

Suppose you're working with 32 bit floats and doing elementwise operations
on vectors of length `n`, something like `y = f(x)` that performs `y[i] =
f(x[i])`. If `f` is simple and fast then it won't be worth it to move the
data to the GPU to evaluate it. If `f` is complex and slow then it may
become worth it.

Side note - more generally we could think of each element y[i] as having
some fixed constant size, so each one is a vector like we've been doing
with the Vecchia.

Suppose that `f` has a fairly predictable run time, ie a fixed number of
FLOPS and no branching. We can pose it as an optimization problem like this:

```

minimize runtime = {
    n * f_cpu                             if CPU
    n * (move_x + f_gpu + move_y) + OH    if GPU
}

fixed parameters:
    n = number of data points
    f_cpu = time to call f(x[i]) on CPU
    f_gpu = ""
    move_x = time to move a single x[i] (derived from bandwidth)
    move_y = ""
    OH = time to setup a GPU job

```

This `OH` may be a couple seconds, because the code is being compiled.

I like to have it in the more general form of an optimization rather than
just a choice between the two, because then we can extend it for how to do
the partial sum reduction.
