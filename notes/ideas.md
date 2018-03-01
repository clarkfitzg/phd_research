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
