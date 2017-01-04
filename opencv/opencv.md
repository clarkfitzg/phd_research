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

BUG: 
```
Error in .C("cdot", a, n, out) :
  "cdot" not resolved from current namespace (Callexample)
```

This means that the cdot function can't be
found. This can happen:

- The function `cdot` isn't actually there.
- The library didn't export it.
- For C++, `extern C` is not used.

Note that `extern C` is not specific to R at all. It just turns off name
mangling to make it compatible with C.

From http://www.agner.org/optimize/calling_conventions.pdf

> The extern "C" attribute is only allowed for functions that can be coded
> in C. Hence, overloaded functions and member functions cannot have the
> extern "C" attribute.

If this is the case, then how can we bring methods with various classes
into R? Do we need to do our own name mangling?

Fought for a long time not realizing that `.C()` returns a list of modified args
rather than actually updating the R objects in place. I must be confusing
it with `.Call()`. Pain could have been avoided by a closer reading of the
docs- I was just going off of the R Extensions manual and missed the little
`$ab`.

Interesting that the R Extensions Manual points out that C interfaces are
to be preferred over C++ for better portability (5.6.1 External C++ code).

I'm looking at the C code written to use `.Call()`, and thinking that it's
unappealing to me because it mixes two languages. I wonder if it could be
rewritten such that all the error checking and R specific building,
memory management, etc, happens seperately from the actual numerical code.

All the [basic
templates](https://github.com/clarkfitzg/templates/tree/master/R) are
written to compute the l2 norm of a vector.  Benchmarks show `.C()` to be
the slowest, presumably because of unnecessary copying in that case. For a
vector of 1 million numbers the C version is a bit under 1 ms, while
vanilla R is 3 ms.

Another learning moment: when defining S4 methods like for `+` the method
signatures must match. Ie. the args must be named `e1, e2`.

## OO links between R / C++

But I still need to do an OO version of the template. This is more subtle.
Should the data stay in C++ and only move to R when required?
Is S4 or RC better? How to call a method from within R?

Now that I've thought more about this it makes more sense when I look 
at what Duncan did with `Rrawpoppler`. Especially important is the file
`src/Rpoppler.h` that contains the definition of `GET_REF`.

```
#define GET_REF(obj, type) \
  (type *) R_ExternalPtrAddr(GET_SLOT(obj, Rf_install("ref")))
```

I guess we need to know the type when get the reference because we're
dealing with just a memory address, so nothing else is known?

TODO: The R extensions manual has a [whole
section](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#External-pointers-and-weak-references)
on this. Read and understand :)

Let's look at what happens in some of this generated code.

```
extern "C"                                  // R uses this to link
SEXP R_Page_getNum(SEXP r_tthis)            // SEXP input and output
{
    Page *tthis = GET_REF(r_tthis, Page);   // Recover the original C++ Page object
    int ans;
    ans = tthis->getNum();                  // Call getNum() method for tthis
    SEXP r_ans = Rf_ScalarInteger(ans);     // Convert to R object and return
    return(r_ans);
}

// Only difference below is that the code creates a new C++ object.

extern "C"
SEXP R_Page_getMediaBox(SEXP r_tthis)
{
    Page *tthis = GET_REF(r_tthis, Page);
    PDFRectangle * ans;
    ans = tthis->getMediaBox();
    SEXP r_ans = R_createRef(ans, "PDFRectanglePtr", NULL);
    return(r_ans);
}
```

Name mangling format seems to be `R_Class_method`. But will this work if
there are multiple methods corresponding to various arguments?

## Necessary files / code

I'm starting to tease out what files are necessary 
and similar for any OO system connecting to R. It will be a good
exercise to get this working in the very simple case, this can also be a
test for RCodegen.

Once I figure this out what is necessary we could make a function in
RcodeGen that builds these R packages with everything they need.

- `src/Rpoppler.h` contains the definition of `GET_REF`
- `src/createRef.cc` is the actual implementation of the reference system.

```
clark@DSI-CF ~/dev/R-3.3.1
$ grep -r "Rf_install(" *
src/include/Rinternals.h:SEXP Rf_install(const char *);
```

I want to know what `Rf_install` does. How can I find this out? My goal
above was to look at the actual definition, but grepping only finds this
one file.
