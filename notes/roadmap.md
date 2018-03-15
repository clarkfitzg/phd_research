Thu Mar 15 10:51:29 PDT 2018

This is to summarize the idea of statically analyzing an entire general R script to
incorporate what we might call "fork-join" parallelism. We start with a script
and build it into something that uses the most parallelism it can.
The audience is someone familiar with R and parallelism, ie. Norm Matloff.

There are a few components or layers of complexity to this.

1. Represent the execution dependency order in the script as a DAG.
2. Rewrite the code / change the computations
3. Minimizing data transfer
4. Revisit intermediate data on worker nodes

This automatic approach differs from the conventional approach to
parallelism. With the conventional approach the user writes according to an
API with an associated mental model of how the parallelism should work. It
assumes that the user knows when the right time to parallelize is. This
isn't too hard if the slow running code is just an `lapply` and we can
simply swap in the `parallel::mclapply`. But task parallelism isn't on most
people's radar.

## Global Variables

## Systems

## Overhead

These are some approximate times for the overhead to do various operations
related to process parallelism.

Time (seconds)   | Operation
--------|----------
10^-4   | eval code on existing worker in same machine
TODO    | eval code on existing worker in different machine in same server rack
10^-3   | process fork    
10^-1   | run `Rscript` from bash

## Locks

Forcing threads to rendezvous can be seen as a form of concurrency lock.

## Data Size

To come up with a reasonable scheduling algorithm we need to estimate the
time required to evaluate each expression. Possibly more importantly, we also
need to know how large the result is so that we can estimate how long it
will take to transfer the result between processes. We can also use the
data sizes to determine which thread of execution should be the manager and
which should be the worker.

For example, in the code below 

```{R}
# Expression 1 produces a large amount of data
x = rnorm(1e7L)
y = rnorm(1)
z = x + y
```

## Scratch

Actually the revisiting data idea might be very helpful on a GPU.

The only difference between these two examples is that one is eagerly
evaluated, and one is lazily evaluated:

```{R}
# Example 1:
h(f(), g())

# Example 2:
a = f()
b = g()
h(a, b)
```

If the parallelism happens only at the expression level then we can get the
parallelism for Example 2, but not for Example 1. We could expand this
recursively by examining the bodies of these functions
