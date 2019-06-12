# Wed Jun 12 11:40:35 PDT 2019
#
# My goal is to annotate rstatic objects with semantic meaning.
# Given a set of initial large objects, and a set of vectorized functions, I want to say which values of subexpressions are also large objects.
# An object is large when it is the result of a vectorized function where the vectorized arguments are large.

library(rstatic)


