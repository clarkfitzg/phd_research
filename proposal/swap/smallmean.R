# Wed Mar 29 14:45:18 PDT 2017

library(microbenchmark)

n = 1:200

times = lapply(n, function(n_i){
    # garbage collection affects benchmarks
    gc()
    times = microbenchmark(mean(rnorm(n_i)))
    data.frame(n = n_i, time = times$time)
})

times = do.call(rbind, times)

# Units are microseconds
times$time = times$time / 1000

smalltime = by(times$time, times$n, quantile)
smalltime = as.data.frame(do.call(rbind, smalltime))
smalltime = cbind(as.integer(row.names(smalltime)), smalltime)
colnames(smalltime) = c("n", "min", "q25", "median", "q75", "max")

with(smalltime, plot(n, median
                   , main = "median time to compute mean(rnorm(n))"
                   , ylab = expression(paste("time (", mu, "s)"))
                   ))

lines(smalltime$n, smalltime$q25, lty = 2)

fit = lm(time ~ n, data = times)

# Throw out the obvious outliers
fit2 = lm(time ~ n, data = times[times$time < 20, ])

summary(fit2)

confint(fit2)
#                  2.5 %     97.5 %
# (Intercept) 4.20876198 4.25000930
# n           0.06412455 0.06448087
#
# For this simple task there's a fixed overhead of ~4.2 microseconds and an
# additional 64 nanoseconds for each additional n.
