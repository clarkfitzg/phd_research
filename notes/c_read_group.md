Mon Jan  9 09:40:53 PST 2017

What's the best practice to write C to be portable when binding to one
language?

It must be generally better to write the core functionality using
only std libraries in C and then write a separate binding / wrapper using
language specific tools ie. `REAL(x)` in R to extract underlying array of
doubles from `SEXP`.
