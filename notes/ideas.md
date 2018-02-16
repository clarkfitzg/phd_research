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
