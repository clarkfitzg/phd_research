# opencv

Open CV computer vision http://opencv.org/

Short Term Goal: Generate the bindings to the C++ opencv library

Long Term Goal: Generalize the creation of C / C++ bindings using RCIndex
and associated packages.

Side note- STL (standard template library) is used here. Templates in C++
provide a way to write code that operates on different types.

## Existing Work

R bindings: https://github.com/swarm-lab/videoplayR

> Currently videoplayR provides only a small fraction of the image processing
> capabilities of OpenCV. The number of functions will increase little by
> little as my needs for more advanced features develop or as other R
> developers provide their own code to be included in the package (hint: pull
> requests to the project repository are very, very welcome:
> https://github.com/swarm-lab/videoplayR/pulls)

This package seems deprecated, moving to a different package that seems to
download and install opencv.

Nice OO porting to R:
https://github.com/swarm-lab/Rvision/blob/master/src/arithmetic.hpp

## Approach

To create the bindings I'll look at what's been done in `RRawpoppler` and see
if I can port it over. In the course of doing this I will learn what
generalizes. This can also be used to improve `RCodeGen` and `RCIndex`.

For an end user the more automatic the code generation process is, the
easier it will be and the more inclined they will be to do it. Conversely,
the computational model has to also be flexible. For example, a user may
want to generate code for only a few functions rather than everything that
a library exports.

Rather than starting out trying to bind everything in the library, lets try to
write the bindings for one or two particular functions so that I can see if
it's correct. I can do this first by hand and then with the tools. Writing
it by hand will force me to better understand the system.

## Minimal Template

Rather than starting out binding something in a large and complex library
that I have no knowledge of, let me step back and consider what it takes to
bind any C++ code.

Putting a binding to a C++ library inside an R package seems like the
natural way to do things. The alternative is to manually compile and have R
scripts using `.Call()` and others. But R users expect packages, and by
using a package we can benefit from R's install tools. 

To write a minimal C++ binding in an R package I should start with the
minimal template that I was developing with Irene's Ripser package.

The [R Extensions
Manual](https://cran.r-project.org/doc/manuals/R-exts.html#Handling-R-objects-in-C)
seems to suggest using the least complex solution that will get the job
done:

> Before you decide to use .Call or .External, you should look at other
> alternatives. First, consider working in interpreted R code; if this is
> fast enough, this is normally the best option. You should also see if
> using .C is enough. If the task to be performed in C is simple enough
> involving only atomic vectors and requiring no call to R, .C suffices. A
> great deal of useful code was written using just .C before .Call and
> .External were available. These interfaces allow much more control, but
> they also impose much greater responsibilities so need to be used with
> care. Neither .Call nor .External copy their arguments: you should treat
> arguments you receive through these interfaces as read-only.

So for my minimal template / example to be useful I should probably do both
`.C()` and `.Call()` interfaces. This is also important to understand the
different implications for memory and garbage collection.

TODO: How to observe what bad things can happen when `PROTECT()` isn't used
in C code.
