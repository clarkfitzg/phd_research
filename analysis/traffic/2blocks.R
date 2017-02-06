# Mon Feb  6 09:37:44 PST 2017
# How to simultaneously evaluate two blocks of code in R?
# Assuming they're independent

library(future)

# start point
n = 10

# 1st block
x = rnorm(n)
x = x + 5
x = x + 10

# 2nd block
y = rnorm(n)
y = y + 5
y = y + 10

# Barrier- code must finish before here.
z = x + y
