Thu Nov  3 10:08:02 PDT 2016

## Qualifying Exam

Potentially have QE in spring 2017. Doing the QE on a topic doesn't mean I
need to spend the remainder of PhD working on it.

Possible committee members are Norm, Cho, Ethan, James, Thomas.

## Code generation

A basic goal of this project would be to use code analysis of C/C++ code to
programmatically generate R bindings for an arbitrary C / C++ library.
We should start on this first.

Need to make an effort to collaborate and extend existing work here- Rcpp,
RCindex, Rcodegen, Nimble, etc. This is important for the community.

## Parallelism

The other project is analyzing R code for compilation and parallelism.
This relates more to Nick's project. Basic idea- one writes an algorithm as
simply as possible in R. What strategies do we use to move data and run it
on a GPU?

One task might be to take some of Cho's work in C++ and implement it in R
to set goals and benchmarks.

## Other

Look into [Nimble](https://r-nimble.org/), which generates C++ code. From
their docs:

> Both BUGS models and NIMBLE algorithms are automatically processed into
> C++ code, compiled, and loaded back into R with seamless interfaces.

OO Codebase seems complex, hard to tell exactly what's happening. Lots of
`eval(), substitute()`. This is one of those projects where it would really
be useful to have a tool to parse through the R code and display it
visually, ie. a flow diagram of function calls and dependencies. Can
CodeDepends do this?
