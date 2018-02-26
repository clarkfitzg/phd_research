Thu Oct 27 11:05:07 PDT 2016

Duncan spent a couple hours going over the state of the art of Rcodegen and
related packages. One high level goal here is to programmatically generate
R bindings to an arbitrary C or C++ library. This is useful since many R
packages simply wrap C / C++ libraries. So automatically generating R
bindings takes away much human error associated with this. It's also useful
to regenerate these bindings as the library is updated.

Since 1998 Duncan has been working on related projects: lcc (little c
compiler), SWIG, gcc -tu, clang.

## Options

RCodeGen could generate R and C code, and then compile and link it. This
could happen with R code generated programatically by modifying `body,
formals`, etc, or it could just process strings. Duncan oscillates between
the two, but thinks that string processing is the best first approach.

Another option is using `Rffi` and `rdyncall`, but we didn't talk much
about this.

A limitation of `RCIndex` is that it doesn't do anything with the bodies of
the functions. This would be an area I could focus my research.
Does `clang` make this available? Looking at what `clang` itself can do
with respect to the parsed code:
[clang docs](http://clang.llvm.org/doxygen/classclang_1_1VarDecl.html)
there is a _ton_ of stuff here. Seems like this level of detail wasn't
available with previous compilers / C code analysis tools.
Note we want to avoid hacking much on clang itself- too much work!

## Background

Interpreted languages like R use unboxing. The idea is that in C there is a
struct called `SEXP` holding important variable information like type,
length, etc, and a memory address for the data. To get to the actual data
one needs to follow that memory address. In C this looks like
```
double *x = REAL(r_x);
```
where `REAL` is a function provided by R returning a C array containing
floating point numbers.
Then before returning to R it must
be "boxed" with all the required metadata for a `SEXP` object. Thus
boxing / unboxing is like a level of indirection.

## Details

The generated code would have to be robust enough to handle many corner
cases such as:

- empty vectors
- NA
- Memory management

We'd need to recursively work through all header files to make sure we
capture everything.

Memory management looks like one of the trickiest parts. If functions or
programs are calling `malloc` then who manages this object?

We may want to allow the user to control when and how C level objects are
copied into R objects. Looks like the conservative thing is to default to
doing a copy. Suggestion for an R implementation of the function:

The code for the generic is
```
setGeneric("it2", function(x, ...) standardGeneric("it2"))
```
Then we define methods
```
setMethod("it2", "integer",
                      function(x, ...)
                          .Call("R_it2_integer", x, PACKAGE = 'whatever') )
```
and similarly for the CIArray.

Here class `CIArray` represents something like `list(<external ptr int*>,
len)`. So it looks to me like a simplified version of an R `SEXP`.

## Next steps

1. Check related projects
2. Write a C wrapper by hand
3. Read R extensions manual as definitive reference
2. See what capabilities `Rcpp` has. Will it make things easier?

Thought for an application- see who in the dept writes C libraries and
offer to automatically generate the R bindings. Cho-Jui Hsieh, Jie Peng, or
Hao Chen? They might appreciate this. Cho-Jui in particular lists [6
libraries](http://www.stat.ucdavis.edu/~chohsieh/rf/), all of which I
checked were in C/C++. Then this might lead to some nice relevant test
cases, as high performance numerical packages with small code bases are
very important to R users.

Another thought- how well would this translate across languages? Could it
hook into Julia as well?

Considering hooking into `clang` directly to interact with their data
structures. Why reimplement what the software already does well?
Looking through the [Clang
docs](http://clang.llvm.org/features.html#diverseclients) this option
appeals to me.  Looks like [Python
bindings](https://github.com/llvm-mirror/clang/tree/master/bindings/python)
are actively maintained. This may be a very nice path for the task. See 2011
[blog
post](http://eli.thegreenplace.net/2011/07/03/parsing-c-in-python-with-clang).
Python has various ways of automatically generating bindings like SWIG and
[SIP](https://wiki.python.org/moin/SIP). So I'd be making something similar
for R.
