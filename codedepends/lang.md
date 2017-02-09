## Concepts

Thu Feb  9 08:51:21 PST 2017

Referring to the [R Language
Definition](https://cran.r-project.org/doc/manuals/r-release/R-lang.html).

> The following table describes the possible values returned by typeof and
> what they are.

I'll go through the less trivial ones and try to give an example of each.

- "any"	a special type that matches all types: there are no objects of this type
- "NULL"	NULL
- "symbol"	a variable name     `quote(x)`
- "closure"	a function      `function(x) x + 1`
- "environment"	an environment      `.GlobalEnv`
- "language"	an R language construct     `quote(y <- x)`
- "builtin"	an internal function that evaluates its arguments   `:`
- "expression"	an expression object    `expression(y <- x)`
- "raw"	a vector containing bytes   `as.raw(1:10)`
- "S4"	an S4 object which is not a simple object `Matrix::sparseMatrix(i = 5, j = 10, x = 1.7)`
- "special"	an internal function that does not evaluate its arguments `typeof(quote)`

These I can't think of easy examples for:

- "externalptr"	an external pointer object - Like reference to C++ object
- "weakref"	a weak reference object
- "pairlist"	a pairlist object (mainly internal)
- "promise"	an object used to implement lazy evaluation

## General notes

Lists are just generic vectors.

TODO: Ask Duncan here:

The relationship between `language` and `expression` objects is not clear
to me. The manual says that language objects are either _calls, expressions, or names_.
Then it would seem that language objects are more general.
`CodeDepends` seems to work with language objects.

> In R one can have objects of type "expression". An expression contains one
> or more statements. A statement is a syntactically correct collection of
> tokens. Expression objects are special language objects which contain
> parsed but unevaluated R statements. The main difference is that an
> expression object can contain several such expressions. 

