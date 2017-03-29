# Wed Mar 29 14:45:18 PDT 2017

# TODO: Use microbenchmark

library(microbenchmark)

n = as.integer(exp(1:10))
n = rep(n, each = 3)

lapply(n, function(n_i){
    # Triggers garbage collection
    time = system.time({x <- rnorm(n_i); xbar <- mean(x)}, gcFirst = TRUE)
    output = data.frame(n = n_i, time = time["elapsed"])
    write.table(output, "smalltimings.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
})


timings = read.table("smalltimings.csv"
                     , col.names = c("n", "seconds"))


with(timings, plot(n, seconds
                   , main = "Time to compute mean(rnorm(n))"
                   ))


