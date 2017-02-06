# Mon Feb  6 09:37:44 PST 2017
# How to simultaneously evaluate two blocks of code in R?
# Assuming they're independent

library(future)

# start point
n = 10

# 1st block
x1 = rnorm(n)
x2 = x1 + 5
x3 = x2 + 10

# 2nd block
y1 = rnorm(n)
y2 = y1 + 5
y3 = y2 + 10

# Barrier- code must finish before here.
z = x3 + y3
