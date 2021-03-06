Wed Jan 18 08:49:06 PST 2017

The [ParallelAccelerator
Package](http://julialang.org/blog/2016/03/parallelaccelerator) from Intel
compiles Julia into OpenMP C++. They take regular user code, identify
parallel patterns and make them actually run in parallel. Besides map,
reduce, and array comprehensions they use a
pattern I wasn't familiar with: stencil computations which iteratively
update an array according to a fixed pattern. Side note- It's a shame they
didn't plot their blurring example.  Nick and I could aspire to making
something like this.

Wed Nov  2 09:55:22 PDT 2016

Ethan shared some links with me on how Julia exposes C code.

[Passing Julia Callback Functions to C](http://julialang.org/blog/2013/05/callback)
Blog post from Steven Johnson.

The calling looks pretty similar to R's. Also R's `PROTECT` in C routines.

> A function pointer in C is essentially just a pointer to the memory
> location of the machine code implementing that function

C doesn't handle closures well.

Blog post doesn't make this task of calling C libraries look any easier
than it would be with Python or R. 

What about [Julia's Rcall](https://github.com/JuliaInterop/RCall.jl)? Randy
Lai has been working on it. How about going the other way and calling Julia
from R?

Fri Oct  7 16:02:23 PDT 2016

Looking at how [Julia does parallelism](http://docs.julialang.org/en/release-0.5/manual/parallel-computing/).

They use the idea of a `Future`. A master process makes a remote call and
then continues, not waiting for it to finish. I like their use of macros
for these.

Like everything in Julia, it seems that within the parallel programming
area they have many nice features, and they've learned from the mistakes
and weird things in other languages.
