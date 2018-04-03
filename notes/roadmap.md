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

The big difference here is that the system _assumes_ we can look at a whole
script ahead of time, and execute it any way we like as long as we
guarantee we're going to get the same answer.

It's interesting beceause R wasn't designed to work like this. We're
experimenting with the language as an object, to see what we can produce
with it by relaxing the evaluation model.

## From other write up


Compilers have used all manners of static analysis and
intermediate optimizations to create more efficient code. Interpreted
languages are much more limited in this respect. This project explores
the use of an alternative evaluation model to improve performance while
preserving language semantics.

The evaluation model for interpreted languages is simple. Each
expression of code is evaluated in the order that it appears in a text file. Informally
each expression is a line of code. This can be
viewed as a set of constraints on the evaluation order of the expressions:

1. expression 1 executes before expression 2
2. expression 2 executes before expression 3
3. ...

What if these constraints are relaxed? Suppose expression 1 defines the variable
`x`, which is not used until expression 17. Then one has the
constraint:

1. expression 1 executes before expression 17

This can be generalized into a directed graph which we'll refer to here as
the __expression dependency graph__ by considering expressions as
nodes and constraints as edges. The edges are implicit based on the order
of the statements in the code. Add an edge from $i \rightarrow k$ if
expression $k$ depends on the execution of expression $i$.  It's safe to
assume $i < k$, because expressions appearing later in a program can't
affect expressions which have already run. Hence the expression graph is
acyclic, i.e. a DAG.

Scheduling execution based on the expression graph allows some expressions to execute in
parallel. For example, the following adjacent lines are independent, so
they can be computed simultaneously:

\begin{verbatim}
sx = sum(x)
sy = sum(y)
\end{verbatim}

Mathematically, the standard evaluation model is a total ordering on the
set of expressions in the code. The dependency graph is a partial ordering.

## Visualization

This graph that I've described is begging for a visualization. I'm thinking
of an interactive DAG where when you click on the node you see the code
that it runs, and when you click on an edge you see the variables that it
uses from previous expressions. We could even do the width of the edges
based on the size of the variables- in some sense that would indicate what
the main thread of execution should be, because if there was just one chain
of creating and using large variables we would see a single thread of
thick edges.

## Global Variables

R's flexibility brings with it some special challenges. We need to
correctly handle
code like the following:

```{R}
f = function() z
z = 10
f1 = f() # 10
z = 20
f2 = f() # 20

# Same thing essentially happens here:
g = function(.z = z) .z
z = 10
g1 = g() # 10
z = 20
g2 = g() # 20
```

This code dynamically looks up the variable z from the global environment.

If we do single static assignment to assign `z1 = 10` and `z2 = 20` then we
need to modify the function as well, ie. have an `f1` which uses `z1`.

We also need to handle environments and reference classes.

## Varible Lifetimes

Since we're generating the code and looking at the whole script we should
only send the variables that are necessary for specific computations. Of
course forked child processes have access to all the variables in the
manager. But for SNOW clusters we have to send these variables, and if
we've kept the child process alive while creating new variables in the
manager then we need to send those new variables over when they're needed
for a computation on the worker.

In the same way that we send the variable when they're needed we can remove
them with `rm()` when they are no longer needed to 

## Systems

I have in mind two basic models for parallel programming: shared memory or
workers communicating over sockets. The shared memory approach is the UNIX
fork, but GPU memory is similar. Communication over sockets is the simple
network of workstations (SNOW) or the MPI cluster. We can also have both,
ie. a SLURM cluster that consists of several physical machines, each of
which can fork.


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
