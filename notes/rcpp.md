Thu Oct 27 15:01:31 PDT 2016

Reviewing what the current state of the art is in auto generating bindings
to C / C++ libraries.

# Rcpp

My overall impression of Rcpp is that it provides similar things. It seems
to require more tinkering with the source itself if you want to have
interoperability between the objects. It's much better if we don't have to
touch the C library we're generating wrappers for.

http://dirk.eddelbuettel.com/code/rcpp.html

> As of version 0.8.1, an extended function 'cxxfunction' is used (which
> requiers inline 0.3.5). This function makes it easier to use C++ code with
> Rcpp. In particular, it enforces use of the .Call interface, adds the Rcpp
> amespace, and sets up exception forwarding. It employs the macros
> BEGIN_RCPP and END_RCPP macros to enclose the user code
> 
> Moreover, with cfunction (and cxxfunction), we can even call external
> libraries and have them linked as well.

Most relevant to our current interests is the vignette titled [Exposing C++
functions and classes with Rcpp
modules](http://dirk.eddelbuettel.com/code/rcpp/Rcpp-modules.pdf).  It
cites the `boost.python` project as inspiration.

> As it is generally a bad idea to expose external pointers ‘as is’, they
> usually get wrapped as a slot of an S4 class.

Using external pointers- something Duncan has mentioned.

> Rcpp automatically deduces the conversions
> that are needed for input and output. This alleviates the need for a
> wrapper function using either Rcpp or the R API.

This is something that we'll need to do as well. Maybe there's commonality
here?

Not clear to me yet how much this is meant to wrap. Will it handle a huge
codebase? Is it meant to?

Hadley's Advanced R claims that Rcpp handles the memory management.

TODO - see exactly what Rcpp does to implement `module()`. It may be all we
need. https://github.com/RcppCore/Rcpp/blob/master/R/Module.R#L162

Uses things like 
```
classes <- .Call( Module__classes_info, xp )
```
where `xp` is a pointer to a C++ module. Corresponding C++ code looks like:
```
RCPP_FUN_1(Rcpp::List, Module__classes_info, XP_Module module) {
    return module->classes_info();
}
```
