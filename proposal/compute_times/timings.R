# Tue Apr 18 08:41:20 PDT 2017

# Considering relative costs of different operations in R. We want to know
# when overhead costs are amortized, or whether they can be.
#
# - function evaluation
# - serialization
# - starting R interpreter
# - forking
#
# It would be interesting to do this across different machines and
# different data types.

library(microbenchmark)



n = 100 * 0:10

x = lapply(n, function(n_i) seq.int(n_i))

benchmark = function(x){
    # Wrapping it in a function because I actually want to know how long it
    # takes to call an R function
    twox = function(x) 2 * x
    bm = microbenchmark(twox(x), times = 1000L)
    quantile(bm$time)
}

times = t(sapply(x, benchmark))

# Sometimes this is linear, sometimes it has irregular spikes. 
# Could be garbage collection, but I'm not sure.
plot(n, times[, 2])

plot(n, times[, 3])

times2 = data.frame(n = n, time = times[, 2])

fit = lm(time ~ n, times2)

summary(fit)

overhead = coef(fit)[1]
slope = coef(fit)[2]

# For which value of n is the overhead only 10 percent?
p = 0.1
np = (overhead - p * overhead) / (p * slope)
# For these observations it's np = 1650


