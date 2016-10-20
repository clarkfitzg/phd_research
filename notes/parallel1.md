Thu Oct 20 15:58:10 PDT 2016

If the goal is to improve R I better understand the current state pretty
well.

Reading through Hadley Wickham's Advanced R [section on
Performance](http://adv-r.had.co.nz/Performance.html).

R is not formally defined as a language like C++, it's more defined in
terms of the implementation of GNU-R.

Refers to [the paper](http://r.cs.purdue.edu/pub/ecoop12.pdf) evaluating the R language.
I could read this to see if they have any suggestions.

### Alternative implementations

Alternative implementations are definitely worth taking a serious look at.

There's [rho](https://github.com/rho-devel/rho) currently being worked on
by Karl Millar. Formerly CXXR. General goal seems to be refactoring and
modernizing R by rewriting the interpreter in C++. This could be contrasted
with Duncan's goal of bypassing the interpreter completely.

Rho is the only one that appears to be currently actively developed.

PQR- pretty quick R by Radford Neal does some automatic numeric
computations with helper threads. See this [blog
post](https://radfordneal.wordpress.com/2013/06/23/parallel-computation-with-helper-threads-in-pqr/).
It doesn't try to split up single operations into parallel. Mentions gains
from "pipelining" which sound similar to how Spark optimizes computation.
