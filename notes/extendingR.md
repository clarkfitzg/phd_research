


Wed Dec 28 16:51:44 PST 2016

> Compiled subroutines dynamically linked to the R process

What does that mean?

Function OOP:

> The call to the generic is evaluated as a call to the selected method

Ie. `print()`

Encapsulated OOP - methods are part of class definition. The more
conventional way of doing it.

Thu Dec 22 16:23:56 PST 2016

Reading through John Chambers' __Extending R__ book. Looks very helpful for
what I'll be doing with Duncan.

Principles:
- Everything that exists in R is an object
- Everything that happens in R is a function call

Mentions `.Primitive()` as being inherently not extensible because it uses
a fixed internal lookup table for speed. So what is this `.Primitive()`?
Indeed, looked at the R C code, and it is just a table in the C code in
`src/main/names.c`.
Interesting to me that the C code for internal things like `do_if`
corresponding to R's `if()` is
pretty small, maybe 20 lines.

`.Primitive()` actually seems bad for OOP. How do we write `+` or `length`
methods for objects? Could look in the `Matrix` package and see how it's
done. Pretty cool, they use S4 classes and lots of virtual classes. Looks
like it's just the regular S4 `setMethod()`. Then how does it actually
work?

TODO: Visualize the Matrix OO hierarchy, ie. with GraphViz
