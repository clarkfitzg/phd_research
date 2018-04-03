# From https://cran.r-project.org/doc/manuals/r-release/R-ints.html
#
# Note that primitive functions make no use of R code, and hence are very
# different from the usual interpreted functions. In particular, formals
# and body return NULL for such objects.

body(c)

is.primitive(c)

# When recursing into code we're going to hit the wall here.
