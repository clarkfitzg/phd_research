# Mon Feb  6 09:37:44 PST 2017
# How to simultaneously evaluate two blocks of code in R?
# Assuming they're independent

library(future)

# start point
n = 10

cat("1st block started.\n")
x = rnorm(n)
Sys.sleep(3)
x = x + 5
cat("1st block done.\n")

cat("2nd block started.\n")
y = rnorm(n)
Sys.sleep(3)
y = y + 5
cat("2nd block done.\n")

z = x + y
