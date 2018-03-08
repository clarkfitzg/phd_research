Wed Mar  7 16:14:14 PST 2018

When is it legal to exchange operations to make them faster?
For example:

```{R}
x = 1:100   # Need a bigger number of different op for this to make sense.
x[1] + 5    # Faster
(x + 5)[1]  # Slower
```

To get from the slow to the fast you push the selection through the binary
operation. How far will this idea go?


Wed Mar  7 16:06:10 PST 2018

Caching / precomputing results can save enormous amounts of time.

We could apply this to a single R computation- the idea is iterative
development. For example, you write a bunch of code and then you make a
small change. This is basically the same idea as make, drake, and all that
though.

Here's a simple example:

```{R}
diag(solve(X))
```

and then you change the code to:

```{R}
diag(solve(X) + 1)
```

It would be nice if we didn't have to do `solve(X)` again. This code
motivates another idea, see above.

Fri Mar  2 15:14:03 PST 2018

I go along and write R code in an interactive session, experimenting with all
manner of different things. I decide that the last line I entered shows a
meaningful result, so I do something like `CodeAnalysis::keep_last()`. This
goes through the history and pulls out all the relevant commands I need to
successfully execute my last command.


Fri Mar  2 14:51:37 PST 2018

Translate R code into tensorflow.


Thu Mar  1 11:46:53 PST 2018

Hmm, I wonder if it's ever possible to more quickly combine multiple
logical conditions? We could use [short-circuit
evaluation](https://en.wikipedia.org/wiki/Short-circuit_evaluation).
Suppose you're doing `x == 5 & y == 6`. Then you can instead do `c1 =
which(x == 5)` then somehow pull the result from `y[c1] == 6`.


Mon Feb 19 10:26:01 PST 2018

Blog post: Any vectorized R function can be pretty easily made parallel.


Fri Feb 16 15:13:49 PST 2018

If I restrict the scope of code analysis to data frames then there are 3 DSL's:

- data.table
- dplyr
- [rquery](https://winvector.github.io/rquery/) (new package, but designed
  with this sort of optimization in mind)

I call them DSL's because they're all similar to SQL type queries on
tables. What I'm thinking about doing then is a sort of global script
optimization on these languages, which is sort of like PL/SQL.


## Run once then modify

Fri Feb 16 15:13:49 PST 2018

Suppose we observe the actual code as it runs, so that we know everything
we like:

- The dimensions, class, and object size of every object
- How long each statement takes to execute
- All side effects

Then we can create a version that will be faster, or at least not slower,
by using parallelism. I'm thinking of two transformations:

- Replace apply family functions with their parallel equivalents if we
  think it will be faster, based on previous timings on that particular machine.
- Task parallelism by calling some groups of statements within
  `mcparallel()`, returning the objects to the main process when necessary.

This will work for multicore, single machine. It should also work for SNOW.
But how extensible will it be?

Does this use any code analysis? No. It just needs to look at the state of
the global variables before and after. But it does incorporate knowledge of
the data.


Fri Feb 16 10:07:15 PST 2018

The more we know about the data and the operations we may be able to skip
some condition checking. For example, if we know ahead of time that `x` is
not `NULL` then if we call `f(x)` where `f` has the line:
```
if(is.null(x)) ...
```
then we can replace `f` with a version `f'` that removes this line.

More generally if we know that the data isn't going to affect the value of
any conditional statements then we can replace `f` with a
new version that doesn't check those conditions and only includes the
actual code statements that will run.


Thu Jan 11 11:13:52 PST 2018

Is there a way to convert SQL to R code? R is generally more expressive, so
this should be doable. Why do it? SQL engines already have query
optimizers, and it's unlikely that turning it to R will make it work any
better.


Fri Dec  1 10:20:40 PST 2017

Could I take profiling information as input to decide when and how to
parallelize?

Simon Urbanek wrote an R / OpenCL package in 2012. Everything I'm
interested in it seems like Simon has done significant work on.

Do basic computations in R like `+` for vectors use BLAS? No, they need to
handle NA's. It's done explicitly in the C code `arithmetic.c` which loops
through each pair of elements in two integer vectors and calls `R_integer_plus`
which handles `NA_INTEGER`. But where is `NA_INTEGER` defined?
In `include/R_ext/Arith.h` we see the line:
```
include/R_ext/Arith.h:#define NA_INTEGER        R_NaInt
```
along with a comment that says R_NaInt is the minimum integer. in
`arithmetic.c` we see the line setting it to `INT_MIN`, the C language
constant.


GPU programming with OpenCL seems to require a lot of boilerplate. Could we
generate this and / or simplify execution on GPU?
