Tue Dec 27 16:12:09 PST 2016



Thu Dec 22 16:23:56 PST 2016

Reading through John Chambers' __Extending R__ book. Looks very helpful for
what I'll be doing with Duncan.

Principles:
- Everything that exists in R is an object
- Everything that happens in R is a function call

Mentions `.Primitive()` as being inherently not extensible because it uses
a fixed internal lookup table for speed. So what is this `.Primitive()`?
Indeed, looked at the R C code, and it is just a table in the C code.
Interesting to me that the C code for internal things like `do_if`
corresponding to R's `if()` is
pretty small, maybe 20 lines.
